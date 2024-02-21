function start_distance_scanner()
    robot.distance_scanner.enable()
	robot.distance_scanner.set_angle(math.pi / 2)
end

function stop_distance_scanner()
    robot.distance_scanner.disable()
end

function get_front_distance()
    return robot.distance_scanner.long_range[1].distance
end

function get_back_distance()
    return robot.distance_scanner.long_range[2].distance
end