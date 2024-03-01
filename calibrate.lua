require "move"
require "distance"
require "proximity"

SENSOR_DISTANCE_FROM_WALL = 14
POSITION_ERROR_THRESHOLD = 1

is_slow_calibrating = false

-- This function checks if a calibration is needed based on the distance from the front wall if available and exceeds the threshold
function is_slow_calibration_needed()
    angle, value = get_closest_object()
    if angle ~= 0 and not is_slow_calibrating then
        return true
    elseif angle == 0 and is_slow_calibrating then
        is_slow_calibrating = false
        return false
    else
        return false
    end
end

function slow_calibrate()
    if not is_slow_calibrating then
        is_slow_calibrating = true
        angle, value = get_closest_object()
        if angle > 0 then
            print("Calibrating angle: " .. angle .. " turning right of " .. tostring(math.pi / 2 - math.abs(angle)))
            move(BASIC_MOVE.TURN, MOVE_DIRECTION.RIGHT, math.pi / 2 - math.abs(angle), true)
        elseif angle < 0 then
            print("Calibrating angle: " .. angle .. " turning left of " .. tostring(math.pi - math.abs(angle)))
            move(BASIC_MOVE.TURN, MOVE_DIRECTION.LEFT, math.pi / 2 - math.abs(angle), true)
        end
    end
end

function is_fast_calibration_needed()
    front_distance = get_front_distance()
    if front_distance > 0 then
        if front_distance < SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD or front_distance > SENSOR_DISTANCE_FROM_WALL + POSITION_ERROR_THRESHOLD then
            return true
        end
    end
    return false
end

--[[
    This function is used to calibrate the robot's position at the end of a movement by checking its distance from a wall in front of it.
    If the distance is greater than MAZE_UNIT_LENGHT / 2, the robot will schedule a new backwards movement.
    If the distance is less than MAZE_UNIT_LENGHT / 2, the robot will schedule a new forwards movement.
]]
function fast_calibrate()
    front_distance = get_front_distance()
        if front_distance > 0 then
            if front_distance < SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD then
                print("Calibrating: " .. front_distance .. " moving backwards of " .. (SENSOR_DISTANCE_FROM_WALL - front_distance))
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS, SENSOR_DISTANCE_FROM_WALL - front_distance, true)
            elseif front_distance > SENSOR_DISTANCE_FROM_WALL  + POSITION_ERROR_THRESHOLD and front_distance < MAX_SHORT_RANGE_DISTANCE then
                print("Calibrating: " .. front_distance .. " moving forwards of " .. (front_distance - SENSOR_DISTANCE_FROM_WALL))
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD, front_distance - SENSOR_DISTANCE_FROM_WALL, true)
            end
        end
end