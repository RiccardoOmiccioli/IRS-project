require "move"
require "distance"
require "calibrate"

-- Global variables
n_steps = 0

depth_first = require "depth_first"
race_management = require "race_management"

-- This function is executed every time you press the 'execute' button
function init()
	n_steps = 0

	start_distance_scanner()

	robot.leds.set_single_color(3, "red")
	robot.leds.set_single_color(4, "red")
	robot.leds.set_single_color(9, "green")
	robot.leds.set_single_color(10, "green")

	move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.N_STRAIGHT, MOVE_DIRECTION.FORWARD, 5)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.N_STRAIGHT, MOVE_DIRECTION.FORWARD, 5)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.N_STRAIGHT, MOVE_DIRECTION.FORWARD, 4)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
	move(COMPLEX_MOVE.N_STRAIGHT, MOVE_DIRECTION.FORWARD, 3)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
	move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)

	stopwatch.init()
end


-- This function is executed at each time step. It must contain the logic of your controller
function step()

	depth_first.start_algorithm()
	race_management.run()

	move()
	-- if move() then print("Continue") else print("Done moving") end
	-- if not move() then
	-- 	print("Done moving")
	-- end

	-- ******************************************************************
	-- check floor and start/stop time
	-- if move() then print("Continue and check obstacle/calibrate") else
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
	n_steps = 0
end


-- This function is executed only once, when the robot is removed from the simulation
function destroy()
   -- put your code here
end