maze_data = require "maze_data"
distance = require "distance"

local depth_first = {}
local maze
local parent = {row = 1, column = 1}
local cell_weight = 1

function depth_first.init()
    maze = maze_data.new()
end

function depth_first.algorithm()
    robot_orientation = get_current_heading()
    current_row, current_col = get_current_row_and_column()

    maze.update_visited(current_row, current_col, 1)
    maze.update_parent(current_row, current_col,{row = parent.row, column = parent.column})
    maze.update_weight(current_row, current_col, cell_weight)

    current_cell_info = maze.get_cell_info(current_row, current_col)
    --log(cell_weight.." present,added ".. current_cell_info.weight)
    
    -- check walls for neighbours
    wall_distances = get_all_distances() 
    for key,value in pairs(wall_distances) do
        if value == -2 or value > 16 then
            if robot_orientation == HEADING.NORTH then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                end
            elseif robot_orientation == HEADING.EAST then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                end
            elseif robot_orientation == HEADING.SOUTH then
                if key == "front" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                elseif key == "back" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                elseif key == "right" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                elseif key == "left" then
                    maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                end
            elseif robot_orientation == HEADING.WEST then
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
        end
    end

    for i=1,#maze do
        if #maze[i].reachable_neighbours ~=0 then
            for j=1,#maze[i].reachable_neighbours do
                log(maze[i].row..","..maze[i].column..","..maze[i].weight.."->"..maze[i].reachable_neighbours[j].row .. "|" .. maze[i].reachable_neighbours[j].column)
            end
        end
    end
    -- decide movement
   
    parent.row = current_row
    parent.column = current_col
    cell_weight = cell_weight + 1
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