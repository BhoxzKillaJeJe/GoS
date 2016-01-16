if GetObjectName(GetMyHero()) ~= "Annie" then return end

require('Inspired')

menu = Menu("Annie", "Annie")
menu:SubMenu("c", "Combo")
menu:SubMenu("h", "Harass")
menu:SubMenu("m", "Misc")
menu:SubMenu("ks", "KillSteal")
menu:SubMenu("lh", "LastHit")
menu:SubMenu("d", "Drawings")

menu.c:Boolean("cq", "Use Q", true)
menu.c:Boolean("cw", "Use W", true)
menu.c:Boolean("ce", "Use E", true)
menu.c:Boolean("cr", "Use R", true)
menu.c:Slider("acr", "AutoR if enemies is > x and have stun", 3,1,5,1)
menu.c:Slider("hcr", "R if enemy hp% is <", 45,5,100,5)

menu.h:Boolean("hq", "Use Q", true)
menu.h:Boolean("hw", "Use W", true)

menu.m:KeyBinding("aq", "AutoLastHit", string.byte("J"), true)
if Ignite ~= nil then menu.m:Boolean("aign", "Auto Ignite", true) end

menu.ks:Boolean("ksq", "Use Q", true)
menu.ks:Boolean("ksw", "Use W", true)
menu.ks:Boolean("ksr", "Use R", true)

--menu.lh:Boolean("q", "LastHit w/ Q", true)
--menu.lh:Boolean("w", "LastHit w/ W", true)

menu.d:Boolean("dq", "Draw Q", false)
menu.d:Boolean("dw", "Draw W", false)
menu.d:Boolean("dr", "Draw R", false)
menu.d:Boolean("dmg", "Draw DMG", true)

---SpellData---------------
Annie.SpellData = {
	[_Q] = {dmg = function () return 45 + 35*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) end, range = 625, mana = function () return 55 + 5*GetCastLevel(myHero,_Q) end},
	[_W] = {dmg = function () return 25 + 45*GetCastLevel(myHero,_W) + 0.85*GetBonusAP(myHero) end , range = 625, mana = function () return 60 + 10*GetCastLevel(myHero,_W) end},
	[_E] = {dmg = function () return 10 + 10*GetCastLevel(myHero,_E) + 0.2*GetBonusAP(myHero) end , mana = 20 },
	[_R] = {dmg = function () return 50 + 125*GetCastLevel(myHero,_R) + 0.8*GetBonusAP(myHero) end, range = 600, radius = 250, mana = 100 },
	}
---------------------------

-------Variables-----------
local ts = TargetSelector(625,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGICAL,true,false)
local pstacks = nil
local pstun = nil
local LudensStacks = 0
---------------------------

function Combo()
	local target = GetCurrentTarget()
	local Qtarget = ts:GetTarget()
	if IOW:Mode() == "Combo" then

		if IsReady(_R) and ValidTarget(target,Annie.SpellData[_R].range) and menu.c.cr:Value() and (GetCurrentHP(target)/GetMaxHP(target)) <= menu.c.hcr:Value() then
			CastSkillShot(_R,GetOrigin(target))
		end

		if IsReady(_E) and ValidTarget(target,600) and menu.c.ce:Value() and pstacks == 3 then
			CastSpell(_E)
		end

		if IsReady(_Q) and ValidTarget(Qtarget,Annie.SpellData[_Q].range) and menu.c.cq:Value() then
			CastTargetSpell(Qtarget,_Q)
		end

		if IsReady(_W) and ValidTarget(target,Annie.SpellData[_W].range) and menu.c.cw:Value()	then
			CastSkillShot(_W,GetOrigin(target))
		end
	end 
end

function Harass()
	local target = GetCurrentTarget()
	local Qtarget = ts:GetTarget()
	if IOW:Mode() == "Harass" then

		if IsReady(_W) and ValidTarget(target,Annie.SpellData[_W].range) and menu.h.hw:Value() then
			CastSkillShot(_W,GetOrigin(target))
		end

		if IsReady(_Q) and ValidTarget(Qtarget,Annie.SpellData[_Q].range) and menu.h.hq:Value() then
			CastTargetSpell(Qtarget,_Q)
		end
	end
end

function AutoR()
	for i,enemy in pairs(GetEnemyHeroes()) do
		local enemycount = CountObjectsNearPos(GetOrigin(enemy),Annie.SpellData[_R].range,Annie.SpellData[_R].radius - GetHitBox(enemy),GetEnemyHeroes())
		
		if IsReady(_R) and ValidTarget(enemy,Annie.SpellData[_R].range) and enemycount >= menu.c.acr:Value() and menu.c.cr:Value() and pstun == true then
			CastSkillShot(_R,GetOrigin(enemy))
		end
	end
end

function AutoQ()
	if not IOW.isWindingUp then
		for _,minions in pairs(minionManager.objects) do
			if GetTeam(minions) == MINION_ENEMY and ValidTarget(minions,Annie.SpellData[_Q].range) and menu.m.aq:Value() then
				local predhp = IOW:PredictHealth(minions, GetDistance(minions)*0.5+250)
				if predhp > 0 then
					if predhp+5 < CalcDamage(myHero,minions,0,Annie.SpellData[_Q].dmg) then
						CastTargetSpell(minions,_Q)
					end
				end
			end
		end
	end
end

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		local Qdmg = CalcDamage(myHero,enemy,0,Annie.SpellData[_Q].dmg + Ludens())
		local Wdmg = CalcDamage(myHero,enemy,0,Annie.SpellData[_W].dmg + Ludens())
		local Rdmg = CalcDamage(myHero,enemy,0,Annie.SpellData[_R].dmg + Ludens())
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		if ValidTarget(enemy,Annie.SpellData[_W].range) and Wdmg > enemyhp and menu.ks.ksw:Value() and IsReady(_W) then
			CastSkillShot(_W,GetOrigin(enemy))
		elseif ValidTarget(enemy,Annie.SpellData[_Q].range) and Qdmg > enemyhp and menu.ks.ksq:Value() and IsReady(_Q) then
			CastTargetSpell(enemy,_Q)
		elseif ValidTarget(enemy,Annie.SpellData[_R].range + 100) and Rdmg > enemyhp and menu.ks.ksr:Value() and IsReady(_R) then
			CastSkillShot(_R,GetOrigin(enemy))
		elseif ValidTarget(enemy,625) and Qdmg + Wdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and IsReady(_Q) and IsReady(_W) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Qdmg + Rdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_R) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Rdmg + Wdmg > enemyhp and menu.ks.ksr:Value() and menu.ks.ksw:Value() and IsReady(_R) and IsReady(_W) then
			CastSkillShot(_R,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Qdmg + Wdmg + Rdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastTagetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy))end, 250) end, 250))
		end
	end
end

function Ludens()
	return LudensStacks == 100 and 100+0.1*GetBonusAP(myHero) or 0
end

function AutoIgnite()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if Ignite and menu.m.aign:Value() then
			local HPShield = GetCurrentHP(enemy)+GetDmgShield(enemy)
            if IsReady(Ignite) and 20*GetLevel(myHero)+50 > HPShield+(GetHPRegen(enemy)*3) and ValidTarget(enemy, 600) then
              CastTargetSpell(enemy, Ignite)
          end
        end 
    end
end

OnUpdateBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "pyromania" then
			pstacks = buff.Count
		elseif buff.Name == "pyromania_particle" then
			pstun = true
		elseif buff.Name == "itemmagicshankcharge" then
			LudensStacks = buff.Count
		end
	end
end

OnRemoveBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "pyromania" then
			pstacks = 0
		elseif buff.Name == "pyromania_particle" then
			pstun = false
		end
	end
end

OnTick(function(myHero)
 	if not IsDead(myHero) then
 		Combo()
 		Harass()
 		AutoR()
 		AutoQ()
 		KillSteal()
 		AutoIgnite()
 	end
end

OnDraw(function(myHero)
	local target = GetCurrentTarget()
	local Qdmg = CalcDamage(myHero,target,0,Annie.SpellData[_Q].dmg + Ludens())
	local Wdmg = CalcDamage(myHero,target,0,Annie.SpellData[_W].dmg + Ludens())
	local Rdmg = CalcDamage(myHero,target,0,Annie.SpellData[_R].dmg + Ludens())
	local enemyhp = GetCurrentHP(target) + GetDmgShield(target) + GetMagicShield(target)
	local apdmg = Qdmg + Wdmg + Rdmg + Ludens()

	if menu.d.dq:Value() and IsReady(_Q) then
		DrawCircle(GetOrigin(myHero),625,5,100,0xff00ff00)
	end
	if menu.d.dw:Value() and IsReady(_W) then
		DrawCircle(GetOrigin(myHero),625,5,100,0xff00ff00)
	end
	if menu.d.dr:Value() and IsReady(_R) then
		DrawCircle(GetOrigin(myHero),600,5,100,0xff00ff00)
	end
	if menu.d.dmg:Value() and ValidTarget(target,2000) then
		DrawDmgOverHpBar(target,enemyhp,0,apdmg,ARGB(180,255,255,255))
	end
end
