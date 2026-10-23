-- Builds the URL sent to the client for a site: the configured URL plus the optional
-- ?embed= origin hint and a short-lived signed ?embed_token=.
--
-- Token format (must match the site, e.g. court-connect server/embed.js):
--   <exp>.<hex HMAC-SHA256(secret, "embed-v1|<origin>|<exp>")>
-- where origin is the NUI page origin, https://cfx-nui-<resource name in lowercase>.
local Embed = {}

Embed.TOKEN_TTL = 60
Embed.MIN_SECRET_LENGTH = 16

function Embed.nuiOrigin(resourceName)
    -- Browsers lowercase hostnames, so the origin the site sees is lowercase.
    return 'https://cfx-nui-' .. string.lower(resourceName)
end

function Embed.urlEncode(value)
    return (tostring(value):gsub('[^%w%-%._~]', function(ch)
        return string.format('%%%02X', ch:byte())
    end))
end

function Embed.appendQuery(url, params)
    if #params == 0 then return url end
    local hashAt = url:find('#', 1, true)
    local base, hash = url, ''
    if hashAt then base, hash = url:sub(1, hashAt - 1), url:sub(hashAt) end
    local parts = {}
    for _, kv in ipairs(params) do
        parts[#parts + 1] = Embed.urlEncode(kv[1]) .. '=' .. Embed.urlEncode(kv[2])
    end
    local sep = base:find('?', 1, true) and '&' or '?'
    return base .. sep .. table.concat(parts, '&') .. hash
end

function Embed.signToken(secret, origin, exp)
    return tostring(exp) .. '.' .. Sha256.hmacHex(secret, 'embed-v1|' .. origin .. '|' .. tostring(exp))
end

-- site: a Config.Sites entry. opts: { resourceName, secret (string or nil), now (unix seconds) }.
-- Returns url, warning (string or nil).
function Embed.buildUrl(site, opts)
    local origin = Embed.nuiOrigin(opts.resourceName)
    local params = {}
    local warning
    if site.embedParam ~= false and (site.embedParam or site.embedSecretConvar) then
        params[#params + 1] = { 'embed', origin:sub(#'https://' + 1) }
    end
    if site.embedSecretConvar then
        local secret = opts.secret or ''
        if #secret >= Embed.MIN_SECRET_LENGTH then
            if site.embedParam == false then
                params[#params + 1] = { 'embed', origin:sub(#'https://' + 1) }
            end
            params[#params + 1] = { 'embed_token', Embed.signToken(secret, origin, opts.now + Embed.TOKEN_TTL) }
        elseif #secret > 0 then
            warning = ('convar %s is shorter than %d characters, so no embed token is sent'):format(site.embedSecretConvar, Embed.MIN_SECRET_LENGTH)
        end
    end
    return Embed.appendQuery(site.url, params), warning
end

_G.Embed = Embed
return Embed
