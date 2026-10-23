local RESOURCE = GetCurrentResourceName()
local warned = {}

local function log(msg)
    print(('[%s] %s'):format(RESOURCE, msg))
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, {
        color = { 255, 80, 80 },
        args = { 'Web', msg },
    })
end

local function canOpen(src, site)
    return not site.ace or IsPlayerAceAllowed(src, site.ace)
end

-- Opens a site for a player without a permission check. Commands and client requests
-- check permissions before calling this; other resources calling the export decide themselves.
local function openSite(src, siteId)
    local site = Config.Sites[siteId]
    if not site or type(site.url) ~= 'string' then
        log(('unknown site "%s"'):format(tostring(siteId)))
        return false
    end
    local secret = site.embedSecretConvar and GetConvar(site.embedSecretConvar, '') or nil
    local url, warning = Embed.buildUrl(site, { resourceName = RESOURCE, secret = secret, now = os.time() })
    if warning and not warned[siteId] then
        warned[siteId] = true
        log(('site "%s": %s'):format(siteId, warning))
    end
    TriggerClientEvent(RESOURCE .. ':open', src, {
        id = siteId,
        url = url,
        title = site.title or siteId,
        width = site.width,
        height = site.height,
        fullscreen = site.fullscreen == true,
        timeout = Config.LoadTimeout,
    })
    return true
end

local function closeSite(src)
    TriggerClientEvent(RESOURCE .. ':close', src)
end

for siteId, site in pairs(Config.Sites) do
    if site.command then
        RegisterCommand(site.command, function(src)
            if src == 0 then
                log(('/%s can only be used in game'):format(site.command))
                return
            end
            if not canOpen(src, site) then
                notify(src, ('You do not have permission to use /%s.'):format(site.command))
                return
            end
            openSite(src, siteId)
        end, false)
    end
    if site.embedSecretConvar and GetConvar(site.embedSecretConvar, '') == '' then
        log(('site "%s": convar %s is not set, so no embed token is sent (fine if the site allows framing without one)'):format(siteId, site.embedSecretConvar))
    end
end

-- Client export OpenSite asks the server, so permissions are always checked here.
RegisterNetEvent(RESOURCE .. ':request', function(siteId)
    local src = source
    local site = type(siteId) == 'string' and Config.Sites[siteId]
    if not site then return end
    if not canOpen(src, site) then
        notify(src, 'You do not have permission to open that.')
        return
    end
    openSite(src, siteId)
end)

RegisterCommand(Config.CloseCommand or 'webclose', function(src, args)
    local target = tonumber(args[1])
    if target and target ~= src then
        if src ~= 0 and not IsPlayerAceAllowed(src, Config.AdminAce) then
            notify(src, 'You do not have permission to close another player\'s panel.')
            return
        end
        closeSite(target)
    elseif src ~= 0 then
        closeSite(src)
    end
end, false)

exports('OpenSite', openSite)
exports('CloseSite', closeSite)
