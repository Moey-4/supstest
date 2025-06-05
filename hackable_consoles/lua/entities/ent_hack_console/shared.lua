ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Hack Console"
ENT.Author = "Moey-4"
ENT.Category = "Supptest"
ENT.Spawnable = true

-- Setup networking for linked props count (optional)
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "LinkedPropCount")
end
