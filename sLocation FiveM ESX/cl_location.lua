ESX = exports['es_extended']:getSharedObject()

local lastSpawnTime = 0 
local isSpawningVehicle = false 
local rentalEndTime = nil 
local currentVehicle = nil 

function IsPositionFree(coords) 
    local vehicles = ESX.Game.GetVehiclesInArea(coords, 3.0)
    return #vehicles == 0 
end

function CheckAvailableSpawnPoint()
    local spawnPositions = Config_Location.VehicleSpawn.positions
    for _, pos in ipairs(spawnPositions) do 
        if IsPositionFree(vector3(pos.x, pos.y, pos.z)) then 
            return true 
        end
    end
    return false 
end

function SpawnVehicle(vehicleName) 
    if isSpawningVehicle then 
    end
    isSpawningVehicle = true 

    local playerPed = PlayerPedId() 
    local spawnPositions = Config_Location.VehicleSpawn.positions

    local spawnCoords = nil 
    local spawnHeading = nil 
    for _, pos in ipairs(spawnPositions) do 
        if IsPositionFree(vector3(pos.x, pos.y, pos.z)) then 
            spawnCoords = vector3(pos.x, pos.y, pos.z) 
            spawnHeading = pos.heading
            break 
        end
    end

    if not spawnCoords then 
        ESX.ShowNotification("🚨 Toutes les positions de spawn sont occupées")
        isSpawningVehicle = false 
        return 
    end 

    ESX.Game.SpawnVehicle(vehicleName, spawnCoords, spawnHeading, function(vehicle)
        if vehicle then 
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1) 
            currentVehicle = vehicle
        else 
            ESX.ShowNotification("🚨 Erreur lors de la création du véhicule. Merci d'ouvrir un ticket")
        end
        isSpawningVehicle = false 
    end)
end

RegisterNetEvent('s0ltrak:location:spawnVehicle', function(vehicleName, rentalTime)
    lastSpawnTime = GetGameTimer() 
    rentalEndTime = lastSpawnTime + rentalTime * 60000
    SpawnVehicle(vehicleName) 
end)

function OpenLocation() 
    local spawnLocationVeh = RageUI.CreateMenu('Location', 'Louer un véhicule')
    RageUI.Visible(spawnLocationVeh, not RageUI.Visible(spawnLocationVeh))

    while spawnLocationVeh do 
        Wait(0) 
        RageUI.IsVisible(spawnLocationVeh, function()
            for k, v in pairs(Config_Location.Location.Vehicule) do 
                RageUI.Button(v.label, 'Appuyez sur ~r~Entrée~s~ pour choisir la durée', {RightLabel = v.price .. "$"}, true, {
                    onSelected = function() 
                        if CheckAvailableSpawnPoint() then 
                            local input = lib.inputDialog("Durée de location", {
                                {label = "Entrez la durée en minutes :", type = "number", min = 1, max = 20}
                            })
                            if input and tonumber(input[1]) then 
                                local rentalTime = tonumber(input[1])
                                TriggerServerEvent('s0ltrak:location:buy', v.name, v.price, rentalTime)
                                RageUI.CloseAll()
                            else 
                                ESX.ShowNotification("🚨 Durée invalide")
                            end
                        else 
                            ESX.ShowNotification("🚨 Toutes les positions de spawn sont occupées")
                        end
                    end
                })
            end
        end)

        if not RageUI.Visible(spawnLocationVeh) then 
            spawnLocationVeh = nil
        end
    end
end



CreateThread(function()
    while true do 
        Wait(1000) 
        if currentVehicle and rentalEndTime then 
            local currentTime = GetGameTimer() 
            local timeLeft = math.ceil((rentalEndTime - currentTime) / 1000) 
            if timeLeft <= 0 then 
                SetVehicleEngineHealth(currentVehicle, 0) 
                SetVehicleUndriveable(currentVehicle, true) 
                ESX.ShowNotification("🚨 Le temps de location est écoulé. Le véhicule est désormais inutilisable") 
                currentVehicle = nil 
                currentEndTime = nil 
            else 
                local minutes = math.floor(timeLeft / 60) 
                local seconds = timeLeft % 60 
                if seconds == 0 then 
                    ESX.ShowNotification("🚨 Temps restant pour la location : " .. minutes .. " minutes. Avant l'arrêt total du vehicule")
                end
            end
        end
    end
end)


CreateThread(function()
    local blip = AddBlipForCoord(Config_Location.Location.pos)

    SetBlipSprite(blip, Config_Location.Location.Blip.Sprite)
    SetBlipDisplay(blip, Config_Location.Location.Blip.Display)
    SetBlipScale(blip, Config_Location.Location.Blip.Scale)
    SetBlipColour(blip, Config_Location.Location.Blip.Colour)
    SetBlipAsShortRange(blip, true) 
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Location de voiture")
    EndTextCommandSetBlipName(blip)

    while true do 
        Wait(0) 
        local playerPed = PlayerPedId() 
        local playerCoords = GetEntityCoords(playerPed) 
        local locationPos = Config_Location.Location.pos 

        if locationPos and playerCoords then 
            local distance = GetDistanceBetweenCoords(playerCoords, locationPos.x,locationPos.y ,locationPos.z, true) 
            if distance <= 1.5 then 
                DrawMarker(
                    Config_Location.Marker.type,
                locationPos.x,
                locationPos.y,
                locationPos.z - 1.0,
                0, 0, 0,
                0, 0, 0,
                Config_Location.Marker.scale.x, Config_Location.Marker.scale.y, Config_Location.Marker.scale.z,
                Config_Location.Marker.color.r, Config_Location.Marker.color.g, Config_Location.Marker.color.b, Config_Location.Marker.color.a,
                false, true, 2, nil, nil, false
             )
             ESX.ShowHelpNotification('Appuyez sur [~r~E~w~] pour intéragir')
             if IsControlJustReleased(0, 38) then 
                OpenLocation() 
             end
            else 
                Wait(500) 
            end
        else 
            print('[^6CLIENT^7] => [^6SERVER^7] => [^2INFO^7] => [^3ESX^7] => => [^6SERVER^7] => [^6SERVER^7] => [^2INFO^7] => [^3ESX^7] => => [^1ERROR^7] => => Coordonnées de location non définies')
            Wait(1000)
        end
    end
end)