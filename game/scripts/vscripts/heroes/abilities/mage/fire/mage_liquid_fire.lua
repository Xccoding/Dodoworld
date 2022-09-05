if  mage_liquid_fire == nil then
    mage_liquid_fire = class({})
end
LinkLuaModifier( "modifier_mage_liquid_fire", "heroes/abilities/mage/fire/mage_liquid_fire.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_liquid_fire_debuff", "heroes/abilities/mage/fire/mage_liquid_fire.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_liquid_fire:GetIntrinsicModifierName()
    if self:GetLevel() >= 1 then
        return "modifier_mage_liquid_fire"
    end
end
--液态火监控modifiers
if modifier_mage_liquid_fire == nil then
	modifier_mage_liquid_fire = class({})
end
function modifier_mage_liquid_fire:IsHidden()
    return true
end
function modifier_mage_liquid_fire:IsDebuff()
    return false
end 
function modifier_mage_liquid_fire:IsPurgable()
    return false
end
function modifier_mage_liquid_fire:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_liquid_fire:CDeclareFunctions()
    return {
    }
end
function modifier_mage_liquid_fire:GetAbilityValues()
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.int_factor = self:GetAbilitySpecialValueFor("int_factor")
    self.combo_multiple = self:GetAbilitySpecialValueFor("combo_multiple")
end
function modifier_mage_liquid_fire:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        self.dot_pct = self:GetCaster():GetIntellect() * (self.int_factor * 0.01)
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(0)
    end
end
function modifier_mage_liquid_fire:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_liquid_fire:OnIntervalThink()
    if IsServer() then
        self.dot_pct = self:GetCaster():GetIntellect() * (self.int_factor * 0.01)
        self:SendBuffRefreshToClients()
    end
end
function modifier_mage_liquid_fire:AddCustomTransmitterData()
    return {
    dot_pct = self.dot_pct
    }
end
function modifier_mage_liquid_fire:HandleCustomTransmitterData( data )
    self.dot_pct = data.dot_pct
end
function modifier_mage_liquid_fire:OnTooltip()
    return self.dot_pct
end
function modifier_mage_liquid_fire:OnTakeDamage(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local hCaster = params.attacker
            local hTarget = params.unit
            local hAbility = self:GetAbility()
            local damage_pool = 0
            if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and (bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT) then
                damage_pool = params.damage * self.dot_pct * 0.01
                if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO then
                    damage_pool = damage_pool * self.combo_multiple * 0.01
                end
                hTarget:AddNewModifier(hCaster, hAbility, "modifier_mage_liquid_fire_debuff", {duration = self.duration, damage_pool = damage_pool})
            end
        end
    end
end
--液态火modifiers
if modifier_mage_liquid_fire_debuff == nil then
	modifier_mage_liquid_fire_debuff = class({})
end
function modifier_mage_liquid_fire_debuff:IsHidden()
    return false
end
function modifier_mage_liquid_fire_debuff:IsDebuff()
    return true
end 
function modifier_mage_liquid_fire_debuff:IsPurgable()
    return true
end
function modifier_mage_liquid_fire_debuff:OnCreated(params)
    self.dot_interval= self:GetAbilitySpecialValueFor("dot_interval")
    if IsServer() then
        self.damage_pool = params.damage_pool
        self.damage_tick = 0
        self:SetHasCustomTransmitterData(true)
        self:StartIntervalThink(self.dot_interval)
        self:OnIntervalThink()
        EmitSoundOnEntityForPlayer("Hero_Jakiro.LiquidFire", self:GetParent(), self:GetCaster():GetPlayerOwnerID())
    end
    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particleID, false, false, -1, false, false)
end
function modifier_mage_liquid_fire_debuff:OnRefresh(params)
    self.dot_interval= self:GetAbilitySpecialValueFor("dot_interval")
    if IsServer() then
        self.damage_pool = params.damage_pool + self.damage_pool
        self:OnIntervalThink()
    end
end
function modifier_mage_liquid_fire_debuff:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local Target = self:GetParent()
        local fDamage = math.max(self.damage_pool / (math.floor(self:GetRemainingTime() + 0.5) / self.dot_interval + 1) , 1)

        ApplyDamage({
            victim = Target,
            attacker = hCaster,
            damage = fDamage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
        })
        self.damage_pool = self.damage_pool - self.damage_pool / (math.floor(self:GetRemainingTime() + 0.5) / self.dot_interval + 1)
        self.damage_tick = self.damage_pool / (math.floor(self:GetRemainingTime() + 0.5) / self.dot_interval + 1)
        self:SendBuffRefreshToClients()
    end
end
function modifier_mage_liquid_fire_debuff:AddCustomTransmitterData()
    return {
        damage_tick = self.damage_tick
    }
end
function modifier_mage_liquid_fire_debuff:HandleCustomTransmitterData( data )
    self.damage_tick = data.damage_tick
end
function modifier_mage_liquid_fire_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_mage_liquid_fire_debuff:OnTooltip()
    return self.damage_tick
end