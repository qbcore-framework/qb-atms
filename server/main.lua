local dailyWithdraws = {}

QBCore.Functions.CreateCallback('qb-debitcard:server:requestCards', function(source, cb)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local visas = self.Functions.GetItemsByName('visa')
    local masters = self.Functions.GetItemsByName('mastercard')
    local cards = {}

    if visas ~= nil and masters ~= nil then
        for _, v in visas do
            table.insert(cards, v.info)
        end
        for _, v in masters do
            table.insert(cards, v.info)
        end
    end
    return cards
end)

QBCore.Functions.CreateCallback('qb-debitcard:server:deleteCard', function(source, cb, data)
    local cn = data.cardNumber
    local ct = data.cardType
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local found = xPlayer.Functions.GetCardSlot(cn, ct)
    if found ~= nil then
        xPlayer.Functions.RemoveItem(ct, 1, found)
        cb(true)
    else
        cb(false)
    end
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

RegisterServerEvent('qb-atms:server:openATM')
AddEventHandler('qb-atms:server:openATM', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local visas = xPlayer.Functions.GetItemsByName('visa')
    local masters = xPlayer.Functions.GetItemsByName('mastercard')
    local cards = {}

    if visas ~= nil and masters ~= nil then
        for _, v in pairs(visas) do
            local info = v.info
            local cardNum = info.cardNumber
            local cardHolder = info.citizenid
            local xCH = QBCore.Functions.GetPlayerByCitizenId(cardHolder)
            if xCH ~= nil then
                if xCH.PlayerData.charinfo.card ~= cardNum then
                    info.cardActive = false
                end
            else
                exports.ghmattimysql:execute('SELECT charinfo FROM players WHERE citizenid=@citizenid', {['@citizenid'] = info.citizenid}, function(player)
                    local xCH = json.decode(player[1].charinfo)
                    if xCH.card ~= cardNum then
                        info.cardActive = false
                    end
                end)
            end
            table.insert(cards, v.info)
        end
        for _, v in pairs(masters) do
            local info = v.info
            local cardNum = info.cardNumber
            local cardHolder = info.citizenid
            local xCH = QBCore.Functions.GetPlayerByCitizenId(cardHolder)
            if xCH ~= nil then
                if xCH.PlayerData.charinfo.card ~= cardNum then
                    info.cardActive = false
                end
            else
                exports.ghmattimysql:execute('SELECT charinfo FROM players WHERE citizenid=@citizenid', {['@citizenid'] = info.citizenid}, function(player)
                    xCH = json.decode(player[1].charinfo)
                    if xCH.card ~= cardNum then
                        info.cardActive = false
                    end
                end)
            end
            table.insert(cards, v.info)
        end
    end
    TriggerClientEvent('qb-atms:client:loadATM', src, cards)
end)

Citizen.CreateThread(function()
    while true do
        Wait(3600000)
        dailyWithdraws = {}
        TriggerClientEvent('QBCore:Notify', -1, "Daily Withdraw Limit Reset", "success")
    end
end)

RegisterServerEvent('qb-atms:server:doAccountWithdraw')
AddEventHandler('qb-atms:server:doAccountWithdraw', function(data)
    if data ~= nil then 
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local cardHolder = data.cid

        local xCH = QBCore.Functions.GetPlayerByCitizenId(cardHolder)
        if not dailyWithdraws[cardHolder] then
            dailyWithdraws[cardHolder] = 0
        end

        local dailyWith = tonumber(dailyWithdraws[cardHolder]) + tonumber(data.amount)

        if dailyWith < 5000 then
            local banking = {}
            if xCH ~= nil then
                local bank = xCH.Functions.GetMoney('bank')
                local bankCount = xCH.Functions.GetMoney('bank') - tonumber(data.amount)
                if bankCount > 0 then
                    xCH.Functions.RemoveMoney('bank', tonumber(data.amount))
                    xPlayer.Functions.AddMoney('cash', tonumber(data.amount))
                    dailyWithdraws[cardHolder] = dailyWithdraws[cardHolder] + tonumber(data.amount)
                    TriggerClientEvent('QBCore:Notify', src, "Withdraw $" .. data.amount .. ' from credit card. Daily Withdraws: ' .. dailyWithdraws[cardHolder], "success")
                else
                    TriggerClientEvent('QBCore:Notify', src, "You cant go into minus in ATM.", "error")
                end

                banking['online'] = true
                banking['name'] = xCH.PlayerData.charinfo.firstname .. ' ' .. xCH.PlayerData.charinfo.lastname
                banking['bankbalance'] = xCH.Functions.GetMoney('bank')
                banking['accountinfo'] = xCH.PlayerData.charinfo.account
                banking['cash'] = xPlayer.Functions.GetMoney('cash')
            else
                exports.ghmattimysql:execute('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = cardHolder}, function(player)
                    local xCH = json.decode(player[1])
                    local bankCount = tonumber(xCH.money.bank) - tonumber(data.amount)
                    if bankCount > 0  then
                        xPlayer.Functions.AddMoney('cash', tonumber(data.amount))
                        xCH.money.bank = bankCount
                        exports.ghmattimysql:execute('UPDATE players SET money=@money WHERE citizenid=@citizenid', {['@money'] = xCH.money, ['@citizenid'] = cardHolder})
                        dailyWithdraws[cardHolder] = dailyWithdraws[cardHolder] + tonumber(data.amount)
                        TriggerClientEvent('QBCore:Notify', src, "Withdraw $" .. data.amount .. ' from credit card. Daily Withdraws: ' .. dailyWithdraws[cardHolder], "success")
                    else
                        TriggerClientEvent('QBCore:Notify', src, "You cant go into minus in ATM.", "error")
                    end

                    banking['online'] = false
                    banking['name'] = xCH.charinfo.firstname .. ' ' .. xCH.charinfo.lastname
                    banking['bankbalance'] = xCH.money.bank
                    banking['accountinfo'] = xCH.charinfo.account
                    banking['cash'] = xPlayer.Functions.GetMoney('cash')
                end)
            end
            TriggerClientEvent('qb-atms:client:updateBankInformation', src, banking)
        else
            TriggerClientEvent('QBCore:Notify', src, "You have reached the daily limit.", "error")
        end
    end
end)


QBCore.Functions.CreateCallback('qb-atms:server:loadBankAccount', function(source, cb, cid, cardnumber)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local cardHolder = cid

    local xCH = QBCore.Functions.GetPlayerByCitizenId(cardHolder)
    local banking = {}
    if xCH ~= nil then
        banking['online'] = true
        banking['name'] = xCH.PlayerData.charinfo.firstname .. ' ' .. xCH.PlayerData.charinfo.lastname
        banking['bankbalance'] = xCH.Functions.GetMoney('bank')
        banking['accountinfo'] = xCH.PlayerData.charinfo.account
        banking['cash'] = xPlayer.Functions.GetMoney('cash')
    else
        exports.ghmattimysql:execute('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = cardHolder}, function(player)
            local xCH = json.decode(player[1])
            banking['online'] = false
            banking['name'] = xCH.charinfo.firstname .. ' ' .. xCH.charinfo.lastname
            banking['bankbalance'] = xCH.money.bank
            banking['accountinfo'] = xCH.charinfo.account
            banking['cash'] = xPlayer.Functions.GetMoney('cash')
        end)
    end
    cb(banking)
end)
