local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function PlayATMAnimation(animation)
    local playerPed = PlayerPedId()
    if animation == 'enter' then
        RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do
            Wait(0)
        end
        TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end

    if animation == 'exit' then
        RequestAnimDict('amb@prop_human_atm@male@exit')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@exit') do
            Wait(0)
        end
        TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@exit', "exit", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end
end

local listen = false
local function Listen4Control()
    listen = true

    CreateThread(function()
        while listen do
            if IsControlJustPressed(0, 38) then -- E
                exports["qb-core"]:KeyPressed()
                TriggerServerEvent("qb-atms:server:enteratm")
                listen = false
                break
            end
            Wait(1)
        end
    end)
end

-- Events

RegisterNetEvent("hidemenu", function()
	InATM = false
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

local NewZones = {}
CreateThread(function()
    if not Config.UseTarget then
        for k, v in pairs(Config.ATMcoords) do
            NewZones[#NewZones+1] = CircleZone:Create(vector3(v.x, v.y, v.z), 1.5, {
                useZ = true,
                debugPoly = false,
                name = k,
            })
        end

        local combo = ComboZone:Create(NewZones, {name = "RandomZOneName", debugPoly = false})
        combo:onPlayerInOut(function(isPointInside, point, zone)
            if isPointInside then
                exports["qb-core"]:DrawText("[E] Use ATM")
                Listen4Control()
            else
                exports["qb-core"]:HideText()
                listen = false
            end
        end)
    else
        exports['qb-target']:AddTargetModel(Config.ATMModels, {
            options = {
                {
                    event = 'qb-atms:server:enteratm',
                    type = 'server',
                    icon = "fas fa-credit-card",
                    label = "Use ATM",
                },
            },
            distance = 1.5,
        })
    end
end)

RegisterNetEvent('qb-atms:client:loadATM', function(cards)
    if cards and cards[1] then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed, true)
        for _, v in pairs(Config.ATMModels) do
            local hash = joaat(v)
            local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
            if atm then
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

RegisterNUICallback("NUIFocusOff", function()
    InATM = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
    PlayATMAnimation('exit')
end)

RegisterNUICallback("playATMAnim", function()
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), anim, "idle_a", 1.0,-1.0, 3000, 1, 1, true, true, true)
end)

RegisterNUICallback("doATMWithdraw", function(data)
    if data then
        TriggerServerEvent('qb-atms:server:doAccountWithdraw', data)
    end
end)

RegisterNUICallback("loadBankingAccount", function(data)
    QBCore.Functions.TriggerCallback('qb-atms:server:loadBankAccount', function(banking)
        if banking and type(banking) == "table" then
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

RegisterNUICallback("removeCard", function(data)
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
