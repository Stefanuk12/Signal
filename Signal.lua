-- // Services
local RunService = game:GetService("RunService")

-- // Vars
local Heartbeat = RunService.Heartbeat

-- // Signal Class
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

-- // Connection Class
local Connection = {}
Connection.__index = Connection

-- // Connection Constructor
function Connection.new(Signal, Callback)
    -- // Check Signal
    local typeofSignal = typeof(Signal)
    assert(typeofSignal == "table" and Signal.ClassName == "Signal", "bad argument #1 to 'new' (Signal expected, got " .. typeofSignal .. ")")

    -- // Check callback
    local typeofCallback = typeof(Callback)
    assert(typeofCallback == "function", "bad argument #2 for 'new' (function expected, got " .. typeofCallback .. ")")

    -- // Create
    local self = setmetatable({}, Connection)

    -- // Set properties
    self.Function = Callback
    self.State = true
    self.Signal = Signal

    -- // Return new class
    return self
end

-- // Enable a conneciton
function Connection.Enable(self)
    self.State = true
end

-- // Disable a connection
function Connection.Disable(self)
    self.State = false
end

-- // Disconnect a connection
function Connection.Disconnect(self)
    -- // Vars
    local Connections = self.Signal.Connections
    local selfInTable = table.find(Connections, self)

    -- // Remove
    table.remove(Connections, selfInTable)
end
Connection.disconnect = Connection.Disconnect

-- // Signal Constructor
function Signal.new(Name)
    -- // Check Name
    local typeofName = typeof(Name)
    assert(typeofName == "string", "bad argument #1 for 'new' (string expected, got " .. typeofName .. ")")

    -- // Create
    local self = setmetatable({}, Signal)

    -- // Set properties
    self.Connections = {}

    -- // Return new class
	return self
end

-- // Connect to a signal
function Signal.Connect(self, Callback)
    -- // Check callback
    local typeofCallback = typeof(Callback)
    assert(typeofCallback == "function", "bad argument #1 for 'Connect' (function expected, got " .. typeofCallback .. ")")

    -- // Create Connection Object
    local connection = Connection.new(self, Callback)

    -- // Add to connections
    table.insert(self.Connections, connection)

    -- // Return
    return connection
end
Signal.connect = Signal.Connect

-- // Fire a signal
function Signal.Fire(self, ...)
    -- // Loop through connections
    for _, connection in ipairs(self.Connections) do
        -- // See whether it can be fired
        if not (connection.State) then
            continue
        end

        -- // Fire
        coroutine.wrap(connection.Function)(...)
    end
end
Signal.fire = Signal.Fire

-- // Wait for a signal
function Signal.Wait(self, Timeout)
    -- // Vars
    Timeout = (Timeout and Timeout * 1000 or 9e9) -- // Convert into ms
    local returnVal = {}
    local Fired = false

    -- // Connect
    local connection = self:Connect(function(...)
        returnVal = {...}
        Fired = true
    end)

    -- // Wait until fired
    local timeElapsed = tick()
    while (true) do
        -- // Wait
        Heartbeat:Wait()

        -- // Set time elapsed
        timeElapsed = tick() - timeElapsed

        -- // See if fired or timed out
        if not (Fired or timeElapsed > Timeout) then
            continue
        end

        -- // Break out of the loop
        break
    end

    -- // Disconnect
    connection:Disconnect()

    -- // Return
    return unpack(returnVal)
end
Signal.wait = Signal.Wait

-- // Destroy a signal
function Signal.Destroy(self)
    self = nil
end
Signal.destroy = Signal.destroy

-- //
return Signal