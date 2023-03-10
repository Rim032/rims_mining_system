rms = rms or {}
rms.version = 1.10
rms.build_date = "3/9/2023"

if SERVER then
    include("rms/server/sv_rms_ply_manage.lua")
    include("rms/sh_rms_config.lua")

    AddCSLuaFile("rms/sh_rms_config.lua")
end

if CLIENT then 
    include("rms/sh_rms_config.lua")
    MsgC(Color(69, 140, 255), "##[Rim's Mining System: Client Initialized]##\n")
end

hook.Add("PostGamemodeLoaded", "rms_sv_backup_load", function()
    timer.Simple(0, function()
        if SERVER then
            include("rms/server/sv_rms_ply_manage.lua")
            include("rms/sh_rms_config.lua")
        
            AddCSLuaFile("rms/sh_rms_config.lua")
            MsgC(Color(69, 140, 255), "##[Rim's Mining System: Server Initialized]##\n")
        end
    end)
end)