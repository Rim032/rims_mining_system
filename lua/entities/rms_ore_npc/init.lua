AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("rms_open_dealer_menu")
util.AddNetworkString("rms_dealer_sell_ore")
util.AddNetworkString("rms_dealer_sell_finished")
local plyM = FindMetaTable("Player")

function ENT:Initialize()
	local npc_mdl_list = {
		"models/Humans/Group01/Female_01.mdl",
		"models/Humans/Group01/Male_01.mdl",
		"models/Humans/Group01/Female_07.mdl",
		"models/Humans/Group01/male_06.mdl"
	}

	self:SetModel(npc_mdl_list[math.random(1, 4)])
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetSequence(2)

	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:Wake()
	else
		print("[RMS] Ore NPC physics failed.")
	end

	self:SetColor(Color(255, 255, 235, 255))
end

sound.Add( {
	name = "sell_sound",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 80,
	pitch = 100,
	sound = "buttons/blip1.wav"
} )

function ENT:SetupDataTables()
	self:NetworkVar("Int", 1, "ore_price")
end

local delay = 1
local last_ocr = -delay

function ENT:Use(ply, caller, useType, value)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	if !IsValid(self) then return end

	local ply_shootpos = ply:GetShootPos()
	ore_npc_pos = self:GetPos()
	local time_elps = CurTime() - last_ocr

	if (ply_shootpos - ore_npc_pos):Length() < 85 then
		if time_elps > delay then
			net.Start("rms_open_dealer_menu")
				net.WriteVector(self:GetPos())
				
				net.WriteInt(ply.ore_list["Copper"], 12)
				net.WriteInt(ply.ore_list["Coal"], 12)
				net.WriteInt(ply.ore_list["Iron"], 12)
				net.WriteInt(ply.ore_list["Gold"], 12)
			net.Send(ply)

			last_ocr = CurTime()
		end
	end
end

function ENT:Think()
	net.Receive("rms_dealer_sell_ore", function(len, ply)
		local ore_choice = net.ReadString()
		ply:SellOre(ore_choice, rms.price_list[ore_choice])
	end)
end

function plyM:SellOre(ore_name, ore_price)
	if !IsValid(self) then return end
    if ore_name == nil or ore_price == nil then return end

    local time_elps = CurTime() - last_ocr

    if self.ore_list[ore_name] > 0 then
        self:addMoney(ore_price)
        self.ore_list[ore_name] = self.ore_list[ore_name] - 1

		net.Start("rms_dealer_sell_finished")
			net.WriteString(ore_name)
			net.WriteInt(ore_price, 16)
		net.Send(self)

        return self.ore_list[ore_name]
    end
end