MAZE_UNIT_LENGHT = 0.5
CELL_OFFSET = 0.25
MAX_MAZE_POSITION = 4.0

--[[
    This function receives a table with n rows where each row has m columns and should write an xml file that contains the walls of the maze
    A wall has the following format:
        <box id="wall1" size="0.5, 0.05, 0.2" movable="false">
            <body position="-3,75, 3.5, 0"  orientation="0,0,0" />
        </box>
    The id of the box is an unique identifier that starts with the word wall followed by an incremental number
    The size of the box is the size of the wall the first number is the width, the second is the lenght and the third is the height
    The height never changes but width and lenght can change to create lateral and vertical walls
    In the case of a vertical wall the width is 0.05 and the lenght is 0.5
    In the case of a lateral wall the width is 0.5 and the lenght is 0.05
    The position of the box is the position of the wall in the maze area considering that the max area is from -400 to +400 in both x and y directions
    A maze can be smaller than the total area available and the walls should always be a distance of 0.5 apart from each other
    The orientation of the box is always 0,0,0
    For each cell in the maze this function creates from 0 to 4 walls in the correct position according to the value of the cell
    The value of the cell is a number from 0 to 15 and it represents the walls that the cell has
    The walls are represented by the following numbers:
        1 -  a single wall to the left
        2 -  a single wall to the top
        3 -  a single wall to the right
        4 -  a single wall to the bottom
        5 -  a wall to the left and to the bottom
        6 -  a wall to the right and to the bottom
        7 -  a wall to the right and to the top
        8 -  a wall to the left and to the top
        9 -  a wall to the left and to the right
        10 - a wall to the top and to the bottom
        11 - a wall to the left, to the bottom and to the right
        12 - a wall to the top, to the right and to the bottom
        13 - a wall to the left, to the top and to the right
        14 - a wall to the top, to the left and to the bottom
        15 - no walls
        16 - all walls
]]
function write_maze_xml(maze)
    local file = io.open("maze.xml", "w")

    local wall_id = 1

    for i, row in ipairs(maze) do
        for j, column in ipairs(row) do
            -- create left wall if the cell has a wall to the left
            if column == 1 or column == 5 or column == 8 or column == 9 or column == 11 or  column == 13 or column == 14 or column == 16 then
                file:write("<box id=\"wall" .. wall_id .. "\" size=\"0.05, 0.5, 0.2\" movable=\"false\">\n")
                file:write("  <body position=\"" .. (j - 1) * MAZE_UNIT_LENGHT - MAX_MAZE_POSITION .. "," .. MAX_MAZE_POSITION - i * MAZE_UNIT_LENGHT + CELL_OFFSET .. " ,0\" orientation=\"0,0,0\" />\n")
                file:write("</box>\n")
                wall_id = wall_id + 1
            end
            -- create top wall if the cell has a wall to the top
            if column == 2 or column == 7 or  column == 8 or  column == 10 or  column == 12 or  column == 13 or  column == 14 or  column == 16 then
                file:write("<box id=\"wall" .. wall_id .. "\" size=\"0.5, 0.05, 0.2\" movable=\"false\">\n")
                file:write("  <body position=\"" .. (j - 1) * MAZE_UNIT_LENGHT - MAX_MAZE_POSITION + CELL_OFFSET .. "," .. MAX_MAZE_POSITION - i * MAZE_UNIT_LENGHT + MAZE_UNIT_LENGHT .. " ,0\" orientation=\"0,0,0\" />\n")
                file:write("</box>\n")
                wall_id = wall_id + 1
            end
            -- create right wall if the cell has a wall to the right
            if column == 3 or column == 6 or  column == 7 or  column == 9 or  column == 11 or  column == 12 or  column == 13 or  column == 16 then
                file:write("<box id=\"wall" .. wall_id .. "\" size=\"0.05, 0.5, 0.2\" movable=\"false\">\n")
                file:write("  <body position=\"" .. (j - 1) * MAZE_UNIT_LENGHT - MAX_MAZE_POSITION + MAZE_UNIT_LENGHT .. "," .. MAX_MAZE_POSITION - i * MAZE_UNIT_LENGHT + CELL_OFFSET .. " ,0\" orientation=\"0,0,0\" />\n")
                file:write("</box>\n")
                wall_id = wall_id + 1
            end
            -- create bottom wall if the cell has a wall to the bottom
            if column == 4 or column == 5 or  column == 6 or  column == 10 or  column == 11 or  column == 12 or  column == 14 or  column == 16 then
                file:write("<box id=\"wall" .. wall_id .. "\" size=\"0.5, 0.05, 0.2\" movable=\"false\">\n")
                file:write("  <body position=\"" .. (j - 1) * MAZE_UNIT_LENGHT - MAX_MAZE_POSITION + CELL_OFFSET .. "," .. MAX_MAZE_POSITION - i * MAZE_UNIT_LENGHT .. " ,0\" orientation=\"0,0,0\" />\n")
                file:write("</box>\n")
                wall_id = wall_id + 1
            end
        end
    end

    file:close()
end


maze_configuration_two_way = { 
    {  4,  4, 15,  4,  4,  3,  1, 15},
    {  2,  7,  9,  9,  8,  6, 11,  1},
    {  3,  5,  6,  5,  4,  2, 10,  4},
    { 15, 10,  7,  8,  7,  9, 14,  2},
    {  3, 13,  9,  5,  3,  5,  7,  1},
    {  3,  1,  3,  8,  3,  8,  6,  1},
    {  3,  9,  5,  6,  9,  1,  7,  1},
    {  3,  1,  2,  3,  1,  3,  1, 15},
}

maze_configuration_one_way = { 
    {  4,  4,  3,  9,  5,  3,  1, 15},
    {  2,  7,  1,  3,  8,  6, 11,  1},
    {  3,  5,  6,  5, 15,  2, 10,  4},
    { 15, 10,  7,  8,  3,  9, 14,  2},
    {  3, 13,  9,  5,  6,  5,  7,  1},
    {  3,  1,  3,  8,  7,  8,  6,  1},
    {  3,  9,  5,  6,  9,  1,  7,  1},
    {  3,  1,  2,  3,  1,  3,  1, 15},
}

test_configuration = {
    {  1, 15,  2, 15,  3, 15,  4},
    { 15, 15, 15, 15, 15, 15, 15},
    {  5, 15,  6, 15,  7, 15,  8},
    { 15, 15, 15, 15, 15, 15, 15},
    {  9, 15, 10, 15, 11, 15, 12},
    { 15, 15, 15, 15, 15, 15, 15},
    { 13, 15, 14, 15, 15, 15, 16},
}

write_maze_xml(maze_configuration_one_way)