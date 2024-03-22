floor_detector = require "floor_detector"
stopwatch = require "stopwatch"


local race_management = {}

PENALTY_SEC = 3 -- seconds of penalty
PENALTY_COOLDOWN = 100 -- number of steps until a new penalty can be added

race_states = {RUN = "RUN", STOP = "STOP"}


penalty_start = 0
penalty_count = 0

is_penalty_enabled = true
is_floor_detection_enabled = true

function race_management.init()
	stopwatch.init()
	penalty_start = 0
	penalty_count = 0
	race_state = race_states.STOP
end

function race_management.run()

	local race_state = race_states.RUN

	if is_penalty_enabled then
		race_management.check_penalty()
	end
	if is_floor_detection_enabled then
		-- Check floor colour
		check = floor_detector.check()

		if check == floor_type.FINISH then
			log("FINISH ZONE")
			if penalty_count == 0 then -- Check penalty count
				log("Arrival time: " .. stopwatch.get_seconds() .. " sec")
			else
				log("Arrival time: " .. stopwatch.get_seconds() .. " sec" .. " + " .. penalty_count * PENALTY_SEC .. " sec penalty" )
			end

			race_state = race_states.STOP
		else
			log("MOVING")
			-- Check floor and start stopwatch
			if check == floor_type.START then
				log("START ZONE")
				stopwatch.init()
			else
				stopwatch.increment()
			end
			-- log("Time: " .. stopwatch.get_seconds())
			-- stopwatch.print_debug()
		end
	end
	return race_state
end

-- Check if a penalty need to be added by checking if the robot is touching a wall and if the cooldown has passed
function race_management.check_penalty()
	if is_touching_wall() and math.abs(penalty_start - stopwatch.get_steps()) >= PENALTY_COOLDOWN then
		penalty_start = stopwatch.get_steps()
		race_management.add_penalty()
	end
end

-- Increment penalty count
function race_management.add_penalty()
	penalty_count = penalty_count + 1
end

-- Reset penalty count
function race_management.reset_penalty()
	penalty_count = 0
end

return race_management