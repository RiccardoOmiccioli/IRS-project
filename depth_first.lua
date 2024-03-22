maze_data = require "maze_data"
distance = require "distance"
require "path"
require "utils"

local depth_first = {}
local maze
local parent = {row = nil, column = nil}

function depth_first.init()
    maze = maze_data.new()
end

function depth_first.execute()
    current_row, current_col = get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then

        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        check_walls_update_neighbours(maze, current_row, current_col)
    end

    local reachable_neighbours = update_parent_not_visited_reachable_neighbours(maze, current_row, current_col)

    local not_visited_neighbours = depth_first.not_visited_neighbours_cells(reachable_neighbours)

    local destination

    -- Check not visited neighbours size
    if #not_visited_neighbours > 0 then
        destination = not_visited_neighbours[math.random(1, #not_visited_neighbours)]
    else
        local parent_row, parent_column = depth_first.parent_with_neighbours_not_visited(current_row, current_col)
        destination = maze.get_cell(parent_row, parent_column)
    end
  
    calculate_path_and_move(maze, current_row, current_col, destination)

    -- Debug
    -- maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

    -- Update parent
    parent.row, parent.column = current_row, current_col
end

function depth_first.not_visited_neighbours_cells(reachable_neighbours)
    local all_reachable_neighbours = {}
    for _, neighbour in ipairs(reachable_neighbours) do
        local n = maze.get_cell(neighbour.row, neighbour.column)
        if not n.visited then
            table.insert(all_reachable_neighbours, n)
        end
    end
    return all_reachable_neighbours
end

-- Recursively search for a parent with at least one not visited neighbour
function  depth_first.parent_with_neighbours_not_visited(p_row, p_column)

    local parent = maze.get_cell(p_row, p_column).parent
    local parent_neighbours = maze.get_cell(parent.row, parent.column).reachable_neighbours

    local has_one_not_visited = false

    -- Check if parent has at least one not visited neighbour
    for i = 1, #parent_neighbours do
        local temp = maze.get_cell(parent_neighbours[i].row, parent_neighbours[i].column)
        if not temp.visited then
            has_one_not_visited = true              
        end
    end

    if has_one_not_visited then
        return parent.row, parent.column
    else
        return depth_first.parent_with_neighbours_not_visited(parent.row, parent.column)                   
    end
end


return depth_first