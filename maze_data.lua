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
    for i=MIN_ROW_COL_POS,MAX_ROW_COL_POS do
        for j=MIN_ROW_COL_POS,MAX_ROW_COL_POS do
            table.insert(maze_data,{row = i, column = j, visited = 0, weight = 0, parent = {row = 1, column = 1}, reachable_neighbours = {}})
        end
    end
    return maze_data
end

function maze_data.update_visited(row, column, value)
    maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["visited"] = value
end

function maze_data.update_weight(row, column, value)
    maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["weight"] = value
end

function maze_data.update_parent(row, column, value)
    maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["parent"]["row"] = value.row
    maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["parent"]["column"] = value.column
end

function maze_data.update_reachable_neighbours(row, column, value)
    if value.row >= MIN_ROW_COL_POS and value.row <= MAX_ROW_COL_POS 
    and value.column >= MIN_ROW_COL_POS and value.column <= MAX_ROW_COL_POS then
        if #maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["reachable_neighbours"] == 0 then
            table.insert(maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["reachable_neighbours"], value)
        else
            is_present = false
            for _,v in pairs(maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["reachable_neighbours"]) do
                if v.row == value.row and v.column == value.column then
                    is_present = true
                    break
                end
            end
            if not(is_present) then table.insert(maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]["reachable_neighbours"], value) end
        end
    end
end

function maze_data.get_cell_info(row, column)
    return maze_data[((row-MIN_ROW_COL_POS)*MAX_ROW_COL_POS)+column]
end

return maze_data