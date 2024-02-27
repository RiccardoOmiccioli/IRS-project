Queue = require "Queue"
maze_data = require "maze_data"

local depth_first = {}
local coda
local maze 

function depth_first.init()
    coda = Queue.new()
    maze = maze_data.new()
    coda:enqueue({row=1,column=1}) -- enqueue the root
end

function depth_first.algorithm()

    if not(coda:isEmpty()) then
        dequeue = coda:dequeue()
        current_cell = maze.get_cell_info(dequeue.row, dequeue.column)
        log(current_cell.visited .. "|" .. current_cell.weight)

        maze.update_visited(current_cell.row, current_cell.column, 1)
        -- check walls
        -- decide reachable neighbours + update them in maze
        -- for each reachable neighbour update parent
        -- add each reachable neighbour to the queue
    end
end

return depth_first