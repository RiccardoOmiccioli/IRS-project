MAX_SHORT_RANGE_DISTANCE = 30
DISTANCE_THRESHOLD = 0.5

local previous_distance = {front = 0, back = 0, right = 0, left = 0}
local current_distance = {front = 0, back = 0, right = 0, left = 0}

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

function get_all_distances()
    distances = {front = 0, back = 0, right = 0, left = 0}

    distances.front = get_front_distance
    distances.back = get_back_distance
    distances.right = get_right_distance
    distances.left = get_left_distance
    
    return distances
end

-- checks if the current distance is different from the previous one my more than DISTANCE_THRESHOLD. Returns true if it is, false otherwise. Then updates the previous distance with the current one. to be compared values should be more than 0
function is_distance_changed()
    current_distance.front = get_front_distance()
    current_distance.back = get_back_distance()
    current_distance.right = get_right_distance()
    current_distance.left = get_left_distance()
    is_changed = false
    if current_distance.front > 0 and math.abs(current_distance.front - previous_distance.front) > DISTANCE_THRESHOLD or
        current_distance.back > 0 and math.abs(current_distance.back - previous_distance.back) > DISTANCE_THRESHOLD or
        current_distance.right > 0 and math.abs(current_distance.right - previous_distance.right) > DISTANCE_THRESHOLD or
        current_distance.left > 0 and math.abs(current_distance.left - previous_distance.left) > DISTANCE_THRESHOLD
    then
        is_changed = true
    end
    previous_distance.front = current_distance.front
    previous_distance.back = current_distance.back
    previous_distance.right = current_distance.right
    previous_distance.left = current_distance.left
    return is_changed
end
