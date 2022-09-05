local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__Delete = ____lualib.__TS__Delete
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 114,["9"] = 114,["10"] = 115,["11"] = 116,["12"] = 117,["13"] = 118,["14"] = 119,["15"] = 119,["16"] = 119,["17"] = 119,["19"] = 122,["22"] = 126,["23"] = 127,["24"] = 127,["25"] = 128,["26"] = 129,["27"] = 132,["28"] = 133,["29"] = 134,["33"] = 139,["36"] = 2,["37"] = 2,["38"] = 2,["40"] = 2,["41"] = 5,["42"] = 5,["43"] = 5,["45"] = 5,["46"] = 8,["47"] = 8,["48"] = 8,["50"] = 8,["51"] = 9,["52"] = 16,["53"] = 9,["54"] = 18,["55"] = 19,["56"] = 18,["57"] = 22,["58"] = 23,["59"] = 22,["60"] = 28,["61"] = 28,["62"] = 28,["63"] = 28,["64"] = 31,["65"] = 31,["66"] = 31,["67"] = 31,["68"] = 34,["69"] = 34,["70"] = 34,["71"] = 34,["72"] = 37,["73"] = 37,["74"] = 37,["75"] = 37,["76"] = 37,["78"] = 37,["79"] = 38,["80"] = 38,["81"] = 38,["82"] = 38,["83"] = 38,["85"] = 38,["86"] = 39,["87"] = 39,["88"] = 39,["89"] = 39,["90"] = 39,["92"] = 39,["93"] = 42,["94"] = 43,["95"] = 45,["97"] = 47,["99"] = 50,["100"] = 52,["101"] = 54,["102"] = 56,["103"] = 57,["104"] = 58,["105"] = 59,["106"] = 60,["108"] = 57,["109"] = 42,["110"] = 65,["111"] = 66,["112"] = 68,["114"] = 70,["116"] = 73,["117"] = 74,["118"] = 76,["119"] = 78,["120"] = 80,["121"] = 81,["122"] = 82,["123"] = 83,["124"] = 84,["126"] = 81,["127"] = 88,["128"] = 89,["129"] = 90,["130"] = 91,["131"] = 92,["133"] = 94,["134"] = 95,["136"] = 97,["137"] = 98,["140"] = 102,["142"] = 105,["143"] = 65,["144"] = 108,["145"] = 109,["146"] = 110,["148"] = 108});
local ____exports = {}
local getFileScope, toDotaClassInstance
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
    local ____table_9 = ____table
    local prototype = ____table_9.prototype
    while prototype do
        for key in pairs(prototype) do
            if not (rawget(instance, key) ~= nil) then
                if key ~= "__index" then
                    instance[key] = prototype[key]
                end
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
    return target:AddNewModifier(caster, ability, self.name, modifierTable)
end
function BaseModifier.find_on(self, target)
    return target:FindModifierByName(self.name)
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
local ____setmetatable_2 = setmetatable
local ____exports_BaseAbility_prototype_1 = ____exports.BaseAbility.prototype
local ____CDOTA_Ability_Lua_0 = CDOTA_Ability_Lua
if ____CDOTA_Ability_Lua_0 == nil then
    ____CDOTA_Ability_Lua_0 = C_DOTA_Ability_Lua
end
____setmetatable_2(____exports_BaseAbility_prototype_1, {__index = ____CDOTA_Ability_Lua_0})
local ____setmetatable_5 = setmetatable
local ____exports_BaseItem_prototype_4 = ____exports.BaseItem.prototype
local ____CDOTA_Item_Lua_3 = CDOTA_Item_Lua
if ____CDOTA_Item_Lua_3 == nil then
    ____CDOTA_Item_Lua_3 = C_DOTA_Item_Lua
end
____setmetatable_5(____exports_BaseItem_prototype_4, {__index = ____CDOTA_Item_Lua_3})
local ____setmetatable_8 = setmetatable
local ____exports_BaseModifier_prototype_7 = ____exports.BaseModifier.prototype
local ____CDOTA_Modifier_Lua_6 = CDOTA_Modifier_Lua
if ____CDOTA_Modifier_Lua_6 == nil then
    ____CDOTA_Modifier_Lua_6 = C_DOTA_Modifier_Lua
end
____setmetatable_8(____exports_BaseModifier_prototype_7, {__index = ____CDOTA_Modifier_Lua_6})
____exports.registerAbility = function(____, name) return function(____, ability)
    if name ~= nil then
        ability.name = name
    else
        name = ability.name
    end
    local env = unpack(getFileScope(nil))
    env[name] = {}
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
    env[name] = {}
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
local function clearTable(self, ____table)
    for key in pairs(____table) do
        __TS__Delete(____table, key)
    end
end
return ____exports
