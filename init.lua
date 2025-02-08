local PlayerData = {}
local invehicle = false
local imagepath = 'nui://qb-inventory/html/images/'

-- Check if QB-Core is started
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    PlayerData = QBCore.Functions.GetPlayerData()

    -- Set job grade if it exists
    if PlayerData.job then
        PlayerData.job.grade = PlayerData.job.grade and PlayerData.job.grade.level or 1
    end

    -- Radial menu access
    if lib.addRadialItem then
        SetTimeout(100, function()
            local access = HasAccess()
            return access and HasRadialMenu()
        end)
    end

    -- Event for when player is loaded
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.job then
            PlayerData.job.grade = PlayerData.job.grade and PlayerData.job.grade.level or 1
        end
        HasRadialMenu()
    end)

    -- Event for job updates
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        PlayerData.job = job
        if PlayerData.job then
            PlayerData.job.grade = PlayerData.job.grade and PlayerData.job.grade.level or 1
        end
        HasRadialMenu()
    end)

else
    -- Fallback for standalone mode
    PlayerData = { job = 'mechanic', grade = 9 }
    if lib.addRadialItem then
        SetTimeout(100, function()
            return HasRadialMenu()
        end)
    end
    warn('You are not using any supported framework')
end
