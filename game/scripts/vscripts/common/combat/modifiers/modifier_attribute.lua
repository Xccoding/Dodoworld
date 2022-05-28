--标记战斗用modifiers
if modifier_attribute == nil then
	modifier_attribute = class({})
end
function modifier_attribute:IsHidden()
    return false
end
function modifier_attribute:IsDebuff()
    return false
end 
function modifier_attribute:IsPurgable()
    return false
end
function modifier_attribute:RemoveOnDeath()
    return false
end
function modifier_attribute:OnCreated(params)
    if IsServer() then
       self:StartIntervalThink(0.1)
    end
end
function modifier_attribute:OnIntervalThink()
    if IsServer() then
        local hCaster = self:GetCaster()
        local bUpdate = false
        local attr_old = CustomNetTables:GetTableValue("unit_attribute", hCaster:entindex()) or 
        {
            DPS = 0,
            HPS = 0,
        }

        local attr_new = 
        {
            DPS = hCaster:GetDPS(),
            HPS = hCaster:GetDPS(),
        }

        for attr, value in pairs(attr_new) do
            if value ~= attr_old[attr] then
                bUpdate = true
                break
            end
        end

        if bUpdate then
            
        end

        

    end
end