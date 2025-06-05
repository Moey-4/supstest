TOOL.Category = "Supptest"
TOOL.Name = "Console Linker"

if CLIENT then
    language.Add("tool.console_linker.name", "Console Linker")
    language.Add("tool.console_linker.desc", "Link hackable consoles to props to toggle nocollide and material on hack.")
    language.Add("tool.console_linker.0", "Left click a console to select it, then right click a prop to link.")
end

-- Store selected console entity per player
local selectedConsole = {}

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) then return false end

    -- Check for console entity class
    if ent:GetClass() ~= "ent_hack_console" then
        if CLIENT then
            chat.AddText(Color(255,0,0), "You must select a hack console entity.")
        end
        return false
    end

    local ply = self:GetOwner()
    selectedConsole[ply] = ent

    if CLIENT then
        chat.AddText(Color(0,255,0), "Console selected! Now right click a prop to link.")
    end

    return true
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) then return false end

    local ply = self:GetOwner()
    local console = selectedConsole[ply]

    if not IsValid(console) then
        if CLIENT then
            chat.AddText(Color(255,0,0), "You must left click a console first!")
        end
        return false
    end

    -- Prevent linking the console entity to itself
    if ent == console then
        if CLIENT then
            chat.AddText(Color(255,0,0), "Cannot link the console to itself!")
        end
        return false
    end

    if SERVER then
        -- Retrieve linked props or create table
        console.LinkedProps = console.LinkedProps or {}

        -- Avoid duplicates
        for _, linkedEnt in ipairs(console.LinkedProps) do
            if linkedEnt == ent then
                if CLIENT then
                    chat.AddText(Color(255,255,0), "This prop is already linked!")
                end
                return false
            end
        end

        table.insert(console.LinkedProps, ent)

        -- Optionally network the number of linked props or save to a networked var if needed
        -- But not necessary here unless you want client awareness

        ply:ChatPrint("[Console Linker] Linked prop to console.")
    end

    -- Clear selection for the player
    selectedConsole[ply] = nil

    return true
end

function TOOL:Holster()
    -- Clear selection if tool is holstered
    local ply = self:GetOwner()
    selectedConsole[ply] = nil
end

function TOOL:Deploy()
    local ply = self:GetOwner()
    selectedConsole[ply] = nil
end
