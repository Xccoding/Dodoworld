LinkLuaModifier( "modifier_death_knight_mortal_strike", "heroes/abilities/death_knight/frost/death_knight_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_mortal_strike_crit", "heroes/abilities/death_knight/frost/death_knight_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_mortal_strike_free_nova", "heroes/abilities/death_knight/frost/death_knight_mortal_strike.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_mortal_strike == nil then
	death_knight_mortal_strike = class({})
end
function death_knight_mortal_strike:GetIntrinsicModifierName()
    return "modifier_death_knight_mortal_strike"
end
function death_knight_mortal_strike:GetCastRange(vLocation, hTarget)
	return self:GetCaster():Script_GetAttackRange() + self:GetCaster():GetHullRadius()
end
function death_knight_mortal_strike:GetAbilityTextureName()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_death_knight_mortal_strike_crit") then
        return "kunkka_divine_anchor_tidebringer"
    else
        return "death_knight_mortal_strike"
    end
end
--被动modifier
if modifier_death_knight_mortal_strike == nil then
	modifier_death_knight_mortal_strike = class({})
end
function modifier_death_knight_mortal_strike:IsDebuff()
	return false
end
function modifier_death_knight_mortal_strike:IsHidden()
	return true
end
function modifier_death_knight_mortal_strike:IsPurgable()
	return false
end
function modifier_death_knight_mortal_strike:OnCreated(params)
    self.records = {}
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
    self.crit_duration = self:GetAbility():GetSpecialValueFor("crit_duration")
    self.nova_free_chance = self:GetAbility():GetSpecialValueFor("nova_free_chance")
    self.nova_free_duration = self:GetAbility():GetSpecialValueFor("nova_free_duration")
    self.bulldoze_stack = self:GetAbility():GetSpecialValueFor("bulldoze_stack")
    self.mana_get_pct = self:GetAbility():GetSpecialValueFor("mana_get_pct")
end
function modifier_death_knight_mortal_strike:OnRefresh(params)
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
    self.crit_duration = self:GetAbility():GetSpecialValueFor("crit_duration")
    self.nova_free_chance = self:GetAbility():GetSpecialValueFor("nova_free_chance")
    self.nova_free_duration = self:GetAbility():GetSpecialValueFor("nova_free_duration")
    self.bulldoze_stack = self:GetAbility():GetSpecialValueFor("bulldoze_stack")
    self.mana_get_pct = self:GetAbility():GetSpecialValueFor("mana_get_pct")
end
function modifier_death_knight_mortal_strike:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
	}
end
function modifier_death_knight_mortal_strike:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_ATTACK_CRIT,
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT,
        CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_CONSTANT,
    }
end
function modifier_death_knight_mortal_strike:C_OnAttackCrit(params)
	if params.attacker == self:GetParent() then
        local hCaster = self:GetParent()

        if RandomFloat(0, 100) < self.crit_chance then
            if not (self:CheckUseOrb(params.record)) then
                hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_death_knight_mortal_strike_crit", {duration = self.crit_duration})
            end
        end
    end
end
function modifier_death_knight_mortal_strike:C_GetModifierBonusMagicalCritChance_Constant(params)
	if params.attacker ~= nil and params.attacker == self:GetParent() then
        local hAbility = self:GetAbility()
        if params.attacker:HasModifier("modifier_death_knight_mortal_strike_crit") then
            if params.inflictor ~= nil and params.inflictor == hAbility then
                EmitSoundOn("Hero_Kunkka.TidebringerDamage", params.target)
                return 100
            elseif params.inflictor == nil and self:CheckUseOrb(params.record) then
                params.attacker:RemoveModifierByName("modifier_death_knight_mortal_strike_crit")
                return 100
            end
        end
    end
    return 0
end
function modifier_death_knight_mortal_strike:C_GetModifierBonusPhysicalCritChance_Constant(params)
	if params.attacker ~= nil and params.attacker == self:GetParent() then
        local hAbility = self:GetAbility()
        if params.attacker:HasModifier("modifier_death_knight_mortal_strike_crit") then
            if params.inflictor ~= nil and params.inflictor == hAbility then
                EmitSoundOn("Hero_Kunkka.TidebringerDamage", params.target)
                return 100
            elseif params.inflictor == nil and self:CheckUseOrb(params.record) then
                params.attacker:RemoveModifierByName("modifier_death_knight_mortal_strike_crit")
                return 100
            end
        end
    end
    return 0
end
function modifier_death_knight_mortal_strike:OnAttackStart(params)
    if params.attacker == self:GetParent() then  
    end
end
function modifier_death_knight_mortal_strike:OnAttack(params)
    if not IsServer() then 
        return 
    end
    if params.attacker == self:GetParent() then
        if self:CheckUseOrb(params.record) then
            local hCaster = self:GetCaster()
            local hAbility = self:GetAbility()
            if hAbility:GetCurrentAbilityCharges() > 0 then
                hAbility:UseResources(true, true, true)
                hAbility:SetCurrentAbilityCharges(hAbility:GetCurrentAbilityCharges() - 1)
                hCaster:CGiveMana(hCaster:GetMaxMana() * self.mana_get_pct * 0.01, hAbility, hCaster)

                local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_mortal_strike.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
                --ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetAbsOrigin(), false)
                ParticleManager:ReleaseParticleIndex(particleID)
            end    
        end
    end
end
function modifier_death_knight_mortal_strike:OnAttackRecord(params)
    if not IsServer() then 
        return 
    end
    if params.attacker == self:GetParent() then
        local hCaster = self:GetCaster()
        local hAbility = self:GetAbility()
        local hTarget = params.target

        if not IsValidEntity(hTarget)  or hAbility:CastFilterResultTarget(hTarget) ~= UF_SUCCESS then
            return
        end

        if (not hCaster:IsSilenced()) and hAbility:IsCooldownReady() and hAbility:GetCurrentAbilityCharges() > 0 and hAbility:IsOwnersManaEnough() and (hCaster:GetCurrentActiveAbility() == hAbility or hAbility:GetAutoCastState()) then            --self.records[params.record] = true
            table.insert( self.records, {iRecord = params.record, bOrb = true})
        end
        --print("attack_record",params.record)
    end
end
function modifier_death_knight_mortal_strike:OnAttackLanded(params)
    if not IsServer() then 
        return 
    end
    if params.attacker == self:GetParent() then
        if self:CheckUseOrb(params.record) then
            local hCaster = self:GetCaster()
            local hAbility = self:GetAbility()
            local hTarget = params.target
            local iDamage_type = DAMAGE_TYPE_PHYSICAL
            local sound_name = "Hero_SkeletonKing.CriticalStrike"

            if hCaster:HasModifier("modifier_death_knight_mortal_strike_crit") then
                iDamage_type = DAMAGE_TYPE_MAGICAL
                sound_name = "Hero_Kunkka.Tidebringer.Attack"
            end
            --print(self.damage + self.ap_factor)
            ApplyDamage({
				victim = hTarget,
				attacker = hCaster,
				damage = self.damage + self.ap_factor,
				damage_type = iDamage_type,
				ability = hAbility,
				damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
			})

            EmitSoundOn(sound_name, hCaster)

            --触发免费nova
            if RandomFloat(0, 100) < self.nova_free_chance then
                hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_mortal_strike_free_nova", {duration = self.nova_free_duration})
            end

            --威吓叠层
            local bulldoze_buff = hCaster:FindModifierByName("modifier_death_knight_bulldoze")
            if bulldoze_buff ~= nil then
                bulldoze_buff:SetStackCount(bulldoze_buff:GetStackCount() + self.bulldoze_stack)
            end

        end
    end
end
function modifier_death_knight_mortal_strike:OnAttackRecordDestroy(params)
    if params.attacker == self:GetParent() then
        if params.record then
            self:RemoveRecord(params.record)
        end
    end
end
--必爆modifier
if modifier_death_knight_mortal_strike_crit == nil then
	modifier_death_knight_mortal_strike_crit = class({})
end
function modifier_death_knight_mortal_strike_crit:IsDebuff()
	return false
end
function modifier_death_knight_mortal_strike_crit:IsHidden()
	return false
end
function modifier_death_knight_mortal_strike_crit:IsPurgable()
	return false
end
function modifier_death_knight_mortal_strike_crit:OnCreated( params )
    EmitSoundOn("Hero_Kunkaa.Tidebringer", self:GetParent())
    local hCaster = self:GetParent()
    if IsServer() then
        local particle_name = "particles/units/heroes/death_knight/death_knight_mortal_strike_crit_kunkka_weapon_tidebringer_fxset.vpcf"
        if hCaster:GetUnitName() == "npc_dota_hero_chaos_knight" then
            particle_name = "particles/units/heroes/death_knight/death_knight_mortal_strike_crit_kunkka_weapon_tidebringer_fxset_ck_version.vpcf"
        end
        local attach_point = "attach_weapon"
        if hCaster:GetUnitName() == "npc_dota_hero_abaddon" then
            attach_point = "attach_attack1"
        end

        local particleID = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, hCaster)
        ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, attach_point, Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)
    
    end

end
--免费凛风冲击modifier
if modifier_death_knight_mortal_strike_free_nova == nil then
	modifier_death_knight_mortal_strike_free_nova = class({})
end
function modifier_death_knight_mortal_strike_free_nova:IsDebuff()
	return false
end
function modifier_death_knight_mortal_strike_free_nova:IsHidden()
	return false
end
function modifier_death_knight_mortal_strike_free_nova:IsPurgable()
	return false
end
function modifier_death_knight_mortal_strike_free_nova:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_death_knight_mortal_strike_free_nova:GetEffectName()
    return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end
function modifier_death_knight_mortal_strike_free_nova:OnCreated( params )
    EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", self:GetParent())
end
function modifier_death_knight_mortal_strike_free_nova:GetTexture()
    return "lich_frost_nova"
end
