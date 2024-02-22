floor_detector = require "floor_detector"
stopwatch = require "stopwatch"

local race_management = {}

function race_management.run()
    -- Check floor colour
	check = floor_detector.check()

	if check == floor_type.FINISH then
		log("FINISH ZONE")
		log("Arrival time: " .. stopwatch.getSeconds() .. " sec")
	else
		log("MOVING")
		-- Check floor and start stopwatch
		if check == floor_type.START then
			log("START ZONE")
			stopwatch.init()
		else
			stopwatch.increment()
		end
		-- log("Time: " .. stopwatch.getSeconds())
		--stopwatch.printDebug() -- debug
	end
end

return race_management