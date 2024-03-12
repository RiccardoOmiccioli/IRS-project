require "move"
require "distance"
require "calibrate"
require "position"
require "proximity"

-- Global variables
depth_first = require "depth_first"
breadth_first = require "breadth_first"
random_explore = require "random_explore"
race_management = require "race_management"

-- This function is executed every time you press the 'execute' button
function init()

	start_distance_scanner()

	robot.leds.set_single_color(3, "red")
	robot.leds.set_single_color(4, "red")
	robot.leds.set_single_color(9, "green")
	robot.leds.set_single_color(10, "green")

	stopwatch.init()
	depth_first.init()
	-- random_explore.init()
	-- breadth_first.init()
end


-- This function is executed at each time step. It must contain the logic of your controller
function step()
	race_management.run()

	is_moving, remaining_moves = move()
	if not is_moving then
		if remaining_moves == 0 then
			print("--------------------SET SLOW VELOCITY-------------------")
			set_slow_velocity() -- set default velocity to slow after a list of movements is done

			depth_first.algorithm()
			-- random_explore.algorithm()
			-- breadth_first.algorithm()
		end
	end

	-- ******************************************************************
	-- check floor and start/stop time
	-- if move() then print("Continue and check obstacle/calibrate") else
		-- depth_first.algorithm()
			-- check walls
			-- decide next move
	-- end
	-- ******************************************************************

end


--[[
	This function is executed every time you press the 'reset'
    button in the GUI. It is supposed to restore the state
    of the controller to whatever it was right after init() was
    called. The state of sensors and actuators is reset
    automatically by ARGoS.
]]
function reset()
end


-- This function is executed only once, when the robot is removed from the simulation
function destroy()
   -- put your code here
end