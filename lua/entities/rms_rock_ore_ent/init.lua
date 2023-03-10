AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local entM = FindMetaTable("Entity")

function ENT:Initialize()
	self:SetModel("models/rim/rms_rock_ore_01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self.pos = self:GetPos()
	self:SetPos(Vector(self.pos) + Vector(0, 0, -15))
	
	local phys = self:GetPhysicsObject()
	local rand_skin = math.random(0, 3)
	self:SetSkin(rand_skin)
	
	if phys:IsValid() then
		phys:Wake()
	else
		print("[RMS] Unmined Ore physics failed.")
	end

	self.valid_hits = 0
end

function ENT:OnTakeDamage(damage)
	self.attacker = damage:GetAttacker()

	if(self.attacker:GetActiveWeapon():GetClass() == "rms_pickaxe_swep") then
		self.valid_hits = self.valid_hits + 1
		self:drop_ores()
	end
end

function entM:drop_ores()
	if rms.hit_list == nil then rms.initialize_hits() end
	local physobj = self:GetPhysicsObject()

	local ent_skin = self:GetSkin()
	local ore_ent_list = {
		"rms_copper_ore_ent",
		"rms_iron_ore_ent",
		"rms_coal_ore_ent",
		"rms_gold_ore_ent",
	}

	if rms.hit_list[ent_skin + 1] then
		if self.valid_hits >= rms.hit_list[ent_skin + 1] then
			local ore_ent = ents.Create(ore_ent_list[ent_skin + 1])
			ore_ent:SetPos(Vector(self:GetPos()) + physobj:LocalToWorldVector(Vector(65, 0, 110)))
			ore_ent:Spawn()

			self.valid_hits = 0
		end
	end
end