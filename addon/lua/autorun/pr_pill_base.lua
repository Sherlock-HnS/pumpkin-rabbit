hook.Add( "PreDrawHalos", "pumpkinwabbitseason", function()
	local orange = Color(255,155,0)

	if ( LocalPlayer():GetNWBool('PRwallhaks') == true ) then
		local plyrs = {}
		plyrs = ents.FindByClass("player*")
		for i,plr in ipairs(plyrs) do
    		if plr == LocalPlayer() then table.remove(plyrs, i) end
		end	 
		halo.Add(plyrs, orange, 5, 5, 50, true, true )
	end
end )


if !pcall(require,"pk_pills") then
	if SERVER then
		hook.Add("PlayerInitialSpawn","pk_pill_extfail_cl",function(ply)
			if game.SinglePlayer() || ply:IsListenServerHost() then
				ply:SendLua('notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
			end
		end)
		hook.Add("Initialize","pk_pill_extfail_sv",function(ply)
			print("[ALERT] One or more pill extensions failed to load. Did you forget to install Parakeet's Pill Pack?")
		end)
	end
	return

	hook.Add("SetupPlayerVisibility", "VisibilityHandler", function()
    	for i,plr in ipairs(player.GetAll()) do
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
		local hookname = 'pumprab' .. tostring(ply)

		if not state then
			hook.Remove('CalcView', hookname)
			return
		end

		local transitionStart = RealTime()

		hook.Add('CalcView', hookname, function(ply, pos, angles, fov)
			if not IsValid(ply) or not ply:Alive() or not IsValid(ent) then
				hook.Remove('CalcView', hookname)
				return
			end	
			local transitionProgress = math.Clamp((RealTime() - transitionStart) / 0.25, 0, 1)
			local cam = ent:GetAttachment(ent:LookupAttachment('camera'))
			return {
				origin = LerpVector(transitionProgress, pos, cam.Pos),
				angles = LerpAngle(transitionProgress, angles, cam.Ang),
				fov = 90,
				drawviewer = false
			}
		end)
	end)
end

AddCSLuaFile()
include("include/pr.lua")