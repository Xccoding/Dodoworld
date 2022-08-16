require('ai.boss_base_ai')

if ai_creature_lamper_maurice == nil then
    ai_creature_lamper_maurice = class(boss_base_ai)
end

function Spawn(kv)
    if IsServer() then
        if thisEntity == nil then
            return
        end
        SaveSpawnKV(thisEntity, kv)
        thisEntity.current_order = { order = nil, fEndtime = nil }
        thisEntity.AI = ai_creature_lamper_maurice(thisEntity, 0.25)

    end
end

function ai_creature_lamper_maurice:SetupBehaviors()
    boss_base_ai.SetupBehaviors(self)

    self.behaviors = {
        "NormalAttack",
        "lamper_maurice_head_butt",
        "lamper_maurice_seek_help",
    }
end

function ai_creature_lamper_maurice:constructor(hUnit, fInterval)
    boss_base_ai.constructor(self, hUnit, fInterval)
    self.me:SetThink('On_lamper_maurice_think', self, 'On_lamper_maurice_think', fInterval)
end

function ai_creature_lamper_maurice:On_lamper_maurice_think()
    self.Available_pct = self:GetAvailableAbilityPercent()
    return self:OnCommonThink()
end

function ai_creature_lamper_maurice:GetDesireFor_NormalAttack(behavior_name)
    return {
        desire = 10 / (10 + self.Available_pct) * 100,
    }
end

function ai_creature_lamper_maurice:GetDesireFor_lamper_maurice_head_butt(ability_name)
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    -- local find_radius = hAbility:GetCastRange(unit:GetAbsOrigin(), nil)
    -- local hTarget = nil
    local desire = 30

    if AI_manager:GetWishAttackTarget(unit) ~= nil then
        return {
            order_table = {
                UnitIndex = unit:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = hAbility:entindex(),
                TargetIndex = AI_manager:GetWishAttackTarget(unit):entindex(),
                Queue = false,
            },
            desire = desire,
            cost_time = hAbility:GetCastPoint() + 0.5,
        }
    else
        return {
            desire = 0,
        }
    end
end

function ai_creature_lamper_maurice:GetDesireFor_lamper_maurice_seek_help(ability_name)
    local unit = self.me
    local hAbility = unit:FindAbilityByName(ability_name)
    local desire = 30

    if unit:GetHealth() < 90 then
        desire = 40
    end

    local buff = unit:FindModifierByName("modifier_lamper_maurice_seek_help")
    if buff.moles ~= nil and type(buff.moles) == "table" then
        local bSleepmoleExist = false
        for _, mole in pairs(buff.moles) do
            if mole:IsAlive() and mole:HasModifier("modifier_lamper_maurice_seek_help_sleep") then
                bSleepmoleExist = true
                break
            end
        end

        if bSleepmoleExist then
            return {
                order_table = {
                    UnitIndex = unit:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = hAbility:entindex(),
                    Queue = false,
                },
                desire = desire,
                cost_time = hAbility:GetCastPoint() + hAbility:GetChannelTime() + 0.5,
            }
        else
            return {
                desire = 0,
            }
        end    
    else
        return {
            desire = 0,
        }
    end


end