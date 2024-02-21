require "move"
require "distance"

--[[
    This function is used to calibrate the robot's position at the end of a movement by checking its distance from a wall in front of it.
    If the distance is greater than MAZE_UNIT_LENGHT / 2, the robot will schedule a new backwards movement.
    If the distance is less than MAZE_UNIT_LENGHT / 2, the robot will schedule a new forwards movement.
]]
function fast_calibrate()
    -- if robot.distance_scanner[1].value > 0.5 then
    --     robot.wheels.set_velocity(FAST_CALIBRATION_VELOCITY, FAST_CALIBRATION_VELOCITY)
    -- else
    --     robot.wheels.set_velocity(0, 0)
    -- end
end