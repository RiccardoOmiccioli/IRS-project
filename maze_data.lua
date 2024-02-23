local maze_data = {}

--[[ 
    data structure representing the maze
    visited true/false if visited by the robot
    priority is the discovery order
    parent is the parent cell
]]
function maze_data.new()
    for i=1,16 do
        table.insert(maze_data,{})
        for j=1,16 do
            table.insert(maze_data[i],{visited = 0, priority = 0, parent = {x=0,y=0}})
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
    maze_data[row][column]["parent"]["x"] = value[1]
    maze_data[row][column]["parent"]["y"] = value[2]
end

return maze_data