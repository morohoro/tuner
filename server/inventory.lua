if config.sandboxmode then return end
QBCore = nil
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

GetPlayerFromId = function(src)
    if QBCore then
        return QBCore.Functions.GetPlayer(src)
    end
end

GetInventoryItems = function(src, method, items, metadata)
    if QBCore then
        local Player = GetPlayerFromId(src)
        local data = {}
        for _, item in pairs(Player.PlayerData.items or {}) do
            if items == item.name then
                item.metadata = item.info
                if item and item.metadata and item.metadata.quality then
                    item.metadata.durability = item.metadata.quality
                end
                table.insert(data, item)
            end
        end
        return data
    end
end

GetMoney = function(src)
    if QBCore then
        local Player = GetPlayerFromId(src)
        return Player.PlayerData.money.cash
    end
end

RemoveMoney = function(src, amount)
    if QBCore then
        local Player = GetPlayerFromId(src)
        Player.Functions.RemoveMoney('cash', tonumber(amount))
    end
end

RemoveInventoryItem = function(src, item, count, metadata, slot)
    if QBCore then
        return exports['qb-inventory']:RemoveItem(src, item, count, slot, metadata)
    end
end

AddInventoryItem = function(src, item, count, metadata, slot)
    if QBCore then
        metadata.quality = metadata.durability
        return exports['qb-inventory']:AddItem(src, item, count, slot, metadata)
    end
end

SetDurability = function(src, percent, slot, metadata, item)
    if QBCore then
        local Player = GetPlayerFromId(src)
        Player.PlayerData.items[slot].info.quality = percent
        Player.Functions.SetPlayerData("items", Player.PlayerData.items)
    end
end

RegisterStash = function(id, label, slots, size, perms, groups)
    if GetResourceState('ox_inventory') ~= 'started' then return end
    return exports.ox_inventory:RegisterStash(id, label, slots, size, perms, groups)
end

-- Register ESX & QBcore Items if ox_inventory is missing
RegisterUsableItem = {}
if QBCore then
    RegisterUsableItem = QBCore.Functions.CreateUseableItem
end

if GetResourceState('ox_inventory') ~= 'started' then
    local register = function(source, item)
        local src = source
        local Player = GetPlayerFromId(src)
        local itemdata = type(item) == 'table' and item or {name = item, label = item} -- support ancient framework
        RemoveInventoryItem(src, itemdata.name, 1, itemdata.metadata, itemdata.slot)
        TriggerClientEvent("useItem", src, false, {name = itemdata.name, label = itemdata.label}, true)
    end
    for k, v in pairs(config.engineparts) do
        RegisterUsableItem(v.item, register)
    end
    for k, v in pairs(config.engineupgrades) do
        RegisterUsableItem(v.item, register)
    end
    for k, v in pairs(config.tires) do
        RegisterUsableItem(v.item, register)
    end
    for k, v in pairs(config.drivetrain) do
        RegisterUsableItem(v.item, register)
    end
    for k, v in pairs(config.extras) do
        RegisterUsableItem(v.item, register)
    end
    RegisterUsableItem('repairparts', register)
end
