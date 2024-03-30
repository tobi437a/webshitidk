local mt = getrawmetatable(game)
setreadonly(mt, false)

local originalNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local methodName = getnamecallmethod()
    local args = {...}

    if (methodName == "Kick" or methodName == "kick") and self == game.Players.LocalPlayer then
        warn("Attempt to kick LocalPlayer prevented.")
        return
    end

    return originalNamecall(self, unpack(args))
end)

setreadonly(mt, true)
