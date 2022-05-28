--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 118,["6"] = 118,["7"] = 119,["8"] = 120,["11"] = 124,["12"] = 125,["13"] = 126,["14"] = 127,["15"] = 128,["16"] = 129,["17"] = 129,["18"] = 129,["19"] = 129,["21"] = 132,["24"] = 136,["25"] = 137,["26"] = 138,["27"] = 139,["28"] = 142,["29"] = 143,["32"] = 147,["35"] = 2,["36"] = 2,["37"] = 2,["39"] = 2,["40"] = 5,["41"] = 5,["42"] = 5,["44"] = 5,["45"] = 8,["46"] = 8,["47"] = 8,["49"] = 8,["50"] = 9,["51"] = 16,["52"] = 16,["54"] = 17,["55"] = 9,["56"] = 20,["57"] = 21,["58"] = 20,["59"] = 24,["60"] = 25,["61"] = 24,["62"] = 30,["63"] = 30,["64"] = 30,["65"] = 30,["66"] = 33,["67"] = 33,["68"] = 33,["69"] = 33,["70"] = 36,["71"] = 36,["72"] = 36,["73"] = 36,["74"] = 39,["75"] = 40,["76"] = 41,["77"] = 44,["78"] = 45,["79"] = 47,["81"] = 49,["83"] = 52,["84"] = 54,["85"] = 55,["87"] = 57,["89"] = 60,["90"] = 62,["91"] = 63,["92"] = 64,["93"] = 65,["94"] = 66,["96"] = 63,["97"] = 44,["98"] = 71,["99"] = 72,["100"] = 74,["102"] = 76,["104"] = 79,["105"] = 80,["106"] = 82,["107"] = 83,["109"] = 85,["111"] = 88,["112"] = 90,["113"] = 91,["114"] = 92,["115"] = 93,["116"] = 94,["118"] = 91,["119"] = 98,["120"] = 99,["121"] = 100,["122"] = 101,["123"] = 102,["125"] = 104,["126"] = 105,["128"] = 107,["129"] = 108,["132"] = 112,["134"] = 115,["135"] = 71});
local ____exports = {}
local clearTable, getFileScope, toDotaClassInstance
function clearTable(self, ____table)
    for key in pairs(____table) do
        __TS__Delete(____table, key)
    end
end
function getFileScope(self)
    local level = 1
    while true do
        local info = debug.getinfo(level, "S")
        if info and info.what == "main" then
            return {
                getfenv(level),
                info.source
            }
        end
        level = level + 1
    end
end
function toDotaClassInstance(self, instance, ____table)
    local prototype = ____table.prototype
    while prototype do
        for key in pairs(prototype) do
            if not (rawget(instance, key) ~= nil) then
                instance[key] = prototype[key]
            end
        end
        prototype = getmetatable(prototype)
    end
end
____exports.BaseAbility = __TS__Class()
local BaseAbility = ____exports.BaseAbility
BaseAbility.name = "BaseAbility"
function BaseAbility.prototype.____constructor(self)
end
____exports.BaseItem = __TS__Class()
local BaseItem = ____exports.BaseItem
BaseItem.name = "BaseItem"
function BaseItem.prototype.____constructor(self)
end
____exports.BaseModifier = __TS__Class()
local BaseModifier = ____exports.BaseModifier
BaseModifier.name = "BaseModifier"
function BaseModifier.prototype.____constructor(self)
end
function BaseModifier.apply(self, target, caster, ability, modifierTable)
    if caster == nil then
        caster = target
    end
    return target:AddNewModifier(caster, ability, self.name, modifierTable)
end
function BaseModifier.on(self, target)
    return target:HasModifier(self.name)
end
function BaseModifier.remove(self, target)
    target:RemoveModifierByName(self.name)
end
____exports.BaseModifierMotionHorizontal = __TS__Class()
local BaseModifierMotionHorizontal = ____exports.BaseModifierMotionHorizontal
BaseModifierMotionHorizontal.name = "BaseModifierMotionHorizontal"
__TS__ClassExtends(BaseModifierMotionHorizontal, ____exports.BaseModifier)
____exports.BaseModifierMotionVertical = __TS__Class()
local BaseModifierMotionVertical = ____exports.BaseModifierMotionVertical
BaseModifierMotionVertical.name = "BaseModifierMotionVertical"
__TS__ClassExtends(BaseModifierMotionVertical, ____exports.BaseModifier)
____exports.BaseModifierMotionBoth = __TS__Class()
local BaseModifierMotionBoth = ____exports.BaseModifierMotionBoth
BaseModifierMotionBoth.name = "BaseModifierMotionBoth"
__TS__ClassExtends(BaseModifierMotionBoth, ____exports.BaseModifier)
setmetatable(____exports.BaseAbility.prototype, {__index = CDOTA_Ability_Lua or C_DOTA_Ability_Lua})
setmetatable(____exports.BaseItem.prototype, {__index = CDOTA_Item_Lua or C_DOTA_Item_Lua})
setmetatable(____exports.BaseModifier.prototype, {__index = CDOTA_Modifier_Lua or C_DOTA_Modifier_Lua})
____exports.registerAbility = function(____, name) return function(____, ability)
    if name ~= nil then
        ability.name = name
    else
        name = ability.name
    end
    local env = unpack(getFileScope(nil))
    if env[name] then
        clearTable(nil, env[name])
    else
        env[name] = {}
    end
    toDotaClassInstance(nil, env[name], ability)
    local originalSpawn = env[name].Spawn
    env[name].Spawn = function(self)
        self:____constructor()
        if originalSpawn then
            originalSpawn(self)
        end
    end
end end
____exports.registerModifier = function(____, name) return function(____, modifier)
    if name ~= nil then
        modifier.name = name
    else
        name = modifier.name
    end
    local env, source = unpack(getFileScope(nil))
    local fileName = string.gsub(source, ".*scripts[\\/]vscripts[\\/]", "")
    if env[name] then
        clearTable(nil, env[name])
    else
        env[name] = {}
    end
    toDotaClassInstance(nil, env[name], modifier)
    local originalOnCreated = env[name].OnCreated
    env[name].OnCreated = function(self, parameters)
        self:____constructor()
        if originalOnCreated then
            originalOnCreated(self, parameters)
        end
    end
    local ____type = LUA_MODIFIER_MOTION_NONE
    local base = modifier.____super
    while base do
        if base == ____exports.BaseModifierMotionBoth then
            ____type = LUA_MODIFIER_MOTION_BOTH
            break
        elseif base == ____exports.BaseModifierMotionHorizontal then
            ____type = LUA_MODIFIER_MOTION_HORIZONTAL
            break
        elseif base == ____exports.BaseModifierMotionVertical then
            ____type = LUA_MODIFIER_MOTION_VERTICAL
            break
        end
        base = base.____super
    end
    LinkLuaModifier(name, fileName, ____type)
end end
return ____exports
