-- get sound file here: https://anonfile.com/10Y4X6j4o4/voice_input_wav
local menu = gui.Reference("MISC", "GENERAL", "Extra")
local f12killsound = gui.Checkbox(menu, "killsound", "F12 Kill Sound", 0)
local currentTime = 0
local timer = 0
local enabled = true
local snd_time = 0.3 -- set sound file length default f12 sound = 0.6 .
local fl_val = nil
f12killsound:SetDescription("Plays F12 sound when you kill someone")
local function handler()
currentTime = globals.RealTime()
if currentTime >= timer then
timer = globals.RealTime() + snd_time
if enabled then
client.SetConVar("voice_loopback", 0, true)
client.SetConVar("voice_inputfromfile", 0, true)
client.Command("-voicerecord", true)
enabled = false
gui.SetValue("misc.fakelag.enable", fl_val)
end
end
end
local function on_player_death(Event)
if f12killsound:GetValue() == false or Event:GetName() ~= "player_death" then
return
end
local INT_ATTACKER = Event:GetInt("attacker")
if INT_ATTACKER == nil then
return
end
local local_ent = client.GetLocalPlayerIndex()
local attacker_ent = entities.GetByUserID(INT_ATTACKER)
if local_ent == nil or attacker_ent == nil then
return
end
if (attacker_ent:GetIndex() == local_ent) then
if not enabled then 
fl_val = gui.GetValue("misc.fakelag.enable")
end
gui.SetValue("misc.fakelag.enable", 0)
client.SetConVar("voice_loopback", 1, true)
client.SetConVar("voice_inputfromfile", 1, true)
client.Command("+voicerecord", true)
timer, enabled = globals.RealTime() + snd_time, true
end
end
client.AllowListener("player_death")
callbacks.Register("FireGameEvent", on_player_death)
callbacks.Register("Draw", handler)
