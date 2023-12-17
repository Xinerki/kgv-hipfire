
-- Define what weapon GROUPS are allowed to hipfire
groups = {
	[860033945] = true, -- SHOTGUN
	[970310034] = true, -- ASSAULT RIFLE
	[-957766203] = true, -- SUBMACHINE GUN
	-- [1159398588] = true, -- LIGHT MACHINE GUN
	[3082541095] = true, -- SNIPER
	[-1212426201] = true, -- SNIPER TOO I THINK??
}

-- Define individual WEAPONS that are allowed to hipfire
weapons = {
	-- Grenade Launcher is a 'heavy', so is the rpg, but we don't want to hipfire that
	[`WEAPON_GRENADELAUNCHER`] = true,
	
	-- Railgun is a 'heavy' but is fine to hipfire
	[`WEAPON_RAILGUN`] = true,
	[`WEAPON_RAILGUNXM3`] = true,
}

-- Define individual WEAPONS that aren't allowed to hipfire
-- This and 'weapons' above bypasses category.
weapons_disabled = {
	-- These are the only SMGs that won't like this hipfire
	[`WEAPON_MICROSMG`] = true,
	[`WEAPON_TECPISTOL`] = true,
	[`WEAPON_MINISMG`] = true,
	[`WEAPON_GUSENBERG`] = true,
	[`WEAPON_MACHINEPISTOL`] = true,
}

-- the code

last_sync = 0
sync_interval = 100 -- sync every nth ms

CreateThread(function()
	while true do Wait(0)
		-- you don't need this, look away
		debug_render = GlobalState.debug
		
		for i,v in pairs(GetActivePlayers()) do
			local ped = GetPlayerPed(v)
			if ped ~= PlayerPedId() then
				local pos = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0)
				local pitch_u = Player(GetPlayerServerId(v)).state.hipfire_pitch_u or 0.0
				local pitch_d = Player(GetPlayerServerId(v)).state.hipfire_pitch_d or 0.0
				local h = GetEntityHeading(ped) - 161.3
			
				if debug_render then
					DrawMarker(
						28,
						pos,
						0.0, 0.0, 0.0,
						0.0, 0.0, 0.0,
						vec(1.0, 1.0, 1.0) * 0.05,
						64, 64, 255, 64,
						false, false, 0, false
					)
				end
				
				local off = vec(math.sin(math.rad(-h)), math.cos(math.rad(-h))) * 0.15 * (1.0 - pitch_u / 90.0)
				pos += vec(off.x, off.y, 0.0) -- * (1.0 - pitch_d / 90.0)
				pos += vec(0.0, 0.0, -0.25) * (1.0 - pitch_d / 90.0) / (1.0 - pitch_u / 180.0)
			
				if debug_render then
					DrawMarker(
						28,
						pos,
						0.0, 0.0, 0.0,
						0.0, 0.0, 0.0,
						vec(1.0, 1.0, 1.0) * 0.05,
						255, 0, 0, 64,
						false, false, 0, false
					)
				end
				
				local hipfiring = Player(GetPlayerServerId(v)).state.hipfire
				
				if hipfiring then
					SetIkTarget(ped, 4, nil, nil, pos.x, pos.y, pos.z, 0.0, 200, 200)
			
					if debug_render then
						DrawMarker(
							28,
							pos,
							0.0, 0.0, 0.0,
							0.0, 0.0, 0.0,
							vec(1.0, 1.0, 1.0) * 0.1,
							0, 255, 0, 64,
							false, false, 0, false
						)
					end
				end
			end
		end
	
		local pos = GetPedBoneCoords(PlayerPedId(), 57005, 0.0, 0.0, 0.0)
		local pitch_u = math.max(0.0, GetGameplayCamRelativePitch())
		local pitch_d = math.max(0.0, -GetGameplayCamRelativePitch())
		local h = GetEntityHeading(PlayerPedId()) - 161.3
		
		if debug_render then
			DrawMarker(
				28,
				pos,
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0,
				vec(1.0, 1.0, 1.0) * 0.05,
				64, 64, 255, 64,
				false, false, 0, false
			)
		end
		
		local off = vec(math.sin(math.rad(-h)), math.cos(math.rad(-h))) * 0.15 * (1.0 - pitch_u / 90.0)
		pos += vec(off.x, off.y, 0.0) -- * (1.0 - pitch_d / 90.0)
		pos += vec(0.0, 0.0, -0.25) * (1.0 - pitch_d / 90.0) / (1.0 - pitch_u / 180.0)
		
		if debug_render then
			DrawMarker(
				28,
				pos,
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0,
				vec(1.0, 1.0, 1.0) * 0.05,
				255, 0, 0, 64,
				false, false, 0, false
			)
		end
		
		local hipfiring = not IsPedRunningMeleeTask(PlayerPedId()) and not IsPedGoingIntoCover(PlayerPedId()) and not IsPedInCover(PlayerPedId()) and not IsPedReloading(PlayerPedId()) and IsAimCamActive() and not IsControlPressed(0, 25) and not IsControlPressed(0, 37)
		
		local _, wep = GetCurrentPedWeapon(PlayerPedId())
		local group = GetWeapontypeGroup(wep)
		
		hipfiring = hipfiring and (weapons[wep] or groups[group])
		hipfiring = hipfiring and not weapons_disabled[wep]
		
		if hipfiring then
			SetIkTarget(PlayerPedId(), 4, nil, nil, pos.x, pos.y, pos.z, 0.0, 200, 200)
			
			if debug_render then
				DrawMarker(
					28,
					pos,
					0.0, 0.0, 0.0,
					0.0, 0.0, 0.0,
					vec(1.0, 1.0, 1.0) * 0.1,
					0, 255, 0, 64,
					false, false, 0, false
				)
			end
		end
		
		if GetGameTimer() > last_sync + sync_interval then
			LocalPlayer.state:set('hipfire', hipfiring, true)
			LocalPlayer.state:set('hipfire_pitch_u', pitch_u, true)
			LocalPlayer.state:set('hipfire_pitch_d', pitch_d, true)
			last_sync = GetGameTimer()
		end
	end
end)