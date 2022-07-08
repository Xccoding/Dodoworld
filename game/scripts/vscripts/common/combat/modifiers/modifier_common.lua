_G.COMBAT_STATUS_TIME = 600--标准战斗状态持续时间
_G.COMBAT_STATUS_OUT_TIME = 1.5--标准战斗退出时间

require('modifiers.Cmodifier')
require('common.attribute_manager')

--通用modifiers
if modifier_common == nil then
	modifier_common = class({})
end
function modifier_common:IsHidden()
    return true
end
function modifier_common:IsDebuff()
    return false
end 
function modifier_common:IsPurgable()
    return false
end
function modifier_common:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
        MODIFIER_EVENT_ON_MODIFIER_ADDED,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
    }
end
function modifier_common:RemoveOnDeath()
    return false
end
function modifier_common:OnCreated(params)
    self.damage_records = {}
end

function modifier_common:OnTakeDamageKillCredit(params)
    local hAttacker = params.attacker
    local hVictim = params.target
    
    if not (hVictim:HasModifier("modifier_escape") or hAttacker:HasModifier("modifier_escape")) then
        local aggro_target = nil
        if not hVictim:HasModifier("modifier_combat") then
            aggro_target = hAttacker:entindex()
        end
        hAttacker:AddNewModifier(hAttacker, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
        hVictim:AddNewModifier(hVictim, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME, aggro_target = aggro_target})
    end
end
function modifier_common:OnModifierAdded( params )
    if params.unit == self:GetParent() then
        local tBuff = params.added_buff
        local hCaster = tBuff:GetCaster()
        local hParent = self:GetParent()
        local aggro_target = nil
        if not hParent:HasModifier("modifier_combat") then
            aggro_target = hCaster:entindex()
        end
        if tBuff:GetName() == "modifier_taunt_custom" and not (hParent:HasModifier("modifier_escape") or hCaster:HasModifier("modifier_escape")) then
            hCaster:AddNewModifier(hCaster, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
            hParent:AddNewModifier(hParent, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME, aggro_target = aggro_target})
        end
    end
end
function modifier_common:OnTakeDamage(params)
    local hAttacker = params.attacker
    local hVictim = params.unit
    local number_length = math.floor(math.log(math.floor(params.damage),10) + 1)

    -- for index = 1, #self.damage_records do
    --     print(self.damage_records[index].crit, self.damage_records[index].record)
    -- end

    for index = 1, #self.damage_records do
        local msg_type = 0
        local paticle_name
        local particleID

        if self.damage_records[index].record == params.record then
            if params.damage > 0 then
                if self.damage_records[index].crit == true then
                    --print("特效暴击")
                    --暴击特效
                    paticle_name = "particles/msg_fx/msg_crit.vpcf"
                    msg_type = 4
                else
                    --print("特效没暴击")
                    paticle_name = "particles/msg_fx/msg_damage.vpcf"
                    --普通伤害特效
                    msg_type = 9
                end
                if hAttacker:IsOwnedByAnyPlayer() then
                    particleID = ParticleManager:CreateParticleForPlayer(paticle_name, PATTACH_OVERHEAD_FOLLOW, hVictim, hAttacker:GetPlayerOwner())
                else
                    particleID = ParticleManager:CreateParticle(paticle_name, PATTACH_OVERHEAD_FOLLOW, hVictim)
                end
                ParticleManager:SetParticleControl(particleID, 1, Vector(0, math.floor(params.damage), msg_type))
                ParticleManager:SetParticleControl(particleID, 2, Vector(1, number_length + 1, 0))
                if params.damage_type == DAMAGE_TYPE_PHYSICAL then
                    ParticleManager:SetParticleControl(particleID, 3, Vector(216, 13, 13))
                elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
                    ParticleManager:SetParticleControl(particleID, 3, Vector(0, 191, 255))
                end
                ParticleManager:ReleaseParticleIndex(particleID)
            end
            table.remove(self.damage_records, index)
            break
        end
    end

    -- for index = 1, #self.damage_records do
    --     print(self.damage_records[index].crit, self.damage_records[index].record)
    -- end

end
function modifier_common:GetModifierTotalDamageOutgoing_Percentage( params )
    if not IsServer() then return end

    local hAttacker = params.attacker
    local hVictim = params.target
    local fPercent = 0--基础伤害比率

    --计算护甲减伤
    if params.damage_type == DAMAGE_TYPE_PHYSICAL then
        local armor_pct = hVictim:GetPhysicalDamageReduction(hAttacker:GetLevel() - hVictim:GetLevel())
        fPercent = fPercent - armor_pct
    elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
        --计算魔抗减伤
        local armor_pct = hVictim:GetMagicalDamageReduction(hAttacker:GetLevel() - hVictim:GetLevel())
        fPercent = fPercent - armor_pct
    end
    
    --普通攻击伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        local crit_chance = 0
        local crit_damage = CDOTA_BASE_CRIT_DAMAGE
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
            crit_damage = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_DAMAGE, params, MODIFIER_CALCULATE_TYPE_SUM)
        elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
            crit_chance = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
            crit_damage = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_DAMAGE, params, MODIFIER_CALCULATE_TYPE_SUM)
        end

        if RandomFloat(0, 100) < crit_chance then
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            fPercent = fPercent + crit_damage
        else
            table.insert(self.damage_records, {crit = false, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_ATTACK_NOTCRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_ATTACK_NOTCRIT, params)
            fPercent = fPercent + 0
        end
    end

    --技能伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        local crit_chance = 0
        local crit_damage = CDOTA_BASE_CRIT_DAMAGE
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
            crit_damage = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_DAMAGE, params, MODIFIER_CALCULATE_TYPE_SUM)
        else
            crit_chance = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
            crit_damage = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_DAMAGE, params, MODIFIER_CALCULATE_TYPE_SUM)
        end
        if RandomFloat(0, 100) < crit_chance then
            --print("数值暴击")
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            fPercent = fPercent + crit_damage
        else
            --print("数值没暴击")
            table.insert(self.damage_records, {crit = false, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_SPELL_NOTCRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_SPELL_NOTCRIT, params)
            fPercent = fPercent + 0
        end
    end

    return fPercent

end
function modifier_common:GetModifierBaseAttackTimeConstant()
    if IsServer() then
        return self:GetParent():GetUnitAttribute(BASE_ATTACK_TIME, {}, MODIFIER_CALCULATE_TYPE_MAX)
    end
end
function modifier_common:GetModifierPhysical_ConstantBlock( params )
    if not IsServer() then return end

    local hAttacker = params.attacker
    local hVictim = params.target
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        local block_chance = hVictim:GetUnitAttribute(BLOCK_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
        if RandomFloat(0, 100) < block_chance then
            return params.damage * hVictim:GetUnitAttribute(BLOCK_PERCENT, params, MODIFIER_CALCULATE_TYPE_SUM) * 0.01
        end
    end
end
function modifier_common:GetModifierIgnorePhysicalArmor()
    return 1
end