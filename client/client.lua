WarMenu.CreateMenu('peds', '', 'Ped Menu')

local data = {}

CreateThread(function() -- Don't mind this, once the player connects it will no longer loop.
	while (true) do
        Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
			Wait(500)
			TriggerServerEvent('t-pedmenu:server:player-connected')
			break
		end
    end
end)

RegisterNetEvent('t-pedmenu:client:player-connected', function(s_data)
    data.peds = s_data[1]
    data.donator = s_data[2]
end)

RegisterNetEvent('t-pedmenu:client:show-notification', function(text)
    notification(text)
end)

RegisterNetEvent('t-pedmenu:client:update-perms', function(bool)
    if (bool == nil or type(bool) ~= 'boolean') then return end

    data.donator = bool
    notification('Permissions have been ~g~refreshed~s~.')
end)

function notification(text)
    SetNotificationTextEntry('string')
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(true, true)
end

function getModel()
    local ped = PlayerPedId()
    return GetEntityModel(ped)
end

function changePed(args)
    if (not args or type(args) ~= 'table') then return end
    local ped = args?.model

    if (not IsModelValid(ped) or not IsModelAPed(ped)) then
        notification(('%s is not a valid ped model.'):format(input))
        return
    end

    RequestModel(ped)
    while not HasModelLoaded(ped) do Wait(100) end
    SetPlayerModel(PlayerId(), ped)
    SetModelAsNoLongerNeeded(ped)

    notification(('%s is now your current ped model.'):format(args?.label))
end

function openMenu()
    if (not data?.donator) then
        notification('You are ~r~not~s~ a donator.')
        return
    end

    if WarMenu.IsAnyMenuOpened() then return end

    WarMenu.OpenMenu('peds')

    while (true) do
        if (WarMenu.Begin('peds')) then
            for i = 1, (type(data?.peds) == 'table' and #data?.peds or 0) do
                local v = data?.peds[i]
                local btn = WarMenu.Button(v.label, getModel() == v.model and '~g~Enabled' or '~c~Disabled')

                if (btn) then
                    changePed(v)
                end
            end
            WarMenu.End()
        else
            return
        end

        Wait(0)
    end
end

RegisterCommand('pedmenu', function() openMenu() end)
RegisterKeyMapping('pedmenu', 'Open Pedmenu', 'keyboard', '')