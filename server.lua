-- Server-side command with Ace permission check
-- Players need the ace: courtcommand.allow

RegisterCommand('court', function(source, args, rawCommand)
    if source == 0 then
        print('[court_web] This command can only be used in-game.')
        return
    end

    if not IsPlayerAceAllowed(source, 'courtcommand.allow') then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 50, 50},
            multiline = true,
            args = {"Court", "You do not have permission to use /court."}
        })
        return
    end

    -- Tell the client to open the UI
    TriggerClientEvent('court:open', source)
end, false)

-- Optional: allow admins to force-close for a player
RegisterCommand('courtclose', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'courtcommand.allow') then
        local target = tonumber(args[1]) or source
        if target and target > 0 then
            TriggerClientEvent('court:forceClose', target)
        end
    end
end, true)
