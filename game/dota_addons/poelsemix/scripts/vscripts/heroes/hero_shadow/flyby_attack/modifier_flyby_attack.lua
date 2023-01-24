modifier_flyby_attack = class({})

ori_damage_min = 0
ori_damage_max = 0
damage_bonus = 0

--------------------------------------------------------------------------------

function modifier_flyby_attack:IsHidden()
	return false
end
--------------------------------------------------------------------------------

function modifier_flyby_attack:IsPurgeable()
	return false
end
--------------------------------------------------------------------------------

function modifier_flyby_attack:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_flyby_attack:OnCreated( kv )
	self.min_damage_bonus = self:GetAbility():GetSpecialValueFor( "min_damage_bonus" )
	self.max_damage_bonus = self:GetAbility():GetSpecialValueFor( "max_damage_bonus" )
	-- self.attack_range = self:GetAbility():GetSpecialValueFor( "attack_range" )
	self.attack_range_for_max = self:GetAbility():GetSpecialValueFor( "attack_range_for_max" )
end

--------------------------------------------------------------------------------

function modifier_flyby_attack:OnRefresh( kv )
	self.min_damage_bonus = self:GetAbility():GetSpecialValueFor( "min_damage_bonus" )
	self.max_damage_bonus = self:GetAbility():GetSpecialValueFor( "max_damage_bonus" )
	-- self.attack_range = self:GetAbility():GetSpecialValueFor( "attack_range" )
	self.attack_range_for_max = self:GetAbility():GetSpecialValueFor( "attack_range_for_max" )
end

--------------------------------------------------------------------------------

function modifier_flyby_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEAL_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end
function modifier_flyby_attack:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range_for_max")
end
--------------------------------------------------------------------------------

function modifier_flyby_attack:OnDealDamage( params )
	if (params.attacker ~= self:GetParent()) then return end
-- %attack_damage is set to the damage value after mitigation
	params.damageoutgoing_percentage = damage_bonus
end 

--------------------------------------------------------------------------------

function modifier_flyby_attack:OnAttackStart( params )
	if (params.attacker ~= self:GetParent()) then return end
	if params.target == nil then
		return
	end
	
	----------------------------------------------------
	-- Finds the distance between attacker and target --
	----------------------------------------------------
	local self_pos = params.attacker:GetAbsOrigin()	--casters position
    local target_pos = params.target:GetAbsOrigin()	--targets position
    local dis_vec = target_pos - self_pos		--vector between caster and target
    local dis = math.sqrt((dis_vec.x*dis_vec.x)+(dis_vec.y*dis_vec.y))		--distance between caster and target

	
	----------------------------------------------------
	--    Determins damage bonus based on distance    --
	----------------------------------------------------
	min_damage = self.min_damage_bonus - 1
	max_damage = self.max_damage_bonus - 1
	attackRange = params.attacker:GetBaseAttackRange()
	dist_bonus = 0
	if dis < attackRange / 3 then
		dist_bonus = min_damage
	elseif dis < (attackRange / 3) * 2 then
		dist_bonus = (min_damage + max_damage) / 2
	else 
		dist_bonus = max_damage
	end

	damage_bonus = dist_bonus
	FindClearSpaceForUnit(params.attacker, target_pos, true)
	
end

--------------------------------------------------------------------------------

function modifier_flyby_attack:OnAttackLanded( params )
	if (params.attacker ~= self:GetParent()) then return end 

	if damage_bonus >= 0 then
		ApplyDamage({ victim = params.target, attacker = params.attacker, damage = params.damage * damage_bonus, damage_type = DAMAGE_TYPE_PURE  })
	else
		params.target:Heal((-damage_bonus) * params.damage, params.target)
	end
end
--------------------------------------------------------------------------------