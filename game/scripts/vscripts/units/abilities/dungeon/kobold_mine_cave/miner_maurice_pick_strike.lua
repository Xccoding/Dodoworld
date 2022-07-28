LinkLuaModifier( "modifier_miner_maurice_pick_strike", "units/abilities/dungeon/kobold_mine_cave/miner_maurice_pick_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_miner_maurice_pick_strike_debuff", "units/abilities/dungeon/kobold_mine_cave/miner_maurice_pick_strike.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if miner_maurice_pick_strike == nil then
	miner_maurice_pick_strike = class({})
end
function miner_maurice_pick_strike:GetIntrinsicModifierName()
	return "modifier_miner_maurice_pick_strike"
end
---------------------------------------------------------------------
--Modifiers
if modifier_miner_maurice_pick_strike == nil then
	modifier_miner_maurice_pick_strike = class({})
end
function modifier_miner_maurice_pick_strike:IsPurgable()
	return false
end
function modifier_miner_maurice_pick_strike:IsDebuff()
	return false
end
function modifier_miner_maurice_pick_strike:IsHidden()
	return true
end
function modifier_miner_maurice_pick_strike:OnCreated(params)
	self.duration = self:GetAbilitySpecialValueFor("duration")
end
function modifier_miner_maurice_pick_strike:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_miner_maurice_pick_strike:OnDestroy()
	if IsServer() then
	end
end
function modifier_miner_maurice_pick_strike:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_miner_maurice_pick_strike:OnAttackLanded( params )
	local hParent = self:GetParent()
    if params.attacker == hParent and self:GetAbility() ~= nil and self:GetAbility():IsCooldownReady() then
        params.target:AddNewModifier(hParent, self:GetAbility(), "modifier_miner_maurice_pick_strike_debuff", {duration = self.duration} )
        EmitSoundOn("DOTA_Item.MedallionOfCourage.Activate", params.target)
        self:GetAbility():UseResources(true, true, true)
    end
end
--=======================================modifier_miner_maurice_pick_strike_debuff=======================================
if modifier_miner_maurice_pick_strike_debuff == nil then
	modifier_miner_maurice_pick_strike_debuff = class({})
end
function modifier_miner_maurice_pick_strike_debuff:IsHidden()
	return false
end
function modifier_miner_maurice_pick_strike_debuff:IsDebuff()
	return true
end
function modifier_miner_maurice_pick_strike_debuff:IsPurgable()
	return false
end
function modifier_miner_maurice_pick_strike_debuff:IsPurgeException()
	return false
end
function modifier_miner_maurice_pick_strike_debuff:OnCreated(params)
	self.armor_reduce = self:GetAbilitySpecialValueFor("armor_reduce")
end
function modifier_miner_maurice_pick_strike_debuff:OnRefresh(params)
end
function modifier_miner_maurice_pick_strike_debuff:OnDestroy(params)
end
function modifier_miner_maurice_pick_strike_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end
function modifier_miner_maurice_pick_strike_debuff:CDeclareFunctions()
	return {
        CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT
	}
end
function modifier_miner_maurice_pick_strike_debuff:C_GetModifierPhysicalArmor_Constant( params )
	return self.armor_reduce
end
function modifier_miner_maurice_pick_strike_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_miner_maurice_pick_strike_debuff:GetEffectName()
    return "particles/items2_fx/medallion_of_courage.vpcf"
end
function modifier_miner_maurice_pick_strike_debuff:OnTooltip()
	return self.armor_reduce
end
