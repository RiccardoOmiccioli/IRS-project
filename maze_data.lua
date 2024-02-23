local maze_data = {}

--[[ 
    data structure representing the maze
    id for each cell is row|column
    visited true/false if visited by the robot
    priority is the discovery order
    parent is the id of parent cell
]]
function maze_data.new()
    for i=1,16 do
        table.insert(maze_data,{})
        for j=1,16 do
            table.insert(maze_data[i],{id = i.."|"..j, visited = 0, priority = 0, parent = "1|1"})
        end
    end

    return maze_data
end

function maze_data.update_visited(row, column, value)
    maze_data[row][column]["visited"] = value
end

function maze_data.update_priority(row, column, value)
    maze_data[row][column]["priority"] = value
end

function maze_data.update_parent(row, column, value)
    maze_data[row][column]["parent"] = value
end

return maze_data