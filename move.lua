local move = {}

MAZE_UNIT_LENGTH = 50 -- cm length of a maze unit
TURN_LINEAR_LENGTH = math.pi * robot.wheels.axis_length / 4 -- linear distance that the wheels needs to travel to turn 90 degrees
TURN_RADIUS =  robot.wheels.axis_length / 2 -- radius of the circle that the wheels travels when turning

MAX_FAST_CONSTANT_VELOCITY = 100 -- cm/s to be used on fast movements that do not require acceleration or deceleration
MIN_FAST_LINEAR_VELOCITY = 100 -- cm/s minimum linear velocity to be used on fast movements that require acceleration or deceleration
MAX_FAST_LINEAR_VELOCITY = 1000 -- cm/s maximum linear velocity to be used on fast movements that require acceleration or deceleration
MAX_FAST_ACCELERATION = 4 -- cm/s^2 to be used on fast movements that require acceleration
MAX_FAST_DECELERATION = 4 -- cm/s^2 to be used on fast movements that require deceleration

MAX_SLOW_CONSTANT_VELOCITY = 50 -- cm/s to be used on slow movements that do not require acceleration or deceleration
MIN_SLOW_LINEAR_VELOCITY = 50 -- cm/s minimum linear velocity to be used on slow movements that require acceleration or deceleration
MAX_SLOW_LINEAR_VELOCITY = 100 -- cm/s maximum linear velocity to be used on slow movements that require acceleration or deceleration
MAX_SLOW_ACCELERATION = 4 -- cm/s^2 to be used on slow movements that require acceleration
MAX_SLOW_DECELERATION = 1 -- cm/s^2 to be used on slow movements that require deceleration

max_constant_velocity = MAX_SLOW_CONSTANT_VELOCITY -- cm/s to be used on movements that do not require acceleration or deceleration
min_linear_velocity = MIN_SLOW_LINEAR_VELOCITY -- cm/s minimum linear velocity to be used on movements that require acceleration or deceleration
max_linear_velocity = MAX_SLOW_LINEAR_VELOCITY -- cm/s maximum linear velocity to be used on movements that require acceleration or deceleration
max_acceleration = MAX_SLOW_ACCELERATION -- cm/s^2
max_deceleration = MAX_SLOW_DECELERATION -- cm/s^2

is_moving = false -- used to check if a movement is in progress

distance_traveled = 0
distance_to_travel = 0
current_velocity = 0
current_move = nil

move_array = {} -- array of movements to be done

-- set bot parameters for fast movements
function move.set_fast_velocity()
    max_constant_velocity = MAX_FAST_CONSTANT_VELOCITY
    min_linear_velocity = MIN_FAST_LINEAR_VELOCITY
    max_linear_velocity = MAX_FAST_LINEAR_VELOCITY
    max_acceleration = MAX_FAST_ACCELERATION
    max_deceleration = MAX_FAST_DECELERATION
end

-- set bot parameters for slow movements
function move.set_slow_velocity()
    max_constant_velocity = MAX_SLOW_CONSTANT_VELOCITY
    min_linear_velocity = MIN_SLOW_LINEAR_VELOCITY
    max_linear_velocity = MAX_SLOW_LINEAR_VELOCITY
    max_acceleration = MAX_SLOW_ACCELERATION
    max_deceleration = MAX_SLOW_DECELERATION
end

-- Checks if the bot stopped based on distance sensors if available
function move.is_stopped()
    return not distance.is_distance_changed()
end

-- Starts a new straight movement or continues movement if already going straight
function move.straight()
    distance_to_travel = current_move.delta ~= nil and current_move.delta or MAZE_UNIT_LENGTH
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
        current_velocity = min_linear_velocity
    else
        if distance_traveled < distance_to_travel / 2 then
            current_velocity = current_velocity + max_acceleration
            if current_velocity > max_linear_velocity then
                current_velocity = max_linear_velocity
            end
        elseif distance_traveled >= distance_to_travel / 2 then
            current_velocity = current_velocity - max_deceleration
            if current_velocity < min_linear_velocity then
                current_velocity = min_linear_velocity
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
function move.turn()
    distance_to_travel = current_move.delta ~= nil and (current_move.delta * TURN_RADIUS) or TURN_LINEAR_LENGTH
    if not is_moving then
        distance_traveled = 0
        current_velocity = max_constant_velocity
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

--[[
    If a movement and a direction are provided adds a movement with that direction to the movements to be done.
    If a movement, direction and a delta are provided adds a movement in a direction which has a specified distance or angle to the movements to be done.
    If a movement, direction and a delta are provided and has_priority is true adds a movement to the beginning of the movements to be done.
    The move and direction parameters are required on any new move to execute.
    The delta and has_priority parameters are optional and can only be used on basic movements.
    If called without parameters continues to execute programmed movements.
    Returns a boolean value indicating if the bot is in the middle of a movement.
]]
function move.move(movement, direction, delta, has_priority)
    if movement then
        if table_contains(BASIC_MOVE, movement) then
            if has_priority == true then
                table.insert(move_array, 1, {movement = movement, direction = direction, delta = delta})
            else
                table.insert(move_array, {movement = movement, direction = direction, delta = delta})
            end
        elseif movement == COMPLEX_MOVE.N_STRAIGHT then
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = direction, delta = delta * MAZE_UNIT_LENGTH})
        elseif movement == COMPLEX_MOVE.FLIP then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi})
        elseif movement == COMPLEX_MOVE.FLIP_AND_FORWARD then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi})
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGTH})
        elseif movement == COMPLEX_MOVE.TURN_AND_FORWARD then
            table.insert(move_array, {movement = BASIC_MOVE.TURN, direction = direction, delta = math.pi / 2})
            table.insert(move_array, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGTH})
        end
    else
        if is_moving then
            current_move.movement()
        else
            if move.is_stopped() then
                if calibrate.is_calibration_needed() then
                    calibrate.calibrate_position()
                end
                if #move_array > 0 then
                    current_move = table.remove(move_array, 1)
                    position.update_position(current_move.movement, current_move.direction, current_move.delta)
                    current_move.movement()
                end
            end
        end
    end
    return is_moving, #move_array
end

MOVE_DIRECTION = { FORWARD = 1, BACKWARDS = 2, LEFT = 3, RIGHT = 4 }

--[[
    BASIC_MOVE represents the basic movements that the bot is programmed to do
        STRAIGHT is a move that goes straight one MAZE_UNIT_LENGTH or a given delta if provided
        TURN is a move that turns 90 degrees or a given delta if provided
]]
BASIC_MOVE = { STRAIGHT = move.straight, TURN = move.turn }

--[[
    COMPLEX_MOVE is a move that is composed from one or more BASIC_MOVE
        N_STRAIGHT is a move that goes forward or backwards n times the MAZE_UNIT_LENGTH
        FLIP is a move that turns 180 degrees
        FLIP_AND_FORWARD is a move that turns 180 degrees and then goes forward one MAZE_UNIT_LENGTH
        TURN_AND_FORWARD is a move that turns 90 degreed and then goes forward one MAZE_UNIT_LENGTH
]]
COMPLEX_MOVE = { N_STRAIGHT = 1, FLIP = 2, FLIP_AND_FORWARD = 3, TURN_AND_FORWARD = 4 }

--[[
    This function optimizes an array of movements by converting consecutive movements in the same direction into a single movement
    It takes an array of movements as input and returns an optimized array of movements
    Optimization is done in that way:
        - First it converts all COMPLEX_MOVE into BASIC_MOVE
        - Then it converts all consecutive BASIC_MOVE in the same direction into a single BASIC_MOVE
]]
function move.optimize_movements(movements)
    local basic_movements = {}
    for i, movement in ipairs(movements) do
        if movement.movement == COMPLEX_MOVE.N_STRAIGHT then
            for j = 1, movement.delta do
                table.insert(basic_movements, {movement = BASIC_MOVE.STRAIGHT, direction = movement.direction, delta = movement.delta * MAZE_UNIT_LENGTH})
            end
        elseif movement.movement == COMPLEX_MOVE.FLIP then
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi / 2})
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi / 2})
        elseif movement.movement == COMPLEX_MOVE.FLIP_AND_FORWARD then
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi / 2})
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = MOVE_DIRECTION.RIGHT, delta = math.pi / 2})
            table.insert(basic_movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGTH})
        elseif movement.movement == COMPLEX_MOVE.TURN_AND_FORWARD then
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = movement.direction, delta = math.pi / 2})
            table.insert(basic_movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD, delta = MAZE_UNIT_LENGTH})
        elseif movement.movement == BASIC_MOVE.STRAIGHT then
            table.insert(basic_movements, {movement = BASIC_MOVE.STRAIGHT, direction = movement.direction, delta = MAZE_UNIT_LENGTH})
        elseif movement.movement == BASIC_MOVE.TURN then
            table.insert(basic_movements, {movement = BASIC_MOVE.TURN, direction = movement.direction, delta = math.pi / 2})
        end
    end

    local optimized_movements = {}
    local movement = nil

    for i, basic_movement in ipairs(basic_movements) do
        if movement and movement.movement == basic_movement.movement and movement.direction == basic_movement.direction then
            if basic_movement.delta then
                movement.delta = movement.delta + basic_movement.delta
            else
                if basic_movement.movement == BASIC_MOVE.STRAIGHT then
                    movement.delta = movement.delta + MAZE_UNIT_LENGTH
                else
                    movement.delta = movement.delta + math.pi / 2
                end
            end
        else
            if movement then
                table.insert(optimized_movements, movement)
            end
            movement = basic_movement
        end

        if i == #basic_movements then
            table.insert(optimized_movements, movement)
        end
    end
    return optimized_movements
end

return move
