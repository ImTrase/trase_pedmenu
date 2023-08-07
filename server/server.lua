local function hasRole(target, roleId)
    return exports.trase_discord:hasRole(target, roleId, false)
end

RegisterNetEvent('t-pedmenu:server:player-connected', function()
    if (not config or type(config) ~= 'table' or not config?.peds or type(config?.peds) ~= 'table') then
        print('^4[Ped-Menu] ^1[ERROR]^0: Config is corrupted or unable to be found.')
        return
    end

    local src = source
    local has_permission = false

    if (config?.discord?.enabled) then
        has_permission = (hasRole(source, config?.discord?.role) or IsPlayerAceAllowed(source, 'pedmenu'))
    else
        has_permission = IsPlayerAceAllowed(source, 'pedmenu')
    end

    TriggerClientEvent('t-pedmenu:client:player-connected', src, {config?.peds, has_permission})
end)

local cooldown = {}

if (config?.discord?.enabled and config?.discord?.refresh?.enabled) then
    RegisterCommand(config?.discord?.refresh?.command, function(source)
        if (cooldown[source]) then
            TriggerClientEvent('t-pedmenu:client:show-notification', source, ('You must ~r~wait~s~ %s seconds before using command again.'):format(cooldown[source]))
            return
        end

        local has_permission = false

        if (config?.discord?.enabled) then
            has_permission = (hasRole(source, config?.discord?.role) or IsPlayerAceAllowed(source, 'pedmenu'))
        else
            has_permission = IsPlayerAceAllowed(source, 'pedmenu')
        end

        TriggerClientEvent('t-pedmenu:client:update-perms', source, has_permission)

        cooldown[source] = config?.discord?.refresh?.cooldown

        while (cooldown[source] ~= 0) do
            Wait(1000)
            cooldown[source] = (cooldown[source] -1)

            if (cooldown[source] == 0) then
                cooldown[source] = nil
            end
        end
    end)
end