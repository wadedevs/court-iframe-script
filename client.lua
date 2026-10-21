local isOpen = false

-- CHANGE THIS to the website you want to display
local websiteUrl = "https://docket.sadoj.net/admin/login"

RegisterNetEvent('court:open', function()
    if isOpen then return end
    isOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'open',
        url = websiteUrl
    })
end)

RegisterNetEvent('court:forceClose', function()
    if isOpen then
        closeUI()
    end
end)

function closeUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb({ ok = true })
end)

-- Safety: release focus if resource stops while open
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and isOpen then
        SetNuiFocus(false, false)
    end
end)

-- Optional: allow Escape to also close (already handled in NUI, this is backup)
CreateThread(function()
    while true do
        if isOpen then
            if IsControlJustReleased(0, 322) then -- ESC
                closeUI()
            end
        end
        Wait(isOpen and 0 or 500)
    end
end)
