local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local taxiTableCached = {}
local taxiTable = {
    {
	location = { 176352, 159675, 4820, 20},
	spawn = { 175725, 159235, 4818, 20}
	}
}

AddEvent("OnPackageStart", function(player)
    for k,v in pairs(taxiTable) do
        v.npcObject = CreateNPC(v.location[1], v.location[2], v.location[3], v.location[4])
		CreateText3D("Taxi\n".._("press_e"), 18, v.location[1], v.location[2], v.location[3] + 120, 0, 0, 0)
        table.insert( taxiTableCached, v.npcObject )
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "taxiboss:setup", taxiTableCached)
end)

AddRemoteEvent("TaxiCheckJob", function(player)
    CallRemoteEvent(player, "taxiboss:startconversation", PlayerData[player].job, PlayerData[player].driver_license)    
end)

AddRemoteEvent("GetJobTaxi", function(player)
	local taxiCount = 0
	
    for k,v in pairs(PlayerData) do
		if v.job == "taxi" then
			taxiCount = taxiCount + 1
		end
	end
	if taxiCount == 5 then
	return CallRemoteEvent(player, "MakeNotification", _("job_full"), "linear-gradient(to right, #ff5f6d, #ffc371)")
	else
	    CallRemoteEvent(player, "MakeNotification", _("new_taxi"), "linear-gradient(to right, #00b09b, #96c93d)")
		PlayerData[player].job = "taxi"
	end
end)

AddRemoteEvent("SpawnTaxi", function(player)
	local nearestTaxi = GetNearestTaxiBoss(player)
	local isSpawnable = true
	
	for k,v in pairs(GetAllVehicles()) do
		local x, y, z = GetVehicleLocation(v)
		local dist2 = GetDistance3D(taxiTable[nearestTaxi].spawn[1], taxiTable[nearestTaxi].spawn[2], taxiTable[nearestTaxi].spawn[3], x, y, z)
		if dist2 < 300.0 then
			isSpawnable = false
			CallRemoteEvent(player, "MakeNotification", _("no_place"), "linear-gradient(to right, #ff5f6d, #ffc371)")
			break
		end
	end
	if isSpawnable then
		if PlayerData[player].job_vehicle ~= nil then
			DestroyVehicle(PlayerData[player].job_vehicle)
			DestroyVehicleData(PlayerData[player].job_vehicle)
			PlayerData[player].job_vehicle = nil
		end
		
		local vehicle = CreateVehicle(2, taxiTable[nearestTaxi].spawn[1], taxiTable[nearestTaxi].spawn[2], taxiTable[nearestTaxi].spawn[3], taxiTable[nearestTaxi].spawn[4])
		PlayerData[player].job_vehicle = vehicle
		CreateVehicleData(player, vehicle, 2)
		SetVehiclePropertyValue(vehicle, "locked", true, true)
		CallRemoteEvent(player, "MakeNotification", _("spawn_taxi"), "linear-gradient(to right, #00b09b, #96c93d)")
		return
	end
end)

AddRemoteEvent("LeaveJobTaxi", function(player)
	if PlayerData[player].job_vehicle ~= nil then
		DestroyVehicle(PlayerData[player].job_vehicle)
		DestroyVehicleData(PlayerData[player].job_vehicle)
		PlayerData[player].job_vehicle = nil
	end
	
	PlayerData[player].job = ""
	CallRemoteEvent(player, "MakeNotification", _("leave_taxi"), "linear-gradient(to right, #ff5f6d, #ffc371)")
end)


function GetNearestTaxiBoss(player)
	local x, y, z = GetPlayerLocation(player)

	for k,v in pairs(GetAllNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 250.0 then
			for k,i in pairs(taxiTable) do
				if v == i.npcObject then
					return k
				end
			end
		end
	end

	return 0
end
