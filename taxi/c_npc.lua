local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end
local CUI = ImportPackage("cinematicui")

local taxibossTableIds = {}

AddRemoteEvent("taxiboss:setup", function(taxibossObjects)
    taxibossTableIds = taxibossObjects
end)

AddEvent("OnKeyPress", function(key)
    if key == "E" and not onSpawn and not onCharacterCreation then
        if GetNearestTaxiBossNpc() ~= 0 then
            CallRemoteEvent("TaxiCheckJob")
        end
    end
end)

AddRemoteEvent("taxiboss:startconversation", function(playerjob, playerlicense)
	local params = {
		title = _("taxiboss_name"),
		actions = {}
	}

	if playerjob == "" then
		if playerlicense == 1 then
			params.message = _("taxiboss_needjob")
			table.insert(params.actions, {
				text = _("taxiboss_yes1"),
				callback = "TakeJob",
				close_on_click = true
			})
		else
			params.message = _("taxiboss_needdriverlicense")
		end
	else
		if playerjob == "taxi" then
			params.message = _("taxiboss_whatdouwant")
			table.insert(params.actions, {
				text = _("taxiboss_spawn"),
				callback = "SpawnVehiculeTaxi",
				close_on_click = true
			})
				table.insert(params.actions, {
				text = _("taxiboss_leave"),
				callback = "LeaveTaxi",
				close_on_click = true
			})
		else
			params.message = _("taxiboss_havejob")
		end
	end

	table.insert(params.actions, {
		text = _("taxiboss_bye"),
		close_on_click = true
	})
	
	CUI.startCinematic(params, NearestNpc, "STOP")
end)

AddEvent("TakeJob", function()
	CallRemoteEvent("GetJobTaxi")
end)

AddEvent("SpawnVehiculeTaxi", function()
	CallRemoteEvent("SpawnTaxi")
end)

AddEvent("LeaveTaxi", function()
	CallRemoteEvent("LeaveJobTaxi")
end)

function GetNearestTaxiBossNpc()
    local x, y, z = GetPlayerLocation()
    
    for k, v in pairs(taxibossTableIds) do
        local x2, y2, z2 = GetNPCLocation(v)
        if x2 == nil or x2 == false then return 0 end
        local dist = GetDistance3D(x, y, z, x2, y2, z2)
        
        if dist < 200.0 then
            for k, i in pairs(taxibossTableIds) do                
                if v == i then
                    return v
                end
            end
        end
    end
    
    return 0
end