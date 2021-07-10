playerData, playerLoaded = nil, false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function(data)
    playerData = data
    playerLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    playerData = nil
end)

RegisterNetEvent("hidemenu")
AddEventHandler("hidemenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
end)

RegisterNUICallback("NUIFocusOff", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
end)

RegisterNUICallback("playATMAnim", function(data, cb)
    local playerPed = PlayerPedId()
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(1)
    end

    if HasAnimDictLoaded(anim) then 
        TaskPlayAnim(PlayerPedId(), anim, "idle_a", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end
end)

RegisterNUICallback("doATMWithdraw", function(data, cb)
    if data ~= nil then
        TriggerServerEvent('qb-atms:server:doAccountWithdraw', data)
    end
end)

RegisterNetEvent('qb-atms:client:updateBankInformation')
AddEventHandler('qb-atms:client:updateBankInformation', function(banking)
    SendNUIMessage({
        status = "loadBankAccount",
        information = banking
    })
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end 

RegisterNUICallback("loadBankingAccount", function(data, cb)
    QBCore.Functions.TriggerCallback('qb-atms:server:loadBankAccount', function(banking)
        if banking ~= false and type(banking) == "table" then
            SendNUIMessage({
                status = "loadBankAccount",
                information = banking
            })
        else
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
        end
    end, data.cid, data.cardnumber)
    print(data.cid, data.cardnumber)
end)

RegisterNetEvent('qb-atms:client:loadATM')
AddEventHandler('qb-atms:client:loadATM', function(cards)
    if cards ~= nil and cards[1] ~= nil then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed, true)
        for k, v in pairs(Config.ATMModels) do
            local hash = GetHashKey(v)
            local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.2)
            if atm then 
                local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, hash, false, false, false)
                local atmCoords = GetEntityCoords(obj, false)
                QBCore.Functions.Progressbar("accessing_atm", "Accessing ATM", 1500, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function() -- Done
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        status = "openATMFrontScreen",
                        cards = cards,
                    })
                end, function()
                    QBCore.Functions.Notify("Failed!", "error")
                end)
            end
        end     
    else
        QBCore.Functions.Notify("You do not have a debit card to pay with, please visit a branch to order a card. or ensure one is on your person.", "error")
    end
end)

RegisterNUICallback("removeCard", function(data, cb)
    QBCore.Functions.TriggerCallback('qb-debitcard:server:deleteCard', function(hasDeleted)
        if hasDeleted then
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
            QBCore.Functions.Notify('Card has deleted.', 'success')
        else
            QBCore.Functions.Notify('Failed to delete card.', 'error')
        end
    end, data)
end)

local letSleep = true
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        letSleep = true
        if playerLoaded and QBCore ~= nil then 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed, true)
            for k, v in pairs(Config.ATMModels) do
                local hash = GetHashKey(v)
                local nearATM = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.2)
                if nearATM then 
                    local atm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, hash, false, false, false)
                    local atmExists = DoesEntityExist(atm)
                    if atmExists then 
                        local atmCoords = GetEntityCoords(atm)
                        QBCore.Functions.DrawText3D(atmCoords.x, atmCoords.y, atmCoords.z+1, "Press ~g~E~s~ to use the ATM.")
                        letSleep = false
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent("qb-atms:server:openATM")
                        end
                    end
                end
            end
        end

        if letSleep then
            Citizen.Wait(100)
        end
    end
end)
