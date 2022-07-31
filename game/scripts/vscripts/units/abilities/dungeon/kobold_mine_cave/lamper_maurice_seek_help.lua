LinkLuaModifier( "modifier_lamper_maurice_seek_help", "units/abilities/dungeon/kobold_mine_cave/lamper_maurice_seek_help.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lamper_maurice_seek_help_sleep", "units/abilities/dungeon/kobold_mine_cave/lamper_maurice_seek_help.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if lamper_maurice_seek_help == nil then
	lamper_maurice_seek_help = class({})
end
function lamper_maurice_seek_help:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end
function lamper_maurice_seek_help:GetChannelAnimation()
    return ACT_DOTA_VICTORY
end
function lamper_maurice_seek_help:OnSpellStart()
	local hCaster = self:GetCaster()

    --EmitSoundOnLocationWithCaster(hCaster:GetAbsOrigin(), "venomancer_venm_underattack_02", hCaster)
    EmitGlobalSound("venomancer_venm_underattack_02")
end
function lamper_maurice_seek_help:GetIntrinsicModifierName()
    return "modifier_lamper_maurice_seek_help"
end
function lamper_maurice_seek_help:OnChannelFinish(bInterrupted)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    if not bInterrupted then
        local buff = hCaster:FindModifierByName("modifier_lamper_maurice_seek_help")
        for i = 1, #buff.moles do
            if IsValidEntity(buff.moles[i]) and buff.moles[i]:IsAlive() and buff.moles[i]:HasModifier("modifier_lamper_maurice_seek_help_sleep") then
                buff.moles[i]:RemoveModifierByName("modifier_lamper_maurice_seek_help_sleep")
                EmitSoundOnLocationWithCaster(buff.moles[i]:GetAbsOrigin(), "Hero_Meepo.Poof.End00", buff.moles[i])
                break
            end  
        end
    end
end
--=======================================modifier_lamper_maurice_seek_help=======================================
if modifier_lamper_maurice_seek_help == nil then
    modifier_lamper_maurice_seek_help = class({})
end
function modifier_lamper_maurice_seek_help:IsHidden()
    return true
end
function modifier_lamper_maurice_seek_help:IsDebuff()
    return false
end
function modifier_lamper_maurice_seek_help:IsPurgable()
    return false
end
function modifier_lamper_maurice_seek_help:IsPurgeException()
    return false
end
function modifier_lamper_maurice_seek_help:OnCreated(params)
    local hCaster = self:GetCaster()
    self.count = self:GetAbilitySpecialValueFor("count")
    if IsServer() then
        self:StartIntervalThink(1)
    end
end
function modifier_lamper_maurice_seek_help:OnRefresh(params)
end
function modifier_lamper_maurice_seek_help:OnDestroy(params)
end
function modifier_lamper_maurice_seek_help:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH
    }
end
function modifier_lamper_maurice_seek_help:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_COMBAT_START,
        CMODIFIER_EVENT_ON_COMBAT_END,
    }
end
function modifier_lamper_maurice_seek_help:C_OnCombatStart()
    local hCaster = self:GetCaster()
    if self.moles ~= nil and type(self.moles) == "table" then
        for _, mole in pairs(self.moles) do
            if IsValidEntity(mole) and mole:IsAlive() then
                mole:RemoveSelf()
            end
        end
    end
    self.moles = {}
    local range_min = self:GetAbilitySpecialValueFor("range_min")
    local range_max = self:GetAbilitySpecialValueFor("range_max")
    for i = 1, self.count do
        CreateUnitByNameAsync("creature_miner_maurice", hCaster:GetAbsOrigin() + RandomVector(RandomFloat(range_min, range_max)), true, hCaster, hCaster, hCaster:GetTeamNumber(), 
        function (unit)
            unit.spawn_entity = hCaster
            table.insert(self.moles, unit)
            unit:AddNewModifier(hCaster, self:GetAbility(), "modifier_lamper_maurice_seek_help_sleep", {})
        end)
        
    end
end
function modifier_lamper_maurice_seek_help:C_OnCombatEnd()
    if self.moles ~= nil and type(self.moles) == "table" then
        for _, mole in pairs(self.moles) do
            if IsValidEntity(mole) and mole:IsAlive() then
                mole:RemoveSelf()
            end
        end
        self.moles = {}
    end
end
function modifier_lamper_maurice_seek_help:OnDeath( params )
    if not IsServer() then
       return 
    end
    local unit = params.unit
    if unit:GetUnitName() == "creature_lamper_maurice" then
        if self.moles ~= nil and type(self.moles) == "table" then
            for _, mole in pairs(self.moles) do
                if IsValidEntity(mole) and mole:IsAlive() then
                    mole:RemoveSelf()
                end
            end
        end
    end
end
--=======================================modifier_lamper_maurice_seek_help_sleep=======================================
if modifier_lamper_maurice_seek_help_sleep == nil then
    modifier_lamper_maurice_seek_help_sleep = class({})
end
function modifier_lamper_maurice_seek_help_sleep:IsHidden()
    return true
end
function modifier_lamper_maurice_seek_help_sleep:IsDebuff()
    return false
end
function modifier_lamper_maurice_seek_help_sleep:IsPurgable()
    return false
end
function modifier_lamper_maurice_seek_help_sleep:IsPurgeException()
    return false
end
function modifier_lamper_maurice_seek_help_sleep:OnCreated(params)
    local hParent = self:GetParent()
    if IsServer() then
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_inground.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        self:AddParticle(particleID, true, false, -1, false, false)
    end
end
function modifier_lamper_maurice_seek_help_sleep:OnRefresh(params)
end
function modifier_lamper_maurice_seek_help_sleep:OnDestroy(params)
    local hParent = self:GetParent()
    if IsServer() then
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_burrow_endend.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particleID)
    end
end
function modifier_lamper_maurice_seek_help_sleep:DeclareFunctions()
    return {
    }
end
function modifier_lamper_maurice_seek_help_sleep:CDeclareFunctions()
    return {
    }
end
function modifier_lamper_maurice_seek_help_sleep:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
