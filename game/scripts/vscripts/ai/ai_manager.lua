AI_WANDER_TYPE_ACTIVE = 1
AI_WANDER_TYPE_PASSIVE = 2
AI_GET_TARGET_ORDER_DHPS = 1
AI_GET_TARGET_ORDER_RANGE = 2

AGGRO_MSG_CD = 3

local BaseNPC
if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end
if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end
--获取当前仇恨目标
function CDOTA_BaseNPC:C_GetAggroTarget()
    if self.C_AggroTarget ~= nil and (not self.C_AggroTarget:IsNull()) then
        return self.C_AggroTarget
    end
    return nil
end
--清除当前仇恨目标
function CDOTA_BaseNPC:C_ClearAggroTarget()
    self.C_AggroTarget = nil
end
--更新仇恨目标
function CDOTA_BaseNPC:C_RefreshAggroTarget(iGetOrder, fFind_radius, hAggro_target)
    local aggro_target = nil
    --如果预传入一个单位，直接设置它为目标
    if hAggro_target ~= nil then
        aggro_target = hAggro_target
    end
    --如果被嘲讽了，选他做目标
    if self:HasModifier("modifier_taunt_custom") and aggro_target == nil then
        aggro_target = self:FindModifierByName("modifier_taunt_custom"):GetCaster()
    end
    --没被嘲讽
    if aggro_target == nil then
        if iGetOrder == AI_GET_TARGET_ORDER_DHPS then
            aggro_target = self:C_GetAggroTargetByDHPS()
            if aggro_target == nil then
                aggro_target = self:C_GetAggroTargetByRange(fFind_radius)
            end 
        elseif iGetOrder == AI_GET_TARGET_ORDER_RANGE then
            aggro_target = self:C_GetAggroTargetByRange(fFind_radius)
            if aggro_target == nil then
                aggro_target = self:C_GetAggroTargetByDHPS()
            end
        end
    end
    --加仇恨特效
    if aggro_target ~= nil then
        if self.C_AggroTarget ~= aggro_target or (self.C_AggroTarget == aggro_target and not aggro_target:HasModifier("modifier_hide_aggro")) then
            local particleID = ParticleManager:CreateParticle("particles/msg_fx/msg_aggro.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
            ParticleManager:SetParticleControlEnt(particleID, 1, aggro_target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
            ParticleManager:SetParticleControl(particleID, 3, Vector(255, 69, 0))
            ParticleManager:ReleaseParticleIndex(particleID)
            aggro_target:AddNewModifier(aggro_target, nil, "modifier_hide_aggro", {duration = AGGRO_MSG_CD})
            if self.C_AggroTarget ~= aggro_target then
                EmitSoundOn("General.PingWarning", aggro_target)
            end
        end
    end
    self.C_AggroTarget = aggro_target
end
--DPS优先选择仇恨目标
function CDOTA_BaseNPC:C_GetAggroTargetByDHPS()
    local max_hatred = 0
    local aggro_target = nil
    local units = FindUnitsInRadius(self:GetTeamNumber(), self:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit ~= nil and unit:IsAlive() then
            --print("打印DPS",unit:GetDPS())
            if unit:GetDPS() > 0 or unit:GetHPS() > 0 then
                if unit:GetDPS() * unit:GetAggroFactor() + unit:GetHPS() * unit:GetAggroFactor() > max_hatred then
                    max_hatred = unit:GetDPS() * unit:GetAggroFactor() + unit:GetHPS() * unit:GetAggroFactor()
                    aggro_target = unit
                end
            end
        end
    end
    return aggro_target
end
--距离优先选择仇恨目标
function CDOTA_BaseNPC:C_GetAggroTargetByRange(fFind_radius)
    local aggro_target = nil
    if fFind_radius > 0 then
        local units = FindUnitsInRadius(self:GetTeamNumber(), self:GetAbsOrigin(), nil, fFind_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
        for _, unit in pairs(units) do
            if unit ~= nil and unit:IsAlive() then
                aggro_target = unit
                break
            end
        end
    end
    return aggro_target
end