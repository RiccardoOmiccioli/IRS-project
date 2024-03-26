local proximity = {}

SENSORS_NUMBER = 24
PROXIMITY_THRESHOLD = 0.90

-- Returns angle and value of the closest object. If no object is detected returns 0 and 0.
function proximity.get_closest_object()
    proximity_angles = {}
    proximity_angle = 0
    proximity_value = 0
    for i=1,#robot.proximity do
        if robot.proximity[i].value > proximity_value then
            proximity_angles = {}
            table.insert(proximity_angles, robot.proximity[i].angle)
            proximity_value = robot.proximity[i].value
        elseif robot.proximity[i].value == proximity_value and proximity_value > 0 then
            table.insert(proximity_angles, robot.proximity[i].angle)
        end
    end

    if #proximity_angles == 1 then
        proximity_angle = proximity_angles[1]
    elseif #proximity_angles > 1 then
        for angle in pairs(proximity_angles) do
            proximity_angle = proximity_angle + angle
        end
        proximity_angle = proximity_angle / #proximity_angles
    end

    return proximity_angle, proximity_value
end

-- Returns true if the robot is closer to a wall than a certain threshold
function proximity.is_touching_wall()
    for i=1,SENSORS_NUMBER do
        if robot.proximity[i].value > PROXIMITY_THRESHOLD then
            return true
        end
    end
    return false
end

return proximity
