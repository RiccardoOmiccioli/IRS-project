local flood_fill = {}

local maze
local maze_flood
local flood_queue
local parent = {row = nil, column = nil}
local path_to_destinaton
local destination = nil

function flood_fill.init()
    flood_queue = queue.new()
    maze = maze_data.new()
    flood_fill.set_maze_weight()
    flood_fill.print_weight()
end

function flood_fill.execute()
    current_row, current_col = position.get_current_row_and_column()

    if not maze.get_cell(current_row, current_col).visited then

        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col, {row = parent.row, column = parent.column})

        check_walls_update_neighbours(maze, current_row, current_col)
    end

    update_parent_not_visited_reachable_neighbours(maze, current_row, current_col)

    local current_cell = maze.get_cell(current_row, current_col)

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

    -- Print debug
    --flood_fill.print_weight()
    --print("Current cell: r".. current_cell.row .. "| c"..current_cell.column .. " | weight:" .. current_cell.weight .. " | visited:" .. tostring(current_cell.visited))
    --print("Next cell: r".. destination.row .. "| c"..destination.column .. " | weight:" .. destination.weight .. " | visited:" .. tostring(destination.visited))

    calculate_path_and_move(maze, current_row, current_col, destination)

    --maze.print_maze(maze, trace_path_to_target(maze.get_cell(current_row, current_col), destination, maze))

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
    --print("FLOOD FILL !")

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

-- DEMO of maze exploration
--[[ function flood_fill.maze_exploration(current_cell)
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

end ]]

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
    else
        reach_table = flood_fill.not_visited_cell_neighbours(cell)
    end
    return reach_table
end

-- Get a table of neighbours of a not visited cell
function flood_fill.not_visited_cell_neighbours(cell)
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

-- Get a table of neighbours that prioritize not_visited_and_lighter_neighbours and if not possible get the lighter_neighbours
function flood_fill.choose_neighbours(current_cell)
    local tmp = flood_fill.not_visited_and_lighter_neighbours(current_cell)
    if #tmp > 0 then
        return tmp
    else
        return flood_fill.lighter_neighbours(current_cell)
    end
end

-- Get a table of neighbour of the current cell with lower weight and not visited
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

-- Get a table of neighbour of the current cell with lower weight
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

-- Get a table of reachable neighbours cells
function flood_fill.reachable_neighbours_cells(reachable_neighbours)
    local all_reachable_neighbours = {}
    for _, neighbour in ipairs(reachable_neighbours) do
        local n = maze.get_cell(neighbour.row, neighbour.column)
        table.insert(all_reachable_neighbours, n)
    end
    return all_reachable_neighbours
end

-- Set the initial maze cells weight
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

-- Set a new destinetion for further maze exploration
function flood_fill.set_new_destination(row, column)
    for i, cell in ipairs(maze) do
        cell.weight = flood_fill.manhattan_distance(row, column, cell.row, cell.column)
    end
end

-- Calculate the manhattan distance of two points
-- point1 at (x1,y1) and point2 at (x2,y2), it is |x1 - x2| + |y1 - y2|
function flood_fill.manhattan_distance(first_row, first_column, second_row, second_column)
    return math.abs(second_row - first_row) + math.abs(second_column - first_column)
end

-- Debug print
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

function flood_fill.get_destination()
    return destination
end

function flood_fill.get_maze_data()
    return maze
end

return flood_fill
