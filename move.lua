MAZE_UNIT_LENGHT = 50 -- cm length of a maze unit
MAX_CONSTANT_VELOCITY = 100 -- cm/s to be used on movements that do not require acceleration or deceleration
MIN_LINEAR_VELOCITY = 100 -- cm/s minimum linear velocity to be used on movements that require acceleration or deceleration
MAX_LINEAR_VELOCITY = 1000 -- cm/s maximum linear velocity to be used on movements that require acceleration or deceleration
MAX_ACCELERATION = 4 -- cm/s^2
MAX_DECELERATION = 4 -- cm/s^2
TURN_LINEAR_LENGTH = math.pi * robot.wheels.axis_length / 4 -- linear distance that the wheels needs to travel to turn 90 degrees
TURN_RADIUS =  robot.wheels.axis_length / 2 -- radius of the circle that the wheels travels when turning

is_moving = false -- used to check if a movement is in progress

distance_traveled = 0
distance_to_travel = 0
current_velocity = 0
current_move = nil

move_array = {} -- array of movements to be done

-- Checks if the bot stopped based on distance sensors if available
function is_stopped()
    return not is_distance_changed()
end


-- Starts a new straight movement or continues movement if already going straight
function straight()
    distance_to_travel = current_move.delta ~= nil and current_move.delta or MAZE_UNIT_LENGHT
    if not is_moving then
        distance_traveled = 0
        is_moving = true
    else
        distance_traveled = distance_traveled + math.abs(robot.wheels.distance_left)
        if distance_traveled >= distance_to_travel then
            is_moving = false
        end
    end
    current_velocity = math.abs(current_velocity)
    if distance_traveled == 0 then
        current_velocity = MIN_LINEAR_VELOCITY
    else
        if distance_traveled < distance_to_travel / 2 then
            current_velocity = current_velocity + MAX_ACCELERATION
            if current_velocity > MAX_LINEAR_VELOCITY then
                current_velocity = MAX_LINEAR_VELOCITY
            end
        elseif distance_traveled >= distance_to_travel / 2 then
            current_velocity = current_velocity - MAX_DECELERATION
            if current_velocity < MIN_LINEAR_VELOCITY then
                current_velocity = MIN_LINEAR_VELOCITY
            end
        end
        if distance_traveled >= distance_to_travel then
            current_velocity = 0
        end
    end
    if current_move.direction == MOVE_DIRECTION.BACKWARDS then current_velocity = -current_velocity end
    robot.wheels.set_velocity(current_velocity, current_velocity)
end

-- Starts a new turn movement or continues movement if already turning
function turn()
    distance_to_travel = current_move.delta ~= nil and (current_move.delta * TURN_RADIUS) or TURN_LINEAR_LENGTH
    if not is_moving then
        distance_traveled = 0
        current_velocity = MAX_CONSTANT_VELOCITY
        is_moving = true
    else
        distance_traveled = distance_traveled + math.abs(robot.wheels.distance_left)
        if distance_traveled >= distance_to_travel then
            is_moving = false
            current_velocity = 0
        end
    end
    if current_move.direction == MOVE_DIRECTION.LEFT then
        robot.wheels.set_velocity(-current_velocity, current_velocity)
    else
        robot.wheels.set_velocity(current_velocity, -current_velocity)
    end
end

function l_turn()
    -- TODO
end

--[[
    If a movement and a direction are provided adds a movement with that direction to the movements to be done.
    If a movement, direction and a delta are provided adds a movement in a direction which has a specified distance or angle to the movements to be done.
    If a movement, direction and a delta are provided and has_priority is true adds a movement to the beginning of the movements to be done.
    The move and direction parameters are required on any new move to execute.
    The delta and has_priority parameters are optional and can only be used on basic movements.
    If called without parameters continues to execute programmed movements.
    Returns a boolean value indicating if the bot is in the middle of a movement.
]]
function move(movement, direction, delta, has_priority)
    if movement then
        if table_contains(BASIC_MOVE, movement) then
            if has_priority == true then
                table.insert(move_array, 1, {movement = movement, direction = direction, delta = delta})
            else
                table.insert(move_array, {movement = movement, direction = direction, delta = delta})
            end
        elseif movement == COMPLEX_MOVE.N_STRAIGHT then
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = direction, delta = delta * MAZE_UNIT_LENGHT})
        elseif movement == COMPLEX_MOVE.FLIP then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi})
        elseif movement == COMPLEX_MOVE.FLIP_AND_FORWARD then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi})
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGHT})
        elseif movement == COMPLEX_MOVE.TURN_AND_FORWARD then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = direction, delta = math.pi / 2})
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGHT})
        end
    else
        if is_moving then
            if is_slow_calibration_needed() then -- pause the current movement
                is_moving = false
                robot.wheels.set_velocity(0, 0)
                table.insert(move_array, 1, {movement = current_move.movement, direction = current_move.direction, delta = distance_to_travel - distance_traveled})
            else
                current_move.movement()
            end
        else
            if is_stopped() then
                if is_slow_calibration_needed() then
                    -- slow_calibrate()
                elseif is_fast_calibration_needed() then
                    fast_calibrate()
                end
                if #move_array > 0 then
                    current_move = table.remove(move_array, 1)
                    current_move.movement()
                end
            end
        end
    end
    return is_moving
end

MOVE_DIRECTION = { FORWARD = 1, BACKWARDS = 2, LEFT = 3, RIGHT = 4 }

--[[
    BASIC_MOVE represents the basic movements that the bot is programmed to do
        STRAIGHT is a move that goes straight one MAZE_UNIT_LENGHT or a given delta if provided
        TURN is a move that turns 90 degrees or a given delta if provided
        L_TURN *NOT IMPLEMENTED* is a move that executes a L turn smoothly
]]
BASIC_MOVE = { STRAIGHT = straight, TURN = turn, L_TURN = l_turn }

--[[
    COMPLEX_MOVE is a move that is composed from one or more BASIC_MOVE
        N_STRAIGHT is a move that goes forward or backwards n times the MAZE_UNIT_LENGHT
        FLIP is a move that turns 180 degrees
        FLIP_AND_FORWARD is a move that turns 180 degrees and then goes forward one MAZE_UNIT_LENGHT
        TURN_AND_FORWARD is a move that turns 90 degreed and then goes forward one MAZE_UNIT_LENGHT
]]
COMPLEX_MOVE = { N_STRAIGHT = 1, FLIP = 2, FLIP_AND_FORWARD = 3, TURN_AND_FORWARD = 4 }

-- Checks if a table contains a given value
function table_contains(table, value)
    found = false
    for k, v in pairs(table) do
        if v == value then
            found = true
        end
    end
    return found
end

--[[ Usage
    if move() then
        -- do something while the robot is moving
    else
        -- decide next move and use move function eg.
        move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	    move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	    move(COMPLEX_MOVE.N_STRAIGHT, MOVE_DIRECTION.FORWARD, 5)
    end
]]