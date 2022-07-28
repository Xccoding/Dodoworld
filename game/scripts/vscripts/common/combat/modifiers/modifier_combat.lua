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
    if IsServer() then
        self.combat_start_time = GameRules:GetGameTime()
        self.damage = 0
        self.heal = 0
        CFireModifierEvent(hParent, CMODIFIER_EVENT_ON_COMBAT_START, {})
        if not hParent:IsControllableByAnyPlayer() and params.aggro_target ~= nil then
            hParent:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_DHPS, FIND_UNITS_EVERYWHERE, EntIndexToHScript(params.aggro_target))
        end
        self:StartIntervalThink(FrameTime())
    end
end
function modifier_combat:OnDestroy()
    local hParent = self:GetParent()
    if IsServer() then
        CFireModifierEvent(hParent, CMODIFIER_EVENT_ON_COMBAT_END, {})
    end
end
function modifier_combat:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_combat:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_HEAL,
    }
end
function modifier_combat:OnTakeDamage( params )
    if not IsServer() then
        return
    end
    if params.attacker == self:GetParent() then
        self.damage = self.damage + params.damage
        if self:GetParent():IsControllableByAnyPlayer() then
            self:GetParent():UpdateDHPS()
        end
    end
end
function modifier_combat:C_OnHeal( params )
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
            --英雄特有的仇恨监控
            local IsAggroTarget = false
            local enemies = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do
                if enemy:C_GetAggroTarget() ~= nil and enemy:C_GetAggroTarget() == hParent then
                    IsAggroTarget = true
                    break
                end
            end
            if not IsAggroTarget then
                --脱战驱散
                hParent:Purge(false, true, false, true, true)
                self:Destroy()
            end
        end
    end
end