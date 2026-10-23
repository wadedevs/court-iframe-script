local RESOURCE = GetCurrentResourceName()
local isOpen = false

-- CSP (frame-ancestors) can't name hosts with characters other than letters, digits and "-".
-- Sites can still trust such names through a signed embed token, but warn so owners know.
if RESOURCE:find('[^%w%-]') then
    print(('[%s] note: the resource name has characters other than letters, digits and "-". '
        .. 'Sites that check the embed origin need an embed token (see README) or a renamed folder.'):format(RESOURCE))
end

local function open(data)
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'open', site = data })
end

local function close()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'close' })
end

RegisterNetEvent(RESOURCE .. ':open', function(data)
    if type(data) ~= 'table' or type(data.url) ~= 'string' then return end
    open(data)
end)

RegisterNetEvent(RESOURCE .. ':close', close)

RegisterNUICallback('close', function(_, cb)
    close()
    cb({ ok = true })
end)

-- Default keybinds (players can change them in Settings > Key Bindings > FiveM).
for siteId, site in pairs(Config.Sites) do
    if site.command and site.key then
        RegisterKeyMapping(site.command, ('Open %s'):format(site.title or siteId), 'keyboard', site.key)
    end
end

-- Backup ESC handling in case the page loses keyboard focus to the iframe.
CreateThread(function()
    while true do
        if isOpen then
            DisableControlAction(0, 200, true) -- pause menu
            if IsDisabledControlJustReleased(0, 200) or IsControlJustReleased(0, 322) then
                close()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name == RESOURCE and isOpen then
        SetNuiFocus(false, false)
    end
end)

-- Exports for other client resources.
exports('OpenSite', function(siteId)
    TriggerServerEvent(RESOURCE .. ':request', siteId)
end)

-- Opens an arbitrary URL (no embed token). Only other resources on your server can call this.
exports('OpenUrl', function(url, title)
    if type(url) ~= 'string' or not url:match('^https?://') then return end
    open({ id = 'custom', url = url, title = title or url, timeout = Config.LoadTimeout })
end)

exports('Close', close)
exports('IsOpen', function() return isOpen end)
