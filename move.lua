MAX_VELOCITY = 100 -- cm/s
MAZE_UNIT_LENGHT = 50 -- cm
TURN_LINEAR_LENGTH = math.pi * robot.wheels.axis_length / 4 -- linear distance that the wheels needs to travel to turn 90 degrees

distance_traveled = 0
is_moving = false
current_move = nil
move_array = {}

-- Starts a new forward movement or continues movement if already going forward
function forward()
    if not is_moving then
        distance_traveled = 0
        robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
        is_moving = true
    else
        distance_traveled = distance_traveled + robot.wheels.distance_left
        if distance_traveled >= MAZE_UNIT_LENGHT then
            robot.wheels.set_velocity(0, 0)
            is_moving = false
        end
    end
end

-- Starts a new backwards movement or continues movement if already going backwards
function backwards()
    if not is_moving then
        distance_traveled = 0
        robot.wheels.set_velocity(-MAX_VELOCITY, -MAX_VELOCITY)
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
        robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
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
        robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)
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
function move(movement)
    if movement then
        if table_contains(BASIC_MOVE, movement) then
            table.insert(move_array, movement)
        elseif movement == COMPLEX_MOVE.FLIP then
            table.insert(move_array, BASIC_MOVE.TURN_RIGHT)
            table.insert(move_array, BASIC_MOVE.TURN_RIGHT)
        elseif movement == COMPLEX_MOVE.FLIP_AND_FORWARD then
            table.insert(move_array, BASIC_MOVE.TURN_RIGHT)
            table.insert(move_array, BASIC_MOVE.TURN_RIGHT)
            table.insert(move_array, BASIC_MOVE.FORWARD)
        elseif movement == COMPLEX_MOVE.GO_LEFT then
            table.insert(move_array, BASIC_MOVE.TURN_LEFT)
            table.insert(move_array, BASIC_MOVE.FORWARD)
        elseif movement == COMPLEX_MOVE.GO_RIGHT then
            table.insert(move_array, BASIC_MOVE.TURN_RIGHT)
            table.insert(move_array, BASIC_MOVE.FORWARD)
        end
    else
        if is_moving then
            current_move()
        else
            if #move_array > 0 then
                current_move = table.remove(move_array, 1)
                current_move()
            end
        end
    end
    return is_moving
end

-- BASIC_MOVE represents the basic movements that the bot is programmed to do
BASIC_MOVE = { FORWARD = forward, BACKWARDS = backwards, TURN_LEFT = turn_left, TURN_RIGHT = turn_right }

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
        move(COMPLEX_MOVE.GO_LEFT)
    end
]]