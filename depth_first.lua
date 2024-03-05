maze_data = require "maze_data"
distance = require "distance"

local depth_first = {}
local maze
local parent = {row = 1, column = 1}

function depth_first.init()
    maze = maze_data.new()
    maze.update_weight(1, 1, 1) -- Init first cell weight
end

function depth_first.algorithm()
    robot_orientation = get_current_heading()
    current_row, current_col = get_current_row_and_column()
    
    if maze.get_cell_info(current_row, current_col).visited then
        log("visited")
    else
        log("not visited")
        maze.update_visited(current_row, current_col, true)
        maze.update_parent(current_row, current_col,{row = parent.row, column = parent.column})

        -- check walls for neighbours
        wall_distances = get_all_distances()
        for key,value in pairs(wall_distances) do
            if value == -2 or value > 16 then
                row_temp = 0
                column_temp = 0
                if robot_orientation == HEADING.NORTH then
                    if key == "front" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                        row_temp = current_row-1
                        column_temp = current_col
                    elseif key == "back" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                        row_temp = current_row+1
                        column_temp = current_col
                    elseif key == "right" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                        row_temp = current_row
                        column_temp = current_col+1
                    elseif key == "left" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                        row_temp = current_row
                        column_temp = current_col-1
                    end
                elseif robot_orientation == HEADING.EAST then
                    if key == "front" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                        row_temp = current_row
                        column_temp = current_col+1
                    elseif key == "back" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                        row_temp = current_row
                        column_temp = current_col-1
                    elseif key == "right" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                        row_temp = current_row+1
                        column_temp = current_col
                    elseif key == "left" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                        row_temp = current_row-1
                        column_temp = current_col
                    end
                elseif robot_orientation == HEADING.SOUTH then
                    if key == "front" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                        row_temp = current_row+1
                        column_temp = current_col
                    elseif key == "back" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                        row_temp = current_row-1
                        column_temp = current_col
                    elseif key == "right" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                        row_temp = current_row
                        column_temp = current_col-1
                    elseif key == "left" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                        row_temp = current_row
                        column_temp = current_col+1
                    end
                elseif robot_orientation == HEADING.WEST then
                    if key == "front" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col-1})
                        row_temp = current_row
                        column_temp = current_col-1
                    elseif key == "back" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row, column=current_col+1})
                        row_temp = current_row
                        column_temp = current_col+1
                    elseif key == "right" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row-1, column=current_col})
                        row_temp = current_row-1
                        column_temp = current_col
                    elseif key == "left" then
                        --maze.update_reachable_neighbours(current_row, current_col,{row=current_row+1, column=current_col})
                        row_temp = current_row+1
                        column_temp = current_col
                    end
                end

                -- Update neighbours weight
                if maze.get_cell_info(row_temp, column_temp).weight == 0 then
                    maze.update_weight(row_temp, column_temp, maze.get_cell_info(current_row, current_col).weight+1)
                end

                maze.update_reachable_neighbours(current_row, current_col, {row = row_temp, column = column_temp})
                --log("r:"..row_temp .. " c:" .. column_temp .. " | weight: ".. maze.get_cell_info(row_temp, column_temp).weight)
            end
        end

    end

    current_cell_info = maze.get_cell_info(current_row, current_col)

    -- pick a random reachable neighbour to move towards it
    if #current_cell_info.reachable_neighbours ~= 0 then
        num = math.random(1, #current_cell_info.reachable_neighbours)
    end
    neighbour = maze.get_cell_info(current_cell_info.reachable_neighbours[num].row,current_cell_info.reachable_neighbours[num].column)

    -- decision of movement
    if robot_orientation == HEADING.NORTH then
        if current_col - neighbour.column < 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
        elseif current_col - neighbour.column == 0 then
            if current_row - neighbour.row < 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
            elseif current_row - neighbour.row > 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
            end
        elseif current_col - neighbour.column > 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
        end
    elseif robot_orientation == HEADING.EAST then
        if current_row - neighbour.row < 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
        elseif current_row - neighbour.row == 0 then
            if current_col - neighbour.column > 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
            elseif current_col - neighbour.column < 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
            end 
        elseif current_row - neighbour.row > 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
        end
    elseif robot_orientation == HEADING.SOUTH then
        if current_col - neighbour.column < 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
        elseif current_col - neighbour.column == 0 then
            if current_row - neighbour.row < 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
            elseif current_row - neighbour.row > 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.RIGHT)
            end
        elseif current_col - neighbour.column > 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
        end
    elseif robot_orientation == HEADING.WEST then
        if current_row - neighbour.row < 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.LEFT)
        elseif current_row - neighbour.row == 0 then
            if current_col - neighbour.column > 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.FORWARD)
            elseif current_col - neighbour.column < 0 then
                move(BASIC_MOVE.STRAIGHT, MOVE_DIRECTION.BACKWARDS)
            end 
        elseif current_row - neighbour.row > 0 then
            move(COMPLEX_MOVE.TURN_AND_FORWARD, MOVE_DIRECTION.RIGHT)
        end
    end

    -- print for debug
    for i=1,#maze do
        if #maze[i].reachable_neighbours ~=0 then
            for j=1,#maze[i].reachable_neighbours do
                log(maze[i].row..","..maze[i].column..",w"..maze[i].weight.."->"..maze[i].reachable_neighbours[j].row .. "|" .. maze[i].reachable_neighbours[j].column)
            end
        end
    end
   
    parent.row = current_row
    parent.column = current_col
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