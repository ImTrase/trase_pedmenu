function showError(text)
    if (not text) then
        print('^1[ERROR]^0: Text is nil')
        return
    end

    print(('^4[Ped-Menu] ^1[ERROR]^0: %s\n^4[Ped-Menu] ^3[Support]^0: Discord.gg/trase'):format(text))
end

function showSuccess(text)
    if (not text) then
        print('^1[ERROR]^0: Text is nil')
        return
    end

    print(('^4[Ped-Menu] ^2[SUCCESS]^0: %s'):format(text))
end

function getData()
    if (not config?.discord?.enabled) then return end

    local url = ('https://discordapp.com/api/guilds/%s'):format(config?.discord?.guild) or ''
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        data = resultData
    end, 'GET', '', {['Content-Type'] = 'application/json', ['Authorization'] = ('Bot %s'):format(config?.discord?.token)})

    while (not data) do Wait(100) end

    return json.decode(data)
end

function checkDiscord()
    if (not config?.discord?.enabled) then return end
    
    if (not config?.discord?.guild or config?.discord?.guild == '') then
        showError('Guild id specified in the config is not filled in or is unable to be found.')
        return
    end

    if (not config?.discord?.token or config?.discord?.token == '') then
        showError('Bot token specified in the config is not filled in or is unable to be found.')
        return
    end

    if (not config?.discord?.role or config?.discord?.role == '') then
        showError('Role specified in the config is not filled in or is unable to be found.')
        return
    end

    showSuccess(('Discord Authorized To: %s'):format(getGuildName()))
end

CreateThread(function()
    checkDiscord()
end)

function getGuildName()
    if (not config?.discord?.enabled) then return end

    local data = getData()

    if (data and type(data.name) == 'string') then
        return data.name or 'Unknown'
    else
        showError('Discord information provided is incorrect')
        return
    end
end

function getRoles(target)
    if (not config?.discord?.enabled) then return end
    
    local promise = promise.new()

    for k, v in ipairs(GetPlayerIdentifiers(target)) do
        if string.match(v, "discord:") then
            discordId = string.gsub(v, "discord:", "")
            break;
        end
    end

    local url = ('https://discordapp.com/api/guilds/%s/members/%s'):format(config?.discord?.guild, discordId) or ''

    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        local data = json.decode(resultData)
        local p_roles = {}

        if data then
            local roles = {}

            for i = 1, (type(data.roles) == 'table' and #data.roles or 0) do
                roles[i] = tonumber(data.roles[i])
            end

            p_roles = roles 
        end

        promise:resolve({p_roles})
    end, 'GET', '', {['Content-Type'] = 'application/json', ['Authorization'] = ('Bot %s'):format(config?.discord?.token)})
 
    return table.unpack(Citizen.Await(promise))
end

function hasRole(target, role)
    local roles = getRoles(target)

    for i = 1, (type(roles) == 'table' and #roles or 0) do
        if (roles[i] == tonumber(role)) then
            return true
        end
    end

    return false
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