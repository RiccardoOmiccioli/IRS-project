MAZE_UNIT_LENGHT = 50 -- cm
MAX_CONSTANT_VELOCITY = 100 -- cm/s
MIN_LINEAR_VELOCITY = 100 -- cm/s
MAX_LINEAR_VELOCITY = 1000 -- cm/s
MAX_ACCELERATION = 2 -- cm/s^2
MAX_DECELERATION = 2 -- cm/s^2
TURN_LINEAR_LENGTH = math.pi * robot.wheels.axis_length / 4 -- linear distance that the wheels needs to travel to turn 90 degrees

is_moving = false
distance_traveled = 0
current_velocity = 0
current_move = nil
move_array = {}

-- Starts a new forward movement or continues movement if already going forward
function forward()
    if not is_moving then
        distance_traveled = 0
        current_velocity = MIN_LINEAR_VELOCITY
        robot.wheels.set_velocity(current_velocity, current_velocity)
        is_moving = true
    else
        distance_traveled = distance_traveled + robot.wheels.distance_left
        distance_to_travel = current_move.repetitions ~= nil and current_move.repetitions * MAZE_UNIT_LENGHT or MAZE_UNIT_LENGHT
        if distance_traveled < distance_to_travel / 2 then
            current_velocity = current_velocity + MAX_ACCELERATION
            if current_velocity > MAX_LINEAR_VELOCITY then
                current_velocity = MAX_LINEAR_VELOCITY
            end
            robot.wheels.set_velocity(current_velocity, current_velocity)
        elseif distance_traveled >= distance_to_travel / 2 then
            current_velocity = current_velocity - MAX_DECELERATION
            if current_velocity < MIN_LINEAR_VELOCITY then
                current_velocity = MIN_LINEAR_VELOCITY
            end
            robot.wheels.set_velocity(current_velocity, current_velocity)
        end
        if distance_traveled >= distance_to_travel then
            robot.wheels.set_velocity(0, 0)
            is_moving = false
        end
    end
end

-- Starts a new backwards movement or continues movement if already going backwards
function backwards()
    if not is_moving then
        distance_traveled = 0
        robot.wheels.set_velocity(-MAX_CONSTANT_VELOCITY, -MAX_CONSTANT_VELOCITY)
        is_moving = true
    else
        distance_traveled = distance_traveled + math.abs(robot.wheels.distance_left)
        if distance_traveled >= MAZE_UNIT_LENGHT then
            robot.wheels.set_velocity(0, 0)
            is_moving = false
        end
    end
end

-- Starts a new turn left movement or continues movement if already turning left
function turn_left()
    if not is_moving then
        distance_traveled = 0
        robot.wheels.set_velocity(-MAX_CONSTANT_VELOCITY, MAX_CONSTANT_VELOCITY)
        is_moving = true
    else
        distance_traveled = distance_traveled + robot.wheels.distance_right
        if distance_traveled >= TURN_LINEAR_LENGTH then
            robot.wheels.set_velocity(0, 0)
            is_moving = false
        end
    end
end

-- Starts a new turn right movement or continues movement if already turning right
function turn_right()
    if not is_moving then
        distance_traveled = 0
        robot.wheels.set_velocity(MAX_CONSTANT_VELOCITY, -MAX_CONSTANT_VELOCITY)
        is_moving = true
    else
        distance_traveled = distance_traveled + robot.wheels.distance_left
        if distance_traveled >= TURN_LINEAR_LENGTH then
            robot.wheels.set_velocity(0, 0)
            is_moving = false
        end
    end
end

--[[
    If a movement is provided, adds a movement to the movements to be done.
    If called without parameters continues to execute programmed movements.
    Returns a boolean value indicating if the bot is in the middle of a movement.
]]
function move(movement, repetitions)
    if movement then
        if table_contains(BASIC_MOVE, movement) then
            if repetitions ~= nil then
                table.insert(move_array, {movement = movement, repetitions = repetitions})
            else
                table.insert(move_array, {movement = movement})
            end
        elseif movement == COMPLEX_MOVE.FLIP then
            table.insert(move_array, {movement = BASIC_MOVE.TURN_RIGHT})
            table.insert(move_array, {movement = BASIC_MOVE.TURN_RIGHT})
        elseif movement == COMPLEX_MOVE.FLIP_AND_FORWARD then
            table.insert(move_array, {movement = BASIC_MOVE.TURN_RIGHT})
            table.insert(move_array, {movement = BASIC_MOVE.TURN_RIGHT})
            table.insert(move_array, {movement = BASIC_MOVE.FORWARD})
        elseif movement == COMPLEX_MOVE.GO_LEFT then
            table.insert(move_array, {movement = BASIC_MOVE.TURN_LEFT})
            table.insert(move_array, {movement = BASIC_MOVE.FORWARD})
        elseif movement == COMPLEX_MOVE.GO_RIGHT then
            table.insert(move_array, {movement = BASIC_MOVE.TURN_RIGHT})
            table.insert(move_array, {movement = BASIC_MOVE.FORWARD})
        end
    else
        if is_moving then
            current_move.movement()
        else
            if #move_array > 0 then
                current_move = table.remove(move_array, 1)
                current_move.movement()
            end
        end
    end
    return is_moving
end

-- BASIC_MOVE represents the basic movements that the bot is programmed to do
BASIC_MOVE = { FORWARD = forward, BACKWARDS = backwards, TURN_LEFT = turn_left, TURN_RIGHT = turn_right, L_TURN_LEFT = l_turn_left, L_TURN_RIGHT = l_turn_right }

-- COMPLEX_MOVE is a move that is composed from at least two BASIC_MOVE
COMPLEX_MOVE = { FLIP = 1, FLIP_AND_FORWARD = 2, GO_LEFT = 3, GO_RIGHT = 4}

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
        move(BASIC_MOVE.FORWARD)
        move(BASIC_MOVE.FORWARD, 3)
        move(COMPLEX_MOVE.GO_LEFT)
    end
]]