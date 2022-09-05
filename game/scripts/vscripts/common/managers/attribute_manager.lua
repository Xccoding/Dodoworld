
--link英雄属性modifier
LinkLuaModifier( "modifier_hero_attribute", "common/attributes/modifiers/modifier_hero_attribute.lua", LUA_MODIFIER_MOTION_NONE )
--link普通单位属性modifier
LinkLuaModifier( "modifier_basic_attribute", "common/attributes/modifiers/modifier_basic_attribute.lua", LUA_MODIFIER_MOTION_NONE )

-- _G.ATTR_KEY_READ_ON_SPAWN = {
--     "ArmorPhysical",
--     "CustomMagicalResistance",
-- }

-------------------------------双端内容-------------------------------
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
function BaseNPC:GetUnitAttribute(attrName, params, calculate_type)--根据字段获取属性
    calculate_type = calculate_type or MODIFIER_CALCULATE_TYPE_SUM
    local buffs = self:FindAllModifiers()
    local attr = 0--TODO默认属性改回0
    local func_constant = _G["CMODIFIER_PROPERTY_"..attrName.."_CONSTANT"]
    local func_percent = _G["CMODIFIER_PROPERTY_"..attrName.."_PERCENT"]
    local func_total_percent = _G["CMODIFIER_PROPERTY_"..attrName.."_TOTAL_PERCENT"]

    if calculate_type == MODIFIER_CALCULATE_TYPE_SUM then
        --计算固定值部分
        if func_constant ~= nil then
            for _, buff in pairs(buffs) do
                if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                    attr = attr + buff[func_constant](buff, params)
                end
            end
        end
        
        --计算百分比部分
        if func_percent ~= nil then
            local percent_sum = 0
            for _, buff in pairs(buffs) do
                if buff[func_percent] ~= nil and type(buff[func_percent]) == "function" then
                    percent_sum = percent_sum + buff[func_percent](buff, params)
                end
            end
            attr = attr * ( 100 + percent_sum) * 0.01
        end

        --总乘算部分
        if func_total_percent ~= nil then
            for _, buff in pairs(buffs) do
                if buff[func_total_percent] ~= nil and type(buff[func_total_percent]) == "function" then
                    attr = attr * ( 100 + buff[func_total_percent](buff, params)) * 0.01
                end
            end 
        end

    elseif calculate_type == MODIFIER_CALCULATE_TYPE_MAX then
        attr = 0
        if func_constant ~= nil then
            for _, buff in pairs(buffs) do
                if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                    attr = math.max(attr, buff[func_constant](buff, params))
                end
            end
        end
    elseif calculate_type == MODIFIER_CALCULATE_TYPE_MIN then
        attr = 0
        if func_constant ~= nil then
            for _, buff in pairs(buffs) do
                if buff[func_constant] ~= nil and type(buff[func_constant]) == "function" then
                    attr = math.min(attr, buff[func_constant](buff, params))
                end
            end
        end
    end

    
    
    return attr
end

function BaseNPC:IsUseMana()
    local unit = self
    local label = unit:GetUnitLabel()
    local current_schools = CustomNetTables:GetTableValue("hero_schools", tostring(unit:GetPlayerOwnerID())).schools_index or 0
    
    if KeyValues.SchoolsKv[label] == nil then
        return false
    end

    if KeyValues.SchoolsKv[label][tostring(current_schools)] ~= nil then
        if KeyValues.SchoolsKv[label][tostring(current_schools)].usemana == 1 then
            return true
        else
            return false
        end
    end

    return false

end

-------------------------------服务端内容-------------------------------
if IsServer() then
    --获取技能伤害基数
    function CDOTA_BaseNPC:GetDamageforAbility( iCalculate_type )
        local dmg = self:GetAverageTrueAttackDamage(self)
        --暂时都计算主属性
        if self:IsRealHero() then
            if iCalculate_type == ABILITY_DAMAGE_CALCULATE_TYPE_AP then
                dmg = self:GetAverageTrueAttackDamage(self)
            elseif iCalculate_type == ABILITY_DAMAGE_CALCULATE_TYPE_SP then
                dmg = self:GetUnitAttribute(SPELL_POWER, {}, MODIFIER_CALCULATE_TYPE_SUM)
            end
        end
        return dmg
    end

    --根据护甲计算减伤率
    function CDOTA_BaseNPC:GetPhysicalDamageReduction( level_diff )
        level_diff = level_diff or 0
        if level_diff > PHYSICAL_ARMOR_IGNORE_LEVEL_MAX then
            level_diff = PHYSICAL_ARMOR_IGNORE_LEVEL_MAX
        end
        if level_diff < -PHYSICAL_ARMOR_IGNORE_LEVEL_MAX then
            level_diff = -PHYSICAL_ARMOR_IGNORE_LEVEL_MAX
        end

        local iPhysicalArmor =  self:GetUnitAttribute(PHYSICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)
        local ignored_pct = level_diff * PHYSICAL_ARMOR_IGNORE_LEVEL_FACTOR
        
        iPhysicalArmor = iPhysicalArmor * (100 - ignored_pct) * 0.01
        local armor_pct = iPhysicalArmor / (iPhysicalArmor + (30 + self:GetLevel() * 4) * CDOTA_ATTRIBUTE_AGILITY_PHYSICAL_ARMOR) * 100
        return armor_pct
    end

    --根据魔抗计算减伤率
    function CDOTA_BaseNPC:GetMagicalDamageReduction( level_diff )
        level_diff = level_diff or 0
        if level_diff > MAGICAL_ARMOR_IGNORE_LEVEL_MAX then
            level_diff = MAGICAL_ARMOR_IGNORE_LEVEL_MAX
        end
        if level_diff < -MAGICAL_ARMOR_IGNORE_LEVEL_MAX then
            level_diff = -MAGICAL_ARMOR_IGNORE_LEVEL_MAX
        end

        local iMagicalArmor =  self:GetUnitAttribute(MAGICAL_ARMOR, {}, MODIFIER_CALCULATE_TYPE_SUM)
        local ignored_pct = level_diff * MAGICAL_ARMOR_IGNORE_LEVEL_FACTOR
        
        iMagicalArmor = iMagicalArmor * (100 - ignored_pct) * 0.01
        local armor_pct = iMagicalArmor / (iMagicalArmor + (30 + self:GetLevel() * 4) * CDOTA_ATTRIBUTE_INTELLIGENCE_MAGICAL_ARMOR) * 100
        return armor_pct
    end

    --把单位的指定键值暂存到他身上
    function SaveSpawnKV( thisEntity, kv )
        local kv_attr_table = {}
        --属性键值
        -- for i = 1, #ATTR_KEY_READ_ON_SPAWN do
        --     if kv:GetValue(ATTR_KEY_READ_ON_SPAWN[i]) ~= nil then
        --         kv_attr_table[ATTR_KEY_READ_ON_SPAWN[i]] = tonumber(kv:GetValue(ATTR_KEY_READ_ON_SPAWN[i]))
        --     end
        -- end
        -- thisEntity.kv_attr_table = kv_attr_table
        --AI行为键值
        local kv_ai_table = {}
        for i = 1, #AI_KEY_READ_ON_SPAWN do
            if kv:GetValue(AI_KEY_READ_ON_SPAWN[i]) ~= nil then
                kv_ai_table[AI_KEY_READ_ON_SPAWN[i]] = tonumber(kv:GetValue(AI_KEY_READ_ON_SPAWN[i]))
            end
        end
        thisEntity.kv_ai_table = kv_ai_table
    end

end
