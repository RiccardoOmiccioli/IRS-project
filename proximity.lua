-- Returns angle and value of the closest object. If no object is detected returns 0 and 0.
function get_closest_object()
    proximity_angle = 0
    proximity_value = 0
    for i=1,#robot.proximity do
        if robot.proximity[i].value > proximity_value then
            proximity_angle = robot.proximity[i].angle
            proximity_value = robot.proximity[i].value
        end
    end
    return proximity_angle, proximity_value
end