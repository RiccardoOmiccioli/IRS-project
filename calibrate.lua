local calibrate = {}

SENSOR_DISTANCE_FROM_WALL = 14
POSITION_ERROR_THRESHOLD = 1

--[[
    This function checks if the robot's position needs to be calibrated.
    It checks the distance from the wall in front and at the back of the robot and if the error is greater than the POSITION_ERROR_THRESHOLD it returns true.
]]
function calibrate.is_calibration_needed()
    front_distance = distance.get_front_distance()
    back_distance = distance.get_back_distance()
    if front_distance > 0 or back_distance > 0 then
        if math.abs(front_distance - SENSOR_DISTANCE_FROM_WALL) > POSITION_ERROR_THRESHOLD or math.abs(back_distance - SENSOR_DISTANCE_FROM_WALL) > POSITION_ERROR_THRESHOLD then
            return true
        end
    end
    return false
end

--[[
    This function is used to calibrate the robot's position at the end of a movement by checking its distance from a wall in front or at the back of it.
    If the error is greater than the POSITION_ERROR_THRESHOLD it moves the robot to correct its position.
]]
function calibrate.calibrate_position()
    local front_distance = distance.get_front_distance()
    local back_distance = distance.get_back_distance()

    -- Calibrate based on front distance
    if front_distance > 0 then
        if front_distance < SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD then
            local move_distance = SENSOR_DISTANCE_FROM_WALL - front_distance
            print("Calibrating front: " .. front_distance .. ", moving backwards by " .. move_distance)
            move.move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS, move_distance, true)
        elseif front_distance > SENSOR_DISTANCE_FROM_WALL + POSITION_ERROR_THRESHOLD and front_distance < MAX_SHORT_RANGE_DISTANCE then
            local move_distance = front_distance - SENSOR_DISTANCE_FROM_WALL
            print("Calibrating front: " .. front_distance .. ", moving forwards by " .. move_distance)
            move.move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD, move_distance, true)
        end
    -- Calibrate based on back distance
    elseif back_distance > 0 then
        if back_distance < SENSOR_DISTANCE_FROM_WALL - POSITION_ERROR_THRESHOLD then
            local move_distance = SENSOR_DISTANCE_FROM_WALL - back_distance
            print("Calibrating back: " .. back_distance .. ", moving forwards by " .. move_distance)
            move.move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD, move_distance, true)
        elseif back_distance > SENSOR_DISTANCE_FROM_WALL + POSITION_ERROR_THRESHOLD and back_distance < MAX_SHORT_RANGE_DISTANCE then
            local move_distance = back_distance - SENSOR_DISTANCE_FROM_WALL
            print("Calibrating back: " .. back_distance .. ", moving backwards by " .. move_distance)
            move.move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS, move_distance, true)
        end
    end
end

return calibrate
