config = {}

config.discord = { -- Required trase_discord: https://github.com/ImTrase/trase_discord
    enabled = true,
    role = '', -- The discord role of the donator, ensure the value is "number"
    refresh = { -- A command to refresh permissions. (Used to prevent discord rate limits) [ONLY FOR DISCORD PERMS]
        enabled = true, -- Enable commmand?
        command = 'pedrefresh', -- The command to refresh perms
        cooldown = 10 -- Seconds to wait between usage
    }
}

config.peds = {
    [1] = {label = 'DC', model = `a_m_m_fatlatin_01`},
    [2] = {label = 'Monkey', model = `a_c_chimp`},
}