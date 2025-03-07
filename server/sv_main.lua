QBCore = exports[Config.coreData.scriptName]:GetCoreObject()

RegisterNetEvent("x99-chopshop:server:sellItem")
AddEventHandler("x99-chopshop:server:sellItem", function(itemData, npctype)
    local player = QBCore.Functions.GetPlayer(source)
    local isInConfig = false
    for i = 1, #Config.itemlist do
        if Config.itemlist[i] == itemData.item.name then
            isInConfig = true
            break
        end
    end
    if player and isInConfig then
        local prices
        for k, v in pairs(Config.cheapNpc.items) do
             if v.name == itemData.item.name then
                 prices = v.price
                 break
             end
        end
        local price = 0
        for i = 1, itemData.item.amount do
            price = price + math.random(prices[1], prices[2])
        end 
        local success = player.Functions.RemoveItem(itemData.item.name, itemData.item.amount)
        if success then
            player.Functions.AddMoney("cash", price)
        end
    end
end)

RegisterNetEvent("x99-chopshop:server:sellAll")
AddEventHandler("x99-chopshop:server:sellAll", function()
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        for i = 1, #Config.itemlist do
            local itemData = player.Functions.GetItemByName(Config.itemlist[i])
            if itemData then
                for k, v in pairs(Config.cheapNpc.items) do
                    if v.name == itemData.name then
                        prices = v.price
                        break
                    end
                end
                local price = 0 
                for i = 1, itemData.amount do
                    price = price + math.random(prices[1], prices[2])
                end
                local success = player.Functions.RemoveItem(itemData.name, itemData.amount)
                if success then
                    player.Functions.AddMoney("cash", price)
                end
            end
        end
    end
end)