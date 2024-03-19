maze_data = require "maze_data"
distance = require "distance"
require "path"
require "utils"

local random_explore = {}
local maze
local parent = {row = nil, column = nil}

function random_explore.init()
    maze = maze_data.new()
end

function random_explore.algorithm()
    current_row, current_col = get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then

        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        check_walls_update_neighbours(maze, current_row, current_col)
    end

    local reachable_neighbours = maze.get_cell(current_row, current_col).reachable_neighbours

    -- for each reachable_neighbour that is not visited update parent with current cell
    for i, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
            maze.update_parent(neighbour.row, neighbour.column, {row = current_row, column = current_col})
        end
    end

    parent.row, parent.column = current_row, current_col

    local target_cell = nil
    -- check if current cell reachable_neighbours are visited if not choose a random one as the target cell
    local has_unexplored_neighbours = false
    for i, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
            has_unexplored_neighbours = true
            target_cell = maze.get_cell(neighbour.row, neighbour.column)
            break
        end
    end

    if not has_unexplored_neighbours then
        -- if all reachable_neighbours are visited, choose a random not visited cell that is reachable
        local filtered_cells = random_explore.not_visited()
        target_cell = filtered_cells[math.random(1, #filtered_cells)]
    end

    current_cell_path = trace_path_to_start(maze.get_cell(current_row, current_col), maze)
    target_cell_path = trace_path_to_start(target_cell, maze)

    local movements = calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), target_cell, maze))
    for _, movement in ipairs(movements) do
       move(movement.movement, movement.direction, movement.delta)
    end

    maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), target_cell, maze))
end

function random_explore.filter()
    local temp_table = {}
    for i, cell in ipairs(maze) do
        if cell.visited then
            for j, neighbour in ipairs(cell.reachable_neighbours) do
                neighbour_cell = maze.get_cell(neighbour.row, neighbour.column)
                if not neighbour_cell.visited then
                    table.insert(temp_table, neighbour_cell)
                    break
                end
            end
        end
    end
    return temp_table
end

-- this function returns a table with all cells that are not visited but that have a parent cell
function random_explore.not_visited()
    local temp_table = {}
    for i, cell in ipairs(maze) do
        if not cell.visited and cell.parent.row ~= nil and cell.parent.column ~= nil then
            table.insert(temp_table, cell)
        end
    end
    return temp_table
end

return random_explore