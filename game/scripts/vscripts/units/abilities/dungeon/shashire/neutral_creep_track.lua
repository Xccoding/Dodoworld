LinkLuaModifier( "modifier_neutral_creep_track", "units/abilities/dungeon/shashire/neutral_creep_track.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if neutral_creep_track == nil then
	neutral_creep_track = class({})
end
function neutral_creep_track:GetIntrinsicModifierName()
	return "modifier_neutral_creep_track"
end
---------------------------------------------------------------------
--Modifiers
if modifier_neutral_creep_track == nil then
	modifier_neutral_creep_track = class({})
end
function modifier_neutral_creep_track:OnCreated(params)
	if IsServer() then
	end
end
function modifier_neutral_creep_track:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_neutral_creep_track:OnDestroy()
	if IsServer() then
	end
end
function modifier_neutral_creep_track:DeclareFunctions()
	return {
	}
end