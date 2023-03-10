AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/rim/rms_mined_ore_01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:Wake()
	else
		print("[RMS] Iron Ore physics failed.")
		self:Remove()
	end

	self:SetColor(Color(255, 218, 66, 255))
end

local delay = 1
local last_ocr = -delay

function ENT:Use(ply, caller, useType, value)
	rms_inv_cap_check(ply, "Gold")

	if ply.ore_list["Gold"] < rms.max_carryable_ores then
		ply.ore_list["Gold"] = ply.ore_list["Gold"] + 1
		self:Remove()
	else
		if time_elps > delay then
			ply:PrintMessage(HUD_PRINTTALK, "[RMS]: Gold inventory slot is full (Max: " ..rms.max_carryable_ores.. ")")
			last_ocr = CurTime()
		end
	end
end