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
    current_row, current_col = get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then
        
        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        check_walls_update_neighbours(maze, current_row, current_col)
    end

    update_parent_not_visited_reachable_neighbours(maze, current_row, current_col, cells_queue)

    if not cells_queue:isEmpty() then
        local destination = cells_queue:dequeue()

        calculate_path_and_move(maze, current_row, current_col, destination)

        -- Debug
        -- maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
    end

    -- Update parent
    parent.row, parent.column = current_row, current_col
end

return breadth_first