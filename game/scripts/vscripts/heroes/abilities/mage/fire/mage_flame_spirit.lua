LinkLuaModifier( "modifier_mage_flame_spirit", "heroes/abilities/mage/fire/mage_flame_spirit.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mage_flame_spirit == nil then
	mage_flame_spirit = class({})
end
function mage_flame_spirit:GetIntrinsicModifierName()
	return "modifier_mage_flame_spirit"
end
---------------------------------------------------------------------
--Modifiers
if modifier_mage_flame_spirit == nil then
	modifier_mage_flame_spirit = class({})
end
function modifier_mage_flame_spirit:OnCreated(params)
	if IsServer() then
	end
end
function modifier_mage_flame_spirit:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_mage_flame_spirit:OnDestroy()
	if IsServer() then
	end
end
function modifier_mage_flame_spirit:DeclareFunctions()
	return {
	}
end