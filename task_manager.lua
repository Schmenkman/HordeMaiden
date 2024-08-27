local explorer = require("core.explorer")

local task_manager = {}
local tasks = {}
local task_configs = {}
local current_task = nil

function task_manager.register_task(task, config)
    table.insert(tasks, task)
    task_configs[task.name] = config or {}
end

function task_manager.execute_tasks()
    local next_task = nil

    -- Check for priority tasks first
    for _, task in ipairs(tasks) do
        if task.should_execute() and task_configs[task.name].priority then
            next_task = task
            break
        end
    end

    -- If no priority task is found, check for other tasks
    if not next_task then
        for _, task in ipairs(tasks) do
            if task.should_execute() then
                next_task = task
                break
            end
        end
    end

    if next_task ~= current_task then
        -- Handle task exit
        if current_task then
            if task_configs[current_task.name].uses_explorer and 
               (not next_task or not task_configs[next_task.name].uses_explorer) then
                explorer:stop()
            end
            if current_task.on_exit then
                current_task.on_exit()
            end
        end
        
        -- Handle task enter
        local prev_task = current_task
        current_task = next_task
        if current_task then
            if task_configs[current_task.name].uses_explorer and 
               (not prev_task or not task_configs[prev_task.name].uses_explorer) then
                explorer:start(current_task.name)
            end
            if current_task.on_enter then
                current_task.on_enter()
            end
        end
    end

    -- Execute current task
    if current_task then
        current_task.execute()
    else
        explorer:stop()
    end

    -- Always update explorer if it's enabled
    explorer:on_update()
end

function task_manager.get_current_task()
    return current_task or { name = "Idle" }
end

return task_manager