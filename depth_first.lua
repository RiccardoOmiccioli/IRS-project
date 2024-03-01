maze_data = require "maze_data"
distance = require "distance"

cardinal_points = {NORTH=1, SOUTH=2, EAST=3, WEST=4}
local depth_first = {}
local maze
local robot_orientation = cardinal_points.EAST
local parent = {row=1,column=1}

function depth_first.init()
    maze = maze_data.new()
end

function depth_first.algorithm()
    current_row, current_col = get_current_row_and_column()
    current_cell_info = maze.get_cell_info(current_row, current_col)

    maze.update_visited(current_row, current_col, 1)
    maze.update_parent(current_row, current_col,{row = parent.row, column = parent.column})
    
    -- check walls for neighbours
    wall_distances = get_all_distances() 
    for key,value in pairs(wall_distances) do
        if value == -2 or value > 16 then
            if robot_orientation == cardinal_points.NORTH then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                end
            elseif robot_orientation == cardinal_points.EAST then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                end
            elseif robot_orientation == cardinal_points.SOUTH then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                end
            elseif robot_orientation == cardinal_points.WEST then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                end
            end
        
            -- update weight
        end
    end

    for j=1,#maze do
        if #maze[j].reachable_neighbours ~=0 then
            for i=1,#maze[j].reachable_neighbours do
                log(maze[j].row..","..maze[j].column.."->"..maze[j].reachable_neighbours[i].row .. "|" .. maze[j].reachable_neighbours[i].column)
            end
        end
    end
    -- decide movement
    -- update robot_orientation
   
    parent.row = current_row
    parent.column = current_col

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