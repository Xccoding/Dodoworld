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
	local hTarget = self:GetCursorTarget()
	local channel_time = self:GetSpecialValueFor("channel_time")

	--EmitSoundOn("Hero_DragonKnight.DragonTail.Target", hTarget)

	
end
function lamper_maurice_seek_help:OnChannelFinish(bInterrupted)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    if not bInterrupted then
        local buff = hCaster:FindModifierByName("modifier_lamper_maurice_seek_help")
        for i = 1, #buff.moles do
            if IsValidEntity(buff.moles[i]) and buff.moles[i]:IsAlive() then
                buff.moles[i]:RemoveModifierByName("modifier_lamper_maurice_seek_help_sleep")
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
        --TODO预铺小弟
        self.moles = {}
        for i = 1, self.count do
            local mole = CreateUnitByNameAsync("creature_miner_maurice", hCaster:GetAbsOrigin() + RandomVector(200, 500), true, hCaster, hCaster, hCaster:GetTeamNumber(), 
            function (unit)
                unit:AddNewModifier(hCaster, self:GetAbility(), "modifier_lamper_maurice_seek_help_sleep", {})
            end)
            table.insert(self.moles, mole)
        end
    end
end
function modifier_lamper_maurice_seek_help:OnRefresh(params)
end
function modifier_lamper_maurice_seek_help:OnDestroy(params)
end
function modifier_lamper_maurice_seek_help:DeclareFunctions()
    return {
    }
end
function modifier_lamper_maurice_seek_help:CDeclareFunctions()
    return {
    }
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
    if IsClient() then
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_burrow.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        self:AddParticle(particleID, true, false, -1, false, false)
    end
end
function modifier_lamper_maurice_seek_help_sleep:OnRefresh(params)
end
function modifier_lamper_maurice_seek_help_sleep:OnDestroy(params)
    local hParent = self:GetParent()
    if IsClient() then
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_burrow_endend.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        self:AddParticle(particleID, true, false, -1, false, false)
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
    }
end

