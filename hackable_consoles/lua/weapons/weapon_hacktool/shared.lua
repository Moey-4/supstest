SWEP.PrintName = "Hacking Tool"
SWEP.Author = "Bamrp_Moe"
SWEP.Instructions = "Right-click a console to hack."
SWEP.Category = "Hack Test"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "weapon_base"

SWEP.ViewModel = "models/swcw_items/sw_datapad_v.mdl"
SWEP.WorldModel = "models/swcw_items/sw_datapad.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- Override primary attack to do nothing (no shooting or sounds)
function SWEP:PrimaryAttack()
end

-- Override secondary attack similarly
function SWEP:SecondaryAttack()
end

-- Optional: disable ammo consumption and reload
function SWEP:Reload()
end
