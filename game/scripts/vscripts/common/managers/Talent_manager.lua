Talent_manager = {}

_G.Talent_KV_UpgradeTypes = {
    ADD = 0,
    MULTI = 1,
    OVERRIDE = 2,
}
Talent_List_Length = 6

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
    for ability_name, kv in pairs(talent_upgrades_kv) do
        if kv.CustomAbilityCharges ~= nil then
            local ability = self.hero:FindAbilityByName(ability_name)
            if ability.AbilityCharge_manager ~= nil then
                ability.AbilityCharge_manager:StartRestoreCharge()
            end
        end
    end

    local allbuffs = self.hero:FindAllModifiers()
    for _, buff in pairs(allbuffs) do
        if buff:GetCaster() == self.hero and buff.GetAbilityValues ~= nil and type(buff.GetAbilityValues) == "function" then
            buff:GetAbilityValues()
        end
    end

    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), Tm.TalentList)
end

function Talent_manager:RemoveTalent(talent)
    local school_index = Abilities_manager:GetCurrentSchools(self.hero)
    local this_talentKv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent]
    local TalentFloor = this_talentKv.TalentFloor
    self.hero.Talent_manager.TalentList[TalentFloor] = ""
    local talent_upgrades_kv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent].UpgradeAbilities
    for ability_name, kv in pairs(talent_upgrades_kv) do
        if kv.CustomAbilityCharges ~= nil then
            local ability = self.hero:FindAbilityByName(ability_name)
            if ability.AbilityCharge_manager ~= nil then
                ability.AbilityCharge_manager:StartRestoreCharge()
            end
        end
    end

    local allbuffs = self.hero:FindAllModifiers()
    for _, buff in pairs(allbuffs) do
        if buff:GetCaster() == self.hero and buff.GetAbilityValues ~= nil and type(buff.GetAbilityValues) == "function" then
            buff:GetAbilityValues()
        end
    end

    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), Tm.TalentList)
end

function Talent_manager:SelectTalent(talent)
    local school_index = Abilities_manager:GetCurrentSchools(self.hero)
    local this_talentKv = KeyValues.TalentKv[self.hero:GetUnitLabel()][tostring(school_index)][talent]
    local TalentFloor = 1 --this_talentKv.TalentFloor
    local current_talent = self.hero.Talent_manager.TalentList[TalentFloor]

    if current_talent ~= "" then
        self:RemoveTalent(current_talent)
    end
    
    if talent ~= "" then
        self:AddTalent(talent)
    end
    CustomNetTables:SetTableValue("hero_talents", tostring(self.hero:GetPlayerOwnerID()), Tm.TalentList)
end

