
--Abilities
if common_AbilityDataGetter == nil then
	common_AbilityDataGetter = class({})
end
function common_AbilityDataGetter:GetAbilityTextureName()
	return GetAbilityValueTexture
end
