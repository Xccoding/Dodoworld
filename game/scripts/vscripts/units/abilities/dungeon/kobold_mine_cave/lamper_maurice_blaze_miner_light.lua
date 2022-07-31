LinkLuaModifier( "modifier_lamper_maurice_blaze_miner_light", "units/abilities/dungeon/kobold_mine_cave/lamper_maurice_blaze_miner_light.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lamper_maurice_blaze_miner_light_debuff", "units/abilities/dungeon/kobold_mine_cave/lamper_maurice_blaze_miner_light.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if lamper_maurice_blaze_miner_light == nil then
	lamper_maurice_blaze_miner_light = class({})
end
function lamper_maurice_blaze_miner_light:GetIntrinsicModifierName()
	return "modifier_lamper_maurice_blaze_miner_light"
end
---------------------------------------------------------------------
--Modifiers
if modifier_lamper_maurice_blaze_miner_light == nil then
	modifier_lamper_maurice_blaze_miner_light = class({})
end
function modifier_lamper_maurice_blaze_miner_light:IsPurgable()
	return false
end
function modifier_lamper_maurice_blaze_miner_light:IsDebuff()
	return false
end
function modifier_lamper_maurice_blaze_miner_light:IsHidden()
	return true
end
function modifier_lamper_maurice_blaze_miner_light:OnCreated(params)
	local hParent = self:GetParent()
	self.radius = self:GetAbilitySpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end
end
function modifier_lamper_maurice_blaze_miner_light:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_lamper_maurice_blaze_miner_light:OnDestroy()
	if IsServer() then
	end
end
function modifier_lamper_maurice_blaze_miner_light:DeclareFunctions()
	return {
	}
end
function modifier_lamper_maurice_blaze_miner_light:OnIntervalThink()
	local hParent = self:GetParent()
	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_cast.vpcf", PATTACH_CUSTOMORIGIN, hParent)
	ParticleManager:SetParticleControlEnt(particleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0, 0, -30), false)
	ParticleManager:ReleaseParticleIndex(particleID)
end
function modifier_lamper_maurice_blaze_miner_light:IsAura()
	return true
end
function modifier_lamper_maurice_blaze_miner_light:GetModifierAura()
	return "modifier_lamper_maurice_blaze_miner_light_debuff"
end
function modifier_lamper_maurice_blaze_miner_light:GetAuraRadius()
	return self.radius
end
function modifier_lamper_maurice_blaze_miner_light:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_lamper_maurice_blaze_miner_light:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
--=======================================modifier_lamper_maurice_blaze_miner_light_debuff=======================================
if modifier_lamper_maurice_blaze_miner_light_debuff == nil then
	modifier_lamper_maurice_blaze_miner_light_debuff = class({})
end
function modifier_lamper_maurice_blaze_miner_light_debuff:IsHidden()
	return false
end
function modifier_lamper_maurice_blaze_miner_light_debuff:IsDebuff()
	return true
end
function modifier_lamper_maurice_blaze_miner_light_debuff:IsPurgable()
	return false
end
function modifier_lamper_maurice_blaze_miner_light_debuff:IsPurgeException()
	return false
end
function modifier_lamper_maurice_blaze_miner_light_debuff:OnCreated(params)
	self.miss_pct = self:GetAbilitySpecialValueFor("miss_pct")
end
function modifier_lamper_maurice_blaze_miner_light_debuff:OnRefresh(params)
end
function modifier_lamper_maurice_blaze_miner_light_debuff:OnDestroy(params)
end
function modifier_lamper_maurice_blaze_miner_light_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end
function modifier_lamper_maurice_blaze_miner_light_debuff:CDeclareFunctions()
	return {
	}
end
function modifier_lamper_maurice_blaze_miner_light_debuff:GetModifierMiss_Percentage()
	return self.miss_pct
end
