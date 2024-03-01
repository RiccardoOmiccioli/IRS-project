maze_data = require "maze_data"
distance = require "distance"

cardinal_points = {NORTH, SOUTH, EAST, WEST}
local depth_first = {}
local maze
local robot_orientation = cardinal_points.EAST
local parent = {row=1,column=1}

function depth_first.init()
    maze = maze_data.new()
end

function depth_first.algorithm()
    -- get current_cell
    current_cell_info = maze.get_cell_info(1, 1) -- to do: add current_cell.row, current_cell.column

    maze.update_visited(current_cell_info.row, current_cell_info.column, 1)
    maze.update_parent(current_cell_info.row, current_cell_info.column,{row = parent.row, column = parent.column})
    
    -- check walls for neighbours
    wall_distances = get_all_distances() 
    for key,value in pairs(wall_distances) do
        if value == -2 or value > 20 then
            -- decide reachable neighbours + update them in maze
            --[[ robot_orientation and key
            EAST 
                front => (1,1) {current_row, current_column+1} (1,2) 
                -- maze.update_reachable_neighbours(1,1,{row=1, column =2})
                -- weight = 1
                back
                right
                left
            OVEST
                front => (1,5) {current_row, current_column-1} (1,4)
                -- maze.update_reachable_neighbours(1,5,{row=1, column =4})
                back
                right
                left ]]
        end
    end

    -- decide movement
    -- update robot_orientation
   
    parent.row = current_cell_info.row
    parent.column = current_cell_info.column

    -- end
end

function depth_first.sort()
    temp_table = maze
    table.sort(temp_table, function(a,b) return a.weight < b.weight end)
    return temp_table
end

function depth_first.visited_filter()
    temp_table = {}
    for i=1,#maze do
        if maze[i]["visited"] == 1 then
            table.insert(temp_table, maze[i])
        end
    end
    return temp_table
end

return depth_first