floor_detector = require "floor_detector"
stopwatch = require "stopwatch"
depth_first = require "depth_first"

local race_management = {}

PENALTY_SEC = 3 -- seconds of penalty
penalty_count = 0

function race_management.run()
    -- Check floor colour
	check = floor_detector.check()

	if check == floor_type.FINISH then
		log("FINISH ZONE")
		if penalty_count == 0 then -- Check penalty count
			log("Arrival time: " .. stopwatch.get_seconds() .. " sec")
		else
			log("Arrival time: " .. stopwatch.get_seconds() .. " sec" .. " + " .. penalty_count * PENALTY_SEC .. " sec penalty" )
		end
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
		depth_first.algorithm()
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