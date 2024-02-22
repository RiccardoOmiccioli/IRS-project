-- Define the Queue class
local Queue = {}
Queue.__index = Queue

-- Constructor function to create a new queue
function Queue.new()
    local self = setmetatable({}, Queue)
    self._data = {}
    return self
end

-- Method to enqueue an element into the queue
function Queue:enqueue(value)
    table.insert(self._data, value)
end

-- Method to dequeue an element from the queue
function Queue:dequeue()
    if self:isEmpty() then
        return nil
    else
        return table.remove(self._data, 1)
    end
end

-- Method to check if the queue is empty
function Queue:isEmpty()
    return #self._data == 0
end

-- Method to get the size of the queue
function Queue:size()
    return #self._data
end

-- Method to peek at the front element of the queue without removing it
function Queue:peek()
    if self:isEmpty() then
        return nil
    else
        return self._data[1]
    end
end

return Queue