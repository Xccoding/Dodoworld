--=======================================modifier_hero_movingcast=======================================
if modifier_hero_movingcast == nil then
    modifier_hero_movingcast = class({})
end
function modifier_hero_movingcast:IsHidden()
    return true
end
function modifier_hero_movingcast:IsDebuff()
    return false
end
function modifier_hero_movingcast:IsPurgable()
    return false
end
function modifier_hero_movingcast:IsPurgeException()
    return false
end
function modifier_hero_movingcast:GetAbilityValues()
    for _, key_name in pairs(self.keys) do
        self[key_name] = self:GetAbilitySpecialValueFor(key_name)
    end
end
function modifier_hero_movingcast:OnCreated(params)
    self.bInterruputed = false
    self.Callback = params.Callback
    self.keys = {}
    if params.Keys ~= nil then
        local key_array = vlua.split(params.Keys, " ")
        if key_array == nil then
            table.insert(self.keys, params.Keys)
        else
            for k, v in pairs(key_array) do
                table.insert(self.keys, v)
            end
        end
    end
    self:GetAbilityValues()
    if IsServer() then
        local hParent = self:GetParent()
        CustomGameEventManager:Send_ServerToPlayer(hParent:GetPlayerOwner(), "AbilityStart", { ability = self:GetAbility():entindex(), casttype = "phase", duration = self:GetDuration() })
        self:StartIntervalThink(0)
    end
end
function modifier_hero_movingcast:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_hero_movingcast:OnDestroy(params)
    if IsServer() then
        local hParent = self:GetParent()
        CustomGameEventManager:Send_ServerToPlayer(hParent:GetPlayerOwner(), "AbilityEnd", {})
        if not self.bInterruputed and self.Callback ~= nil then
            local hAbility = self:GetAbility()

            if bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
                local dir = (hAbility.hTarget:GetAbsOrigin() - hParent:GetAbsOrigin()):Normalized()
                hParent:SetForwardVector(dir)
            end
            if hAbility[self.Callback] ~= nil and type(hAbility[self.Callback]) == "function" then
                hAbility[self.Callback](hAbility)
            end
        end
    end
end
function modifier_hero_movingcast:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_START,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
    }
end
function modifier_hero_movingcast:CDeclareFunctions()
    return {
    }
end
function modifier_hero_movingcast:GetDisableAutoAttack()
    return 1
end
function modifier_hero_movingcast:OnIntervalThink()
    local hAbility = self:GetAbility()
    local hParent = self:GetParent()
    if bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
        local cast_range = hAbility:GetCastRange(hParent:GetAbsOrigin(), hAbility.hTarget)
        local cast_range_buffer = Abilities_manager:GetAbilityValue(hAbility, "AbilityCastRangeBuffer")
        if cast_range + cast_range_buffer < (hAbility.hTarget:GetAbsOrigin() - hParent:GetAbsOrigin()):Length2D() then
            self.bInterruputed = true
            self:Destroy()
        end
    end
    --TODO无目标增加鼠标监听
end
function modifier_hero_movingcast:OnAbilityStart(params)
    if IsServer() then
        local hParent = self:GetParent()
        local hAbility = params.ability
        if params.unit == hParent then
            if not (bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE) == DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE and bit.band(hAbility:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_IMMEDIATE) == DOTA_ABILITY_BEHAVIOR_IMMEDIATE) then

                self.bInterruputed = true
                self:Destroy()
            end
        end
    end
end
function modifier_hero_movingcast:OnOrder(params)
    local hParent = self:GetParent()
    if params.unit == hParent then
        
        if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
            self.bInterruputed = true
            self:Destroy()
        end
    end
end
function modifier_hero_movingcast:GetOverrideAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end