QBCore = exports[Config.coreData.scriptName]:GetCoreObject()
Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent(Config.coreData.eventPrefix ..':GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
    
    while QBCore.Functions.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    SharedItems = QBCore.Shared.Items
end)

RegisterNetEvent(Config.coreData.eventPrefix ..":Client:OnPlayerLoaded")
AddEventHandler(Config.coreData.eventPrefix ..":Client:OnPlayerLoaded", function()
    isLoggedIn = true
end)

CurrentCops = 0
isLoggedIn = false
isChopping = false
state = { active = false }
ActiveChopping = {}

Citizen.CreateThread(function()
    while Config.setPoliceCountEvent == nil do 
        Citizen.Wait(0)
        print("waiting to config settings")
    end
    RegisterNetEvent(Config.setPoliceCountEvent)
    AddEventHandler(Config.setPoliceCountEvent, function(amount)
        CurrentCops = amount
    end)
end)


Citizen.CreateThread(function()
    RequestModel(Config.cheapNpc.model)
    -- -- RequestModel(Config.secretNpc.model)
    -- while not HasModelLoaded(Config.secretNpc.model) do
    --     Citizen.Wait(0)
    -- end
    while not HasModelLoaded(Config.cheapNpc.model) do
        Citizen.Wait(0)
    end
    if not cheapPed then
        cheapPed = CreatePed(26, Config.cheapNpc.model, Config.cheapNpc.coords.x, Config.cheapNpc.coords.y, Config.cheapNpc.coords.z, Config.cheapNpc.heading, false, 1)
        SetPedCombatAttributes(cheapPed, 46, true)                     
        SetPedFleeAttributes(cheapPed, 0, 0)                      
        SetBlockingOfNonTemporaryEvents(cheapPed, true)
        SetEntityAsMissionEntity(cheapPed, true, true)
        SetEntityInvincible(cheapPed, true)
        FreezeEntityPosition(cheapPed, true)
    end
    if not secretPed then
        secretPed = CreatePed(26, Config.secretNpc.model, Config.secretNpc.coords.x, Config.secretNpc.coords.y, Config.secretNpc.coords.z, Config.secretNpc.heading, false, 1)
        SetPedCombatAttributes(secretPed, 46, true)                     
        SetPedFleeAttributes(secretPed, 0, 0)                      
        SetBlockingOfNonTemporaryEvents(secretPed, true)
        SetEntityAsMissionEntity(secretPed, true, true)
        SetEntityInvincible(secretPed, true)
        FreezeEntityPosition(secretPed, true)
    end
    local cheapShopCoords = GetOffsetFromEntityInWorldCoords(cheapPed, 0.1, 0.5, 0.1)
    local secretShopCoords = GetOffsetFromEntityInWorldCoords(secretPed, 0.1, 0.5, 0.1)
    local cheapShopList = 1
    local secretShopList = 1
    local show = false
    local haveItem = 0
    while true do
        local msec = 1000
        -- if isLoggedIn then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local vehicle = GetNearestVehicle()
        local boneList = GetValidBones(vehicle, Config.VehicleChopBones)
        local bone, coords, distance = GetClosestBone(vehicle, boneList)
        local hasNoItem = false
        -- print("zort")
        if CurrentCops >= Config.minCopCount then
            -- print("zort")
            if #(pedCoords - Config.ChopLocation) < 10 and not ActiveChopping[vehicle] then
                msec = 2
                if #(pedCoords - Config.ChopLocation) < 5 then
                    if IsPedInAnyVehicle(ped, false) and not ActiveChopping[vehicle] then
                        DrawText3D(Config.ChopLocation, "~g~E~w~ - "..Config.ChopText.."")
                        if IsControlJustPressed(0, 38) then
                            TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
                            while IsPedInAnyVehicle(ped, false) do
                                Wait(0)
                            end
                            Wait(1000)
                            -- SetTimeout(math.random(30000, 45000), function()
                            --     TriggerEvent('dispatch:client:sendDispatch', 'chopshop')
                            -- end)
                            InteractiveChopping(GetNearestVehicle())
                        end
                    -- elseif state.active then
                    --     print("a")
                    --     isChopping = true
                    --     local inDistance, chopText
    
                    --     if bone.type == "door" and distance <= 1.6 then
                    --         inDistance, chopText = true, "~w~~g~[E]~w~ Kapıyı sök"
                    --     elseif bone.type == "tyre" and distance <= 1.6 then
                    --         inDistance, chopText = true, "~w~~g~[E]~w~ Lastigi sök"
                    --     elseif bone.type == "remains" and distance <= 1.8 then
                    --         inDistance, chopText = true, "~w~~g~[E]~w~ Kalan aracı parcala"
                    --     end
    
                    --     if inDistance then
                    --         DrawText3D(coords, chopText) 
                    --         if IsControlJustPressed(0, 38) then
                    --             local success, boneType, vehicleModel = ChopVehiclePart(vehicle)
                    --         end
                    --     end
                    else
                        DrawText3D(Config.ChopLocation, "The Chop Shop")
                    end
                else
                    DrawText3D(Config.ChopLocation, "The Chop Shop")
                end
            end
        elseif #(pedCoords - Config.ChopLocation) < 5 and Config.enableNotAvailableText then
            msec = 2
            DrawText3D(Config.ChopLocation, "Chop Shop is not available")
        end
        if #(pedCoords - cheapShopCoords) < 2 then
            msec = 2
            -- print(show)
            if not show then
                print("updated")
                show = true
                PlayerData = QBCore.Functions.GetPlayerData()
                items = PlayerData.items
            end
            local getItem = GetItemByName(items, Config.cheapNpc.items[cheapShopList].name)
            print(getItem)
            if getItem then
                haveItem = getItem.amount
                hasNoItem = false
            else
                haveItem = 0
            end
            -- if haveItem ~= 0 then
                DrawText3D(cheapShopCoords, "[E] - Chop Shop Market")
                if IsControlJustPressed(0, 38) then
                    OpenSellMenu()
                end
            -- else
            --     DrawText3D(cheapShopCoords, "Satabilecegin bir esyan bulunmuyor")
            --     if cheapShopList < #Config.cheapNpc.items then
            --         cheapShopList = cheapShopList + 1
            --     elseif hasNoItem then
            --         msec = 0
            --         hasNoItem = true
            --         cheapShopList = 1
            --     end
            -- end
            -- else
            --     DrawText3D(cheapShopCoords, "Satabilecek malzemen bulunmamakta")
            -- end
            if IsControlJustPressed(1, 175) and cheapShopList < #Config.cheapNpc.items then
                cheapShopList = cheapShopList + 1
            elseif IsControlJustPressed(1, 174) and cheapShopList > 1 then
                cheapShopList = cheapShopList - 1
            elseif cheapShopList < 0 then
                cheapShopList = 1
            end
            if IsControlJustPressed(0, 176) then
                PlayerData = QBCore.Functions.GetPlayerData()
                items = PlayerData.items
                for k, v in pairs(items) do
                    if v.name == Config.cheapNpc.items[cheapShopList].name and v.amount > 0 then
                        TriggerEvent('inventory:client:ItemBox', SharedItems[v.name], 'remove', v.amount)
                        TriggerServerEvent("QBCore:Server:RemoveItem", v.name, v.amount)
                        Wait(300)
                        TriggerServerEvent("QBCore:Server:AddItem", "cash", v.amount * math.random(Config.cheapNpc.items[cheapShopList].price[1], Config.cheapNpc.items[cheapShopList].price[2]))
                        PlayerData = QBCore.Functions.GetPlayerData()
                        items = PlayerData.items
                        break
                    end
                end
            end
        elseif #(pedCoords - secretShopCoords) < 15 then
            -- while not IsEntityPlayingAnim(secretPed, Config.secretNpc.animdict, Config.secretNpc.animname, 3) and secretPed do
            --     print("asdddd")
            --     Wait(0)
            --     TaskPlayAnim(secretPed, Config.secretNpc.animdict, Config.secretNpc.animname, 8.0, 8.0, -1, 3, 0, 0, 0, 0)
            -- end
            if #(pedCoords - secretShopCoords) < 2 then
                -- print("asd")
                msec = 2
                DrawText3D(secretShopCoords, "[E] - Chop Shop Market")
                if IsControlJustPressed(0, 38) then
                    OpenSellMenu(2)
                end
            end
        else
            show = false
        end
        if not distance or distance > 10.0 then
            state.active = false
        end
        -- end
    Wait(msec)
    end
end)


AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    DeleteEntity(cheapPed)
    DeleteEntity(secretPed)
  end
end)

RegisterNetEvent("x99-chopshop:client:sellItem")
AddEventHandler("x99-chopshop:client:sellItem", function(itemData)
   TriggerServerEvent("x99-chopshop:server:sellItem", itemData)
end)

RegisterNetEvent("x99-chopshop:client:sellAllItems")
AddEventHandler("x99-chopshop:client:sellAllItems", function(itemData)
   TriggerServerEvent("x99-chopshop:server:sellAll")
end)