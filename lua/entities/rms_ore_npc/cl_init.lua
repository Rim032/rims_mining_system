include("shared.lua")

surface.CreateFont("rms_font", {
    font = "Arial",
    antialias = true,
    size = ScrH()/43.2
})

surface.CreateFont("rms_fontB", {
    font = "Arial",
    antialias = true,
    size = ScrH()/21.6
})

--local ply = LocalPlayer() defined throughout the entire file doesn't work? (defining it outside any of the functions below)

function ENT:Draw()
	self:DrawModel()

	hook.Add("PostDrawOpaqueRenderables", "rms_cl_draw_3dsd_hk", function()
		local ply = LocalPlayer()
		if !IsValid(self) or !IsValid(ply) then return end

		local ply_shootpos = ply:GetShootPos()
		local ply_angles = Angle(0, ply:LocalEyeAngles().y - 90, 90)
		local ore_npc_pos = self:GetPos()
	
		if (ply_shootpos - ore_npc_pos):Length() < 125 then
			cam.Start3D2D(ore_npc_pos + Vector(0, 0, 80), ply_angles, 0.1)
				surface.SetDrawColor(65, 65, 65, 150)
				surface.DrawRect(ScrW()/-8.53, ScrH()/-64, ScrW()/4.27, ScrH()/10)
				surface.SetDrawColor(255, 255, 255, 200)
                surface.DrawRect(ScrW()/-8.53, ScrH()/12, ScrW()/4.27, ScrH()/100)
				draw.SimpleText("Ore Vendor", "rms_fontB", ScrW()/ScrW(), ScrH()/80, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end)
end

net.Receive("rms_open_dealer_menu", function()
	local ply = LocalPlayer()
	local ply_shootpos = ply:GetShootPos()
	local ore_npc_pos = net.ReadVector()

	if (ply_shootpos - ore_npc_pos):Length() < 125 then
		local copper_ore_cnt = net.ReadInt(12)
		local coal_ore_cnt = net.ReadInt(12)
		local iron_ore_cnt = net.ReadInt(12)
		local gold_ore_cnt = net.ReadInt(12)

		rms_dealer_menu(copper_ore_cnt, coal_ore_cnt, iron_ore_cnt, gold_ore_cnt)
	end
end)

net.Receive("rms_dealer_sell_finished", function()
	local ply = LocalPlayer()
	local ore_name = net.ReadString()
	local ore_price = net.ReadInt(16)

	ply:EmitSound("sell_sound")
	chat.AddText(Color(100, 150, 255), "[RMS Ore Vendor]: ", Color(255, 255, 255), "You sold " ..ore_name.. " for $" ..ore_price.. ".")
end)

function rms_dealer_menu(copper_ore_cnt, coal_ore_cnt, iron_ore_cnt, gold_ore_cnt)
	local ply = LocalPlayer()

	if !IsValid(ply) then return end
	if IsValid(main_frame) then return end 
	if copper_ore_cnt == nil or coal_ore_cnt == nil or iron_ore_cnt == nil or gold_ore_cnt == nil then print("[RMS] ERROR: Cannot retrieve the player's ores.") return end

	local main_frame = vgui.Create("DFrame")
	main_frame:SetPos(ScrW()/2, ScrH()/2)
	main_frame:SetSize(ScrW()/4, ScrH()/2)
	main_frame:Center()
	main_frame:MakePopup()
	main_frame:SetDraggable(false)
	main_frame:SetTitle("")
	main_frame:SetWorldClicker(false)
	main_frame.Paint = function(self, w, h, ore_panelA)
		draw.RoundedBox(2, 0, 0, w, h, Color(25, 25, 25, 200))
		draw.RoundedBox(2, 0, 0, w, h/15, Color(75, 75, 75, 200))
		draw.SimpleText("Rim's Mining System", "rms_font", ScrW()/7.68, ScrH()/216, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		self:MoveToBack() --I had to do this.
	end

	create_ore_option("Copper", rms.price_list["Copper"], 1, main_frame, Color(255, 228, 179, 255), copper_ore_cnt)
	create_ore_option("Coal", rms.price_list["Coal"], 2, main_frame, Color(110, 110, 110, 255), coal_ore_cnt)
	create_ore_option("Iron", rms.price_list["Iron"], 3, main_frame, Color(255, 255, 235, 255), iron_ore_cnt)
	create_ore_option("Gold", rms.price_list["Gold"], 4, main_frame, Color(255, 218, 66, 255), gold_ore_cnt)
end

function create_ore_option(ore_name, ore_price, ore_id, main_frame, ore_color, ore_count)
	local ore_text_color = Color(125, 255, 125)
	if ore_count <= 0 then
		ore_text_color = Color(255, 125, 125)
	end

	local ore_panel = vgui.Create("DPanel", main_frame)
	ore_panel:SetText("")
	ore_panel:SetPos(ScrW()/2 - ScrW()/8.53, ScrH()/2 - (ScrH()/3.09 + (ore_id * ScrH()/-8.64)))
	ore_panel:SetSize(ScrW()/4.27, ScrH()/10.8)
	ore_panel:MakePopup()
	ore_panel.Paint = function(self, w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50, 210))
		draw.SimpleText("Sell "..ore_name, "rms_font", ScrW()/5.12, ScrH()/36, ore_text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
		draw.SimpleText("Price: " ..ore_price, "rms_font", ScrW()/5.12, ScrH()/21.6, ore_text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
	end

	local ore_button = vgui.Create("DButton", ore_panel)
	ore_button:SetPos(ScrW()/2 - ScrW()/8.53, ScrH()/2 - (ScrW()/5.49 + (ore_id * -ScrW()/15.36)))
	ore_button:SetSize(ScrW()/4.27, ScrH()/10.8)
	ore_button:MakePopup()
	ore_button:SetText("")
	ore_button.Paint = function(self, w, h) end
	ore_button.DoClick = function()	
		net.Start("rms_dealer_sell_ore")
			net.WriteString(ore_name, 4)
		net.SendToServer()
	end

	local ore_icon = vgui.Create("DModelPanel", ore_panel)
	ore_icon:SetPos(ScrW()/-12.8, ScrH()/-3.85)
	ore_icon:SetSize(ScrW()/4.8, ScrW()/4.8)
	ore_icon:SetModel("models/rim/rms_mined_ore_01.mdl")
	ore_icon:SetColor(ore_color)
	function ore_icon:LayoutEntity(Entity) return end
end