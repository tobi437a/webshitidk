local mt = getrawmetatable(game)
setreadonly(mt, false)

local originalNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local methodName = getnamecallmethod()
    local args = {...}

    if string.lower(methodName) == "kick" and self == game.Players.LocalPlayer then
        return
    end

    return originalNamecall(self, unpack(args))
end)

setreadonly(mt, true)
