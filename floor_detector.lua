local floor_detector = {}

DETECTOR_THRESHOLD = 0.1 -- sensor value threshold

floor_color = {WHITE = 1 , BLACK = 0, GREY = 0.5} -- maze floor color

floor_type = {START = floor_color.GREY, PATH = floor_color.WHITE, FINISH = floor_color.BLACK} -- floor types

-- check of colour floor, returns the floor type
function floor_detector.check()
    ground = robot.motor_ground

    -- Check if part of robot is on spot
    spot = floor_type.PATH
    for i=1,4 do
        if ground[i].value >= (floor_type.START - DETECTOR_THRESHOLD) and -- check color with threshold
        ground[i].value <= (floor_type.START + DETECTOR_THRESHOLD)   then
            spot = floor_type.START
            break
        elseif ground[i].value == floor_type.FINISH then
            spot = floor_type.FINISH
            break
        end
    end

    -- log("COLOR: " .. spot)  -- debug

    return spot
end

return floor_detector
