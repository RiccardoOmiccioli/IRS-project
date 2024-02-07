-- [[ Global variables ]]
MOVE_STEPS = 10
MAX_VELOCITY = 10

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then

		--[[ Check which light sensor detects the max amount of light ]]
		sensor_index = 0
		max_light_detected = 0
		for i=1,#robot.light do
			if robot.light[i].value > max_light_detected then
				sensor_index = i
				max_light_detected = robot.light[i].value
			end
		end

		if sensor_index <= 2 and sensor_index >= 23 then
			left_v = MAX_VELOCITY
			right_v = MAX_VELOCITY
		elseif sensor_index >= 3 and sensor_index <= 12 then
			left_v = 0
			right_v = MAX_VELOCITY
		elseif sensor_index >= 13 and sensor_index <= 22 then
			left_v = MAX_VELOCITY
			right_v = 0
		else --[[ sensor_index == 0 ]]
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end

	end
	robot.wheels.set_velocity(left_v,right_v)

end


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end


--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end