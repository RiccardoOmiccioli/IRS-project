maze_data = require "maze_data"
require "move"
require "position"

function find_path(start_cell, end_cell)
    local movements = {}

    if start_cell.row == end_cell.row and start_cell.column == end_cell.column then
        return movements
    end


end

function trace_path_to_start(cell, maze)
    local path = {}

    -- insert current cell in path
    if cell and cell.row and cell.column then
        table.insert(path, cell)
    end

    local function trace_recursively(current_cell)
        if not current_cell or not current_cell.row or not current_cell.column then
            return
        end
        table.insert(path, current_cell)
        if current_cell.parent.row and current_cell.parent.column then
            trace_recursively(maze.get_cell(current_cell.parent.row, current_cell.parent.column))
        end
    end

    -- if the cell has no parent, return the path
    if not cell.parent.row or not cell.parent.column then
        return path
    end

    trace_recursively(maze.get_cell(cell.parent.row, cell.parent.column))

    return path
end

--[[
    this function traces the path from the start cell to the target cell
    first it traces the path from the start cell to the start
    then it traces the path from the target cell to the start
    then it checks the two paths starting from the start and ignoring the cells in common between the two paths
    the first cell in common is the cell where the two paths meet
    the path from the start cell to the target cell is the path from the start cell to the meeting cell plus the path from the meeting cell to the target cell
]]
function trace_path_to_target(start_cell, target_cell, maze)
    local start_path = trace_path_to_start(start_cell, maze)
    local target_path = trace_path_to_start(target_cell, maze)

    local path = {}

    -- handle special cases
    if start_cell.row == 1 and start_cell.column == 1 then
        local function reverse(tab)
            for i = 1, #tab//2, 1 do
                tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
            end
            return tab
        end
        reverse(target_path)
        return target_path
    end
    if target_cell.row == 1 and target_cell.column == 1 then
        return start_path
    end
    if start_cell.row == target_cell.row and start_cell.column == target_cell.column then
        return path
    end

    -- find the meeting cell between the two paths
    local meeting_cell = nil
    for i, cell in ipairs(start_path) do
        for j, target in ipairs(target_path) do
            if cell.row == target.row and cell.column == target.column then
                meeting_cell = cell
                break
            end
        end
        if meeting_cell then
            break
        end
    end

    -- build the path from the start cell to the meeting cell
    for i, cell in ipairs(start_path) do
        if cell.row == meeting_cell.row and cell.column == meeting_cell.column then
            break
        end
        table.insert(path, cell)
    end
    --remove items from the target path until the meeting cell
    for i = #target_path, 1, -1 do
        if target_path[i].row == meeting_cell.row and target_path[i].column == meeting_cell.column then
            break
        end
        table.remove(target_path, i)
    end
    -- build the path from the meeting cell to the target cell
    for i = #target_path, 1, -1 do
        table.insert(path, target_path[i])
    end

    return path
end

--[[
    this function gets a path and calculates the moves to do to follow the path
    it returns an array of movements to do
    it needs to consider the current heading of the robot and following the path considering the heading of the robot that canges during the path
]]
function calculate_path_movements(path)
    local movements = {}

    if #path == 0 then
        return movements
    end

    local heading = get_current_heading()
    local current_row, current_col = get_current_row_and_column()

    -- remove the first cell from the path as it is the current cell
    table.remove(path, 1)

    for i = 1, #path do
        local cell = path[i]
        if cell.row == current_row then
            if cell.column > current_col then
                if heading == HEADING.NORTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.RIGHT})
                elseif heading == HEADING.EAST then
                    table.insert(movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD})
                elseif heading == HEADING.SOUTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.LEFT})
                elseif heading == HEADING.WEST then
                    table.insert(movements, {movement = COMPLEX_MOVE.FLIP_AND_FORWARD})
                end
                heading = HEADING.EAST
            elseif cell.column < current_col then
                if heading == HEADING.NORTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.LEFT})
                elseif heading == HEADING.EAST then
                    table.insert(movements, {movement = COMPLEX_MOVE.FLIP_AND_FORWARD})
                elseif heading == HEADING.SOUTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.RIGHT})
                elseif heading == HEADING.WEST then
                    table.insert(movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD})
                end
                heading = HEADING.WEST
            end
        elseif cell.column == current_col then
            if cell.row > current_row then
                if heading == HEADING.NORTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.FLIP_AND_FORWARD})
                elseif heading == HEADING.EAST then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.RIGHT})
                elseif heading == HEADING.SOUTH then
                    table.insert(movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD})
                elseif heading == HEADING.WEST then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.LEFT})
                end
                heading = HEADING.SOUTH
            elseif cell.row < current_row then
                if heading == HEADING.NORTH then
                    table.insert(movements, {movement = BASIC_MOVE.STRAIGHT, direction = MOVE_DIRECTION.FORWARD})
                elseif heading == HEADING.EAST then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.LEFT})
                elseif heading == HEADING.SOUTH then
                    table.insert(movements, {movement = COMPLEX_MOVE.FLIP_AND_FORWARD})
                elseif heading == HEADING.WEST then
                    table.insert(movements, {movement = COMPLEX_MOVE.TURN_AND_FORWARD, direction = MOVE_DIRECTION.RIGHT})
                end
                heading = HEADING.NORTH
            end
        end
        current_row = cell.row
        current_col = cell.column
    end

    for i, current_movement in ipairs(movements) do
        _, basic_move = table_contains(BASIC_MOVE, current_movement.movement)
        _, complex_move = table_contains(COMPLEX_MOVE, current_movement.movement)
        _, move_direction = table_contains(MOVE_DIRECTION, current_movement.direction)
        move_movement = basic_move or complex_move
        print(tostring(move_movement) .. " " .. tostring(move_direction))
    end

    return movements
end

function print_path(path)
    for i, cell in ipairs(path) do
        io.write(cell.row .. "-" .. cell.column .. "  ")
    end
    io.write("\n")
end