-- Run with: lua5.4 tests/embed_test.lua  (from the repo root)
dofile("server/sha256.lua")
local Embed = dofile("server/embed.lua")

local function check(name, got, want)
    if got ~= want then
        error(string.format("%s\n  got:  %s\n  want: %s", name, tostring(got), tostring(want)))
    end
    print("ok - " .. name)
end

local SECRET = "test-embed-secret-0123456789"
local site = { url = "https://docket.sadoj.net/admin/login", embedParam = true, embedSecretConvar = "court_embed_secret" }

check("origin is lowercase", Embed.nuiOrigin("Court_Web"), "https://cfx-nui-court_web")
check("token matches court-connect vector", Embed.signToken(SECRET, "https://cfx-nui-court_web", 1792720600),
    "1792720600.d6ec7d0d1d2fb38689324c53f0a3931a4111867218d4ce9fa041638eaa954d39")
check("url with token", Embed.buildUrl(site, { resourceName = "court_web", secret = SECRET, now = 1792720540 }),
    "https://docket.sadoj.net/admin/login?embed=cfx-nui-court_web&embed_token=1792720600.d6ec7d0d1d2fb38689324c53f0a3931a4111867218d4ce9fa041638eaa954d39")
check("no secret: embed param only", Embed.buildUrl(site, { resourceName = "court_web", secret = "", now = 0 }),
    "https://docket.sadoj.net/admin/login?embed=cfx-nui-court_web")
local _, warning = Embed.buildUrl(site, { resourceName = "court_web", secret = "short", now = 0 })
check("short secret warns", warning ~= nil, true)
check("plain site untouched", Embed.buildUrl({ url = "https://example.com/" }, { resourceName = "x", now = 0 }), "https://example.com/")
check("existing query and hash", Embed.buildUrl({ url = "https://a.example/p?x=1#top", embedParam = true }, { resourceName = "web", now = 0 }),
    "https://a.example/p?x=1&embed=cfx-nui-web#top")
print("all embed tests passed")
