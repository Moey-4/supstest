include("shared.lua")

function SWEP:Think()
    if CLIENT and input.IsMouseDown(MOUSE_RIGHT) and not self.RightClickCooldown then
        local ply = LocalPlayer()
        local tr = ply:GetEyeTrace()

        if IsValid(tr.Entity) and tr.Entity:GetClass() == "ent_hack_console" and tr.HitPos:DistToSqr(ply:GetPos()) < 10000 then
            if not tr.Entity:GetNWBool("IsHacked") then
                net.Start("StartHackingAttempt")
                net.WriteEntity(tr.Entity)
                net.SendToServer()
            end
        end

        self.RightClickCooldown = true
        timer.Simple(0.3, function()
            if IsValid(self) then
                self.RightClickCooldown = false
            end
        end)
    end
end

hook.Add("HUDPaint", "HackHint_Draw", function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "weapon_hacktool" then return end

    local tr = ply:GetEyeTrace()
    if not IsValid(tr.Entity) or tr.Entity:GetClass() ~= "ent_hack_console" then return end
    if tr.HitPos:DistToSqr(ply:GetPos()) > 10000 then return end
    if tr.Entity:GetNWBool("IsHacked") then return end

    draw.SimpleText("Use Datapad to Hack", "DermaLarge", ScrW() / 2, ScrH() / 2 + 100, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

include("autorun/client/cl_hacking_minigame.lua")
