require('modifiers.Cmodifier')
local BaseNPC
if IsServer() then
    BaseNPC = CDOTA_BaseNPC
end
if IsClient() then
    BaseNPC = C_DOTA_BaseNPC
end

MODIFIER_CALCULATE_TYPE_SUM = 1
MODIFIER_CALCULATE_TYPE_MAX = MODIFIER_CALCULATE_TYPE_SUM * 2
MODIFIER_CALCULATE_TYPE_MIN = MODIFIER_CALCULATE_TYPE_MAX * 2

--根据字段获取属性
function BaseNPC:GetUnitAttribute(attrName, params, calculate_type)
    calculate_type = calculate_type or MODIFIER_CALCULATE_TYPE_SUM
    local buffs = self:FindAllModifiers()
    local attr = 30--TODO默认属性改回0
    local func_constant = _G["CMODIFIER_PROPERTY_"..attrName.."_CONSTANT"]
    local func_percent = _G["CMODIFIER_PROPERTY_"..attrName.."_PERCENT"]

    if calculate_type == MODIFIER_CALCULATE_TYPE_SUM then
        --计算固定值部分
        for _, buff in pairs(buffs) do
            if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                attr = attr + buff[func_constant](buff, params)
            end
        end
        --计算百分比部分
        for _, buff in pairs(buffs) do
            if buff[func_percent] ~= nil and type(buff[func_percent]) == "function" then
                attr = attr * ( 100 + buff[func_percent](buff, params)) * 0.01
            end
        end
    elseif calculate_type == MODIFIER_CALCULATE_TYPE_MAX then
        attr = 0
        for _, buff in pairs(buffs) do
            if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                attr = math.max(attr, buff[func_constant](buff, params))
            end
        end
    elseif calculate_type == MODIFIER_CALCULATE_TYPE_MIN then
        attr = 0
        for _, buff in pairs(buffs) do
            if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                attr = math.min(attr, buff[func_constant](buff, params))
            end
        end
    end

    
    
    return attr
end

if IsServer() then
    --获取技能伤害基数
    function CDOTA_BaseNPC:GetDamageforAbility( bIsAP )
        local dmg = self:GetAverageTrueAttackDamage(self)
        --暂时都计算主属性
        if self:IsRealHero() then
            dmg = self:GetPrimaryStatValue()
        end
        return dmg
    end
end
