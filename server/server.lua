-----------------------------------------------------
---- For more scripts and updates, visit ------------
--------- https://discord.gg/trase ------------------
-----------------------------------------------------

if Config.Command.Enabled then
    RegisterCommand(Config.Command.Command, function(source, args, rawCommand)
        local src = source
        if Config.Command.RequiredRole then
            local canOpen = exports.trase_discord:hasRole(src, Config.Command.RequiredRole)

            if not canOpen then
                return TriggerClientEvent('chat:addMessage', src, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {'[ERROR]', 'You do not have permission to use this command!'}
                })
            end
        end

        TriggerClientEvent('trase:pedmenu:open', src)
    end, false)
end