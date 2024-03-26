NO_WALL = -2
MAX_WALL_DISTANCE = 25

-- check walls near current cell to find reachable neighbours
function check_walls_update_neighbours(maze, current_row, current_col)
    local robot_orientation = position.get_current_heading()

    wall_distances = distance.get_all_distances()
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
    local movements = path.calculate_path_movements(path.trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

    for _, movement in ipairs(movements) do
        move.move(movement.movement, movement.direction, movement.delta)
    end
end


-- To be called when the robot is on the finish zone, get the fastest path from start
function get_fastest_path_to_finish(algorithm)
    local maze = algorithm.get_maze_data()
    local start = maze.get_cell(MIN_ROW_COL_POS, MIN_ROW_COL_POS)
    local finish = algorithm.get_destination()
    return path.trace_path_to_target(start, finish, maze)
end

-- Checks if a table contains a given value and returns first occurrence
function table_contains(table, value)
    found = false
    key = nil
    for k, v in pairs(table) do
        if v == value then
            found = true
            key = k
            break
        end
    end
    return found, key, value
end
