AbilityCharge_manager = {}

LinkLuaModifier("modifier_AbilityCharge", "common/managers/AbilityCharge_manager.lua", LUA_MODIFIER_MOTION_NONE)

function AbilityCharge_manager:constructor(o, hAbility)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.hAbility = hAbility
    o.ChargeState = false
    return o
end

function AbilityCharge_manager:IsCharging()
    return self.ChargeState
end

function AbilityCharge_manager:SpendCharge()
    self.ChargeModifier:DecrementStackCount()
end

function AbilityCharge_manager:StartRestoreCharge()
    local hAbility = self.hAbility

    if IsValid(hAbility) then
        if not self:IsCharging() and self:C_GetMaxCharges() > self:C_GetCurrentCharges() then
            self.ChargeState = true
            self.ChargeModifier:StartIntervalThink(self:C_GetRestoreTime() - GameRules:GetGameFrameTime() * 2)
            self.ChargeModifier:SetDuration(self:C_GetRestoreTime(), true)
        elseif self:C_GetCurrentCharges() >= self:C_GetMaxCharges() then
            self.ChargeModifier:SetStackCount(self:C_GetMaxCharges())
            if self:IsCharging() then
                self:StopRestoreCharge()
            end
        end
    end
end

function AbilityCharge_manager:StopRestoreCharge()
    local hAbility = self.hAbility
    if IsValid(hAbility) then
        self.ChargeState = false
        self.ChargeModifier:StartIntervalThink(-1)
    end
end

function AbilityCharge_manager:C_GetCurrentCharges()
    return self.ChargeModifier:GetStackCount()
end

function AbilityCharge_manager:C_GetMaxCharges()
    local hAbility = self.hAbility
    local maxcharges = tonumber(Abilities_manager:GetAbilityValue(hAbility, "CustomAbilityCharges"))
    if self.ChargeModifier ~= nil then
        local origin_maxcharges = self.ChargeModifier.MaxCharges
        self.ChargeModifier.MaxCharges = maxcharges
        self.ChargeModifier:SendBuffRefreshToClients()
        if maxcharges > origin_maxcharges then
            self:C_AddCharges(maxcharges - origin_maxcharges)
        end
    end
    return maxcharges
end

function AbilityCharge_manager:C_GetRestoreTime()
    local hCaster = self.hAbility:GetCaster()
    return self.hAbility:GetAbilityChargeRestoreTime(-1) * hCaster:GetCooldownReduction()
end

function AbilityCharge_manager:C_AddCharges(Charges)
    if self:C_GetCurrentCharges() < self:C_GetMaxCharges() then
        local stack_to_add = Charges
        if self:C_GetCurrentCharges() + stack_to_add > self:C_GetMaxCharges() then
            stack_to_add = self:C_GetMaxCharges() - self:C_GetCurrentCharges()
        end
        self.ChargeModifier:SetStackCount(self:C_GetCurrentCharges() + stack_to_add)
    end
    if self:C_GetCurrentCharges() >= self:C_GetMaxCharges() then
        self:StopRestoreCharge()
    else
        self.ChargeModifier:ForceRefresh()
        self:StartRestoreCharge()
    end
end

--=======================================modifier_AbilityCharge=======================================
if modifier_AbilityCharge == nil then
    modifier_AbilityCharge = class({})
end
function modifier_AbilityCharge:IsHidden()
    return true
end
function modifier_AbilityCharge:IsDebuff()
    return false
end
function modifier_AbilityCharge:IsPurgable()
    return false
end
function modifier_AbilityCharge:IsPurgeException()
    return false
end
function modifier_AbilityCharge:RemoveOnDeath()
    return false
end
function modifier_AbilityCharge:DestroyOnExpire()
    return false
end
function modifier_AbilityCharge:OnCreated(params)
    if IsServer() then
        local manager = self:GetAbility().AbilityCharge_manager
        self:SetStackCount(manager:C_GetMaxCharges())
        self:SetHasCustomTransmitterData(true)
        self.MaxCharges = manager:C_GetMaxCharges()
        -- self:StartIntervalThink(0)
    end
end
function modifier_AbilityCharge:OnRefresh(params)
    if IsServer() then
        local manager = self:GetAbility().AbilityCharge_manager
        self.MaxCharges = manager:C_GetMaxCharges()
    end
end
function modifier_AbilityCharge:OnDestroy(params)
    if IsServer() then
    end
end
function modifier_AbilityCharge:DeclareFunctions()
    return {
    }
end
function modifier_AbilityCharge:CDeclareFunctions()
    return {
    }
end
function modifier_AbilityCharge:AddCustomTransmitterData()
    return {
        MaxCharges = self.MaxCharges
    }
end
function modifier_AbilityCharge:HandleCustomTransmitterData(data)
    self.MaxCharges = data.MaxCharges
end
function modifier_AbilityCharge:OnIntervalThink()
    local manager = self:GetAbility().AbilityCharge_manager
    if self:GetRemainingTime() > GameRules:GetGameFrameTime() * 2 then
        self:StartIntervalThink(0)
    else
        manager:C_AddCharges(1)
    end
end
function modifier_AbilityCharge:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_AbilityCharge:GetTexture()
    return tostring(self.MaxCharges)
end

return AbilityCharge_manager