local RunService = game:GetService("RunService")

local GameFrame = {}

local libraries = {}
local functions = {}
local managers = {}

local localGameFrameFolder

local isServer = RunService:IsServer()

if isServer then 
    localGameFrameFolder = game.ServerScriptService.GameFrame
else
    localGameFrameFolder = game.StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("GameFrame")
end

local function invalidManagerRequirements(name: string)
    return warn(name, "Has invalid manager requirements")
end

local function runManager(manager)
    if manager.init then 
        manager:init()
    end
end

local function runManagerPost(manager)
    if manager.postinit then
        manager:postinit()
    end
end

function GameFrame.isLibrary(library: table)
    if library.isLibrary then return true else return false end
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

function GameFrame.loadClasses(className: string)
    local class = if classes[className] then classes[className]
    else script.Classes:FindFirstChild(className) or localGameFrameFolder.Classes:FindFirstChild(className)
    assert(class, className.."Not found in classes folder")
    if typeof(class) == "Instance" then 
        class = require(class)
    end
    if not classes[className] then 

    end
end

function GameFrame.loadManagerByName(managerName: string)
    local manager: ModuleScript? = if managers[managerName] then managers[managerName] 
    else script.Managers:FindFirstChild(managerName) or localGameFrameFolder.Managers:FindFirstChild(managerName)
    assert(manager, managerName.." Not found in managers folder")
    if not managers[managerName] then
        managers[managerName] = manager
    end
    manager = require(manager)
    if manager.init then 
        task.spawn(function()
            manager:init()
        end)
    end
    return manager
end

function GameFrame.loadManagersInDirective(directive: Folder)
    local order
    local directiveChildren = directive:GetChildren()
    local directiveManagers = {}
    for index, module in next, directiveChildren do 
        if module.ClassName ~= "ModuleScript" then continue end
        local manager = require(module)
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

function GameFrame.loadLocalManagers()
    GameFrame.loadManagersInDirective(localGameFrameFolder.Managers)
end

function GameFrame.loadAllManagers()
    loadLocalManagers()
    GameFrame.loadManagersInDirective(script.Managers)
end

function GameFrame.createManager(manager: table)
    local TableUtil = GameFrame.loadLibrary("TableUtil")
    local Network = GameFrame.loadLibrary("Network")
    assert(manager, "manager is nil")
    assert(manager.Name, "Manager requires a name.")
    local manager = TableUtil.Assign(manager, {
        isManager = true;
        frame = GameFrame;
        libraries = libraries;
        functions = functions;
        FireRemote = if isServer then Network.fireClient else Network.fireServer;
        InvokeRemote = if isServer then Network.invokeClient else Network.invokeServer;
        FireAllClients = if isServer then Network.fireAllClients else false;
        listenForEvent = Network.listenForEvent;
        setCallback = Network.setCallback
    })
    managers[manager.Name] = manager
    return manager
end

return GameFrame