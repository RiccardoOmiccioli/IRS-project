queue = require "Queue"
maze_data = require "maze_data"
distance = require "distance"
require "path"
require "utils"

local breadth_first = {}
local cells_queue
local maze
local parent = {row = nil, column = nil}

function breadth_first.init()
    cells_queue = queue.new()
    maze = maze_data.new()
end

function breadth_first.algorithm()
    robot_orientation = get_current_heading()
    current_row, current_col = get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then
        
        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        -- check walls for neighbours
        wall_distances = get_all_distances()
        for key, value in pairs(wall_distances) do
            if value == -2 or value > 25 then
                local row_temp, column_temp = calculate_neighbour_cell(maze, current_row, current_col, robot_orientation, key)
            end
        end
    end

    -- for each reachable_neighbour that is not visited update parent with current cell and add each in queue
    local reachable_neighbours = maze.get_cell(current_row, current_col).reachable_neighbours

    -- for each reachable_neighbour that is not visited update parent with current cell
    for i, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
            maze.update_parent(neighbour.row, neighbour.column, {row = current_row, column = current_col})
            cells_queue:enqueue(maze.get_cell(neighbour.row, neighbour.column))
        end
    end

    if not cells_queue:isEmpty() then
        local destination = cells_queue:dequeue()

        -- Calculate path and move
        local movements = calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
        for _, movement in ipairs(movements) do
            move(movement.movement, movement.direction, movement.delta)
        end

        -- Debug
        -- maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
    end

    -- Update parent
    parent.row, parent.column = current_row, current_col
end

return breadth_first