# fivem-iframe: show any website in game

A small standalone FiveM resource that opens websites in an in-game panel. You list the sites in
`config.lua`; each one gets its own chat command, optional ace permission, size, title and keybind.
Nothing is tied to a particular website, and there are no framework dependencies.

## Install

1. Put this folder in your server's `resources` directory. Any folder name works. A name with only
   letters, digits and `-` (for example `web-viewer`) is the most compatible; see
   [Sites that check who frames them](#sites-that-check-who-frames-them).
2. Add it to `server.cfg`:
   ```cfg
   ensure web-viewer
   ```
3. Edit `config.lua`, then `restart web-viewer`.

Upgrading from the old court script? Replace the files in your existing folder (for example
`court_web`), keep your `ensure` line, and add the `court_embed_secret` convar below. `/court` and
the `courtcommand.allow` ace work the same as before.

## Configure sites

```lua
Config.Sites = {
    wiki = {
        command = 'wiki',               -- /wiki opens it (nil = exports only)
        url = 'https://example.com/',   -- players can't change this
        title = 'Server Wiki',
        ace = nil,                      -- nil = everyone, or e.g. 'wiki.allow'
        width = '70vw', height = '80vh',
        fullscreen = false,
        key = 'F7',                     -- optional default keybind
    },
}
```

Permissions use normal aces:

```cfg
add_ace group.court courtcommand.allow allow
add_principal identifier.discord:123456789012345678 group.court
add_ace group.admin webviewer.admin allow   # lets staff run /webclose <playerId>
```

`/webclose` closes your own panel. Esc and the close button do too.

## Exports

Server:

```lua
exports['web-viewer']:OpenSite(playerId, 'wiki')  -- no permission check: your resource decides
exports['web-viewer']:CloseSite(playerId)
```

Client:

```lua
exports['web-viewer']:OpenSite('wiki')       -- asks the server, which checks the site's ace
exports['web-viewer']:OpenUrl('https://example.com/', 'Title')
exports['web-viewer']:Close()
exports['web-viewer']:IsOpen()
```

## Which sites work

A resource can't force a website to appear inside a frame. Each site decides with its own
`X-Frame-Options` or `Content-Security-Policy: frame-ancestors` headers, and many large sites
(Google, banks, social networks) refuse. Sites that allow framing work. For a site that refuses,
the panel shows the browser's error page, or "This site can't be shown in game" if it never
finishes loading.

## Sites that check who frames them

The panel page's origin is `https://cfx-nui-<resource folder name>`. Sites that only allow
specific parents need to know that origin, but FiveM's browser doesn't send a Referer, and CSP
can't list a host with `_` or other characters outside letters, digits and `-`.

Set `embedParam = true` on a site to add `?embed=cfx-nui-<resource>` to its URL. That tells the site
who claims to be framing it, but anyone can add that parameter, so careful sites won't trust it on
its own.

For those, set `embedSecretConvar` and share a secret with the site. Each time the panel opens, the
server adds a signed token that's valid for 60 seconds:

```
?embed=cfx-nui-<resource>&embed_token=<expiry>.<hex HMAC-SHA256(secret, "embed-v1|https://cfx-nui-<resource>|<expiry>")>
```

The token only proves which in-game page is framing the site. It isn't a login.

Keep the secret server-side: use `set`, never `setr` (replicated convars are readable by every
player), and never put it in `config.lua`, which is sent to clients.

```cfg
set court_embed_secret "a-long-random-string-shared-with-the-site"
```

### SADOJ docket (court-connect)

The default `court` entry has `embedParam = true` and `embedSecretConvar = 'court_embed_secret'`.
Set `court_embed_secret` on the game server to the same value as `FIVEM_EMBED_SECRET` on
court-connect (at least 16 characters). Without it, the docket still loads when the folder name has
only letters, digits and `-`, but not for names like `court_web`.

## Tests

The token signer is pure Lua 5.4. Run its tests with:

```sh
lua5.4 tests/sha256_test.lua && lua5.4 tests/embed_test.lua
```
