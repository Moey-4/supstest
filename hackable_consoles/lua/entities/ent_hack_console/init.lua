AddCSLuaFile()
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/workspace004.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end

    self:SetColor(Color(255, 0, 0)) -- Not hacked
    self:SetNWBool("IsHacked", false)
end
