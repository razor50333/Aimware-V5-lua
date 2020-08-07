local window = gui.Window("rabisapaster.performance.window", "Performance Booster", 200, 400 , 250, 386)
local group = gui.Groupbox(window, "Settings", 16, 16, 218, 354)
local postprocess = gui.Checkbox(group, "rabisapaster.performance.postprocess", "Disable Post Processing", 0)
postprocess:SetDescription("This is already a part of the cheat... ")
local noshadows = gui.Checkbox(group, "rabisapaster.performance.noshadows", "Disable Shadows", 0)
noshadows:SetDescription("The only decent option")
local nosky = gui.Checkbox(group, "rabisapaster.performance.nosky", "Disable 3D sky", 0)
nosky:SetDescription("This would reduce fps, so it does't work")
local fpsboost = gui.Checkbox(group, "rabisapaster.performance.fpsboost", "Smart FPS Booster", 0)
fpsboost:SetDescription("There's nothing smart about it")
local fpsslider = gui.Slider(group, "rabisapaster.performance.fpsslider", "FPS to maintain", 60, 30, 145, 5)
fpsslider:SetDescription("Really only just try, this isn't magic")
local menuref = gui.Reference("MENU")

local lastpostprocess, lastnoshadows, active, lastfpsboost = nil, nil, false, nil

local function convars()

    if noshadows:GetValue() then
        client.SetConVar("r_shadows", 0, true);
        client.SetConVar("cl_csm_static_prop_shadows", 0, true );
        client.SetConVar("cl_csm_shadows", 0, true );
        client.SetConVar("cl_csm_world_shadows", 0, true );
        client.SetConVar("cl_foot_contact_shadows", 0, true );
        client.SetConVar("cl_csm_viewmodel_shadows", 0, true );
        client.SetConVar("cl_csm_rope_shadows", 0, true );
        client.SetConVar("cl_csm_sprite_shadows", 0, true );
    else
        client.SetConVar("r_shadows", 1, true);
        client.SetConVar("cl_csm_static_prop_shadows", 1, true );
        client.SetConVar("cl_csm_shadows", 1, true );
        client.SetConVar("cl_csm_world_shadows", 1, true );
        client.SetConVar("cl_foot_contact_shadows", 1, true );
        client.SetConVar("cl_csm_viewmodel_shadows", 1, true );
        client.SetConVar("cl_csm_rope_shadows", 1, true );
        client.SetConVar("cl_csm_sprite_shadows", 1, true );
    end

    if postprocess:GetValue() then
        client.SetConVar("mat_postprocess_enable", 0, true);
    else
        client.SetConVar("mat_postprocess_enable", 1, true);
    end

end

local time = nil

local frame_rate = 0.0
local function get_abs_fps()
    frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * globals.AbsoluteFrameTime()
    return math.floor((1.0 / frame_rate) + 0.5)
end

local function ondraw()

    if lastfpsboost ~= fpsboost:GetValue() then
        lastfpsboost = fpsboost:GetValue()
        if fpsboost:GetValue() then
            fpsslider:SetDisabled(false)
        else
            fpsslider:SetDisabled(true)
        end
    end

    if not active and menuref:IsActive() then
        window:SetActive(true)
        active = true
    elseif active and not menuref:IsActive() then
        window:SetActive(false)
        active = false
    end

    if time == nil then
        time = globals.CurTime()
    end

    if lastpostprocess ~= postprocess:GetValue() or lastnoshadows ~= noshadows:GetValue() then
        lastpostprocess = postprocess:GetValue()
        lastnoshadows = noshadows:GetValue()
        convars()
    end

    if fpsboost:GetValue() and globals.CurTime() - time >= 0.25 then
        local proctime = gui.GetValue("rbot.hitscan.maxprocessingtime")
        print(proctime)
        if get_abs_fps() < fpsslider:GetValue() then
            if proctime >= 10 then
                gui.SetValue("rbot.hitscan.maxprocessingtime", proctime - 5)
            end
        elseif get_abs_fps() > fpsslider:GetValue() then
            if proctime <= 70 then
                gui.SetValue("rbot.hitscan.maxprocessingtime", proctime + 5)
            end
        end
        time = nil
    end
end

callbacks.Register("Draw", ondraw)

local function event(e)
if e:GetName() == "round_start" then
    convars()
    end     
end

client.AllowListener("round_start")
callbacks.Register ("FireGameEvent", event)