local maze_data = {}
MIN_ROW_COL_POS = 1
MAX_ROW_COL_POS = 16

--[[
    data structure representing the maze
    row of the cell
    column of the cell
    visited true/false if visited by the robot
    weight is the importance of the cell
    parent is row and column of the parent cell
    reachable_neighbours neighbour cells reachable, no walls between
]]
function maze_data.new()
    for i = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
        for j = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
            table.insert(maze_data, {row = i, column = j, visited = false, weight = 0, parent = {row = nil, column = nil}, reachable_neighbours = {}})
        end
    end
    return maze_data
end

function maze_data.update_visited(row, column, value)
    maze_data.get_cell(row, column).visited = value
end

function maze_data.update_weight(row, column, value)
    if maze_data.get_cell(row, column).weight == 0 then
        maze_data.get_cell(row, column).weight = value
    end
end

function maze_data.update_parent(row, column, value)
    local cell = maze_data.get_cell(row, column)
    if not cell.parent.row and not cell.parent.column then
        cell.parent.row = value.row
        cell.parent.column = value.column
    end
end

-- Updates the reachable neighbours list of the cell at the specified row and column
function maze_data.update_reachable_neighbours(row, column, neighbour)
    -- Check if the neighbour is within the maze boundaries
    if neighbour.row >= MIN_ROW_COL_POS and neighbour.row <= MAX_ROW_COL_POS and
       neighbour.column >= MIN_ROW_COL_POS and neighbour.column <= MAX_ROW_COL_POS then
        local cell = maze_data.get_cell(row, column)

        -- Check if the neighbour is not already in the reachable neighbours list
        local is_present = false
        for _, v in ipairs(cell.reachable_neighbours) do
            if v.row == neighbour.row and v.column == neighbour.column then
                is_present = true
                break
            end
        end

        -- If the neighbour is not present, insert it into the reachable neighbours list
        if not is_present then
            table.insert(cell.reachable_neighbours, neighbour)
        end
    end
end

-- Returns the cell at the specified row and column
function maze_data.get_cell(row, column)
    return maze_data[((row - MIN_ROW_COL_POS) * MAX_ROW_COL_POS) + column]
end

function maze_data.print_cell(cell)
    print("cell: " .. cell.row .. "-" .. cell.column .. " visited: " .. tostring(cell.visited) .. " weight: " .. cell.weight .. " parent: " .. tostring(cell.parent.row) .. "-" .. tostring(cell.parent.column) .. " reachable_neighbours: " .. tostring(#cell.reachable_neighbours))
end

--[[
    Prints all the cells in the maze 16 at a time putting a new line after each 16 cells
    If a cell is visited prints ■ otherwise □
    If a cell is the current cell prints ◉
    If a cell has a parent prints ▥
    If a path is provided prints ◎ in the last cell of the path and ◍ in every other cell of the path
]]
function maze_data.print_maze(maze, path)
    if not path then
        path = {}
    end
    local current_row, current_col = get_current_row_and_column()
    local current_heading = get_current_heading()
    for i = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
        for j = MIN_ROW_COL_POS, MAX_ROW_COL_POS do
            local cell = maze.get_cell(i, j)
            if cell.row == current_row and cell.column == current_col then
                if current_heading == HEADING.NORTH then
                    io.write("◒ ")
                elseif current_heading == HEADING.EAST then
                    io.write("◐ ")
                elseif current_heading == HEADING.SOUTH then
                    io.write("◓ ")
                elseif current_heading == HEADING.WEST then
                    io.write("◑ ")
                end
                -- io.write("◉ ")
            elseif cell.row == path[#path].row and cell.column == path[#path].column then
                io.write("◎ ")
            elseif table_contains(path, cell) then
                io.write("● ")
            else
                if cell.visited then
                    io.write("◼ ")
                elseif not cell.visited then
                    if cell and cell.parent and cell.parent.row and cell.parent.column then
                        io.write("▥ ")
                    else
                        io.write("◻ ")
                    end
                end
            end
        end
        print("")
    end
end


return maze_data