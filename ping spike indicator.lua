local function g_Math(int, max, declspec)
    local int = (int > max and max or int)

    local tmp = max / int;
    local i = (declspec / tmp)
    i = (i >= 0 and math.floor(i + 0.5) or math.ceil(i - 0.5))

    return i
end

local function g_ColorByInt(number, max)
    local Colors = {
        { 124, 195, 13 },
        { 176, 205, 10 },
        { 213, 201, 19 },
        { 220, 169, 16 },
        { 228, 126, 10 },
        { 229, 104, 8 },
        { 235, 63, 6 },
        { 237, 27, 3 },
        { 255, 0, 0 }
    }

    i = g_Math(number, max, #Colors)
    return
        Colors[i <= 1 and 1 or i][1], 
        Colors[i <= 1 and 1 or i][2],
        Colors[i <= 1 and 1 or i][3]
end

local g_Num, g_Curtime = {}, {}

callbacks.Register("DrawESP", "Ping spike", function(builder)
    local ent = builder:GetEntity()

    if ent:IsAlive() and ent:IsPlayer() then
        local g_iIndex = ent:GetIndex()
        local g_iLatency = entities.GetPlayerResources():GetPropInt("m_iPing", ent:GetIndex())

        if not g_Num[g_iIndex] or not g_Curtime[g_iIndex] then
            g_Num[g_iIndex] = 0
            g_Curtime[g_iIndex] = 0
        end

        local max_latency = (g_iLatency > 400 and 350 or g_iLatency)
        if g_Num[g_iIndex] ~= g_iLatency and g_Curtime[g_iIndex] < globals.RealTime() then
            d = g_Num[g_iIndex] > g_iLatency and -1 or 1
            g_Curtime[g_iIndex] = globals.RealTime() + 0.01

            g_Num[g_iIndex] = g_Num[g_iIndex] + d
        end

        local r, g, b = g_ColorByInt(g_Num[g_iIndex], 450)
        builder:Color(r, g, b, g_Num[g_iIndex] > 75 and 255 or g_Num[g_iIndex])
        builder:AddTextBottom(g_Num[g_iIndex] .. " ms")
        builder:Color(255, 255, 255, 255)
    end
end)
