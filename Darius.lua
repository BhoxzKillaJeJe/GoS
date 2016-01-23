if GetObjectName(GetMyHero()) ~= "Darius" then return end

require('Inspired')
LoadIOW()

menu = Menu("Darius", "Darius")
menu:SubMenu("c", "Combo")
menu:SubMenu("ks", "KillSteal")
--menu:SubMenu("lh", "LastHit")
menu:SubMenu("d", "Drawings")

menu.c:Boolean("cq", "Use Q", true)
menu.c:Boolean("cw", "Use W", true)
menu.c:Boolean("ce", "Use E", true)
menu.c:KeyBinding("cc", "Combo Key", string.byte(" "))

menu.ks:Boolean("ksq", "Use Q", true)
menu.ks:Boolean("ksw", "Use W", true)
menu.ks:Boolean("kse", "Use E", true)
menu.ks:Boolean("ksr", "Use R", true)

--menu.lh:Boolean("lhw", "LastHit w/ W", true)

menu.d:Boolean("dq", "Draw Q", false)
menu.d:Boolean("de", "Draw E", false)
menu.d:Boolean("dr", "Draw R", false)
menu.d:Boolean("dmg", "Draw Dmg Q/R", true)

-------SpellData---------------
spellData = {
		[_Q] = {dmg = function () return 10 + 30*GetCastLevel(myHero,_Q) + 0.9*(GetBonusDmg(myHero) + GetBaseDamage(myHero)) + (0.1*GetCastLevel(myHero,_Q)*(GetBonusDmg(myHero) + GetBaseDamage(myHero))) end, mana = function() return 25 + 5*GetCastLevel(myHero,_Q) end},
		[_W] = {dmg = function () return 1.4*(GetBonusDmg(myHero) + GetBaseDamage(myHero)) end, mana = 30},
		[_R] = {dmg = function () return 100*GetCastLevel(myHero,_R) + 0.75*(GetBonusDmg(myHero)) end, mana = 100},
	}
-------------------------------
-----Vars--------------------
local pstacks = {}
local Qcast = (CanUseSpell(myHero,_Q) == READYNONCAST) or (CanUseSpell(myHero,_Q) == 4)
target1 = TargetSelector(550,TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)
IOW.Config.s.stick:Value(0)
-----------------------------

function Qwalk()
	local Qtarget = target1:GetTarget()
	if target and Qcast then
		if GetDistance(Qtarget) < 230 then
			local vec = Vector(myHero) + Vector(Vector(myHero)-Vector(Qtarget)):normalized()*(225)
			IOW.movementEnabled = false
			MoveToXYZ(vec)
			return
		elseif GetDistance(Qtarget) > 230 and GetDistance(Qtarget) > 300 then
			IOW.movementEnabled = false
			HoldPosition()
			return
		else 
			IOW.movementEnabled = true
		end
	else
		IOW.movementEnabled = true
	end
end

function Combo()
	local target = GetCurrentTarget()
	local Qtarget = target1:GetTarget()
	local ePred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),math.huge,0.33,550,80,false,true)										
	if menu.c.cc:Value() then

		if IsReady(_Q) and ValidTarget(target,430) and menu.c.cq:Value() then
			CastSpell(_Q)
		end

		if IsReady(_E) and ValidTarget(target,550) and menu.c.ce:Value() and ePred.HitChance == 1 then
			CastSkillShot(_E,ePred.PredPos.x,ePred.PredPos.y,ePred.PredPos.z)
		end

		if IsReady(_W) and ValidTarget(target,275) and menu.c.cw:Value() then
			CastSpell(_W)
		end
	end
end

function KillSteal()
	local Qdmg = ((IsReady(_Q) and spellData[_Q].dmg()) or 0)
	local Wdmg = ((IsReady(_W) and spellData[_W].dmg()) or 0)
	local Rdmg = ((IsReady(_R) and spellData[_R].dmg()) or 0)
	local Cdmg = Qdmg + Wdmg

	for i,enemy in pairs(GetEnemyHeroes()) do
		local Admg = CalcDamage(myHero,enemy,Cdmg,0)
		local Bdmg = CalcDamage(myHero,enemy,Qdmg,0)
		local Ddmg = CalcDamage(myHero,enemy,Wdmg,0)
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		if enemy and enemyhp < Rdmg*(1+(0.2*GetStacks(enemy,0))) and ValidTarget(enemy,450) then
			CastTargetSpell(enemy,_R)
		elseif enemyhp < Bdmg and ValidTarget(enemy,430) then
			CastSpell(_Q)
		elseif enemyhp < Ddmg and ValidTarget(enemy,250) then
			CastSpell(_W)
			AttackUnit(enemy)
		elseif enemyhp < Admg and IsReady(_Q) and IsReady(_W) and IsReady(_E) and ValidTarget(enemy,430) then
			CastSpell(_Q)
			local ePred = GetPredictionForPlayer(GetOrigin(myHero),enemy,GetMoveSpeed(enemy),math.huge,0.33,550,80,false,true)										
			DelayAction(function()
				CastSkillShot(_E,ePred.PredPos.x,ePred.PredPos.y,ePred.PredPos.z)
			end, 750)
			CastSpell(_W)
			AttackUnit(enemy)
		elseif enemyhp < Admg + Rdmg*(1+(0.2*GetStacks(enemy,0))) and IsReady(_Q) and IsReady(_W) and IsReady(_E) and IsReady(_R) and ValidTarget(enemy,430) then
			CastSpell(_Q)
			local ePred = GetPredictionForPlayer(GetOrigin(myHero),enemy,GetMoveSpeed(enemy),math.huge,0.33,550,80,false,true)										
			CastSkillShot(_E,ePred.PredPos.x,ePred.PredPos.y,ePred.PredPos.z)
			CastSpell(_W)
			AttackUnit(enemy)
			CastTargetSpell(enemy,_R)
		end
	end
end

function GetStacks(obj, extrastacks)
	if obj then
		if pstacks[GetNetworkID(obj)] and (pstacks[GetNetworkID(obj)] + extrastacks) <= 5 then
			return pstacks[GetNetworkID(obj)] + extrastacks
		elseif pstacks[GetNetworkID(obj)] and (pstacks[GetNetworkID(obj)] + extrastacks) > 5 then
			return 5
		elseif not pstacks[GetNetworkID(obj)] then
			return 0 + extrastacks
		end
	end
end

OnUpdateBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "dariushemo" then
			pstacks[GetNetworkID(unit)] = buff.Count
		end
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "dariushemo" then
			pstacks[GetNetworkID(unit)] = 0
		end
	end
end)

OnDraw(function(myHero)
	
	if IsReady(_Q) and menu.d.dq:Value() then
		DrawCircle(GetOrigin(myHero),450,1,50,ARGB(180, 255, 255, 255))
	end
	if IsReady(_E) and menu.d.de:Value() then
		DrawCircle(GetOrigin(myHero),570,1,50,ARGB(180, 255, 255, 255))
	end
	if IsReady(_R) and menu.d.dr:Value() then
		DrawCircle(GetOrigin(myHero),450,1,50,ARGB(180, 255, 255, 255))
	end

	for i,enemy in pairs(GetEnemyHeroes()) do
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy)
		local Rdmg = spellData[_R].dmg()
		if IsReady(_R) and ValidTarget(enemy,5000) then
			DrawDmgOverHpBar(enemy,enemyhp,Rdmg,0,ARGB(180, 255, 0, 0))
		end
	end
end)

OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		KillSteal()
		Qwalk()
	end
end)

PrintChat("Darius Loaded")
