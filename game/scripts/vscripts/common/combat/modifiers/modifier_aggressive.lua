

--=======================================modifier_aggressive=======================================
if modifier_aggressive == nil then
    modifier_aggressive = class({})
end
function modifier_aggressive:IsHidden()
    return true
end
function modifier_aggressive:IsDebuff()
    return false
end
function modifier_aggressive:IsPurgable()
    return false
end
function modifier_aggressive:IsPurgeException()
    return false
end
function modifier_aggressive:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(0)
    end
end
function modifier_aggressive:OnRefresh(params)
end
function modifier_aggressive:OnDestroy(params)
end
function modifier_aggressive:DeclareFunctions()
    return {
    }
end
function modifier_aggressive:CDeclareFunctions()
    return {
    }
end
function modifier_aggressive:OnIntervalThink()
    local hParent = self:GetParent()
    if not hParent:InCombat() then
        local enemies = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetAbsOrigin(), nil, RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_CLOSEST, false)
        for _, enemy in pairs(enemies) do
            if IsValid(enemy) and enemy:IsAlive() then
                Aggro_manager:ModifyAggro(hParent, enemy, BASIC_AGGRO_VALUE)
                break
            end
        end
    end
end