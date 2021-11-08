--[[
    Methods:

    GameFrmae.loadLibrary(name: string) -> Library - Requires a module from the library folder.

    GameFrame.loadFunctions(name: string) -> Function - Requires a module from the function folder. The return value of the module must be a function.

    GameFrame.getManager(name: string) -> Manager - Requires a manager, recommended to not use this unless there's a valid reason.

    GameFrame.require(name: string) -> Module - Requires any module by name that is not associated with essential gameframe element 
                                                such as Library and Manager modules. Plese use the intended methods when requiring such modules.

    GameFrame.createManager(parameters: table) -> table - Creates a manager which will be the main source of game functionality.
    GameFrame.loadManagersInDirective(directive: Folder) -> void - Loads every manager in the scope of a specified directive. 
                                                                    This also takes into account descendants
    GameFrame.isLibrary(lib: Library) -> boolean - Returns if the given parameter is a library or not.
    GameFrame.isFunction(func: Function) -> boolean - Returns if the given parameter is a function or not.
    GameFrame.isManager(manager: Manager) -> boolean - Returns if the given parameter is a manager or not.
    GameFrame.isManagerLoaded(manager: Manager) -> boolean - Returns if a certain manager has been loaded.
    GameFrame.waitForManagerLoaded(manager: Manager) -> void - Waits until the given manager is completely loaded.
    
    GameFrame.isLocalManagersLoaded() -> boolean - Returns if all of the lcoal managers have been loaded.
    GameFrame.isAllManagersLoaded -> boolean - Returns if every manager in the game has been loaded.
                                                This of course excludes managers on the client if the module is running on the server and vice versa.

    GameFrame.waitForLocalManagersLoaded() -> boolean - Waits until all the local managers have been loaded
    GameFrame.waitForLocalManagersCallback -> function - The same as the waitForLocalManagerLoaded method except this accepts a callback 
                                                           This can be useful for much cleaner code for when a certain manager gets loaded, 
                                                            The function will be called.
    GameFrame.waitForAllManagersLoaded() -> boolean - Waits until every manager has been loaded
    GameFrame.waitForAllManagersCallback() -> function - The same as waitForLocalManagersCallback except it takes all managers.                                                                
]]
local RunService = game:GetService("RunService")

local GameFrame = {}

local libraries = {}
local functions = {}
local managers = {}
local moduleCache = {}

local localGameFrameFolder

local isServer = RunService:IsServer()

local function addDirectiveToModuleCache(directive)
    for index, object in next, directive:GetDescendants() do 
        if object:IsA("ModuleScript") then 
            if object.Parent == localGameFrameFolder.Functions 
                or object.Parent == localGameFrameFolder.Libraries 
                or object.Parent == localGameFrameFolder.Managers 
                or object.Parent == script.Functions
                or object.Parent == script.Libraries 
                or object.Parent == script.Managers then
                continue 
            end
            moduleCache[object.Name] = object
        end
    end
end

local function invalidManagerRequirements(name: string)
    return warn(name, "Has invalid manager requirements")
end

local function runManager(manager)
    if manager.init then 
        task.spawn(function()
            manager:init()
        end)
    end
    manager.isLoaded = true
end

local function runManagerPost(manager)
    if manager.postinit then
        task.spawn(function()
            manager:postinit()
        end)
    end
end

localGameFrameFolder = if isServer then game.ServerScriptService.GameFrame 
else game.StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("GameFrame")
addDirectiveToModuleCache(game.ReplicatedStorage)
addDirectiveToModuleCache(localGameFrameFolder.Parent)

function GameFrame.isLibrary(library: table)
    if library.isLibrary then return true else return false end
end

function GameFrame.require(moduleName: string)
    local module = moduleCache[moduleName]
    assert(module, moduleName.." Not in module cache")
    return require(module)
end

function GameFrame.loadLibrary(libraryName: string)
    local library: ModuleScript? = if libraries[libraryName] then libraries[libraryName] 
    else script.Libraries:FindFirstChild(libraryName)  or localGameFrameFolder.Libraries:FindFirstChild(libraryName)
    assert(library, libraryName.." Not found in libraries folder")
    if typeof(library) == "Instance" then
        library = require(library)
    end
    if not libraries[libraryName] then 
        libraries[libraryName] = library
    end

    library.isLibrary = true
    return library
end

function GameFrame.isFunction(funcTable: table)
    if funcTable.isFunction then return true else return false end
end

function GameFrame.loadFunction(functionName: string)
    local func = if functions[functionName] then functions[functionName] 
    else script.Functions:FindFirstChild(functionName) or localGameFrameFolder.Functions:FindFirstChild(functionName)
    assert(func, functionName.." Not found in functions folder")
    if typeof(func) == "Instance" then 
        func = require(func)
    end
    if not functions[functionName] then
        functions[functionName] = func
    end

    local returnFunc = setmetatable({
        isFunction = true;
    }, {
        __call = func
    })
    return returnFunc
end

function GameFrame.isManagerLoaded(manager: table)
    if manager.isLoaded then return true else return false end
end

function GameFrame.waitForManagerLoaded(manager: table)
    repeat task.wait() until GameFrame.isManagerLoaded()
    return true
end


function GameFrame.getManager(managerName: string)
    assert(managers[managerName], managerName.." Is not in manager cache")
    return require(managers[managerName])
end

function GameFrame.loadManagersInDirective(directive: Folder)
    local order
    local directiveDescendants = directive:GetDescendants()
    local directiveManagers = {}
    for index, module in next, directiveDescendants do 
        if module.ClassName ~= "ModuleScript" then continue end
        local manager = require(module)
        if manager.Disabled then continue end
        if not manager.isManager then invalidManagerRequirements(module.Name)  end
        if manager.ProcessingOrder then 
            if not order then
                order = {}
            end
            if not order[manager.ProcessingOrder] then 
                order[manager.ProcessingOrder] = {}
            end
            table.insert(order[manager.ProcessingOrder], manager)
        else
            runManager(manager)
        end
        directiveManagers[manager.Name] = manager
        managers[manager.Name] = module
    end

    if order then 
        for processingOrder, processTable in next, order do
            for index, manager in next, processTable do 
                runManager(manager)
            end
        end
    end
    for index, manager in next, directiveManagers do
        runManagerPost(manager)
    end

end

function GameFrame.isLocalManagersLoaded()
    if GameFrame.localManagersLoaded then return true else return false end
end

function GameFrame.isAllManagersLoaded()
    if GameFrame.allManagersLoaded then return true else return false end
end

function GameFrame.waitForLocalManagersLoaded()
    repeat task.wait() until GameFrame.isLocalManagersLoaded()
    return true
end

function GameFrame.waitForAllManagersLoaded()
    repeat task.wait() until GameFrame.isAllManagersLoaded()
    return true
end

function GameFrame.waitForLocalManagersCallback(func)
    GameFrame.waitForLocalManagersLoaded()
    return func()
end

function GameFrame.waitForAllManagersCallback(func)
    GameFrame.waitForAllManagersLoaded()
    return func()
end

function GameFrame.loadLocalManagers()
    GameFrame.loadManagersInDirective(localGameFrameFolder.Managers)
    GameFrame.localManagersLoaded = true 
end

function GameFrame.loadAllManagers()
    GameFrame.loadLocalManagers()
    GameFrame.loadManagersInDirective(script.Managers)
    GameFrame.allManagersLoaded = true
end

function GameFrame.isManager(manager: table)
    if manager.isManager then return true else return false end
end

function GameFrame.createManager(manager: table)
    local TableUtil = GameFrame.loadLibrary("TableUtil")
    local Network = GameFrame.loadLibrary("Network")
    assert(manager, "manager is nil!")
    assert(manager.Name, "Manager requires a name!")
    local manager = TableUtil.Assign(manager, {
        isManager = true;
        Disabled = manager.Disabled;
        framework = GameFrame;
        Name = manager.Name;
        isLoaded = false;
        FireRemote = if isServer then Network.fireClient else Network.fireServer;
        InvokeRemote = if isServer then Network.invokeClient else Network.invokeServer;
        FireAllClients = if isServer then Network.fireAllClients else false;
        listenForEvent = Network.listenForEvent;
        setCallback = Network.setCallback
    })
    managers[manager.Name] = manager
    return manager
end

GameFrame.isLoaded = true
return GameFrame