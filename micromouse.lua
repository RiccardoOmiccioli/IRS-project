-- Global variables
n_steps = 0

stopwatch = require "stopwatch"

-- This function is executed every time you press the 'execute' button
function init()
	require "move"
	n_steps = 0
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(COMPLEX_MOVE.GO_LEFT)
	move(COMPLEX_MOVE.GO_LEFT)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(COMPLEX_MOVE.GO_LEFT)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_RIGHT)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(BASIC_MOVE.FORWARD)
	move(COMPLEX_MOVE.GO_LEFT)
	move(COMPLEX_MOVE.GO_LEFT)

	stopwatch.init()
end


-- This function is executed at each time step. It must contain the logic of your controller
function step()
	move()
	-- if move() then print("Continue") else print("Done moving") end

	-- Increment stopwatch counter and print values
	stopwatch.increment()
	stopwatch.printDebug()
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