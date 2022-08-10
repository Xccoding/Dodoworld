
--Abilities
if common_interactive == nil then
	common_interactive = class({})
end
function common_interactive:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	


	CFireModifierEvent(hCaster, CMODIFIER_EVENT_ON_INTERACTIVE, {unit = hCaster, target = hTarget})
	CFireModifierEvent(hTarget, CMODIFIER_EVENT_ON_INTERACTIVE, {unit = hCaster, target = hTarget})
	
	hCaster:SetContextThink(DoUniqueString("remove_interactive"), function ()
		hCaster:RemoveAbilityByHandle(self)
	end, 0)

end
