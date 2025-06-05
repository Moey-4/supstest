AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_mine01.mdl") -- example model, change if needed
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.LinkedProps = {} -- Table to hold linked props
    self:SetLinkedPropCount(0)
end

-- Called when the console is successfully hacked
function ENT:OnHackedSuccess()
    if not self.LinkedProps or #self.LinkedProps == 0 then return end

    -- Toggle nocollide and material on linked props
    for _, prop in ipairs(self.LinkedProps) do
        if IsValid(prop) then
            -- Toggle NoDraw (as an example toggle, adjust as needed)
            local currentNoDraw = prop:GetNoDraw()
            prop:SetNoDraw(not currentNoDraw)

            -- Toggle material example (use your desired material path)
            if currentNoDraw then
                prop:SetMaterial("")
            else
                prop:SetMaterial("models/debug/debugwhite")
            end

            -- You can add nocollide toggling or other logic here as needed
        end
    end
end

-- Cleanup linked props references if they are removed
function ENT:Think()
    -- Remove invalid props from linked list
    if not self.LinkedProps then return end

    for i = #self.LinkedProps, 1, -1 do
        if not IsValid(self.LinkedProps[i]) then
            table.remove(self.LinkedProps, i)
        end
    end

    self:SetLinkedPropCount(#self.LinkedProps)
end
