Config = {}

-- Shared with players' clients. Never put secrets here: embed secrets are read from
-- server-only convars (see embedSecretConvar below and the README).

-- Seconds the panel waits for a site to load before showing a "can't be shown" message.
Config.LoadTimeout = 10

-- Ace that lets staff force-close another player's panel with /webclose <playerId>.
Config.AdminAce = 'webviewer.admin'

-- Command that closes your own panel (and, with Config.AdminAce, someone else's).
Config.CloseCommand = 'webclose'

-- One entry per website. The key (e.g. court) is the site id used by exports.
--   command            chat command that opens it (no slash). nil = only via exports.
--   url                https:// page to show. Players can't change it.
--   title              text in the panel's title bar.
--   ace                ace permission needed to open it. nil = everyone.
--   width / height     CSS size of the panel (e.g. '85vw', '1200px'). fullscreen = true fills the screen.
--   key                optional default keybind (players can rebind it in Settings > Key Bindings).
--   embedParam         add ?embed=cfx-nui-<resource> so the site knows which NUI page frames it.
--   embedSecretConvar  optional server-only convar holding a secret shared with the site. When set,
--                      each open adds a 60-second signed ?embed_token= so the site can trust the
--                      embed origin even though FiveM's browser sends no Referer.
Config.Sites = {
    court = {
        command = 'court',
        url = 'https://docket.sadoj.net/admin/login',
        title = 'SADOJ Docket',
        ace = 'courtcommand.allow',
        width = '85vw',
        height = '85vh',
        fullscreen = false,
        key = nil,
        embedParam = true,
        embedSecretConvar = 'court_embed_secret',
    },

    -- example = {
    --     command = 'wiki',
    --     url = 'https://example.com/',
    --     title = 'Server Wiki',
    --     ace = nil,
    --     width = '70vw',
    --     height = '80vh',
    --     key = 'F7',
    -- },
}
