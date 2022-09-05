local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__Decorate = ____lualib.__TS__Decorate
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 1,["9"] = 1,["10"] = 3,["11"] = 11,["12"] = 12,["13"] = 11,["15"] = 23,["16"] = 22,["17"] = 13,["18"] = 14,["19"] = 15,["20"] = 13,["21"] = 18,["22"] = 19,["23"] = 18,["24"] = 26,["25"] = 27,["26"] = 28,["27"] = 30,["28"] = 31,["29"] = 26,["30"] = 35,["31"] = 36,["32"] = 35,["33"] = 11,["34"] = 12});
local ____exports = {}
local ____tstl_2Dutils = require("lib.tstl-utils")
local reloadable = ____tstl_2Dutils.reloadable
local heroSelectionTime = 10
____exports.GameMode = __TS__Class()
local GameMode = ____exports.GameMode
GameMode.name = "GameMode"
function GameMode.prototype.____constructor(self)
    self:configure()
end
function GameMode.Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context)
end
function GameMode.Activate()
    GameRules.Addon = __TS__New(____exports.GameMode)
end
function GameMode.prototype.configure(self)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 3)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 3)
    GameRules:SetShowcaseTime(0)
    GameRules:SetHeroSelectionTime(heroSelectionTime)
end
function GameMode.prototype.Reload(self)
    print("Script reloaded!")
end
GameMode = __TS__Decorate({reloadable}, GameMode)
____exports.GameMode = GameMode
return ____exports
