AddCSLuaFile()
include("shared.lua")

util.AddNetworkString("StartHackingAttempt")
util.AddNetworkString("OpenHackingMinigame")
util.AddNetworkString("HackingMinigameResult")

net.Receive("StartHackingAttempt", function(_, ply)
    local ent = net.ReadEntity()

    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(ent) or ent:GetClass() ~= "ent_hack_console" then return end
    if ent:GetNWBool("IsHacked") then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 10000 then return end

    -- Store hack target temporarily on the player
    ply.HackingTarget = ent

    -- Send minigame trigger to client
    net.Start("OpenHackingMinigame")
    net.Send(ply)

    -- Optional: emit start sound
    ply:EmitSound("buttons/button17.wav")
end)

net.Receive("HackingMinigameResult", function(_, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local success = net.ReadBool()
    local ent = ply.HackingTarget

    if not IsValid(ent) or ent:GetClass() ~= "ent_hack_console" then return end
    if ent:GetNWBool("IsHacked") then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 10000 then return end

    if success then
        ent:SetColor(Color(0, 255, 0))
        ent:SetNWBool("IsHacked", true)
        ply:EmitSound("buttons/button15.wav")
    else
        ply:EmitSound("buttons/button10.wav")
    end

    -- Clear target
    ply.HackingTarget = nil
end)
