maze_data = require "maze_data"
distance = require "distance"
require "path"
require "utils"

local depth_first = {}
local maze
local parent = {row = nil, column = nil}

function depth_first.init()
    maze = maze_data.new()
    maze.update_weight(1, 1, 1) -- Initialize first cell weight
end

function depth_first.algorithm()
    robot_orientation = get_current_heading()
    current_row, current_col = get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then

        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        -- check walls for neighbours
        wall_distances = get_all_distances()
        for key, value in pairs(wall_distances) do
            if value == -2 or value > 20 then
                local row_temp, column_temp = calculate_neighbour_cell(maze, current_row, current_col, robot_orientation, key)

                -- Update neighbours weight
                if maze.get_cell(row_temp, column_temp).weight == 0 then
                    maze.update_weight(row_temp, column_temp, maze.get_cell(current_row, current_col).weight + 1)
                end
                --log("r:"..row_temp .. " c:" .. column_temp .. " | weight: ".. maze.get_cell(row_temp, column_temp).weight)
            end
        end
    end

    local reachable_neighbours = maze.get_cell(current_row, current_col).reachable_neighbours

    if #reachable_neighbours > 0 then
        local num = math.random(1, #reachable_neighbours)
        local neighbour = maze.get_cell(reachable_neighbours[num].row, reachable_neighbours[num].column)

        -- Decision of movement
        if robot_orientation == HEADING.NORTH then
            if current_col - neighbour.column < 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
            elseif current_col - neighbour.column == 0 then
                if current_row - neighbour.row < 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
                elseif current_row - neighbour.row > 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
                end
            elseif current_col - neighbour.column > 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
            end
        elseif robot_orientation == HEADING.EAST then
            if current_row - neighbour.row < 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
            elseif current_row - neighbour.row == 0 then
                if current_col - neighbour.column > 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
                elseif current_col - neighbour.column < 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
                end
            elseif current_row - neighbour.row > 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
            end
        elseif robot_orientation == HEADING.SOUTH then
            if current_col - neighbour.column < 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
            elseif current_col - neighbour.column == 0 then
                if current_row - neighbour.row < 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
                elseif current_row - neighbour.row > 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
                end
            elseif current_col - neighbour.column > 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
            end
        elseif robot_orientation == HEADING.WEST then
            if current_row - neighbour.row < 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
            elseif current_row - neighbour.row == 0 then
                if current_col - neighbour.column > 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
                elseif current_col - neighbour.column < 0 then
                    move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
                end
            elseif current_row - neighbour.row > 0 then
                move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
            end
        end
    end

    -- print for debug
    for i, cell in ipairs(maze) do
        if #cell.reachable_neighbours > 0 then
            for j, neighbor in ipairs(cell.reachable_neighbours) do
                log(cell.row .. "," .. cell.column .. ",w" .. cell.weight .. "->" .. neighbor.row .. "|" .. neighbor.column)
            end
        end
    end

    parent.row, parent.column = current_row, current_col

    current_cell_path = trace_path_to_start(maze.get_cell(current_row, current_col), maze)
    visited_cells = depth_first.visited_filter()
    target_cell = visited_cells[math.random(1, #visited_cells)]
    target_cell_path = trace_path_to_start(target_cell, maze)

    print("****************************************************************************************************")
    maze_data.print_cell(maze.get_cell(current_row, current_col))
    print_path(current_cell_path)
    maze_data.print_cell(maze.get_cell(target_cell.row, target_cell.column))
    print_path(target_cell_path)
    print("------------------------------")
    print_path(trace_path_to_target(maze.get_cell(current_row, current_col), target_cell, maze))
    print("------------------------------")
    calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), target_cell, maze))
    print("****************************************************************************************************")


end

function depth_first.sort()
    temp_table = maze
    table.sort(temp_table, function(a, b) return a.weight > b.weight end)
    return temp_table
end

function depth_first.visited_filter()
    local temp_table = {}
    for i, cell in ipairs(maze) do
        if cell.visited then
            table.insert(temp_table, cell)
        end
    end
    return temp_table
end

function depth_first.not_visited_filter()
    local temp_table = {}
    for i, cell in ipairs(maze) do
        if not cell.visited then
            table.insert(temp_table, cell)
        end
    end
    return temp_table
end


return depth_first