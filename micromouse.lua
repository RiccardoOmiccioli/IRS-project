-- Global variables
race_management = require "race_management"
move = require "move"
distance = require "distance"
calibrate = require "calibrate"
position = require "position"
proximity = require "proximity"

local maze_data
local available_algorithms = {DEPTH_FIRST = "depth_first", BREADTH_FIRST = "breadth_first",  FLOOD_FILL = "flood_fill", RANDOM_EXPLORE = "random_explore"}

-- SELECT ALGORITHM --
local algorithm = require(available_algorithms.FLOOD_FILL)

local race
local final_path

-- This function is executed every time you press the 'execute' button
function init()
	math.randomseed(os.time())
	init_robot()
	race_management.init()
	stopwatch.init()
	algorithm.init()
	race = race_states.STOP
end

-- This function is executed at each time step. It must contain the logic of your controller
function step()
	race = race_management.run()

	is_moving, remaining_moves = move.move()

	-- Search best path with algorithm
	if race == race_states.RUN then
		if not is_moving then
			if remaining_moves == 0 then
				move.move.set_slow_velocity() -- set default velocity to slow after a list of movements is done
				algorithm.execute()
			end
		end
	end

	-- When it stops get fastest path
	if race == race_states.STOP then
		print("STOP")
		final_path = get_fastest_path_to_finish(algorithm)
	end
end

--[[
	This function is executed every time you press the 'reset'
    button in the GUI. It is supposed to restore the state
    of the controller to whatever it was right after init() was
    called. The state of sensors and actuators is reset
    automatically by ARGoS.
]]
function reset()
	log("RESET")
	init_robot()
	race_management.init()
	reset_position()
	race = race_states.STOP
	load_fast_path()
end

-- This function is executed only once, when the robot is removed from the simulation
function destroy()
	log("DESTROY")
   -- put your code here
end

function init_robot()
	distance.start_distance_scanner()
	robot.leds.set_single_color(3, "red")
	robot.leds.set_single_color(4, "red")
	robot.leds.set_single_color(9, "green")
	robot.leds.set_single_color(10, "green")
end

function load_fast_path()
	move.set_fast_velocity()
	local movements = calculate_path_movements(final_path)
	for _, movement in ipairs(movements) do
		move.move(movement.movement, movement.direction, movement.delta)
	end
end
