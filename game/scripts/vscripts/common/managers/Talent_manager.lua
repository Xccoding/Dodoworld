Talent_manager = {}

_G.Talent_KV_UpgradeTypes = {
    ADD = 0,
    MULTI = 1,
    OVERRIDE = 2,
}
Talent_List_Length = 6
_G.TalentLevels = {
    12, 24, 36, 48, 60
}

function Talent_manager:constructor(hero)
    Tm = {}
    setmetatable(Tm, self)
    self.__index = self
    Tm.hero = hero
    Tm.TalentList = {}
    --TODO获得玩家的天赋数据来插表
    for i = 1, Talent_List_Length do
        table.insert(Tm.TalentList, "")
    end
    CustomNetTables:SetTableValue("hero_talents", tostring(hero:GetPlayerOwnerID()), Tm.TalentList)
    return Tm
end

function Talent_manager:AddTalent(talent)
    local school_index = Abilities_manager:GetCurrentSchools(self.hero)
    local this_talentKv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent]
    local TalentFloor = this_talentKv.TalentFloor
    self.hero.Talent_manager.TalentList[TalentFloor] = talent
    local talent_upgrades_kv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent].UpgradeAbilities

    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), self.TalentList)

    if talent_upgrades_kv ~= nil then
        for ability_name, kv in pairs(talent_upgrades_kv) do
            if kv.CustomAbilityCharges ~= nil then
                local ability = self.hero:FindAbilityByName(ability_name)
                if ability.AbilityCharge_manager ~= nil then
                    ability.AbilityCharge_manager:StartRestoreCharge()
                end
            end
        end
    end


    local allbuffs = self.hero:FindAllModifiers()
    for _, buff in pairs(allbuffs) do
        if buff:GetCaster() == self.hero and buff.GetAbilityValues ~= nil and type(buff.GetAbilityValues) == "function" then
            buff:GetAbilityValues()
        end
    end

    if this_talentKv.NewAbility ~= nil then
        self.hero:FindAbilityByName(this_talentKv.NewAbility):SetLevel(1)
    end

end

function Talent_manager:RemoveTalent(talent)
    local school_index = Abilities_manager:GetCurrentSchools(self.hero)
    local this_talentKv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent]
    local TalentFloor = this_talentKv.TalentFloor
    self.hero.Talent_manager.TalentList[TalentFloor] = ""
    local talent_upgrades_kv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent].UpgradeAbilities

    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), self.TalentList)

    if talent_upgrades_kv ~= nil then
        for ability_name, kv in pairs(talent_upgrades_kv) do
            if kv.CustomAbilityCharges ~= nil then
                local ability = self.hero:FindAbilityByName(ability_name)
                if ability.AbilityCharge_manager ~= nil then
                    ability.AbilityCharge_manager:StartRestoreCharge()
                end
            end
        end
    end

    local allbuffs = self.hero:FindAllModifiers()
    for _, buff in pairs(allbuffs) do
        if buff:GetCaster() == self.hero and buff.GetAbilityValues ~= nil and type(buff.GetAbilityValues) == "function" then
            buff:GetAbilityValues()
        end
    end

    if this_talentKv.NewAbility ~= nil then
        local hAbility = self.hero:FindAbilityByName(this_talentKv.NewAbility)
        hAbility:SetLevel(0)
        local units = FindUnitsInRadius(self.hero:GetTeamNumber(), self.hero:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if IsValid(unit) then
                local allmodifiers = unit:FindAllModifiers()
                for _, buff in pairs(allmodifiers) do
                    if buff:GetCaster() == self.hero and buff:GetAbility() == hAbility then
                        unit:RemoveModifierByNameAndCaster(buff:GetName(), self.hero)
                    end
                end
            end
        end

    end

end

function Talent_manager:SelectTalent(talent)
    local school_index = Abilities_manager:GetCurrentSchools(self.hero)
    local this_talentKv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent]
    local TalentFloor = this_talentKv.TalentFloor --this_talentKv.TalentFloor
    local current_talent = self.hero.Talent_manager.TalentList[TalentFloor]

    if current_talent ~= "" then
        self:RemoveTalent(current_talent)
    end

    if talent ~= "" then
        self:AddTalent(talent)
    end



    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), self.TalentList)
end