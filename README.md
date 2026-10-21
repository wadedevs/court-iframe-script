## What's included

fxmanifest.lua

server.lua — /court command with courtcommand.allow Ace check

client.lua — NUI open/close + focus handling

html/index.html — Clean centered box with top-right ✕ button and iframe

README.md — Install and permission instructions

## Quick start

Extract the zip into your server’s resources folder (so you have resources/court_web/).

Add to server.cfg:textensure court_web

Give the permission (example):textadd_ace group.admin courtcommand.allow allow

Edit client.lua and change the websiteUrl variable to your actual site.

Restart the server / ensure the resource.

Players with the permission can use /court. Escape or the ✕ button closes it.
