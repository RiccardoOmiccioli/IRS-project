MAX_SHORT_RANGE_DISTANCE = 30

function start_distance_scanner()
    robot.distance_scanner.enable()
	robot.distance_scanner.set_angle(0)
end

function stop_distance_scanner()
    robot.distance_scanner.disable()
end

function get_front_distance()
    return robot.distance_scanner.short_range[1].distance
end

function get_back_distance()
    return robot.distance_scanner.short_range[2].distance
end

function get_right_distance()
    return robot.distance_scanner.long_range[1].distance
end

function get_left_distance()
    return robot.distance_scanner.long_range[2].distance
end