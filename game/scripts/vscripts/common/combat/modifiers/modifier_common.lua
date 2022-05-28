COMBAT_STATUS_TIME = 6--战斗状态持续时间

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
    }
end
function modifier_common:RemoveOnDeath()
    return false
end
function modifier_common:OnCreated(params)
    self.damage_records = {}
    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        self.base_attack_time = 1.70
        -- self:StartIntervalThink(1)
    end
end
function modifier_common:OnIntervalThink()
    if IsServer() then
        -- self.base_attack_time = self:GetParent():GetUnitAttribute(BASE_ATTACK_TIME, {}, MODIFIER_CALCULATE_TYPE_MAX)
        -- self:SendBuffRefreshToClients()
        -- print("s", self.base_attack_time)
    end
end
function modifier_common:AddCustomTransmitterData()
    return {
        base_attack_time = self.base_attack_time
    }
end
function modifier_common:HandleCustomTransmitterData(data)
    self.base_attack_time = data.base_attack_time
end
function modifier_common:OnTakeDamageKillCredit(params)
    local hAttacker = params.attacker
    local hVictim = params.target
    
    if not (hVictim:HasModifier("modifier_escape") or hAttacker:HasModifier("modifier_escape")) then
        hAttacker:AddNewModifier(hAttacker, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
        hVictim:AddNewModifier(hVictim, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
    end
end
function modifier_common:OnModifierAdded( params )
    if params.unit == self:GetParent() then
        local tBuff = params.added_buff
        local hCaster = tBuff:GetCaster()
        local hParent = self:GetParent()
        if tBuff:GetName() == "modifier_taunt_custom" and not (hParent:HasModifier("modifier_escape") or hCaster:HasModifier("modifier_escape")) then
            hCaster:AddNewModifier(hCaster, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
            hParent:AddNewModifier(hParent, nil, "modifier_combat", {duration = COMBAT_STATUS_TIME})
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
    
    --普通攻击伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
        local crit_chance = 0
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
        else
            crit_chance = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
        end
        if RandomFloat(0, 100) < crit_chance then
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_ATTACK_CRIT, params)
            return 50--TODO暴击伤害倍率修改
        else
            table.insert(self.damage_records, {crit = false, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_ATTACK_NOTCRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_ATTACK_NOTCRIT, params)
            return 0
        end
    end

    --技能攻击伤害
    if params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        local crit_chance = 0
        if params.damage_type == DAMAGE_TYPE_PHYSICAL then
            crit_chance = hAttacker:GetUnitAttribute(BONUS_PHYSICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
        else
            crit_chance = hAttacker:GetUnitAttribute(BONUS_MAGICAL_CRIT_CHANCE, params, MODIFIER_CALCULATE_TYPE_SUM)
        end
        if RandomFloat(0, 100) < crit_chance then
            --print("数值暴击")
            table.insert(self.damage_records, {crit = true, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_SPELL_CRIT, params)
            return 50
        else
            --print("数值没暴击")
            table.insert(self.damage_records, {crit = false, record = params.record})
            CFireModifierEvent(hAttacker, CMODIFIER_EVENT_ON_SPELL_NOTCRIT, params)
            CFireModifierEvent(hVictim, CMODIFIER_EVENT_ON_SPELL_NOTCRIT, params)
            return 0
        end
    end

end
function modifier_common:GetModifierBaseAttackTimeConstant()
    --print("enter")
    if IsServer() then
        --print("IsServer")
        self.base_attack_time = self:GetParent():GetUnitAttribute(BASE_ATTACK_TIME, {}, MODIFIER_CALCULATE_TYPE_MAX)
        self:SendBuffRefreshToClients()
        --print("IsServer",self.base_attack_time)
        return self.base_attack_time
    end
    if IsClient() then
        --print("IsClient")
        --print("IsClient",self.base_attack_time)
        return self.base_attack_time
    end
end
