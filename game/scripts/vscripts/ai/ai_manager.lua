AI_WANDER_TYPE_ACTIVE = 1
AI_WANDER_TYPE_PASSIVE = 2
AI_WANDER_TYPE_ALWAYS = AI_WANDER_TYPE_PASSIVE * 2
AI_GET_TARGET_ORDER_DHPS = 1
AI_GET_TARGET_ORDER_RANGE = 2

AGGRO_MSG_CD = 3 --仇恨提示特效的冷却时间
_G.BASIC_AGGRO_VALUE = 10--基础仇恨值，获得仇恨后会至少加上这个值

_G.AI_KEY_READ_ON_SPAWN = {
    "MaxPursueRange",
    "MaxWanderRange",
    "CombatFindRadius",
    "WanderType",
    "SlowNoComabt",
}

if AI_manager == nil then
    AI_manager = {}
end
function AI_manager:constructor()
    self.Aggro_Map = {}
end
--使unit对target的仇恨改变
function AI_manager:ModifyAggro(unit, target, value)
    local unit_index = unit:entindex()
    local target_index = target:entindex()
    local old_wish_target = AI_manager:GetWishAttackTarget(unit)
    if self.Aggro_Map[unit_index] == nil then
        self.Aggro_Map[unit_index] = {}
        self.Aggro_Map[unit_index][target_index] = math.max(0, value)
    else
        if self.Aggro_Map[unit_index][target_index] == nil then
            self.Aggro_Map[unit_index][target_index] = math.max(0, value)
        else
            self.Aggro_Map[unit_index][target_index] = math.max(0, self.Aggro_Map[unit_index][target_index] + value)
        end
    end
    local new_wish_target = AI_manager:GetWishAttackTarget(unit)
    if old_wish_target ~= new_wish_target then
        self:PlayAggroEffect(unit, target, true)
    end
end
--移除unit对target的仇恨
function AI_manager:RemoveAggro(unit, target)
    local unit_index = unit:entindex()
    local target_index = target:entindex()
    if self.Aggro_Map[unit_index] ~= nil and self.Aggro_Map[unit_index][target_index] ~= nil then
        self.Aggro_Map[unit_index][target_index] = nil
    end
    if type(self.Aggro_Map[unit_index]) == "table" and self.Aggro_Map[unit_index] ~= nil then
        if GetElementCount(self.Aggro_Map[unit_index]) <= 0 then
            self.Aggro_Map[unit_index] = nil
        end
    end
end
--移除所有对target的仇恨
function AI_manager:RemoveAllAggro(target)
    local target_index = target:entindex()

    for _, AggroInfo in pairs(self.Aggro_Map) do
        if AggroInfo[target_index] ~= nil then
            AggroInfo[target_index] = nil
        end
        if type(AggroInfo) == "table" and GetElementCount(AggroInfo) <= 0 then
            AggroInfo = nil
        end
    end
end
--判断unit是否在任意怪物的仇恨列表内
function AI_manager:IsAggroTarget(unit)
    local flag = false
    for target_index, aggro_list in pairs(self.Aggro_Map) do
        if IsValid(EntIndexToHScript(target_index)) then
            if aggro_list ~= nil then
                if aggro_list[unit:entindex()] ~= nil and aggro_list[unit:entindex()] ~= 0 then
                    flag = true
                end
            end
        else
            self.Aggro_Map[target_index] = nil
        end
    end
    return flag
end
--获取unit当前最大仇恨目标
function AI_manager:GetAggroTarget(unit)
    local unit_index = unit:entindex()
    local max_aggro_target = nil
    local max_aggro = 0
    if self.Aggro_Map[unit_index] ~= nil and type(self.Aggro_Map[unit_index]) == "table" then
        for target_index, value in pairs(self.Aggro_Map[unit_index]) do
            if value > max_aggro then
                max_aggro_target = EntIndexToHScript(target_index)
            end
        end
    end
    return max_aggro_target
end
--获取unit当前应当攻击的目标
function AI_manager:GetWishAttackTarget(unit)
    if self:GetTauntingTarget(unit) ~= nil then
        return self:GetTauntingTarget(unit)
    else
        if self:GetAggroTarget(unit) ~= nil then
            self:PlayAggroEffect(unit, self:GetAggroTarget(unit), false)
            return self:GetAggroTarget(unit)
        else
            return nil
        end
        
    end
end
--获取当前嘲讽unit的目标
function AI_manager:GetTauntingTarget(unit)
    if unit:HasModifier("modifier_taunt_custom") then
        return unit:FindModifierByName("modifier_taunt_custom"):GetCaster()
    end
end
--清除仇恨
function AI_manager:ClearAggroTarget(unit)
    local unit_index = unit:entindex()
    self.Aggro_Map[unit_index] = nil
end
--播放仇恨特效
function AI_manager:PlayAggroEffect(unit, target, bPlaysound)
    if bPlaysound then
        target:RemoveModifierByName("modifier_hide_aggro")
        EmitSoundOn("General.PingWarning", target)
        local particleID = ParticleManager:CreateParticle("particles/msg_fx/msg_aggro.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
        ParticleManager:SetParticleControl(particleID, 3, Vector(255, 69, 0))
        ParticleManager:ReleaseParticleIndex(particleID)
        target:AddNewModifier(target, nil, "modifier_hide_aggro", { duration = AGGRO_MSG_CD })
    else
        if not target:HasModifier("modifier_hide_aggro") then
            local particleID = ParticleManager:CreateParticle("particles/msg_fx/msg_aggro.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
            ParticleManager:SetParticleControl(particleID, 3, Vector(255, 69, 0))
            ParticleManager:ReleaseParticleIndex(particleID)
            target:AddNewModifier(target, nil, "modifier_hide_aggro", { duration = AGGRO_MSG_CD })
        end
    end

end

return AI_manager