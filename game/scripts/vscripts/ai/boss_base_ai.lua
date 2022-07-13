--desire用x100以后的数值计算！

MAX_CAMP_RANGE = 800
MAX_WANDER_RANGE = 500
COMBAT_FIND_RADIUS = 600

if boss_base_ai == nil then
	boss_base_ai = class({})
end

function boss_base_ai:constructor(hUnit, fInterval)
    self.me = hUnit
    self.Interval = fInterval
    self:SetupBehaviors()
end

function boss_base_ai:SetupBehaviors()

end

function boss_base_ai:OnCommonThink()
    --存在判断
    if self.me == nil then
        --print("unit == nil")
        return -1
    end
    --存活判断
    if not self.me:IsAlive() then
        --print("unit is dead")
        return -1
    end

    --超距脱战返回
    if (self.me:GetAbsOrigin() - self.me.spawn_entity:GetAbsOrigin()):Length2D() >= MAX_CAMP_RANGE then
        if not (self.me.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION and self.me.current_order.bForce == false) then
            self:NewWander(true)
            self.me:C_ClearAggroTarget()
            self.me:RemoveModifierByName("modifier_combat")
            self.me:AddNewModifier(self.me, nil, "modifier_escape", {duration = 0.25})
            return self.Interval
        else
            if self.me.current_order.fEndtime >= GameRules:GetGameTime() then
                self:NewWander(true)
                self.me:C_ClearAggroTarget()
                self.me:RemoveModifierByName("modifier_combat")
                self.me:AddNewModifier(self.me, nil, "modifier_escape", {duration = 0.25})
                return self.Interval
            end
        end
    else
        if self.me.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION and self.me.current_order.bForce == true and (self.me:GetAbsOrigin() - self.me.spawn_entity:GetAbsOrigin()):Length2D() >= MAX_WANDER_RANGE then
            self:NewWander(true)
            self.me:C_ClearAggroTarget()
            self.me:RemoveModifierByName("modifier_combat")
            self.me:AddNewModifier(self.me, nil, "modifier_escape", {duration = 0.25})
            return self.Interval
        end
    end

    --未超距，判断根据什么条件更新仇恨目标
    if self.me:InCombat() then
        self.me:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_DHPS, math.max(self.me:GetAcquisitionRange(), COMBAT_FIND_RADIUS), nil)
    else
        if self.me:GetAcquisitionRange() > 0 then
            self.me:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_RANGE, math.max(self.me:GetAcquisitionRange(), COMBAT_FIND_RADIUS), nil)
        else
            self.me:C_ClearAggroTarget()
        end
    end

    
    if not self.me:InCombat() then
        --非战斗中
        if self.me.wander_type ~= nil then 
            --是否会主动游荡
            if self.me.wander_type == AI_WANDER_TYPE_ACTIVE then
                if self.me.current_order.order == nil or (self.me.current_order.order ~= nil and self.me.current_order.fEndtime < GameRules:GetGameTime()) then
                    -- print("new wander")
                    self:NewWander(false)
                    return self.Interval
                end
            end
        end
    else
        if self.me.current_order.order == nil or (self.me.current_order.order ~= nil and self.me.current_order.fEndtime < GameRules:GetGameTime() and not self.me:IsChanneling()) or self.me.current_order.order == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
            local desires = {}
            if self.behaviors ~= nil then
                for i = 1, #self.behaviors do
                    local behavior = self.behaviors[i]
                    if behavior then
                        local hAbility = self.me:FindAbilityByName(behavior)
                        if behavior == "NormalAttack" or  (behavior ~= "NormalAttack" and (hAbility:IsFullyCastable() and not hAbility:IsPassive() and not hAbility:IsHidden() and hAbility:IsActivated())) then
                            table.insert(desires, { order_name = behavior, order_info = self["GetDesireFor_"..tostring(behavior)]( self, behavior )})
                            --[[AI文件的GetDesireFor_xxx返回一个order_info = {
                                order_table = {},
                                desire = number,
                                cost_time = number,
                            },
                            如果是攻击指令，order_info里只有desire一个参数,
                            一些技能指令如果找不到合适的目标，也可能只返回desire = 0
                            ]]--
                        end
                    end
                end
            end
    
            if #desires > 0 then
                --根据desire重排
                table.sort(desires, function (a, b)
                    return a.order_info.desire > b.order_info.desire
                end)
                -- for _, value in pairs(desires) do
                --     print("N2O", value.order_name, value.order_info.desire)
                -- end
                if desires[1].order_name ~= nil then
                    if desires[1].order_name == "NormalAttack" then
                        --直接处理攻击行为
                        if self.me:C_GetAggroTarget() ~= nil then
                            ExecuteOrderFromTable({
                                UnitIndex = self.me:entindex(),
                                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                                TargetIndex = self.me:C_GetAggroTarget():entindex(),
                                Queue = false,
                            })
                            self.me.current_order = {order = DOTA_UNIT_ORDER_ATTACK_TARGET, fEndtime = GameRules:GetGameTime() + self.me:GetBaseAttackTime(), bForce = false}
                        end
                    else
                        --执行技能
                        ExecuteOrderFromTable(
                            desires[1].order_info.order_table
                        )
                        self.me.current_order = {order = desires[1].order_info.order_table.OrderType, fEndtime = GameRules:GetGameTime() + desires[1].order_info.cost_time, bForce = false}
                    end
                end
            end
    
            return self.Interval
        end
    end
    
    return self.Interval
end

function boss_base_ai:NewWander(bForce)
    local unit = self.me
    local spawn_entity = unit.spawn_entity
    local pos = spawn_entity:GetAbsOrigin()
    local time = (pos - unit:GetAbsOrigin()):Length2D() / unit:GetIdealSpeed()
    for i = 1, 100 do
        local pos_try = spawn_entity:GetAbsOrigin() + RandomVector(RandomFloat(0, 500))
        if GridNav:CanFindPath(unit:GetAbsOrigin(), pos_try) then
            pos = pos_try
            break
        end
    end
    ExecuteOrderFromTable({
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = pos,
        Queue = not bForce,
    })
    unit.current_order = {order = DOTA_UNIT_ORDER_MOVE_TO_POSITION, fEndtime = GameRules:GetGameTime() + time, bForce = bForce}
end

--获取当前可用的技能占主动技能的百分之几
function boss_base_ai:GetAvailableAbilityPercent()
    local AvailableAbility = 0
    local NoPassiveAbility = 0
    --计算主动技能数量
    for index = 0, self.me:GetAbilityCount() - 1 do
        local hAbility = self.me:GetAbilityByIndex(index)
        if hAbility ~= nil and (not hAbility:IsPassive()) then
            NoPassiveAbility = NoPassiveAbility + 1
            if hAbility:IsFullyCastable() and hAbility:IsActivated() then
                AvailableAbility = AvailableAbility + 1
            end
        end
    end
    if NoPassiveAbility == 0 then
        return 0
    else
        return AvailableAbility / NoPassiveAbility * 100
    end
end

