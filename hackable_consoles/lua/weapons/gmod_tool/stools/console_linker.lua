-- lua/weapons/gmod_tools/stools/console_linker.lua

TOOL.Category = "Supptest"
TOOL.Name = "Console Linker"

if CLIENT then
    language.Add("tool.console_linker.name", "Console Linker")
    language.Add("tool.console_linker.desc", "Link hackable console entities to props to toggle nocollide and null material on hack.")
    language.Add("tool.console_linker.0", "Left click a console to select, then left click props to link. Click another console to switch.")
end

if SERVER then
    -- Network messages for console selection and prop linking
    util.AddNetworkString("ConsoleLinker_SelectConsole")
    util.AddNetworkString("ConsoleLinker_LinkProp")
end

-- Server-side storage: linked props by console entity
local linkedProps = {}

local function IsHackableConsole(ent)
    return IsValid(ent) and ent:GetClass() == "ent_hack_console"
end

local function IsValidProp(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    return class:StartWith("prop_") or class:StartWith("gmod_")
end

if SERVER then

    -- Player selects console
    net.Receive("ConsoleLinker_SelectConsole", function(len, ply)
        local console = net.ReadEntity()
        if not IsHackableConsole(console) then return end

        ply.ConsoleLinker_SelectedConsole = console

        -- Initialize console entry if missing
        linkedProps[console] = linkedProps[console] or {}

        ply:ChatPrint("[Console Linker] Selected console.")
    end)

    -- Player links prop to selected console
    net.Receive("ConsoleLinker_LinkProp", function(len, ply)
        local prop = net.ReadEntity()
        local console = ply.ConsoleLinker_SelectedConsole

        if not IsHackableConsole(console) then
            ply:ChatPrint("[Console Linker] No console selected. Left click a console first.")
            return
        end

        if not IsValidProp(prop) then
            ply:ChatPrint("[Console Linker] That is not a valid prop.")
            return
        end

        -- Avoid duplicates
        linkedProps[console] = linkedProps[console] or {}
        for _, linkedProp in ipairs(linkedProps[console]) do
            if linkedProp == prop then
                ply:ChatPrint("[Console Linker] This prop is already linked.")
                return
            end
        end

        table.insert(linkedProps[console], prop)
        ply:ChatPrint("[Console Linker] Prop linked to console.")
    end)

    -- When console is hacked, apply nocollide and null material to linked props
    hook.Add("OnConsoleHacked", "ConsoleLinker_ApplyEffects", function(console)
        if not linkedProps[console] then return end

        for _, prop in ipairs(linkedProps[console]) do
            if IsValid(prop) then
                -- Enable no collide with players and world
                prop:SetCollisionGroup(COLLISION_GROUP_WORLD)

                -- Apply null/invisible material
                prop:SetMaterial("engine/occlusionproxy")
            end
        end
    end)

    -- Clean up links if console removed
    hook.Add("EntityRemoved", "ConsoleLinker_Cleanup", function(ent)
        if linkedProps[ent] then
            linkedProps[ent] = nil
        end
    end)

    -- Remove player's selected console on disconnect
    hook.Add("PlayerDisconnected", "ConsoleLinker_ClearSelection", function(ply)
        ply.ConsoleLinker_SelectedConsole = nil
    end)
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ent = trace.Entity
    local ply = self:GetOwner()

    -- Select console if clicked
    if IsHackableConsole(ent) then
        net.Start("ConsoleLinker_SelectConsole")
        net.WriteEntity(ent)
        net.Send(ply)
        return true
    end

    -- If console selected, link props
    local selectedConsole = ply.ConsoleLinker_SelectedConsole
    if selectedConsole and IsValid(selectedConsole) and IsHackableConsole(selectedConsole) then
        if IsValidProp(ent) then
            net.Start("ConsoleLinker_LinkProp")
            net.WriteEntity(ent)
            net.Send(ply)
            return true
        else
            ply:ChatPrint("[Console Linker] Please left click a valid prop to link.")
            return false
        end
    else
        ply:ChatPrint("[Console Linker] No console selected. Left click a console first.")
        return false
    end
end

function TOOL:Holster()
    if SERVER then
        self:GetOwner().ConsoleLinker_SelectedConsole = nil
    end
    return true
end
