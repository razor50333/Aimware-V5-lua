-- Usage --
panorama.RunScript([[
    RPCServer.register("eval", (arg)=>{
        return eval(arg)
    })
    RPCServer.register("localize", (...args)=>{
        let ret = []
        for (let i = 0; i < args.length; i++) {
            ret.push($.Localize(args[i]))
        }
        return ret
    })
    RPCClient.call("print", ["hello", "panorama"])
]])
RPCClient.call("eval", function(ctx)
    print(ins(ctx))
end, "GameStateAPI.GetScoreDataJSO()")
RPCServer.register("print", function(...)
    print(ins({...}))
end)

local function localize(str)
    RPCClient.call("localize", function(ctx)
        print(ins(ctx))
    end, str)
end
local function localize_string(str)
    local res = localize(str)
    if res == "#FIXME_LOCALIZATION_FAIL_MISSING_STRING" then
        res = false
    end
    return res and res or str
end
local function text_split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end
local function split_localize(text)
    local args = text_split(text, " ")
    local ret = ""
    for key, value in pairs(args) do
        local cache_value = value
        if string.find(value, "%(") then
            value = string.sub(value, 2, -2)
            local res = localize_string(value)
            if res == value then
                value = cache_value
            end
        end
        ret = ret .. localize_string(value)
    end
    return ret
end
print(split_localize("Jungle"))
