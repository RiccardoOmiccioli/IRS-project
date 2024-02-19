local stopwatch =  {}

STEPS_TO_SEC = 60 -- test value --
steps = 0

function stopwatch.init()
     steps = 0
end

function stopwatch.increment()
     steps = steps + 1
end

function stopwatch.getSteps()
     return steps
end

-- This function converts simulation steps in seconds and return the value
function stopwatch.getSeconds()
     return steps / STEPS_TO_SEC
end

function stopwatch.printDebug()
	log("STEPS: " .. stopwatch.getSteps())
     log("SECONDS: " .. stopwatch.getSeconds())
     log("-----------------------------------")
end

return stopwatch


