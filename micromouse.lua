require "move"
require "distance"
require "calibrate"
require "position"
require "proximity"

-- Global variables
race_management = require "race_management"

local maze_data
local available_algorithms = {DEPTH_FIRST = "depth_first", BREADTH_FIRST = "breadth_first",  FLOOD_FILL = "flood_fill", RANDOM_EXPLORE = "random_explore"}

-- SELECT ALGORITHM --
local algorithm = require(available_algorithms.FLOOD_FILL)

local is_reset = false
local race
local final_path

-- This function is executed every time you press the 'execute' button
function init()
	log("INIT")
	math.randomseed(os.time())
	
	init_robot()
	
	race_management.init()
	stopwatch.init()
	
	algorithm.init()

	is_reset = false
	race = race_states.STOP

end


-- This function is executed at each time step. It must contain the logic of your controller
function step()
	log("STEP")

	race = race_management.run()

	is_moving, remaining_moves = move()

	-- Search best path with algorithm
	if race == race_states.RUN then 
		--print("move")
		if not is_moving then
			if remaining_moves == 0 then
				set_slow_velocity() -- set default velocity to slow after a list of movements is done
				algorithm.execute()

				--print("RUN")
			end
		end
	end

	-- When it stops get fastest path
	if race == race_states.STOP then
		print("STOP")
		final_path = algorithm.get_fastest_path_to_finish(1,1)
		--print_path(final_path)
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
	log("RESET")

	init_robot()
	race_management.init()
	reset_position()
	
	race = race_states.STOP
	print("final path -----------------")
	--print_path(final_path)

	load_fast_path()
end


-- This function is executed only once, when the robot is removed from the simulation
function destroy()
	log("DESTROY")
   -- put your code here
end

  
function init_robot()

	start_distance_scanner()

	robot.leds.set_single_color(3, "red")
	robot.leds.set_single_color(4, "red")
	robot.leds.set_single_color(9, "green")
	robot.leds.set_single_color(10, "green")
end
  
function load_fast_path()
	--print("execute fast travel")
	set_fast_velocity()
	local movements = calculate_path_movements(final_path)
	for _, movement in ipairs(movements) do
		move(movement.movement, movement.direction, movement.delta)
	end
end