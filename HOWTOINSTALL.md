# Court Web UI (FiveM)

A simple permission-gated resource that opens a website inside a clean in-game window with a top-right close button.

## Installation

1. Drop the `court_web` folder into your server's `resources` directory.
2. Add this line to your `server.cfg`:
   ```
   ensure court_web
   ```
3. Restart the server (or `refresh` + `ensure court_web`).

## Permission Setup

Players need the Ace permission `courtcommand.allow` to use `/court`.

Example `server.cfg` entries:

```cfg
# Create a group
add_ace group.court courtcommand.allow allow

# Give the group to specific players (use their identifier)
add_principal identifier.license:YOUR_LICENSE_HERE group.court

# Or give it to your existing admin group
add_ace group.admin courtcommand.allow allow
```

You can also add it live with the console command:
```
add_ace group.admin courtcommand.allow allow
```

## Configuration

Edit `client.lua` and change this line to the website you want to display:

```lua
local websiteUrl = "https://example.com"
```

**Note:** Many websites block being embedded in iframes (X-Frame-Options / CSP). Test your target site. YouTube embed URLs, many CAD systems, and simple documentation sites usually work. Google, Facebook, Discord, etc. often do not.

## Commands

| Command       | Description                          | Permission          |
|---------------|--------------------------------------|---------------------|
| `/court`      | Opens the website window             | `courtcommand.allow` |
| `/courtclose` | Force-closes the window (self or ID) | `courtcommand.allow` |

## Features

- Clean centered window with top-right close button
- Escape key also closes the UI
- Proper NUI focus handling (no stuck cursor)
- Server-side Ace permission check
- Resource stop safety cleanup
