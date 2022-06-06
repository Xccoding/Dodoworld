if modifier_channel_watcher == nil then
	modifier_channel_watcher = class({})
end
function modifier_channel_watcher:IsHidden()
    return false
end
function modifier_channel_watcher:IsDebuff()
    return false
end 
function modifier_channel_watcher:IsPurgable()
    return false
end
function modifier_channel_watcher:RemoveOnDeath()
    return false
end
function modifier_channel_watcher:OnCreated(params)
    if IsServer() then
        self.channel_start_time = 0
        self.channel_ability = nil
        self.channel_end_time = 0
        self:StartIntervalThink(FrameTime())
    end
end
function modifier_channel_watcher:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ABILITY_END_CHANNEL,
    }
end
function modifier_channel_watcher:OnIntervalThink()
    if IsServer() then
        local hParent = self:GetParent()
        if self.channel_ability ~= nil then
            CustomNetTables:SetTableValue("channel_list", tostring(hParent:entindex()), {
                channel_ability = self.channel_ability:entindex(),
                channel_percent = (GameRules:GetGameTime() - self.channel_start_time) / (self.channel_end_time - self.channel_start_time)
            })
        end
    end
end
function modifier_channel_watcher:OnAbilityExecuted( params )
    if params.unit == self:GetParent() then
        local hParent = self:GetParent()
        local hAbility = params.ability

        if hAbility:GetChannelTime() > 0 then
            self.channel_start_time = GameRules:GetGameTime()
            self.channel_ability = hAbility
            self.channel_end_time = GameRules:GetGameTime() + hAbility:GetChannelTime()
            CustomNetTables:SetTableValue("channel_list", tostring(hParent:entindex()), {
                channel_ability = hAbility:entindex(),
                channel_percent = 0
            })
        end

    end
end
function modifier_channel_watcher:OnAbilityEndChannel( params )
    if params.unit == self:GetParent() then
        local hParent = self:GetParent()
        local hAbility = params.ability

        if hAbility == self.channel_ability then
            self.channel_ability = nil
            CustomNetTables:SetTableValue("channel_list", tostring(hParent:entindex()), {
                channel_ability = -1,
                channel_percent = 0
            })
        end

    end
end