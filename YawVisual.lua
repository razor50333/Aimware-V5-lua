callbacks.Register("FireGameEvent", function(event)

	if event:GetName() == "round_start" then
		client.SetConVar("viewmodel_fov", 78, true)
		client.SetConVar("viewmodel_offset_z", -2, true)
		client.SetConVar("viewmodel_offset_x", 2, true)
		client.SetConVar("fov_cs_debug", 100, true);
	end

end)

local TickCountValue = 64 * 2;
local DataItems = { };
local LastTickCount = globals.TickCount();

local function GetFadeRGB(Factor, Speed)
    local r = math.floor(math.sin(Factor * Speed) * 127 + 128)
    local g = math.floor(math.sin(Factor * Speed + 2) * 127 + 128)
    local b = math.floor(math.sin(Factor * Speed + 4) * 127 + 128)
    return r, g, b;
end

local function MotionTrajectory()
    
    local LocalPlayer = entities.GetLocalPlayer();
    if (LocalPlayer == nil or LocalPlayer:IsAlive() ~= true) then
        DataItems = { };
        return;
    end
    
    ScreenX, ScreenY = draw.GetScreenSize();
    
    for i = 1, #DataItems do
        local ItemCurrent = DataItems[i];
        local ItemNext = DataItems[i + 1];
        
        if (ItemCurrent ~= nil and ItemNext ~= nil) then
            local CPosX, CPosY = client.WorldToScreen(ItemCurrent.x, ItemCurrent.y, ItemCurrent.z);
            local NPosX, NPosY = client.WorldToScreen(ItemNext.x, ItemNext.y, ItemNext.z);

            if (CPosX ~= nil and CPosY ~= nil and NPosX ~= nil and NPosY ~= nil and CPosX < ScreenX and CPosY < ScreenY and NPosX < ScreenX and NPosY < ScreenY) then
                local ColorR, ColorG, ColorB = GetFadeRGB(i / 10, 1);
                draw.Color(ColorR, ColorG, ColorB, 255);
                draw.Line(CPosX, CPosY, NPosX, NPosY);
                draw.Line(CPosX + 1, CPosY + 1, NPosX + 1, NPosY + 1);
            end
        end
    end
    
    
    local CurrentTickCount = globals.TickCount();
    if (CurrentTickCount - LastTickCount < 1) then
        return;
    end
    
    LastTickCount = CurrentTickCount;
    
    ----------------------------------------------
    
    local LocX, LocY, LocZ = LocalPlayer:GetAbsOrigin();
    local ItemData = { x = LocX, y = LocY, z = LocZ };

    table.insert(DataItems, 1, ItemData);
    if (#DataItems == TickCountValue + 1) then
        table.remove(DataItems, TickCountValue + 1);
    end
    
end

callbacks.Register("Draw", "CbDraw", MotionTrajectory);

local storedTick = 0
local crouched_ticks = { }


local function toBits(num)
    local t = { }
    while num > 0 do
        rest = math.fmod(num,2)
        t[#t+1] = rest
        num = (num-rest) / 2
    end

    return t
end

callbacks.Register("DrawESP", "FD_Indicator", function(Builder)
    local g_Local = entities.GetLocalPlayer()
    local Entity = Builder:GetEntity()

  

    if g_Local == nil or Entity == nil or not Entity:IsAlive() then
        return
    end

    local index = Entity:GetIndex()
    local m_flDuckAmount = Entity:GetProp("m_flDuckAmount")
    local m_flDuckSpeed = Entity:GetProp("m_flDuckSpeed")
    local m_fFlags = Entity:GetProp("m_fFlags")

    if crouched_ticks[index] == nil then
        crouched_ticks[index] = 0
    end

    if m_flDuckSpeed ~= nil and m_flDuckAmount ~= nil then
        if m_flDuckSpeed == 8 and m_flDuckAmount <= 0.9 and m_flDuckAmount > 0.01 and toBits(m_fFlags)[1] == 1 then
            if storedTick ~= globals.TickCount() then
                crouched_ticks[index] = crouched_ticks[index] + 1
                storedTick = globals.TickCount()
            end

            if crouched_ticks[index] >= 5 then
                Builder:Color(255, 255, 0, 255)
                Builder:AddTextRight("Fake Duck")
            end
        else
            crouched_ticks[index] = 0
        end
    end
end)

local VIS_REF = gui.Reference("Visuals", "World", "Extra")
local tracer_enable = gui.Checkbox(VIS_REF, "tracer_enabled", "Enable bullet tracer for localplayer", true)
local tracer_duration = gui.Slider(VIS_REF, "tracer_duration", "Duration of bullet tracer (in seconds)", 2, 0, 60)
local colors =  {{255,0,0}, {0,255,0}, {0,255,255}}
local tracers = {}


local function FireGameEvent(e)
 if not tracer_enable:GetValue() then return end
    if (e:GetName() == "bullet_impact") then
        local shooter = entities.GetByUserID(e:GetInt("userid"))
        if shooter and shooter:GetName() == entities.GetLocalPlayer():GetName() then
            local hit_pos = Vector3(e:GetFloat("x"), e:GetFloat("y"), e:GetFloat("z"))
 local pos = entities.GetLocalPlayer():GetHitboxPosition(1) -- head
 
 table.insert(tracers, {
 hit_pos = hit_pos,
 lp_pos = pos,
 color = colors[ math.random(#colors)],
 time = globals.CurTime()
 })
 
        end
 end
end

local function draw_tracers()
 if not tracer_enable:GetValue() then return end
 for i, v in ipairs(tracers) do
 if globals.CurTime() < v.time + tracer_duration:GetValue() then
 local x, y = client.WorldToScreen( v.hit_pos )
 local x2, y2 = client.WorldToScreen( v.lp_pos ); 
 if x and x2 and y and y2 then
 -- tracers[i].cache = {x=x,y=y,x2=x2,y2=y2}
 draw.Color(unpack(v.color))
 draw.Line(x,y,x2,y2)
 end
 else
 table.remove(tracers, i)
 end
 end
end

client.AllowListener("bullet_impact")
client.AllowListener("player_hurt")
callbacks.Register("FireGameEvent", FireGameEvent)
callbacks.Register("Draw", draw_tracers) 
