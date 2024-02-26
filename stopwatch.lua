local stopwatch =  {}

STEPS_TO_SEC = 60 -- test value --
steps = 0

function stopwatch.init()
     steps = 0
end

function stopwatch.increment()
     steps = steps + 1
end

function stopwatch.get_steps()
     return steps
end

-- This function converts simulation steps in seconds and return the value formatted
function stopwatch.get_seconds()
     return string.format("%.3f", (steps / STEPS_TO_SEC))
end

function stopwatch.print_debug()
	log("STEPS: " .. stopwatch.get_steps())
     log("SECONDS: " .. stopwatch.get_seconds() .. "sec")
     log("-----------------------------------")
end

return stopwatch


