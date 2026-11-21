



if SERVER then


-- Credit to: https://steamcommunity.com/sharedfiles/filedetails/?id=1697376012
local ply = FindMetaTable( "Player" )
function ply:custommessage(...)
	local args = {...}
	
	net.Start( "ONIcustommessage" )
	net.WriteTable(args)
	net.Send(self)
end

end