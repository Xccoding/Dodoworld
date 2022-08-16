--标记战斗用modifiers
if modifier_combat == nil then
    modifier_combat = class({})
end
function modifier_combat:IsHidden()
    return false
end
function modifier_combat:IsDebuff()
    return false
end
function modifier_combat:IsPurgable()
    return false
end
function modifier_combat:OnCreated(params)
    local hParent = self:GetParent()
    local hCaster = self:GetCaster()
    if IsServer() then
        self.combat_start_time = GameRules:GetGameTime()
        self.damage = 0
        self.heal = 0
        CFireModifierEvent(hParent, CMODIFIER_EVENT_ON_COMBAT_START, {})
        if not hParent:IsControllableByAnyPlayer() then
            AI_manager:ModifyAggro(hParent, hCaster, BASIC_AGGRO_VALUE)
        end
        self:StartIntervalThink(0)
    end
end
function modifier_combat:OnDestroy()
    local hParent = self:GetParent()
    if IsServer() then
        hParent:PurgeOnCombatEnd()
        CFireModifierEvent(hParent, CMODIFIER_EVENT_ON_COMBAT_END, {})
    end
end
function modifier_combat:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH,
    }
end
function modifier_combat:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_HEAL,
    }
end
function modifier_combat:RemoveOnDeath()
    return false
end
function modifier_combat:OnTakeDamage(params)
    local hParent = self:GetParent()
    local hCaster = self:GetCaster()
    local hAttacker = params.attacker
    if not IsServer() then
        return
    end
    if hAttacker == hParent then
        self.damage = self.damage + params.damage
        if hParent:IsControllableByAnyPlayer() then
            hParent:UpdateDHPS()
        end
    elseif params.unit == hParent and not hParent:IsControllableByAnyPlayer() then
        AI_manager:ModifyAggro(hParent, hAttacker, params.damage)
    end
end
function modifier_combat:C_OnHeal(params)
    if not IsServer() then
        return
    end
    if params.source == self:GetParent() then
        self.heal = self.heal + params.amount
    end
end
function modifier_combat:OnIntervalThink()
    local hParent = self:GetParent()
    if IsServer() then
        if hParent:IsControllableByAnyPlayer() then
            --英雄特有的更新dps
            hParent:UpdateDHPS()
            if not AI_manager:IsAggroTarget(hParent) then
                --脱战驱散
                hParent:Purge(false, true, false, true, true)
                --驱散一些仅脱战才能驱散的modifier
                self:Destroy()
            end
        end
    end
end
function modifier_combat:OnDeath( params )
    local hParent = self:GetParent()
    if hParent == params.unit then
        if hParent:IsControllableByAnyPlayer() then
            AI_manager:RemoveAllAggro(hParent)
        end
        self:Destroy()
    end
end