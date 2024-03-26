full_1 = {
    --          1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
    --[[ 1]] { 14,  2,  2, 10,  2, 10,  2, 10,  2,  2,  2,  2,  2,  2,  2,  7},
    --[[ 2]] {  8,  6,  9, 14, 15, 12,  1,  7,  9,  9,  9,  9,  9,  9,  9,  9},
    --[[ 3]] {  5,  7,  9, 14,  3, 14,  3, 11,  9, 11, 11,  9, 14,  3, 14,  3},
    --[[ 4]] { 13,  1,  4, 10,  4, 10,  4, 10, 15, 10,  2, 15, 10,  4,  2,  6},
    --[[ 5]] {  5,  4, 10, 10, 10, 10, 10,  7,  5,  2,  6,  1, 12, 13,  5,  7},
    --[[ 6]] { 14,  2, 10, 10, 10, 10, 10,  3, 13,  5,  2,  6,  8,  3,  8,  6},
    --[[ 7]] { 14,  3,  8,  7,  8,  2, 12, 11,  5,  2,  6,  8,  6,  9,  5,  7},
    --[[ 8]] {  8,  3,  9,  5,  6,  5,  7,  8,  7, 11,  8,  6, 13,  5, 10,  3},
    --[[ 9]] {  9,  9,  1, 10, 10, 12,  9,  5,  4,  2,  6,  8,  6, 13,  8,  6},
    --[[10]] {  9,  9,  1,  2, 12,  8,  4, 10,  2,  4,  2,  6,  8,  4,  3, 13},
    --[[11]] {  9,  5,  6,  9, 13,  9, 13, 14, 15,  2,  6,  8,  4,  2,  6,  9},
    --[[12]] {  1, 10,  2,  4, 15,  3,  1,  2,  6,  1,  7,  9, 14, 15, 12,  9},
    --[[13]] {  9,  8,  6, 13,  9,  9,  9,  1,  7,  9,  9,  9, 14, 15, 12,  9},
    --[[14]] {  9,  5,  2, 15,  3,  1,  4,  3,  5, 15,  4, 15,  7,  9, 14,  3},
    --[[15]] {  9,  8,  6,  9,  1, 15,  2,  4, 10,  4,  2,  3,  1,  4, 10,  3},
    --[[16]] {  5,  4, 10,  4,  6, 11,  5, 10, 10, 10,  6,  5,  4, 10, 10,  6}
    }

    half_1 = {
        { 14, 10,  2, 13, 10,  7,  8,  7},
        {  8,  7,  9,  9,  8,  6, 11,  9},
        {  9,  5,  6,  5,  4,  2, 10,  6},
        {  1, 10,  7,  8,  7,  9, 14,  7},
        {  9, 13,  9,  5,  3,  5,  7,  9},
        {  9,  1,  3,  8,  3,  8,  6,  9},
        {  9,  9,  5,  6,  9,  1,  7,  9},
        { 11,  5, 10,  6,  5,  6,  5,  6}
    }

    half_2 = {
        { 14, 10,  7, 13, 14,  7,  8,  7},
        {  8,  7,  1,  3,  8,  6, 11,  9},
        {  9,  5,  6,  5, 15,  2, 10,  6},
        {  1, 10,  7,  8,  3,  9, 14,  7},
        {  9, 13,  9,  5,  6,  5,  7,  9},
        {  9,  1,  3,  8,  7,  8,  6,  9},
        {  9,  9,  5,  6,  9,  1,  7,  9},
        { 11,  5, 10,  6,  5,  6,  5,  6}
    }

    -- Define constants
    local MAZE_UNIT_LENGTH = 0.5
    local CELL_OFFSET = 0.25
    local MAX_MAZE_POSITION = 4.0

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
    function generate_maze_xml(maze_configuration)
        local new_maze_lines = {}
        local wall_id = 1
        for i, row in ipairs(maze_configuration) do
            for j, column in ipairs(row) do
                -- create left wall if the cell has a wall to the left
                if column == 1 or column == 5 or column == 8 or column == 9 or column == 11 or  column == 13 or column == 14 or column == 16 then
                    table.insert(new_maze_lines, string.format("<box id=\"wall%d\" size=\"0.05, 0.5, 0.2\" movable=\"false\">", wall_id))
                    table.insert(new_maze_lines, string.format("  <body position=\"%.2f,%.2f,0\" orientation=\"0,0,0\" />", (j - 1) * MAZE_UNIT_LENGTH - MAX_MAZE_POSITION, MAX_MAZE_POSITION - i * MAZE_UNIT_LENGTH + CELL_OFFSET))
                    table.insert(new_maze_lines, "</box>")
                    wall_id = wall_id + 1
                end
                -- create top wall if the cell has a wall to the top
                if column == 2 or column == 7 or  column == 8 or  column == 10 or  column == 12 or  column == 13 or  column == 14 or  column == 16 then
                    table.insert(new_maze_lines, string.format("<box id=\"wall%d\" size=\"0.5, 0.05, 0.2\" movable=\"false\">", wall_id))
                    table.insert(new_maze_lines, string.format("  <body position=\"%.2f,%.2f,0\" orientation=\"0,0,0\" />", (j - 1) * MAZE_UNIT_LENGTH - MAX_MAZE_POSITION + CELL_OFFSET, MAX_MAZE_POSITION - i * MAZE_UNIT_LENGTH + MAZE_UNIT_LENGTH))
                    table.insert(new_maze_lines, "</box>")
                    wall_id = wall_id + 1
                end
                -- create right wall if the cell has a wall to the right
                if column == 3 or column == 6 or  column == 7 or  column == 9 or  column == 11 or  column == 12 or  column == 13 or  column == 16 then
                    table.insert(new_maze_lines, string.format("<box id=\"wall%d\" size=\"0.05, 0.5, 0.2\" movable=\"false\">", wall_id))
                    table.insert(new_maze_lines, string.format("  <body position=\"%.2f,%.2f,0\" orientation=\"0,0,0\" />", (j - 1) * MAZE_UNIT_LENGTH - MAX_MAZE_POSITION + MAZE_UNIT_LENGTH, MAX_MAZE_POSITION - i * MAZE_UNIT_LENGTH + CELL_OFFSET))
                    table.insert(new_maze_lines, "</box>")
                    wall_id = wall_id + 1
                end
                -- create bottom wall if the cell has a wall to the bottom
                if column == 4 or column == 5 or  column == 6 or  column == 10 or  column == 11 or  column == 12 or  column == 14 or  column == 16 then
                    table.insert(new_maze_lines, string.format("<box id=\"wall%d\" size=\"0.5, 0.05, 0.2\" movable=\"false\">", wall_id))
                    table.insert(new_maze_lines, string.format("  <body position=\"%.2f,%.2f,0\" orientation=\"0,0,0\" />", (j - 1) * MAZE_UNIT_LENGTH - MAX_MAZE_POSITION + CELL_OFFSET, MAX_MAZE_POSITION - i * MAZE_UNIT_LENGTH))
                    table.insert(new_maze_lines, "</box>")
                    wall_id = wall_id + 1
                end
            end
        end
        return new_maze_lines
    end

    -- Define maze configurations
    local maze_configurations = {
        half = {
            half_1,
            half_2,
        },
        full = {
            full_1,
        },
    }

    -- Define background images
    local background_images = {
        half = "maze_half_background.png",
        full = "maze_full_background.png",
    }

    -- Read the content of the argos file
    local file_name = "micromouse.argos"
    local xml_content = io.open(file_name, "r"):read("*all")

    -- Determine maze type from command line argument or default to "half"
    local maze_type = arg[1] or "half"
    -- Determine maze bymber from command line argument or default to 1
    local maze_number = tonumber(arg[2]) or 1

    -- Get maze and background image for the chosen maze type and number
    local selected_maze = maze_configurations[maze_type][maze_number]
    local background_image = background_images[maze_type]

    -- Generate new maze lines
    local new_maze_lines = generate_maze_xml(selected_maze)

    -- Update XML content with new maze lines and background image
    xml_content = xml_content:gsub("<!%-%-maze background start%-%->.-<!%-%-maze background end%-%->", "<!--maze background start-->\n<floor id=\"f\" source=\"image\" path=\"" .. background_image .. "\"/>\n<!--maze background end-->")
    xml_content = xml_content:gsub("<!%-%-maze start%-%->.-<!%-%-maze end%-%->", "<!--maze start-->\n" .. table.concat(new_maze_lines, "\n") .. "\n<!--maze end-->")

    -- Write updated argos file
    io.open(file_name, "w"):write(xml_content)
