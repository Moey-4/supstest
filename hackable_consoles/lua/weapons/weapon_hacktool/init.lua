AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("StartHackingMinigame")
util.AddNetworkString("HackingMinigameResult")
util.AddNetworkString("OpenHackControlMenu")
util.AddNetworkString("SendConsoleProps")

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    local tr = ply:GetEyeTrace()
    local ent = tr.Entity

    if IsValid(ent) and ent:GetClass() == "ent_hack_console" then
        net.Start("StartHackingMinigame")
        net.WriteEntity(ent)
        net.Send(ply)
    else
        ply:ChatPrint("No hackable console targeted.")
    end
end

net.Receive("HackingMinigameResult", function(_, ply)
    local success = net.ReadBool()
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "ent_hack_console" then return end

    if success and ent.LinkedProps then
        for _, prop in ipairs(ent.LinkedProps) do
            if IsValid(prop) then
                prop:SetNoDraw(true)
                prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            end
        end
        ent.IsHacked = true
        ent.HackedBy = ply
        ply:ChatPrint("Console hacked successfully.")
    else
        ply:ChatPrint("Hacking failed.")
    end
end)

net.Receive("OpenHackControlMenu", function(_, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "ent_hack_console" then return end
    if ent.HackedBy ~= ply then return end

    local linkedProps = ent.LinkedProps or {}
    net.Start("SendConsoleProps")
    net.WriteEntity(ent)
    net.WriteUInt(#linkedProps, 8)
    for _, prop in ipairs(linkedProps) do
        net.WriteEntity(prop)
    end
    net.Send(ply)
end)
