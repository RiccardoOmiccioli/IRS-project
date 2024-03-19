queue = require "Queue"
maze_data = require "maze_data"
distance = require "distance"
--depth_first = require "depth_first"
require "path"
require "utils"

local flood_fill = {}
local maze
local maze_flood
local flood_queue
local parent = {row = nil, column = nil}

arrived_bottom_right = false
arrived_destination = false
arrived_start = false

function flood_fill.init()
    math.randomseed(os.time())
    flood_queue = queue.new()
    maze = maze_data.new()
    flood_fill.set_maze_weight()
    flood_fill.print_weight()
end

function flood_fill.algorithm()
    robot_orientation = get_current_heading()
    current_row, current_col = get_current_row_and_column()
    local current_cell = maze.get_cell(current_row, current_col)

    if not current_cell.visited then
        
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
     local reachable_neighbours = current_cell.reachable_neighbours

    -- for each reachable_neighbour that is not visited update parent with current cell
    for i, neighbour in ipairs(reachable_neighbours) do
        if not maze.get_cell(neighbour.row, neighbour.column).visited then
            maze.update_parent(neighbour.row, neighbour.column, {row = current_row, column = current_col})
        end
    end

    local destination
    
    --DEMO
    flood_fill.maze_exploration(current_cell)

    if arrived_start then 
        destination = maze.get_cell(5,5) -- change in select fastest way
    else

        --local temp = flood_fill.lighter_neighbours(current_cell) -- ? filter not visited ?
        local temp = flood_fill.choose_neighbours(current_cell)

        -- Check lower weight neighbours size
        if #temp > 0 then
            --print("LOWER n: " .. #temp)
            
            --destination = temp[math.random(1, #temp)] -- to change in minimum
            destination = flood_fill.get_minimum_weight_neighbour(temp)
        else -- If stuck

            --print("FLOOD FILl")
            flood_fill.perform_flood_fill(current_cell)

            local temp = flood_fill.choose_neighbours(current_cell)
            --print("lighter n: " .. #temp)
            
            
            --destination = temp[math.random(1, #temp)] -- to change in minimum
            destination = flood_fill.get_minimum_weight_neighbour(temp)

        end
    end

   
    -- Print debug
    flood_fill.print_weight()
    print("Current cell: r".. current_cell.row .. "| c"..current_cell.column .. " | weight:" .. current_cell.weight .. " | visited:" .. tostring(current_cell.visited))
    print("Next cell: r".. destination.row .. "| c"..destination.column .. " | weight:" .. destination.weight .. " | visited:" .. tostring(destination.visited))
  
    -- Calculate path and move
    local movements = calculate_path_movements(trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))
    for _, movement in ipairs(movements) do
        move(movement.movement, movement.direction, movement.delta)
    end

    maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

    -- Update parent
    parent.row, parent.column = current_row, current_col

end



-- Food fill algorithm
-- 1. Add current cell to queue
-- 2. While queue is not empty
        -- dequeue CELL
        -- get minimum weight amongst reachable neighbours of CELL **
        -- if CELL weight < minimum of it's neighbours then
            -- set CELL weight to minimum +1 
            -- add all accessible neighbours to queue
        
-- **NOTE: if the CELL is not visited the only way to check for reachable neighbours 
-- is to check if near visited neighbours sees the CELL
function flood_fill.perform_flood_fill(current_cell)
    print("FLOOD FILL !")

    flood_queue:enqueue(current_cell)
    --print("-- ENQUEUE --")

    while not flood_queue:isEmpty() do

        local front_cell = flood_queue:dequeue()
        --print("---- DEQUEUE: R" .. front_cell.row .. "| C" .. front_cell.column)

        local reach_n = flood_fill.get_reachable_neighbours(front_cell)
        --print("---- GET REACHABLE NEIGHBOURS n: " .. #reach_n)

        local minimum_n = flood_fill.get_minimum_weight_neighbour(reach_n)
        --print("---- GET MINIMUM: " .. minimum)

        if front_cell.weight <= minimum_n.weight then

            front_cell.weight = minimum_n.weight + 1

            for _, r in ipairs(reach_n) do
                flood_queue:enqueue(r)
                --print("------ ENQUEUE  R: " .. r.row .." | C: " .. r.column)
            end
        end
    end

end

-- DEMO
function flood_fill.maze_exploration(current_cell)
    -- change destination to bottom right angle for exploration
    if current_cell.weight <= 0 and not arrived_destination then

        --maze_flood = flood_fill.copy(maze)

        flood_fill.set_new_destination(MAX_ROW_COL_POS, MAX_ROW_COL_POS)
        flood_fill.print_weight()
        arrived_destination = true
    end

    -- change destination to start
    if current_cell.row == MAX_ROW_COL_POS and current_cell.column == MAX_ROW_COL_POS and not arrived_bottom_right and arrived_destination then

        
        flood_fill.set_new_destination(MAX_ROW_COL_POS,MIN_ROW_COL_POS)
        flood_fill.print_weight()
        arrived_bottom_right = true
    end

    if current_cell.row == MIN_ROW_COL_POS and current_cell.column == MIN_ROW_COL_POS and not arrived_start and arrived_destination and arrived_bottom_right then
        --maze = maze_flood

   
        local cell = maze.get_cell(6, 5)
        flood_fill.perform_flood_fill(cell)


        arrived_start = true
    end

end


-- get minimum weight neighbour
function flood_fill.get_minimum_weight_neighbour(neighbours)
    local minimum = neighbours[1]

    for _, n in ipairs(neighbours) do
        if n.weight < minimum.weight then
            minimum = n
        end
    end

    return minimum
end


-- Get the reachable neighbours if visited or not
function flood_fill.get_reachable_neighbours(cell)
    local reach_table
    if cell.visited then
        reach_table = flood_fill.reachable_neighbours_cells(cell.reachable_neighbours)
        --print("------ VISITED n: " .. #reach_table)

    else
        -- check if cell is present in neighbour neighbours
        reach_table = flood_fill.cell_is_neighbour(cell)
        --print("------ NOT VISITED n: " .. #reach_table)

    end

    --[[ for _, v in ipairs(reach_table) do
        print("-------- REACH  R: " .. v.row .. " | C: " .. v.column)
    end ]]

    return reach_table
end



-- Get the cells 
function flood_fill.cell_is_neighbour(cell)
    local adjacent_cells = flood_fill.get_adjacent_cells(cell)
    local reach = {}

    -- For each adjacent cell check his neighbours
    for _, c in ipairs(adjacent_cells) do
        if c.visited then
            for _, rn in ipairs(c.reachable_neighbours) do
                if cell.row == rn.row and cell.column == rn.column then
                    table.insert(reach, c)
                end
            end     
        else
            table.insert(reach, c)
        end             
    end

    return reach
end

-- Get adjacent cells
function flood_fill.get_adjacent_cells(cell)
    local adjacent = {}

    if cell.row > 1 then
        table.insert(adjacent, maze.get_cell(cell.row - 1, cell.column))
    end

    if cell.row + 1 < MAX_ROW_COL_POS then
        table.insert(adjacent, maze.get_cell(cell.row + 1, cell.column))
    end

    if cell.column > 1 then
        table.insert(adjacent, maze.get_cell(cell.row, cell.column - 1))
    end

    if cell.column + 1 < MAX_ROW_COL_POS then
        table.insert(adjacent, maze.get_cell(cell.row, cell.column + 1))
    end

    return adjacent
end


function flood_fill.choose_neighbours(current_cell)
    local tmp = flood_fill.not_visited_and_lighter_neighbours(current_cell)
    if #tmp > 0 then
        return tmp
    else
        return flood_fill.lighter_neighbours(current_cell)
    end
end


function flood_fill.not_visited_and_lighter_neighbours(current_cell)
    local tmp ={}
    -- Create a table of not visited neighbour
    for j, neighbour in ipairs(current_cell.reachable_neighbours) do
        local n = maze.get_cell(neighbour.row, neighbour.column)
        if not n.visited and n.weight < current_cell.weight then
            table.insert(tmp, n)
        end
    end
    return tmp
end

function flood_fill.lighter_neighbours(current_cell)
    local tmp ={}
    -- Create a table of not visited neighbour
    for j, neighbour in ipairs(current_cell.reachable_neighbours) do
        local n = maze.get_cell(neighbour.row, neighbour.column)
        if n.weight < current_cell.weight then
            table.insert(tmp, n)
        end
    end
    return tmp
end

function flood_fill.reachable_neighbours_cells(reachable_neighbours)
    local all_reachable_neighbours = {}
    for _, neighbour in ipairs(reachable_neighbours) do
        local n = maze.get_cell(neighbour.row, neighbour.column)
        table.insert(all_reachable_neighbours, n)
    end
    return all_reachable_neighbours
end



-- OLD ----
--[[ function flood_fill.set_maze_weight()

    --[[  
        Split the matrix in 4 submatrix

        * * * * * * * 
        * 1.1 * 1.2 *
        * * * * * * * 
        * 2.1 * 2.2 *
        * * * * * * * 

    for i, cell in ipairs(maze) do
        -- 1.1
        if cell.row <= (MAX_ROW_COL_POS / 2) and cell.column <= (MAX_ROW_COL_POS / 2)  then
            cell.weight = MAX_ROW_COL_POS - cell.row - cell.column
        -- 1.2
        elseif cell.row <= (MAX_ROW_COL_POS / 2) and cell.column > (MAX_ROW_COL_POS / 2)   then
            cell.weight = cell.column - cell.row - 1
        -- 2.1
        elseif cell.row > (MAX_ROW_COL_POS / 2) and cell.column <= (MAX_ROW_COL_POS / 2) then
            cell.weight = cell.row - cell.column - 1
        -- 2.2    
        elseif cell.row > (MAX_ROW_COL_POS / 2) and cell.column > (MAX_ROW_COL_POS / 2) then
            cell.weight = cell.column + cell.row - MAX_ROW_COL_POS - 2
        end
        
    end
end ]]

function flood_fill.set_maze_weight()

    --[[  
        Split the matrix, with four 0 in the center, in 4 submatrix 

        * * * * * * * 
        * 1.1 * 1.2 *
        * * * * * * * 
        * 2.1 * 2.2 *
        * * * * * * * 
    ]]--

    for i, cell in ipairs(maze) do
        -- 1.1 
        if cell.row <= (MAX_ROW_COL_POS / 2) and cell.column <= (MAX_ROW_COL_POS / 2)  then
            cell.weight = flood_fill.manhattan_distance((MAX_ROW_COL_POS / 2), (MAX_ROW_COL_POS / 2), cell.row, cell.column)
        -- 1.2
        elseif cell.row <= (MAX_ROW_COL_POS / 2) and cell.column > (MAX_ROW_COL_POS / 2)   then
            cell.weight = flood_fill.manhattan_distance((MAX_ROW_COL_POS / 2), (MAX_ROW_COL_POS / 2 + 1), cell.row, cell.column)
        -- 2.1
        elseif cell.row > (MAX_ROW_COL_POS / 2) and cell.column <= (MAX_ROW_COL_POS / 2) then
            cell.weight = flood_fill.manhattan_distance((MAX_ROW_COL_POS / 2 + 1), (MAX_ROW_COL_POS / 2), cell.row, cell.column)
        -- 2.2    
        elseif cell.row > (MAX_ROW_COL_POS / 2) and cell.column > (MAX_ROW_COL_POS / 2) then
            cell.weight = flood_fill.manhattan_distance((MAX_ROW_COL_POS / 2 + 1), (MAX_ROW_COL_POS / 2 + 1), cell.row, cell.column)
        end
        
    end
end

function flood_fill.set_new_destination(row, column)
    for i, cell in ipairs(maze) do
        cell.weight = flood_fill.manhattan_distance(row, column, cell.row, cell.column)
    end
end

-- Calculate the manhattan distance of 2 points
function flood_fill.manhattan_distance(first_row, first_column, second_row, second_column)
    return math.abs(second_row - first_row) + math.abs(second_column - first_column)
end


-- Debug
function flood_fill.print_weight()
    for i = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
        for j = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
            local cell = maze.get_cell(i, j)
            if cell.weight<10 then
                io.write(" " .. tostring(cell.weight) .. " ")
            else  
                io.write(tostring(cell.weight) .. " ")
            end
        end
        print("")
    end

    print("-------------------------------------------")

end




function flood_fill.copy(value)
    if type(value) ~= "table" then return value end
    local t = {}
    for i, v in pairs(value) do
      t[i] = flood_fill.copy(v)
    end
    return t
end
  

return flood_fill