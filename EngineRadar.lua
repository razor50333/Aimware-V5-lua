----    Base    code    for    auto    updating.
--
--local    cS    =    GetScriptName()
--local    cV    =    '1.0.0'
--local    gS    =    'PUT    LINK    TO    RAW    LUA    SCRIPT'
--local    gV    =    'PUT    LINK    TO    RAW    VERSION'
--
--local    function    AutoUpdate()
--	if    gui.GetValue('lua_allow_http')    and    gui.GetValue('lua_allow_cfg')    then
--		local    nV    =    http.Get(gV)
--		if    cV    ~=    nV    then
--			local    nF    =    http.Get(gS)
--			local    cF    =    file.Open(cS,    'w')
--			cF:Write(nF)
--			cF:Close()
--			print(cS,    'updated    from',    cV,    'to',    nV)
--		else
--			print(cS,    'is    up-to-date.')
--		end
--	end
--end		
--
--callbacks.Register('Draw',    'Auto    Update')
--callbacks.Unregister('Draw',    'Auto    Update')



local vis_tab_radar = gui.Reference('VISUALS')
local vis_main_tab = gui.Tab(vis_tab_radar, "lua_tab_radar", "EngineRadar & FPSboost")
local EngineRadarchk = gui.Checkbox ( vis_main_tab, "lua_engine_radar", "Enable EngineRadar", 0 );


local function engine_radar_draw()

for index, Player in pairs(entities.FindByClass("CCSPlayer")) do

if not EngineRadarchk:GetValue() then        

Player:SetProp("m_bSpotted", 0);


else

Player:SetProp("m_bSpotted", 1);

end
end
end

callbacks.Register("Draw", "engine_radar_draw", engine_radar_draw);
