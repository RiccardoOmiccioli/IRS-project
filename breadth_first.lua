local breadth_first = {}

local cells_queue
local maze
local parent = {row = nil, column = nil}
local destination = nil

function breadth_first.init()
    cells_queue = queue.new()
    maze = maze_data.new()
end

function breadth_first.execute()
    current_row, current_col = position.get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then

        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        check_walls_update_neighbours(maze, current_row, current_col)
    end

    update_parent_not_visited_reachable_neighbours(maze, current_row, current_col, cells_queue)

    if not cells_queue:isEmpty() then
        destination = cells_queue:dequeue()

        calculate_path_and_move(maze, current_row, current_col, destination)

        -- Debug
        -- maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
    end

    -- Update parent
    parent.row, parent.column = current_row, current_col
end

function breadth_first.get_destination()
    return destination
end

function breadth_first.get_maze_data()
    return maze
end

return breadth_first
