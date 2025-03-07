function PedFaceCoord(pPed, pCoords)
    TaskTurnPedToFaceCoord(pPed, pCoords.x, pCoords.y, pCoords.z)

    Citizen.Wait(100)

    while GetScriptTaskStatus(pPed, 0x574bb8f5) == 1 do
        Citizen.Wait(0)
    end
end

function GetHeadingFromCoords(targetCoords)
    local playerCoords = GetEntityCoords(PlayerPedId())

    local prX, prY = playerCoords.x * math.pi / 180, playerCoords.y * math.pi / 180
    local trX, trY = targetCoords.x * math.pi / 180, targetCoords.y * math.pi / 180

    local y = math.sin(trX - prX) * math.cos(trY)
    local x = math.cos(prY) * math.sin(trY) - math.sin(prY) * math.cos(trY) * math.cos(trX - prX)

    local bearing = math.atan2(y, x)

    local heading = bearing * 180 / math.pi

    return heading
end

function GetNearestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    if not (playerCoords and playerPed) then
        return
    end

    local pointB = GetEntityForwardVector(playerPed) * 0.001 + playerCoords

    local shapeTest = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z, pointB.x, pointB.y, pointB.z, 1.0, 10, playerPed, 7)
    local _, hit, _, _, entity = GetShapeTestResult(shapeTest)

    return (hit == 1 and IsEntityAVehicle(entity)) and entity or false
end

function GetClosestBone(entity, list)
    local playerCoords, bone, coords, distance = GetEntityCoords(PlayerPedId())

    for _, element in pairs(list) do
        local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
        local boneDistance = GetDistanceBetweenCoords(playerCoords, boneCoords, true)

        if not coords then
            bone, coords, distance = element, boneCoords, boneDistance
        elseif distance > boneDistance then
            bone, coords, distance = element, boneCoords, boneDistance
        end
    end

    if not bone then
        bone = {id = GetEntityBoneIndexByName(entity, "bodyshell"), type = "remains", name = "bodyshell"}
        coords = GetWorldPositionOfEntityBone(entity, bone.id)
        distance = #(coords - playerCoords)
    end

    return bone, coords, distance
end

function GetValidBones(entity, list)
    local bones = {}

    for _, bone in ipairs(list) do
        local boneID = GetEntityBoneIndexByName(entity, bone.name)

        if boneID ~= -1 then
            if bone.type == "door" and not IsVehicleDoorDamaged(entity, bone.index) or bone.type == "tyre" and not IsVehicleTyreBurst(entity, bone.index, 1) or bone.type == "engine" then
                bone.id = boneID
                bones[#bones + 1] = bone
            end

        end
    end

    return bones
end

function ChopVehiclePart(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local vehicleModel = GetEntityModel(vehicle)

    local boneList = GetValidBones(vehicle, Config.VehicleChopBones)

    local bone, coords, distance = GetClosestBone(vehicle, boneList)

    local success = false

    PedFaceCoord(PlayerPedId(), coords)

    print(bone.type)
    if bone.type == "tyre" and distance < 1.2 then
        success = ChopVehicleTyre(vehicle, bone.id, bone.index)
    elseif bone.type == "door" and distance < 1.6 then
        success = ChopVehicleDoor(vehicle, bone.id, bone.index)
    elseif bone.type == "engine" and distance < 1.6 then
        success = ChopVehicleEngine(vehicle, bone.id, bone.index)
    elseif bone.type == "remains" and distance < 1.8 then
        success = ChopVehicleRemains(vehicle)
    end

    return success, bone.type, vehicleModel
end

function ChopVehicleTyre(vehicle, boneID, tyreIndex)
    if IsVehicleTyreBurst(vehicle, tyreIndex, 1) then return end

    local task = AnimationTask(vehicle, "bone", boneID, 1.2, "normal", "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1)
    
    local finished = false
    QBCore.Functions.Progressbar("scrap_veh", Config.ProgressBar["tyre"].text, Config.ProgressBar["tyre"].time * 1000, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        finished = true
    end)
    while not finished do
        Wait(10)
    end
    success = finished

    task.abort()

    if success then
        TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "rubber", math.random(1,5))
        SetVehicleTyreBurst(vehicle, tyreIndex, true, 1000.0)
        ClearPedTasks(PlayerPedId())
    end

    return success
end

function ChopVehicleEngine(vehicle, boneID)
    print(vehicle)
    local task = AnimationTask(vehicle, "bone", boneID, 1.2, "normal", "mini@repair", "fixing_a_ped", 1)
    
    local finished = false
    QBCore.Functions.Progressbar("scrap_veh", Config.ProgressBar["engine"].text, Config.ProgressBar["engine"].time * 1000, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        finished = true
    end)
    while not finished do
        Wait(10)
    end
    success = finished

    task.abort()

    if success then
        -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(5,7))
    end

    return success
end

function ChopVehicleDoor(vehicle, boneID, doorIndex)
    if IsVehicleDoorDamaged(vehicle, doorIndex) then return end

    SetVehicleDoorOpen(vehicle, doorIndex, 0, 1)

    local task = AnimationTask(vehicle, "bone", boneID, 1.6, "scenario", "WORLD_HUMAN_WELDING")

    local finished = false
    QBCore.Functions.Progressbar("scrap_veh", Config.ProgressBar["doors"].text, Config.ProgressBar["doors"].time * 1000, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        finished = true
    end)

    while not finished do
        Wait(10)
    end

    success = finished

    local success = finished 

    task.abort()

    if success then
        local chance = math.random(1, 100)
        if chance >= 45 then
            totalitem = 0
            repeat
                local randomItem = math.random(8, 12)
                TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", Config.itemlist[math.random(#Config.itemlist)], randomItem)
                totalitem = totalitem + randomItem 
                Wait(25)
            until (totalitem <= 35)
        end
        -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(2, 5))
        -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(5,7))
        SetVehicleDoorBroken(vehicle, doorIndex, 1)
    end

    return success
end
local cooldown = false

RegisterCommand("dispatch",function()
    if Config.dispatchEvent.isServer then
        TriggerServerEvent(table.unpack(Config.dispatchEvent.event))
    else
        TriggerEvent(table.unpack(Config.dispatchEvent.event))
    end
end)

function ChopVehicleRemains(vehicle, boneID)
    if Config.dispatchEvent.isServer then
        TriggerServerEvent(table.unpack(Config.dispatchEvent.event))
    else
        TriggerEvent(table.unpack(Config.dispatchEvent.event))
    end
    local task = AnimationTask(vehicle, "bone", boneID, 1.8, "normal", "mp_car_bomb", "car_bomb_mechanic", 1)

    local finished = false
    -- if math.random(0, 100) >= 0 then
        -- TriggerEvent("civilian:alertPolice",600.0,"chopshop",veh)
    -- end
    QBCore.Functions.Progressbar("scrap_veh", Config.ProgressBar["engine"].text, Config.ProgressBar["engine"].time * 1000, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        task.abort()
        if not cooldown then 
            Wait(250)
        DeleteEntity(vehicle)
        finished = true
            randomItemWithClass(vehicle)
            setCooldown()
        else
            Wait(250)
            DeleteEntity(vehicle)
            finished = true
            randomCooldownItem()
        end
        Citizen.Wait(250)
    end)
    return finished
end

function randomCooldownItem()
    -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(2,5))
    -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(5,7))
    -- TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "mavikutu", math.random(5,7))
end


function setCooldown()
    cooldown = true
    Citizen.Wait(60 * 60* 1000)
    cooldown = false
end

-- function ChopVehiclePart(vehicle)
--     if not DoesEntityExist(vehicle) then return end

--     local vehicleModel = GetEntityModel(vehicle)

--     local boneList = GetValidBones(vehicle, Config.VehicleChopBones)

--     local bone, coords, distance = GetClosestBone(vehicle, boneList)

--     local success = false

--     PedFaceCoord(PlayerPedId(), coords)

--     if bone.type == "tyre" and distance < 1.2 then
--         success = ChopVehicleTyre(vehicle, bone.id, bone.index)
--     elseif bone.type == "door" and distance < 1.6 then
--         success = ChopVehicleDoor(vehicle, bone.id, bone.index)
--     elseif bone.type == "remains" and distance < 1.8 then
--         success = ChopVehicleRemains(vehicle)
--     end

--     return success, bone.type, vehicleModel
-- end


function AnimationTask(entity, coordsType, coordsOrigin, coordsDist, animationType, animDict, animName, animFlag)
    local self = {}

    self.active = true

    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local playerCoords, coords = GetEntityCoords(playerPed)

        if animationType == "scenario" then
            TaskStartScenarioInPlace(playerPed, animDict, 0, true)
        elseif animationType == "normal" then
            LoadAnimationDic(animDict)
        end

        while self.active do
            local idle = 100

            playerCoords = GetEntityCoords(playerPed)

            if coordsType == "bone" then
                coords = GetWorldPositionOfEntityBone(entity, coordsOrigin)
            else
                coords = GetEntityCoords(entity)
            end

            if animationType == "normal" and not IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
                TaskPlayAnim(playerPed, animDict, animName, -8.0, -8.0, -1, animFlag, 0, 0, 0, 0)
            end

            if #(coords - playerCoords) > coordsDist then
                self.abort()
            end

            Citizen.Wait(idle)
        end

        if animationType == "scenario" then
            ClearPedTasks(playerPed)
        else
            StopAnimTask(playerPed, animDict, animName, 1.5)
        end
    end)

    self.abort = function()
        self.active = false
    end

    return self
end

function LoadAnimationDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
end

function GetItemByName(items, item)
    for k, v in pairs(items) do
        if v.name == item then
            print(v.name, item)
            return v
        end
    end
end

function InteractiveChopping(vehicle, listId)
    if ActiveChopping[vehicle] then return end
    local state = { active = true }

    ActiveChopping[vehicle] = state

    local boneList = GetValidBones(vehicle, Config.VehicleChopBones)

    Citizen.CreateThread(function()
        while state.active do
            boneList = GetValidBones(vehicle, Config.VehicleChopBones)

            Citizen.Wait(100)
        end
    end)

    Citizen.CreateThread(function()
        while state.active do
            local idle = 500

            local bone, coords, distance = GetClosestBone(vehicle, boneList)
            if distance and distance <= 10.0 then
                local inDistance, chopText

                if bone.type == "tyre" and distance <= 1.6 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['tyre'].drawtext..""
                elseif bone.type == "engine" and distance <= 1.6 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['engine'].drawtext..""
                elseif bone.name == "bonnet" and distance <= 1.6 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['hood'].drawtext..""
                elseif bone.name == "boot" and distance <= 1.6 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['trunk'].drawtext..""
                elseif bone.type == "door" and distance <= 1.6 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['doors'].drawtext..""
                elseif bone.type == "remains" and distance <= 1.8 then
                    inDistance, chopText = true, "~g~E~w~ - "..Config.ProgressBar['engine'].drawtext..""
                end

                if inDistance then
                    DrawText3D(coords, chopText)
                    if IsControlJustReleased(0, 38) then
                        local success, boneType, vehicleModel = ChopVehiclePart(vehicle)
                    end
                end

                idle = 0
            end

            if not distance or distance > 10.0 then
                state.active = false
            end

            Citizen.Wait(idle)
        end

        ActiveChopping[vehicle] = nil
    end)
end
function DrawText3D(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-- function DrawText3D(x,y,z, text)
--     if type(x) ~= "number" then
--         SetTextScale(0.35, 0.35)
--         SetTextFont(4)
--         SetTextProportional(1)
--         SetTextColour(255, 255, 255, 215)
--         SetTextEntry("STRING")
--         SetTextCentre(true)
--         AddTextComponentString(y)
--         SetDrawOrigin(x.x,x.y,x.z, 0)
--         DrawText(0.0, 0.0)
--         local factor = (string.len(y)) / 370
--         DrawRect(0.0, 0.0+0.0125, 0.030+ factor, 0.03, 20,10,20, 200)
--         ClearDrawOrigin()
--     else
--         local onScreen, _x, _y = World3dToScreen2d(x.x,x.y,x.z)
--         SetTextScale(0.35, 0.35)
--         SetTextFont(4)
--         SetTextProportional(1)
--         SetTextColour(255, 255, 255, 215)
--         SetTextEntry("STRING")
--         SetTextCentre(true)
--         AddTextComponentString(text)
--         SetDrawOrigin(x,y,z, 0)
--         DrawText(0.0, 0.0)
--         local factor = (string.len(text)) / 370
--         DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 20,10,20, 200)
--         ClearDrawOrigin()
--     end
-- end

--[[
    Vehicle Classes:  
    0: Compacts  
    1: Sedans  
    2: SUVs  
    3: Coupes  
    4: Muscle  
    5: Sports Classics  
    6: Sports  
    7: Super  
    8: Motorcycles  
    9: Off-road  
    10: Industrial  
    11: Utility  
    12: Vans  
    13: Cycles  
    14: Boats  
    15: Helicopters  
    16: Planes  
    17: Service  
    18: Emergency  
    19: Military  
    20: Commercial  
    21: Trains  
]]--

function randomItemWithClass(veh)
    local vC = GetVehicleClass(veh)
    local vH = GetVehicleBodyHealth(veh) / 100
    local vehClasses = {
        [1] = "X",
        [2] = "S",
        [3] = "A",
        [4] = "B",
        [5] = "C",
        [6] = "D",
        [7] = "M",
     }
    local vehClassesReverse = {
        [1] = "M",
        [2] = "D",
        [3] = "C",
        [4] = "B",
        [5] = "A",
        [6] = "S",
        [7] = "X",
     }

    local vehItems = {
        [1] = "plastic",
        [2] = "metalscrap",
        [3] = "copper",
        [4] = "aluminum",
        [5] = "aluminumoxide",
        [6] = "iron",
        [7] = "ironoxide",
        [8] = "steel",
        [9] = "rubber",
        [10] = "glass",
     }
    if vC == 0 or vC == 1 or vC == 2 or vC == 3 then
        for i = 1, math.random(1, 3) do 
            TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", vehItems[math.random(#vehItems)], 1, false)
            Wait(250)
        end
    elseif vC == 4 then 
        for i = 1, math.random(2, 4) do 
            TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", vehItems[math.random(#vehItems)], 1, false)
            Wait(250)
        end
    elseif vC == 5 or vC == 6 then 
        for i = 1, math.random(2, 5) do 
            TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", vehItems[math.random(#vehItems)], 1, false)
            Wait(250)
        end
    elseif vC == 7 then 
        for i = 1, math.random(2, 5) do 
            TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", vehItems[math.random(#vehItems)], 1, false)
            Wait(250)
        end
    else
        for i = 1, math.random(1, 3) do 
            TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", vehItems[math.random(#vehItems)], 1, false)
            Wait(250)
        end
    end
 end

function OpenSellMenu(multiplier)
    PlayerData = QBCore.Functions.GetPlayerData()
    if not multiplier then
        multiplier = 1
    end
    local vehClasses = {
        ["X"] = 1,
        ["S"] = 2,
        ["A"] = 3,
        ["B"] = 4,
        ["C"] = 5,
        ["D"] = 5,
        ["M"] = 6,
     }
    local elementsDef = {}
    local elements = {
        {label = "Üzerinde hiç eşya yok", value = "close"}
    }
    elements = elementsDef
    for k, v in pairs(PlayerData.items) do
        for i = 1, #Config.cheapNpc.items do
            if v.name == Config.cheapNpc.items[i].name then
                if elements == elementsDef then
                    elemets = {}
                end
                local elementTable = {
                    label = "x".. v.amount .. " ".. v.label .. " ["..Config.cheapNpc.items[i].price[1] * multiplier.." ~ "..Config.cheapNpc.items[i].price[2] * multiplier.."] $",
                    value = {item = v, price = Config.cheapNpc.items[i].price}
                }
                table.insert(elements, elementTable)
            end
        end
    end
    if #elements >= 1 then
        local menuTable = {
            {
                header = "Chop Shop Market",
                isMenuHeader = true
            }
        }

        for i = 1, #elements do
            table.insert(menuTable, {
                header = elements[i].label,
                params = {
                    event = "x99-chopshop:client:sellItem",
                    args = {
                        item = elements[i].value.item,
                        price = elements[i].value.price
                    }
                }
            })
        end
        menuTable[#menuTable + 1] = {
            header = "Sell All",
            params = {
                event = "x99-chopshop:client:sellAllItems",
                args = {
                    multiplier = multiplier
                }
            }
        }
        exports[Config.coreData.smallEventPrefix..'-menu']:openMenu(menuTable)
        -- QBCore.UI.Menu.Open('default', GetCurrentResourceName(), 'chopshop_market', {
        --     title    = "Chop Shop Marketi",
        --     align    = 'right',
        --     elements = elements
        -- }, function(data, menu)
        --     if data.current.value ~= nil then
        --         TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:RemoveItem", data.current.value.item.name, data.current.value.item.amount)
        --         TriggerServerEvent(Config.coreData.eventPrefix .. ":Server:AddItem", "cash", data.current.value.item.amount * math.random(data.current.value.price[1] * multiplier, data.current.value.price[2] * multiplier))
        --         menu.close()
        --         Wait(150)
        --         OpenSellMenu(4)
        --     end
        -- end, function(data, menu)
        --     menu.close()
        -- end)
    else
        TriggerEvent("notification", "Satabileceğin bir malzemen yok", 2)
    end
end