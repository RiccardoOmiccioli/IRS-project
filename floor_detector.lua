local floor_detector = {}

-- check of colour floor, returns true if black
function floor_detector.check(robot)
    ground = robot.motor_ground

    -- Check if part of robot is on spot
    spot = false
    for i=1,4 do
        if ground[i].value == 0 then
            spot = true
            break
        end
    end

    return spot
end

return floor_detector