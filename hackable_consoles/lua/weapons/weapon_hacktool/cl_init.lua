include("shared.lua")

function SWEP:PrimaryAttack()
    -- Client-side primary attack can be left empty or used for visual effects
end

hook.Add("PlayerButtonDown", "HackToolOpenConsoleMenu", function(ply, button)
    if button == KEY_E then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_hacktool" then
            local tr = ply:GetEyeTrace()
            local ent = tr.Entity
            if IsValid(ent) and ent:GetClass() == "ent_hack_console" and ent.IsHacked then
                net.Start("OpenHackControlMenu")
                net.WriteEntity(ent)
                net.SendToServer()
            end
        end
    end
end)

net.Receive("SendConsoleProps", function()
    local ent = net.ReadEntity()
    local count = net.ReadUInt(8)
    local props = {}
    for i = 1, count do
        table.insert(props, net.ReadEntity())
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Console Control")
    frame:SetSize(300, 100 + 30 * #props)
    frame:Center()
    frame:MakePopup()

    for _, prop in ipairs(props) do
        local btn = vgui.Create("DButton", frame)
        btn:SetText("Toggle Prop " .. tostring(prop))
        btn:Dock(TOP)
        btn.DoClick = function()
            if IsValid(prop) then
                prop:SetNoDraw(not prop:GetNoDraw())
                prop:SetCollisionGroup(
                    prop:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE
                    and COLLISION_GROUP_NONE
                    or COLLISION_GROUP_IN_VEHICLE
                )
            end
        end
    end
end)
