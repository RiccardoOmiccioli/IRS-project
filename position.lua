require "move"

HEADING = { NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4 }
MAX_MAZE_POSITION = 400

current_heading = HEADING.EAST
current_position = { x = -375, y = 375 }

-- This function receives a BASIC_MOVE, MOVE_DIRECTION and a delta and updated the position based on the current heading and position
function update_position(basic_move, direction, delta)
    if not delta then delta = MAZE_UNIT_LENGHT end
    if basic_move == BASIC_MOVE.STRAIGHT then
        if delta >= MAZE_UNIT_LENGHT / 2 then -- consider only movements greater than half a cell to exlude calibration movements
            if direction == MOVE_DIRECTION.FORWARD then
                if current_heading == HEADING.NORTH then
                    current_position.y = current_position.y + delta
                elseif current_heading == HEADING.EAST then
                    current_position.x = current_position.x + delta
                elseif current_heading == HEADING.SOUTH then
                    current_position.y = current_position.y - delta
                elseif current_heading == HEADING.WEST then
                    current_position.x = current_position.x - delta
                end
            elseif direction == MOVE_DIRECTION.BACKWARDS then
                if current_heading == HEADING.NORTH then
                    current_position.y = current_position.y - delta
                elseif current_heading == HEADING.EAST then
                    current_position.x = current_position.x - delta
                elseif current_heading == HEADING.SOUTH then
                    current_position.y = current_position.y + delta
                elseif current_heading == HEADING.WEST then
                    current_position.x = current_position.x + delta
                end
            end
        end
    elseif basic_move == BASIC_MOVE.TURN then
        if direction == MOVE_DIRECTION.LEFT then
            if current_heading == HEADING.NORTH then
                current_heading = HEADING.WEST
            elseif current_heading == HEADING.EAST then
                current_heading = HEADING.NORTH
            elseif current_heading == HEADING.SOUTH then
                current_heading = HEADING.EAST
            elseif current_heading == HEADING.WEST then
                current_heading = HEADING.SOUTH
            end
        elseif direction == MOVE_DIRECTION.RIGHT then
            if current_heading == HEADING.NORTH then
                current_heading = HEADING.EAST
            elseif current_heading == HEADING.EAST then
                current_heading = HEADING.SOUTH
            elseif current_heading == HEADING.SOUTH then
                current_heading = HEADING.WEST
            elseif current_heading == HEADING.WEST then
                current_heading = HEADING.NORTH
            end
        end
    end
end

--[[
    This function returns the current row and column of the robot considering that there are a total of 16 rows and 16 columns and that each cell is MAZE_UNIT_LENGHT x MAZE_UNIT_LENGHT
    The allowed position goes from -MAX_MAZE_POSITION to MAX_MAZE_POSITION in both x and y
]]
function get_current_row_and_column()
    return math.abs(math.floor((current_position.y - MAX_MAZE_POSITION) / MAZE_UNIT_LENGHT)), math.abs(math.floor((current_position.x + MAX_MAZE_POSITION) / MAZE_UNIT_LENGHT)) + 1
end

-- This function returns the current heading of the robot
function get_current_heading()
    return current_heading
end

-- This function returns the current position of the robot
function get_current_position()
    return current_position.x, current_position.y
end