require('ai.boss_base_ai')
if ai_creature_watcher_adolph == nil then
    ai_creature_watcher_adolph = class( boss_base_ai )
end
function Spawn( kv )
    if IsServer() then
        if thisEntity == nil then
            return
        end
        SaveSpawnKV( thisEntity, kv )
        thisEntity.current_order = {order = nil, fEndtime = nil}
        thisEntity.AI = ai_creature_watcher_adolph( thisEntity, 1 )
    end
end
function ai_creature_watcher_adolph:SetupBehaviors()
    boss_base_ai.SetupBehaviors(self)
    self.behaviors = {
        "NormalAttack",
        "watcher_adolph_dash",
        --"",
    }
end
function ai_creature_watcher_adolph:constructor(hUnit, fInterval)
    boss_base_ai.constructor(self, hUnit, fInterval)
    self.me:SetThink( 'On_watcher_adolph_think', self, 'On_watcher_adolph_think', fInterval )
end
function ai_creature_watcher_adolph:On_watcher_adolph_think()
    self.Available_pct = self:GetAvailableAbilityPercent()
    return self:OnCommonThink()
end

function ai_creature_watcher_adolph:GetDesireFor_NormalAttack( behavior_name )
    return {
        desire = 10 / (10 + self.Available_pct) * 100,
    }
end

function ai_creature_watcher_adolph:GetDesireFor_watcher_adolph_dash( ability_name )
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local pre_time = hAbility:GetSpecialValueFor("pre_time")
    local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    local hTarget = nil
    local desire = 30

    local tTargets = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, find_radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    if #tTargets > 0 then
        for _, enemy in pairs(tTargets) do
            if enemy ~= nil and enemy:IsAlive() then
                if hTarget == nil then
                    hTarget = enemy   
                end
                if enemy:GetHealth() <= hAbility:GetSpecialValueFor("damage") then
                    hTarget = enemy
                    desire = 50
                    break
                end
            end
        end
    end

    if hTarget == nil then
        return {
            desire = 0,
        }
    else
        return {
            order_table = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = hAbility:entindex(),
                TargetIndex = hTarget:entindex(),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + pre_time + 1,
        }
    end


end