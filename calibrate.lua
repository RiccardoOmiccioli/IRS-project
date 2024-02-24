require "move"
require "distance"

SENSOR_DISTANCE_FROM_WALL = 14
POSITION_ERROR_THRESHOLD = 1

MAX_CALIBRATE_SPEED = 50

is_calibrating = false

--[[
    This function is used to calibrate the robot's position at the end of a movement by checking its distance from a wall in front of it.
    If the distance is greater than MAZE_UNIT_LENGHT / 2, the robot will schedule a new backwards movement.
    If the distance is less than MAZE_UNIT_LENGHT / 2, the robot will schedule a new forwards movement.
]]
function fast_calibrate()
    front_distance = get_front_distance()
    if not is_calibrating then
        if front_distance > 0 then
            if front_distance < SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD then
                print("Calibrating: " .. front_distance .. " moving backwards of " .. (SENSOR_DISTANCE_FROM_WALL - front_distance))
                -- move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS, SENSOR_DISTANCE_FROM_WALL - front_distance, true)
                is_calibrating = true
            elseif front_distance > SENSOR_DISTANCE_FROM_WALL  + POSITION_ERROR_THRESHOLD and front_distance < MAX_SHORT_RANGE_DISTANCE then
                print("Calibrating: " .. front_distance .. " moving forwards of " .. (front_distance - SENSOR_DISTANCE_FROM_WALL))
                -- move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD, front_distance - SENSOR_DISTANCE_FROM_WALL, true)
                is_calibrating = true
            end
        end
    elseif is_calibrating then
        if front_distance < SENSOR_DISTANCE_FROM_WALL + POSITION_ERROR_THRESHOLD and front_distance > SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD then
            is_calibrating = false
        end
    end

end