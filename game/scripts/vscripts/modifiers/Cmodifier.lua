--自定义事件
CMODIFIER_EVENT_ON_ATTACK_CRIT = "C_OnAttackCrit"--攻击暴击
CMODIFIER_EVENT_ON_ATTACK_NOTCRIT = "C_OnAttackNotCrit"--攻击未暴击
CMODIFIER_EVENT_ON_SPELL_CRIT = "C_OnSpellCrit"--技能暴击
CMODIFIER_EVENT_ON_SPELL_NOTCRIT = "C_OnSpellNotCrit"--技能未暴击
CMODIFIER_EVENT_ON_HEAL = "C_OnHeal"--主动输出治疗
CMODIFIER_EVENT_ON_HEALED = "C_OnHealed"--被动承受治疗
--自定义属性函数
--暴击
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_CONSTANT = "C_GetModifierBonusPhysicalCritChance_Constant"--物理暴击几率加算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT = "C_GetModifierBonusMagicalCritChance_Constant"--魔法暴击几率加算
CMODIFIER_PROPERTY_BONUS_PHYSICAL_CRIT_CHANCE_PERCENT = "C_GetModifierBonusPhysicalCritChance_Percent"--物理暴击几率乘算
CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT = "C_GetModifierBonusMagicalCritChance_Percent"--魔法暴击几率乘算
--攻击间隔
CMODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT = "C_GetModifierBaseAttackTime_Constant"--基础攻击间隔





--自定义属性
BONUS_PHYSICAL_CRIT_CHANCE = "BONUS_PHYSICAL_CRIT_CHANCE"
BONUS_MAGICAL_CRIT_CHANCE = "BONUS_MAGICAL_CRIT_CHANCE"
BASE_ATTACK_TIME = "BASE_ATTACK_TIME"





if IsServer() then
    function CFireModifierEvent(hUnit, iEvent, params)
        local buffs = hUnit:FindAllModifiers()
        for _, buff in pairs(buffs) do
            if buff[iEvent] ~= nil and type(buff[iEvent]) == "function" then
                buff[iEvent](buff, params)
            end
        end
    end
    function CDOTA_Modifier_Lua:CheckUseOrb(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord and self.records[index].bOrb == true then
                return true
            end
        end
        return false
    end

    function CDOTA_Modifier_Lua:RemoveRecord(iRecord)
        if self.records == nil then
            self.records = {}
        end
        for index = 1, #self.records do
            if self.records[index].iRecord == iRecord then
                table.remove(self.records, index)
                break
            end
        end
    end

end

