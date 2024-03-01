SENSORS_NUMBER = 24

-- Returns angle and value of the closest object. If no object is detected returns 0 and 0.
function get_closest_object()
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