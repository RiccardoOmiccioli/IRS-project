NO_WALL = -2
MAX_WALL_DISTANCE = 25

-- check walls near current cell to find reachable neighbours
function check_walls_update_neighbours(maze, current_row, current_col)
    local robot_orientation = get_current_heading()

    wall_distances = get_all_distances()
    for key, value in pairs(wall_distances) do
        if value == NO_WALL or value > MAX_WALL_DISTANCE then
            calculate_neighbour_cell(maze, current_row, current_col, robot_orientation, key)
        end
    end
end

-- calculate neighbour cell of current cell, based on robot orientation
-- then update current cell reachable neighbours list
function calculate_neighbour_cell(maze, current_row, current_col, robot_orientation, key)
    local row_temp, column_temp = 0, 0

    if robot_orientation == HEADING.NORTH then
        if key == "front" then
            row_temp, column_temp = current_row - 1, current_col
        elseif key == "back" then
            row_temp, column_temp = current_row + 1, current_col
        elseif key == "right" then
            row_temp, column_temp = current_row, current_col + 1
        elseif key == "left" then
            row_temp, column_temp = current_row, current_col - 1
        end
    elseif robot_orientation == HEADING.EAST then
        if key == "front" then
            row_temp, column_temp = current_row, current_col + 1
        elseif key == "back" then
            row_temp, column_temp = current_row, current_col - 1
        elseif key == "right" then
            row_temp, column_temp = current_row + 1, current_col
        elseif key == "left" then
            row_temp, column_temp = current_row - 1, current_col
        end
    elseif robot_orientation == HEADING.SOUTH then
        if key == "front" then
            row_temp, column_temp = current_row + 1, current_col
        elseif key == "back" then
            row_temp, column_temp = current_row - 1, current_col
        elseif key == "right" then
            row_temp, column_temp = current_row, current_col - 1
        elseif key == "left" then
            row_temp, column_temp = current_row, current_col + 1
        end
    elseif robot_orientation == HEADING.WEST then
        if key == "front" then
            row_temp, column_temp = current_row, current_col - 1
        elseif key == "back" then
            row_temp, column_temp = current_row, current_col + 1
        elseif key == "right" then
            row_temp, column_temp = current_row - 1, current_col
        elseif key == "left" then
            row_temp, column_temp = current_row + 1, current_col
        end
    end

    maze.update_reachable_neighbours(current_row, current_col, {row = row_temp, column = column_temp})
end

-- for each reachable neighbour that is not visited update parent with current cell
-- if there is a queue, enqueue neighbours cells
function update_parent_not_visited_reachable_neighbours(maze, current_row, current_col, cells_queue)
    local reachable_neighbours = maze.get_cell(current_row, current_col).reachable_neighbours

    for _, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
            maze.update_parent(neighbour.row, neighbour.column, {row = current_row, column = current_col})
            if cells_queue then
                cells_queue:enqueue(maze.get_cell(neighbour.row, neighbour.column))
            end
        end
    end

    return reachable_neighbours
end

-- calculate path and movements from current cell to destination cell
-- then move the robot
function calculate_path_and_move(maze, current_row, current_col, destination)
    local movements = calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

    for _, movement in ipairs(movements) do
        move(movement.movement, movement.direction, movement.delta)
    end
end
