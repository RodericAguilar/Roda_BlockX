function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayWeapon(weapon,distance,flag)
    local cameraRotation = GetGameplayCamRot()
    
    local weapCoord = GetEntityCoords(weapon)

    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance, 
		cameraCoord.y + direction.y * distance, 
		cameraCoord.z + direction.z * distance 
    )
    if not flag then
        flag = 1
    end
   
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(weapCoord.x, weapCoord.y, weapCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

function RayCastGamePlayCamera(weapon,distance,flag)
    local cameraRotation = GetGameplayCamRot()
    
    local weapCoord = GetEntityCoords(weapon)

    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance, 
		cameraCoord.y + direction.y * distance, 
		cameraCoord.z + direction.z * distance 
    )
    if not flag then
        flag = 1
    end

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

Citizen.CreateThread(function()
    local ped, weapon, pedid, sleep, shoot
    while true do
         sleep = 500 
         pedid = PlayerId()
         ped = PlayerPedId()
         weapon = GetCurrentPedWeaponEntityIndex(ped)
        
        if weapon > 0 and IsPlayerFreeAiming(pedid) then
            local hitW, coordsW, entityW = RayCastGamePlayWeapon(weapon, 15.0,1)
            local hitC, coordsC, entityC = RayCastGamePlayCamera(weapon, 1000.0,1)
            if hitW > 0 and entityW > 0 and math.abs(#coordsW-#coordsC) > 1 then
                sleep = 0
                if Config.All['displaytext'] then 
                Draw3DText(coordsW.x, coordsW.y, coordsW.z, Config.All['text'])
                end
                DisablePlayerFiring(ped,true) 
                DisableControlAction(0, 106, true) 
            end
        else
            Citizen.Wait(1000)
        end    
        Citizen.Wait(sleep)
    end
end)

function Draw3DText(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    if onScreen then
        SetTextScale(0.3, 0.3)
        SetTextFont(0)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end
