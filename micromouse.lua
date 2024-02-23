require "move"
require "distance"

-- Global variables
n_steps = 0

floor_detector = require "floor_detector"
stopwatch = require "stopwatch"
race_management = require "race_management"
maze_data = require "maze_data"

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

	maze_data.new()
	race_management.run()
	maze_data.update_parent(10,13,"1|1")
	get_front_distance()

	move()
	-- if move() then print("Continue") else print("Done moving") end
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