hook.Add("PreDrawHalos", "pumpkinwabbitseason", function()
    local orange = Color(255, 155, 0)

    if (LocalPlayer():GetNWBool('PRwallhaks') == true) then
        local plyrs = {}
        plyrs = ents.FindByClass("player*")
        for i, plr in ipairs(plyrs) do
            if plr == LocalPlayer() then table.remove(plyrs, i) end
        end
        halo.Add(plyrs, orange, 5, 5, 50, true, true)
    end
end)


if ! pcall(require, "pk_pills") then
    if SERVER then
        hook.Add("PlayerInitialSpawn", "pk_pill_extfail_cl", function(ply)
            if game.SinglePlayer() || ply:IsListenServerHost() then
                ply:SendLua(
                'notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
            end
        end)
        hook.Add("Initialize", "pk_pill_extfail_sv", function(ply)
            print("[ALERT] One or more pill extensions failed to load. Did you forget to install Parakeet's Pill Pack?")
        end)
    end
    return

        hook.Add("SetupPlayerVisibility", "VisibilityHandler", function()
            for i, plr in ipairs(player.GetAll()) do
                AddOriginToPVS(plr:GetPos())
            end
        end)
end

if SERVER then
    util.AddNetworkString('PILLSJUMPCAM')
end

if CLIENT then
    net.Receive('PILLSJUMPCAM', function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
        local state = net.ReadBool()
        local hookname = 'pumprab' .. ply:EntIndex()

        hook.Remove('CalcView', hookname) -- evita hooks duplicados

        if not state then return end

        local transitionStart = RealTime()
        local lastAng -- último ângulo válido, usado se o attachment falhar

        hook.Add('CalcView', hookname, function(p, pos, angles, fov)
            if not IsValid(p) or not p:Alive() or not IsValid(ent) then
                hook.Remove('CalcView', hookname)
                return
            end

            local t = math.Clamp((RealTime() - transitionStart) / 0.25, 0, 1)

            -- tenta o attachment "camera"; se não existir, cai para a cabeça/topo do modelo
            ent:SetupBones()
            local camPos, camAng
            local id = ent:LookupAttachment('camera')
            if id and id > 0 then
                local att = ent:GetAttachment(id)
                if att then camPos, camAng = att.Pos, att.Ang end
            end

            if not camPos then
                camPos = ent:GetPos() + Vector(0, 0, 60)
                camAng = ent:GetAngles()
            end

            return {
                origin = LerpVector(t, pos, camPos),
                angles = LerpAngle(t, angles, camAng),
                fov = 90,
                drawviewer = false
            }
        end)
    end)
end

AddCSLuaFile()
include("include/pr.lua")
