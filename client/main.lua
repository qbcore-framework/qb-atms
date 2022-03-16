local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function PlayATMAnimation(animation)
    local playerPed = PlayerPedId()
    if animation == 'enter' then
        RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do
            Wait(1)
        end
        if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then
            TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 3000, 1, 1, true, true, true)
        end
    end

    if animation == 'exit' then
        RequestAnimDict('amb@prop_human_atm@male@exit')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@exit') do
            Wait(1)
        end
        if HasAnimDictLoaded('amb@prop_human_atm@male@exit') then
            TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@exit', "exit", 1.0,-1.0, 3000, 1, 1, true, true, true)
        end
    end
end

-- Events

RegisterNetEvent("hidemenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
end)

RegisterNetEvent('qb-atms:client:updateBankInformation', function(banking)
    SendNUIMessage({
        status = "loadBankAccount",
        information = banking
    })
end)

RegisterNetEvent('qb-atms:client:loadATM', function(cards)
    if cards ~= nil and cards[1] ~= nil then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed, true)
        for k, v in pairs(Config.ATMModels) do
            local hash = GetHashKey(v)
            local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
            if atm then
                local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, hash, false, false, false)
                local atmCoords = GetEntityCoords(obj, false)
                    PlayATMAnimation('enter')
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
        QBCore.Functions.Notify("Please visit a branch to order a card", "error")
    end
end)

-- Callbacks

RegisterNUICallback("NUIFocusOff", function(data, cb)
    TriggerServerEvent('qb-atms:server:unathorize')
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
    PlayATMAnimation('exit')
end)

RegisterNUICallback("playATMAnim", function(data, cb)
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(1)
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
end)

RegisterNUICallback("removeCard", function(data, cb)
    QBCore.Functions.TriggerCallback('qb-debitcard:server:deleteCard', function(hasDeleted)
        if hasDeleted then
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
            QBCore.Functions.Notify('Card has been deleted.', 'success')
        else
            QBCore.Functions.Notify('Failed to delete card.', 'error')
        end
    end, data)
end)

RegisterNUICallback('verifyPIN', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-atms:server:verifyPIN', function(isVerified)
        SendNUIMessage({
            status = isVerified and 'pinSuccess' or 'pinFailed'
        })
    end, data)
end)