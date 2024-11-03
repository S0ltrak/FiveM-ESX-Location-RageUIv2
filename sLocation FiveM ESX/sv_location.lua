ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('s0ltrak:location:buy', function(name, price, rentalTime)
    local source = source 
    local xPlayer = ESX.GetPlayerFromId(source) 
    local bank = tonumber(xPlayer.getAccount('bank').money)
    local playerName = xPlayer.getName() -- Nom du joueur
    local vehicleFound = false 

    for _, vehicle in pairs(Config_Location.Location.Vehicule) do 
        if vehicle.name == name and vehicle.price == tonumber(price) then 
            vehicleFound = true 
            if bank >= vehicle.price then 
                xPlayer.removeAccountMoney('bank', vehicle.price)
                TriggerClientEvent('esx:showNotification', source, "" .. price .. "$ vous ont été prélevés de votre compte bancaire ")
                TriggerClientEvent('s0ltrak:location:spawnVehicle', source, name, rentalTime)
                PerformHttpRequest("https://discord.com/api/webhooks/1302452865096486964/N9Qo17y6oeFC7IksP4VwxJQRWwVOnO_92v_Gh9dXFZQ8XOlHwbxjaR5Nlaq-uyHj6HCP", function(err, text, headers) end, "POST", json.encode({
                    username = "Location de Véhicule",
                    embeds = {{
                        title = "Achat de Location",
                        description = playerName .. " a loué un véhicule.",
                        color = 3066993,
                        fields = {
                            {name = "Véhicule", value = name, inline = true},
                            {name = "Prix", value = price .. "$", inline = true},
                            {name = "Durée de location", value = rentalTime .. " minutes", inline = true},
                            {name = "Compte bancaire restant", value = (bank - vehicle.price) .. "$", inline = true}
                        },
                        footer = {
                            text = "Location de Véhicule",
                            icon_url = "https://e7.pngegg.com/pngimages/200/551/png-clipart-car-finance-vehicle-leasing-money-loan-car-payment-text-truck-thumbnail.png" 
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") 
                    }}
                }), {["Content-Type"] = "application/json"})
            else 
                TriggerClientEvent('esx:showNotification', source, "🚨 Vous n'avez pas d'argent sur votre compte bancaire")
            end
            break
        end
    end

    if not vehicleFound then 
        TriggerClientEvent('esx:showNotification', source, "🚨 Le véhicule n'existe pas")
    end
end)
