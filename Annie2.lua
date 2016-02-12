if GetObjectName(GetMyHero()) ~= "Annie" then return end

require('Inspired')
require('OpenPredict')

menu = Menu("Annie", "Annie")
menu:SubMenu("c", "Combo")
menu:SubMenu("h", "Harass")
-- menu:SubMenu("m", "Misc")
menu:SubMenu("ks", "KillSteal")
menu:SubMenu("lh", "LastHit")
menu:SubMenu("js", "JungleSteal")
menu:SubMenu("d", "Drawings")

menu.c:Boolean("cq", "Use Q", true)
menu.c:Boolean("cw", "Use W", true)
menu.c:Boolean("ce", "Use E", true)
menu.c:Boolean("cr", "Use R", true)
-- menu.c:DropDown("rlogic", "R Logic", 3, {"Stun Only", "Killable", "Default"})
-- menu.c:Info("info", "Default logic is just normal Combo")

menu.h:Boolean("hq", "Use Q", true)
menu.h:Boolean("hw", "Use W", true)

-- local Flash = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil))
-- local Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
-- if Ignite ~= nil then menu.m:Boolean("aign", "Auto Ignite", true) end
-- if Flash ~= nil then menu.m:Boolean("fu", "Flash Ult if Stun is Up", true)
	-- menu.m:KeyBinding("ft", "Flash Ult Key", string.byte("T"))
-- end

menu.ks:Boolean("ksq", "Use Q", true)
menu.ks:Boolean("ksw", "Use W", true)
menu.ks:Boolean("ksr", "Use R", true)

menu.lh:Boolean("q", "LastHit w/ Q", true)

menu.js:Boolean("q", "JungleSteal w/ Q", true)

menu.d:Boolean("dq", "Draw Q", false)
menu.d:Boolean("dw", "Draw W", false)
menu.d:Boolean("dr", "Draw R", false)
menu.d:Boolean("dmg", "Draw DMG", true)

-------Variables-----------
local ts = TargetSelector(625,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGICAL,true,false)
local pstacks = nil
local pstun = nil
-- local LudensStacks = 0
Qdmg = 45 + 35*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero)
Wdmg = 25 + 45*GetCastLevel(myHero,_W) + 0.85*GetBonusAP(myHero)
Rdmg = (50 + 125*GetCastLevel(myHero,_R) + 0.8*GetBonusAP(myHero))
tdmg = Qdmg + Wdmg + Rdmg 	
---------------------------

-- Cast
function CastQ(target)
	if not IsDead(myHero) then
		CastTargetSpell(target,_Q)
	end
end

function CastW(target)
	if not IsDead(myHero) then
		CastSkillShot(_W,GetOrigin(target))
	end
end

function CastR(target)
	if not IsDead(myHero) then
		CastSkillShot(_R,GetOrigin(target))
	end
end
-- 

-- Combo
function Combo()
	if IOW:Mode() == "Combo" then
		local target = ts:GetTarget()

		if IsReady(_R) and ValidTarget(target,600) and menu.c.cr:Value() then
			CastR(target)
		end

		if IsReady(_E) and ValidTarget(target,600) and menu.c.ce:Value() and pstacks == 3 then
			CastSpell(_E)
		end

		if IsReady(_Q) and ValidTarget(target,625) and menu.c.cq:Value() then
			CastQ(target)
		end

		if IsReady(_W) and ValidTarget(target,625) and menu.c.cw:Value() then
			CastW(target)
		end
	end
end
-- 

-- Harass
function Harass()
	if IOW:Mode() == "Harass" then
		local target = ts:GetTarget()

		if menu.h.hq:Value() and ValidTarget(target,625) and IsReady(_Q) then
			CastQ(target)
		end

		if menu.h.hw:Value() and ValidTarget(target,625) and IsReady(_W) then
			CastW(target)
		end
	end
end
-- 

-- KillSteal
function KS()
	for i,enemy in pairs(GetEnemyHeroes()) do
		local dmgq = CalcDamage(myHero,enemy,0,(IsReady(_Q)) and Qdmg or 0) 
		local dmgw = CalcDamage(myHero,enemy,0,(IsReady(_W)) and Wdmg or 0)
		local dmgr = CalcDamage(myHero,enemy,0,(IsReady(_R) and GetCastName(myHero,_R) == "InfernalGuardian") and Rdmg or 0)
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		if ValidTarget(enemy,625) and dmgw > enemyhp and menu.ks.ksw:Value() and IsReady(_W) then
			CastSkillShot(_W,GetOrigin(enemy))
		elseif ValidTarget(enemy,625) and dmgq > enemyhp and menu.ks.ksq:Value() and IsReady(_Q) then
			CastTargetSpell(enemy,_Q)
		elseif ValidTarget(enemy,625) and dmgr > enemyhp and menu.ks.ksr:Value() and IsReady(_R) then
			CastSkillShot(_R,GetOrigin(enemy))
		elseif ValidTarget(enemy,625) and dmgq + dmgw > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and IsReady(_Q) and IsReady(_W) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and dmgq + dmgr > enemyhp and menu.ks.ksq:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_R) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and dmgr + dmgw > enemyhp and menu.ks.ksr:Value() and menu.ks.ksw:Value() and IsReady(_R) and IsReady(_W) then
			CastSkillShot(_R,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and dmgq + dmgw + dmgr > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy))end, 250) end, 250)
		end
	end
end
-- 

-- LastHit
function LastHit()
	if IOW:Mode() == "LastHit" then
		if not IOW.isWindingUp then
			for _,minions in pairs(minionManager.objects) do
				if GetTeam(minions) == MINION_ENEMY and ValidTarget(minions,625) and menu.lh.q:Value() then
					local predhp = IOW:PredictHealth(minions, GetDistance(minions)*0.5+250)
					if predhp+5 > 0 then
						if predhp < CalcDamage(myHero,minions,0,Qdmg) then
							CastTargetSpell(minions,_Q)
						end
					end
				end
			end
		end
	end
end
-- 

-- JungleSteal
function JungleSteal()
	if IOW:Mode() == "LastHit" then
		if not IOW.isWindingUp then
			for _,minions in pairs(minionManager.objects) do
				if GetTeam(minions) == MINION_JUNGLE and ValidTarget(minions,625) and menu.lh.q:Value() then
					local predhp = IOW:PredictHealth(minions, GetDistance(minions)*0.5+250)
					if predhp+5 > 0 then
						if predhp < CalcDamage(myHero,minions,0,Qdmg) then
							CastTargetSpell(minions,_Q)
						end
					end
				end
			end
		end
	end
end
-- 

-- Ignite
-- function Ignite()
-- 	for i,enemy in pairs(GetEnemyHeroes()) do
-- 		if menu.m.aign:Value() then
-- 			local dmg = 20*GetLevel(myHero)+50 > GetCurrentHP(enemy) + (GetHPRegen(enemy)*3)
-- 			if CanUseSpell(myHero,Ignite) == READY and dmg and ValidTarget(enemy,600) then
-- 				CastTargetSpell(enemy,Ignite)
-- 			end
-- 		end
-- 	end
-- end
-- 

-- Buff Checks
OnUpdateBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "pyromania" then
			pstacks = buff.Count
		elseif buff.Name == "pyromania_particle" then
			pstun = true
		-- elseif buff.Name == "itemmagicshankchare" then
		-- 	LudensStacks = buff.Count
		end
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "pyromania" then
			pstacks = 0
		elseif buff.Name == "pyromania_particle" then
			pstun = false
		end
	end
end)
-- 

-- Drawings
OnDraw(function(myHero)
	if menu.d.dq:Value() then
		DrawCircle(GetOrigin(myHero),625,1,50,ARGB(255,0,255,0))
	end
	if menu.d.dw:Value() then
		DrawCircle(GetOrigin(myHero),625,1,50,ARGB(255,0,255,0))
	end
	if menu.d.dr:Value() then
		DrawCircle(GetOrigin(myHero),600,1,50,ARGB(255,255,255,0))
	end

	if menu.d.dmg:Value() then
		for i,unit in pairs(GetEnemyHeroes()) do
			if ValidTarget(unit,5000) then
				local dmgq = CalcDamage(myHero,unit,0,(IsReady(_Q)) and Qdmg or 0) 
				local dmgw = CalcDamage(myHero,unit,0,(IsReady(_W)) and Wdmg or 0)
				local dmgr = CalcDamage(myHero,unit,0,(IsReady(_R) and GetCastName(myHero,_R) == "InfernalGuardian") and Rdmg or 0)
				local tdmg = dmgq + dmgw + dmgr
				local enemyhp = GetCurrentHP(unit) + GetDmgShield(unit) + GetMagicShield(unit)
				DrawDmgOverHpBar(unit,enemyhp,0,tdmg,ARGB(255,0,255,0))
			end
		end
	end
end)

-- Tick
OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		Harass()
		KS()
		LastHit()
		-- Ignite()
		JungleSteal()
	end
end)
-- 

PrintChat("<font color=\"#00FFFF\"><b>[Annie Loaded]</b></font>")
