maze_data = require "maze_data"
distance = require "distance"
require "path"
require "utils"

local depth_first = {}
local maze
local parent = {row = nil, column = nil}


function depth_first.init()
    maze = maze_data.new()
    --maze.update_weight(1, 1, 1) -- Initialize first cell weight
    math.randomseed(os.time())

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
            if value == -2 or value > 25 then
                local row_temp, column_temp = calculate_neighbour_cell(maze, current_row, current_col, robot_orientation, key)

                -- Update neighbours weight
               --[[  if maze.get_cell(row_temp, column_temp).weight == 0 then
                    maze.update_weight(row_temp, column_temp, maze.get_cell(current_row, current_col).weight + 1)
                end ]]
                --log("r:"..row_temp .. " c:" .. column_temp .. " | weight: ".. maze.get_cell(row_temp, column_temp).weight)
            end
        end
    end

    local current_cell = maze.get_cell(current_row, current_col)
    local reachable_neighbours = current_cell.reachable_neighbours

    -- for each reachable_neighbour that is not visited update parent with current cell
    for i, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
           maze.update_parent(neighbour.row, neighbour.column, {row = current_row, column = current_col})
        end
    end

    local not_visited_neighbours = depth_first.not_visited_neighbours_cells(reachable_neighbours)

    local destination

    -- Check not visited neighbours size
    if #not_visited_neighbours > 0 then
        destination = not_visited_neighbours[math.random(1, #not_visited_neighbours)]
    else
        local parent_row, parent_column = depth_first.parent_with_neighbours_not_visited(current_cell.row, current_cell.column)
        destination = maze.get_cell(parent_row, parent_column)
    end

    -- Debug
    print("Current cell: r".. current_cell.row .. "| c"..current_cell.column)
    print("Next cell: r".. destination.row .. "| c"..destination.column)
  
    -- Calculate path and move
    local movements = calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
    for _, movement in ipairs(movements) do
       move(movement.movement, movement.direction, movement.delta)
    end

    maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

    -- print for debug
   --[[  for i, cell in ipairs(maze) do
        if #cell.reachable_neighbours > 0 then
            for j, neighbor in ipairs(cell.reachable_neighbours) do
                log(cell.row .. "," .. cell.column .. ",w" .. cell.weight .. "->" .. neighbor.row .. "|" .. neighbor.column)
            end
        end
    end ]]

    -- Update parent
    parent.row, parent.column = current_row, current_col

--[[     current_cell_path = trace_path_to_start(maze.get_cell(current_row, current_col), maze)
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
    print("****************************************************************************************************") ]]


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


function depth_first.not_visited_filter()
    local temp_table = {}
    for i, cell in ipairs(maze) do
        if not cell.visited then
            table.insert(temp_table, cell)
        end
    end
    return temp_table
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
        --print("Next parent with not visited neighbours: r".. parent.row .. "| c"..parent.column)
        return parent.row, parent.column
    else
        return depth_first.parent_with_neighbours_not_visited(parent.row, parent.column)                   
    end
end


return depth_first