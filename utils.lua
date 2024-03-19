-- check walls near current cell to find reachable neighbours
function check_walls_update_neighbours(maze, current_row, current_col)
    local robot_orientation = get_current_heading()

    wall_distances = get_all_distances()
    for key, value in pairs(wall_distances) do
        if value == -2 or value > 25 then
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