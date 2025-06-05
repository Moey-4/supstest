TOOL.Category = "Supptest"
TOOL.Name = "Console Linker"

TOOL.Information = {
    { name = "left", text = "Left Click: Select console or link prop" }
}

-- Shared
TOOL.ClientConVar["none"] = "0" -- dummy to prevent convar errors

-- Clientside: track selected console entity
if CLIENT then
    TOOL.SelectedConsole = nil

    function TOOL:LeftClick(trace)
        local ent = trace.Entity
        if not IsValid(ent) then return false end

        -- If it's a hack console, select it
        if ent:GetClass() == "ent_hack_console" then
            self.SelectedConsole = ent
            chat.AddText(Color(0, 200, 255), "[Console Linker] Selected console: ", Color(255, 255, 255), tostring(ent))
            return true
        end

        -- If it's a valid prop and a console is selected, send to server
        if self.SelectedConsole and ent:GetClass() ~= "ent_hack_console" then
            net.Start("Supptest_LinkPropToConsole")
            net.WriteEntity(self.SelectedConsole)
            net.WriteEntity(ent)
            net.SendToServer()

            chat.AddText(Color(0, 200, 255), "[Console Linker] Linked prop: ", Color(255, 255, 255), tostring(ent))
            return true
        end

        return false
    end

    function TOOL.BuildCPanel(panel)
        panel:AddControl("Header", { Description = "Left-click a console, then left-click props to link them." })
    end
end

-- Serverside
if SERVER then
    util.AddNetworkString("Supptest_LinkPropToConsole")
    util.AddNetworkString("Supptest_HackSuccess")

    local linkedProps = {} -- [consoleEnt:EntIndex()] = { propEnt, ... }

    net.Receive("Supptest_LinkPropToConsole", function(_, ply)
        local console = net.ReadEntity()
        local prop = net.ReadEntity()

        if not (IsValid(console) and console:GetClass() == "ent_hack_console") then
            ply:ChatPrint("[Console Linker] Invalid console!")
            return
        end

        if not (IsValid(prop) and prop:GetClass() ~= "ent_hack_console") then
            ply:ChatPrint("[Console Linker] Invalid prop!")
            return
        end

        local cid = console:EntIndex()
        linkedProps[cid] = linkedProps[cid] or {}

        for _, p in ipairs(linkedProps[cid]) do
            if p == prop then
                ply:ChatPrint("[Console Linker] Already linked.")
                return
            end
        end

        table.insert(linkedProps[cid], prop)
        ply:ChatPrint("[Console Linker] Prop linked.")
    end)

    local function ApplyEffectsOnLinkedProps(console)
        local cid = console:EntIndex()
        local props = linkedProps[cid]
        if not props then return end

        for _, prop in ipairs(props) do
            if IsValid(prop) then
                prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
                prop:SetMaterial("models/effects/vol_light001")
            end
        end
    end

    -- Hook this into your hack logic or test manually
    net.Receive("Supptest_HackSuccess", function(_, ply)
        local console = net.ReadEntity()
        if IsValid(console) then
            ApplyEffectsOnLinkedProps(console)
        end
    end)
end
