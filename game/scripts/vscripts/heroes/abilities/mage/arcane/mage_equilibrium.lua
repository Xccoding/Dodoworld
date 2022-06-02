if  mage_equilibrium == nil then
    mage_equilibrium = class({})
end
LinkLuaModifier( "modifier_mage_equilibrium", "heroes/abilities/mage/arcane/mage_equilibrium.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_equilibrium_buff", "heroes/abilities/mage/arcane/mage_equilibrium.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_equilibrium:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end
function mage_equilibrium:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end
function mage_equilibrium:GetIntrinsicModifierName()
    return "modifier_mage_equilibrium"
end
function mage_equilibrium:OnChannelFinish(bInterrupted)
    local hCaster = self:GetCaster()
    hCaster:RemoveModifierByName("modifier_mage_equilibrium_buff")
end
function mage_equilibrium:OnSpellStart()
    local hCaster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    hCaster:AddNewModifier(hCaster, self, "modifier_mage_equilibrium_buff", {duration = duration})
    EmitSoundOn("Hero_ObsidianDestroyer.EssenceFlux.Cast", hCaster)
end
--modifiers
if modifier_mage_equilibrium == nil then
	modifier_mage_equilibrium = class({})
end
function modifier_mage_equilibrium:IsHidden()
    return false
end
function modifier_mage_equilibrium:IsDebuff()
    return false
end 
function modifier_mage_equilibrium:IsPurgable()
    return false
end
function modifier_mage_equilibrium:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_mage_equilibrium:OnTooltip()
    return self.bonus_damage
end
function modifier_mage_equilibrium:OnCreated( params )
    self.mana_regen_int_factor = self:GetAbility():GetSpecialValueFor("mana_regen_int_factor")
    self.max_mana_int_factor = self:GetAbility():GetSpecialValueFor("max_mana_int_factor")
    self.arcane_buff_bonus_damage = self:GetAbility():GetSpecialValueFor("arcane_buff_bonus_damage")
    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        -- self.max_mana = 0
        self.mana_regen = 0
        self.bonus_damage = 0
        self:StartIntervalThink(FrameTime())
    end
    
end
function modifier_mage_equilibrium:OnRefresh( params )
    self.mana_regen_int_factor = self:GetAbility():GetSpecialValueFor("mana_regen_int_factor")
    self.max_mana_int_factor = self:GetAbility():GetSpecialValueFor("max_mana_int_factor")
    self.arcane_buff_bonus_damage = self:GetAbility():GetSpecialValueFor("arcane_buff_bonus_damage")
end
function modifier_mage_equilibrium:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hAbility = self:GetAbility()
    if IsServer() then
        -- self.max_mana = hCaster:GetIntellect() * self.max_mana_int_factor * 0.01
        self.mana_regen = hCaster:GetIntellect() * self.mana_regen_int_factor * 0.01
        self.bonus_damage = hCaster:GetIntellect() * self.arcane_buff_bonus_damage * 0.01
        hAbility.equilibrium_pct = self.bonus_damage
        self:OnRefresh()
        self:SendBuffRefreshToClients()
    end
end
function modifier_mage_equilibrium:AddCustomTransmitterData()
    return {
        max_mana = self.max_mana,
        mana_regen = self.mana_regen,
        bonus_damage = self.bonus_damage,
    }
end
function modifier_mage_equilibrium:HandleCustomTransmitterData( data )
    self.mana_regen = data.mana_regen
    self.max_mana = data.max_mana
    self.bonus_damage = data.bonus_damage
end
function modifier_mage_equilibrium:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_equilibrium:GetModifierMPRegenAmplify_Percentage()
    return self.mana_regen
end
function modifier_mage_equilibrium:GetModifierExtraManaPercentage()
    local hCaster = self:GetCaster()
    return hCaster:GetIntellect() * self:GetAbility():GetSpecialValueFor("max_mana_int_factor") * 0.01
end
--唤醒modifiers
if modifier_mage_equilibrium_buff == nil then
	modifier_mage_equilibrium_buff = class({})
end
function modifier_mage_equilibrium_buff:IsHidden()
    return true
end
function modifier_mage_equilibrium_buff:IsDebuff()
    return false
end 
function modifier_mage_equilibrium_buff:IsPurgable()
    return false
end
function modifier_mage_equilibrium_buff:OnTooltip()
    return self.bonus_mana_regen_pct
end
function modifier_mage_equilibrium_buff:OnCreated( params )
    self.bonus_mana_regen_pct = self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct")
    self:StartIntervalThink(0.75)
end
function modifier_mage_equilibrium_buff:OnRefresh( params )
    self.bonus_mana_regen_pct = self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct")
end
function modifier_mage_equilibrium_buff:OnIntervalThink()
    local hCaster = self:GetCaster()
    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
    ParticleManager:ReleaseParticleIndex(particleID)
    EmitSoundOn("Hero_ObsidianDestroyer.Equilibrium.Cast", hCaster)
end
function modifier_mage_equilibrium_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_equilibrium_buff:GetModifierMPRegenAmplify_Percentage()
    return self.bonus_mana_regen_pct
end