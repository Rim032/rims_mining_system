SWEP.PrintName			= "Pickaxe"
SWEP.Author			= "Rim"
SWEP.Instructions		= "Left click to swing."
SWEP.Category         = "[RMS] Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel			= "models/rim/rms_pickaxe_01_v.mdl"
SWEP.WorldModel			= "models/rim/rms_pickaxe_01_w.mdl"
SWEP.HoldType = "melee2"
SWEP.UseHands = true

SWEP.Weight			= 9
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Slot			= 0
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

local pick_hit = Sound("Weapon_Crowbar.Melee_Hit")

function SWEP:Initialize()
    self:SetWeaponHoldType("melee2")
end

function SWEP:PrimaryAttack()
    if(CLIENT) then return end
    ply = self:GetOwner()

    ply:LagCompensation(true)
    local shootpos = ply:GetShootPos()
    local shootpos_limit = shootpos + ply:GetAimVector() * 25

    local tmin = Vector(1,1,1) * -10
    local tmax = Vector(1,1,1) * 10
    local tr = util.TraceHull({
        start = shootpos,
        endpos = shootpos_limit,
        filter = ply,
        mask = MASK_SHOT_HULL,
        mins = tmin,
        maxs = tmax    })

    if(not IsValid(tr.Entity)) then
        tr = util.TraceLine ({
            start = shootpos,
            endpos = shootpos_limit,
            filter = ply, 
            mask = MASK_SHOT_HULL })
    end

    local ent = tr.Entity

    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self.Weapon:SendWeaponAnim( ACT_VM_HITLEFT )

    local trace = self.Owner:GetEyeTrace()

    if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 80 then

        bullet = {}
        bullet.Num    = 1
        bullet.Src    = self.Owner:GetShootPos()
        bullet.Dir    = self.Owner:GetAimVector()
        bullet.Spread = Vector(0, 0, 0)
        bullet.Tracer = 0
        bullet.Force  = 4
        bullet.Damage = 12

        self.Owner:DoAttackEvent()
        self.Owner:FireBullets(bullet) 
        ply:EmitSound(pick_hit)
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()  
    local pick_vm = self.Weapon:GetWeaponViewModel()
    local pick_wm = self.Weapon:GetWeaponWorldModel()
end

if CLIENT then
	local WorldModel = ClientsideModel("models/rim/rms_pickaxe_01_w.mdl")

	WorldModel:SetSkin(0)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()

		if (IsValid(_Owner)) then
            -- Specify a good position
			local offsetVec = Vector(3, -1.2, 6)
			local offsetAng = Angle(180, 90, 0)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = _Owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

            WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end
end