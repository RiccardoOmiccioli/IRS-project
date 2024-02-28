local maze_data = {}

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
    for i=1,16 do
        for j=1,16 do
            table.insert(maze_data,{row = i, column = j, visited = 0, weight = 0, parent = {row = 1, column = 1}, reachable_neighbours = {}})
        end
    end
    return maze_data
end

function maze_data.update_visited(row, column, value)
    maze_data[((row-1)*16)+column]["visited"] = value
end

function maze_data.update_weight(row, column, value)
    maze_data[((row-1)*16)+column]["weight"] = value
end

function maze_data.update_parent(row, column, value)
    maze_data[((row-1)*16)+column]["parent"]["row"] = value.row
    maze_data[((row-1)*16)+column]["parent"]["column"] = value.column
end

function maze_data.update_reachable_neighbours(row, column, value)
    table.insert(maze_data[((row-1)*16)+column]["reachable_neighbours"],value)
end

function maze_data.get_cell_info(row, column)
    return maze_data[((row-1)*16)+column]
end

return maze_data