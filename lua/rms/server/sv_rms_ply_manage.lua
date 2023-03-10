local plyM = FindMetaTable("Player")

hook.Add("PlayerInitialSpawn", "rms_sv_spawn_hook", function(ply)
    ply:initialize_ores()
end)

hook.Add("PostPlayerDeath", "rms_sv_pdeath_hook", function(ply)
    ply:initialize_ores()
end)

function plyM:initialize_ores()
    if !IsValid(self) then return end

    self.ore_list = {
      ["Coal"] = 0,
      ["Copper"] = 0,
      ["Iron"] = 0,
      ["Gold"] = 0,
    }
end

function rms.initialize_hits()
    rms.hit_list = {
        7,
        10,
        4,
        13,
    }
end

function rms.initialize_max_ores()
    rms.max_carryable_ores = 16
end

function rms_inv_cap_check(ply, ore_name)
    if !IsValid(ply) then return end
    if ply.ore_list == nil then ply:initialize_ores() end
    if rms.max_carryable_ores == nil then rms.initialize_max_ores() end

    if ply.ore_list[ore_name] > rms.max_carryable_ores then
        ply.ore_list[ore_name] = 0

        print("[RMS]:  " ..ply:Nick().. " [" ..ply:SteamID().. "]  may be exploiting or encountered a bug (had more ores than the limit).")
    end

    return ply.ore_list
end