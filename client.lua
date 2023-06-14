
categories = {
	[860033945] = true,
	[970310034] = true,
	[1159398588] = true,
	[3082541095] = true,
	[-1212426201] = true,
}

weapons = {
	[`WEAPON_GRENADELAUNCHER`] = true
}

weapons_disabled = {}

CreateThread(function()
	while true do Wait(0)
		for i,v in pairs(GetActivePlayers()) do
			local ped = GetPlayerPed(v)
			if ped ~= PlayerPedId() then
				local pos = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0)
				local pitch_u = Player(GetPlayerServerId(v)).state.hipfire_pitch_u or 0.0
				local pitch_d = Player(GetPlayerServerId(v)).state.hipfire_pitch_d or 0.0
				local h = GetEntityHeading(ped) - 167.1
				
				local off = vec(math.sin(math.rad(-h)), math.cos(math.rad(-h))) * 0.25 * (1.0 - pitch_u / 90.0)
				pos += vec(off.x, off.y, 0.0) -- * (1.0 - pitch_d / 90.0)
				pos += vec(0.0, 0.0, -0.25) * (1.0 - pitch_d / 90.0) / (1.0 - pitch_u / 180.0)
				
				local hipfiring = Player(GetPlayerServerId(v)).state.hipfire
				
				if hipfiring then
					SetIkTarget(ped, 4, nil, nil, pos.x, pos.y, pos.z, 0.0, 200, 200)
				end
			end
		end
	
		local pos = GetPedBoneCoords(PlayerPedId(), 57005, 0.0, 0.0, 0.0)
		local pitch_u = math.max(0.0, GetGameplayCamRelativePitch())
		local pitch_d = math.max(0.0, -GetGameplayCamRelativePitch())
		local h = GetEntityHeading(PlayerPedId()) - 167.1
		
		local off = vec(math.sin(math.rad(-h)), math.cos(math.rad(-h))) * 0.25 * (1.0 - pitch_u / 90.0)
		pos += vec(off.x, off.y, 0.0) -- * (1.0 - pitch_d / 90.0)
		pos += vec(0.0, 0.0, -0.25) * (1.0 - pitch_d / 90.0) / (1.0 - pitch_u / 180.0)
		
		local hipfiring = not IsPedRunningMeleeTask(PlayerPedId()) and not IsPedGoingIntoCover(PlayerPedId()) and not IsPedInCover(PlayerPedId()) and not IsPedReloading(PlayerPedId()) and IsAimCamActive() and not IsControlPressed(0, 25) and not IsControlPressed(0, 37)
		
		local _, wep = GetCurrentPedWeapon(PlayerPedId())
		local category = GetWeapontypeGroup(wep)
		
		hipfiring = hipfiring and (weapons[wep] or categories[category])
		hipfiring = hipfiring and not weapons_disabled[wep]
		
		if hipfiring then
			SetIkTarget(PlayerPedId(), 4, nil, nil, pos.x, pos.y, pos.z, 0.0, 200, 200)
		end
		
		LocalPlayer.state:set('hipfire', hipfiring, true)
		LocalPlayer.state:set('hipfire_pitch_u', pitch_u, true)
		LocalPlayer.state:set('hipfire_pitch_d', pitch_d, true)
	end
end)