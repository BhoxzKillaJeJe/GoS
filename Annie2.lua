if GetObjectName(GetMyHero()) ~= "Annie" then return end

require('Inspired')
require('OpenPredict')

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
menu.c:DropDown("clogic", "Combo Logic", 1, {"QWR", "QRW", "WQR", "WRQ", "RQW", "RWQ"})
-- menu.c:DropDown("rlogic", "R Logic", 3, {"Stun Only", "Killable", "Default"})
menu.c:Info("info", "Default logic is just normal Combo")

menu.h:Boolean("hq", "Use Q", true)
menu.h:Boolean("hw", "Use W", true)

-- local Flash = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil))
local Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
if Ignite ~= nil then menu.m:Boolean("aign", "Auto Ignite", true) end
-- if Flash ~= nil then menu.m:Boolean("fu", "Flash Ult if Stun is Up", true)
	-- menu.m:KeyBinding("ft", "Flash Ult Key", string.byte("T"))
-- end

menu.ks:Boolean("ksq", "Use Q", true)
menu.ks:Boolean("ksw", "Use W", true)
menu.ks:Boolean("ksr", "Use R", true)

menu.lh:Boolean("q", "LastHit w/ Q", true)

menu.d:Boolean("dq", "Draw Q", false)
menu.d:Boolean("dw", "Draw W", false)
menu.d:Boolean("dr", "Draw R", false)
menu.d:Boolean("dmg", "Draw DMG", true)

---SpellData---------------
AnnieW = { delay = 0.25, speed = math.huge, angle = 50, range = 625}
AnnieR = { delay = 0.25, speed = math.huge, radius = 290, range = 600}
---------------------------

-------Variables-----------
local ts = TargetSelector(625,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGICAL,true,false)
local pstacks = nil
local pstun = nil
-- local LudensStacks = 0
local Qdmg = 45 + 35*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero)
local Wdmg = 25 + 45*GetCastLevel(myHero,_W) + 0.85*GetBonusAP(myHero)
local Rdmg = 50 + 125*GetCastLevel(myHero,_R) + 0.8*GetBonusAP(myHero)
local apdmg = Qdmg+Wdmg+Rdmg
---------------------------

-- Cast
function CastQ(target)
	if not IsDead(myHero) then
		CastTargetSpell(target,_Q)
	end
end

function CastW(target)
	local wpred = GetConicAOEPrediction(target,AnnieW)
	if wpred.hitchance => 0.25 then
		CastSkillShot(_W,wpred.castPos)
	end
end

function CastE()
	local mana = GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) + GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) + GetCastMana(myHero,_R,GetCastLevel(myHero,_R))
	local mana2 = GetCurrentMana(myHero)
	if mana < mana2 and pstun == 3 then
		CastSpell(_E)
	end
end

function CastR(target)
	local rpred = GetCircularAOEPrediction(target,AnnieR)
	if wpred.hitchance == 1 then
		CastSkillShot(_R,rpred.castPos)
	end
end
-- 

-- Combo Sequence
function CastQWR(target)
	if menu.c.clogic:Value() == 1 then
		CastQ(target) DelayAction(function() CastW(target) DelayAction(function() CastR(target) end, 250) end, 250)
	end
end

function CastQRW(target)
	if menu.c.clogic:Value() == 2 then
		CastQ(target) DelayAction(function() CastR(target) DelayAction(function() CastW(target) end, 250) end, 250)
	end
end

function CastWQR(target)
	if menu.c.clogic:Value() == 3 then
		CastW(target) DelayAction(function() CastQ(target) DelayAction(function() CastR(target) end, 250) end, 250)
	end
end

function CastWRQ(target)
	if menu.c.clogic:Value() == 4 then
		CastW(target) DelayAction(function() CastR(target) DelayAction(function() CastQ(target) end, 250) end, 250)
	end
end

function CastRQW(target)
	if menu.c.clogic:Value() == 5 then
		CastR(target) DelayAction(function() CastQ(target) DelayAction(function() CastW(target) end, 250) end, 250)
	end
end

function CastRWQ(target)
	if menu.c.clogic:Value() == 6 then
		CastR(target) DelayAction(function() CastW(target) DelayAction(function() CastQ(target) end, 250) end, 250)
	end
end
-- 

-- Combo
function Combo(target)
	if IOW:Mode() == "Combo" then
		local target = ts:GetTarget()

		if menu.c.cq:Value() and ValidTarget(target,625) and IsReady(_Q) then
			CastQ(target)
		end

		if menu.c.cw:Value() and ValidTarget(target,625) and IsReady(_W) then
			CastW(target)
		end

		if menu.c.ce:Value() and ValidTarget(target,550) and IsReady(_E) then
			CastE(target)
		end

		if menu.c.clogic:Value() == 1 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastQWR(target)
		elseif menu.c.clogic:Value() == 2 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastQRW(target)
		elseif menu.c.clogic:Value() == 3 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastWQR(target)
		elseif menu.c.clogic:Value() == 4 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastWRQ(target)
		elseif menu.c.clogic:Value() == 5 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastRQW(target)
		elseif menu.c.clogic:Value() == 6 and ValidTarget(target,625) and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastRWQ(target)
		end
	end
end
-- 

-- Harass
function Harass(target)
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
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		if ValidTarget(enemy,625) and Wdmg > enemyhp and menu.ks.ksw:Value() and IsReady(_W) then
			CastSkillShot(_W,GetOrigin(enemy))
		elseif ValidTarget(enemy,625) and Qdmg > enemyhp and menu.ks.ksq:Value() and IsReady(_Q) then
			CastTargetSpell(enemy,_Q)
		elseif ValidTarget(enemy,625) and Rdmg > enemyhp and menu.ks.ksr:Value() and IsReady(_R) then
			CastSkillShot(_R,GetOrigin(enemy))
		elseif ValidTarget(enemy,625) and Qdmg + Wdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and IsReady(_Q) and IsReady(_W) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Qdmg + Rdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_R) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Rdmg + Wdmg > enemyhp and menu.ks.ksr:Value() and menu.ks.ksw:Value() and IsReady(_R) and IsReady(_W) then
			CastSkillShot(_R,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) end, 250)
		elseif ValidTarget(enemy,625) and Qdmg + Wdmg + Rdmg > enemyhp and menu.ks.ksq:Value() and menu.ks.ksw:Value() and menu.ks.ksr:Value() and IsReady(_Q) and IsReady(_W) and IsReady(_R) then
			CastTargetSpell(enemy,_Q) DelayAction(function() CastSkillShot(_W,GetOrigin(enemy)) DelayAction(function() CastSkillShot(_R,GetOrigin(enemy))end, 250) end, 250)
		end
	end
end
-- 

-- LastHit
function LastHit(minion)
	if IOW:Mode() == "LastHit" then
		for _,minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY and menu.lh.q:Value() then 
				if ValidTarget(minion,625) and (GetHealthPrediction(minion, GetDistance(minion)*0.5+250) < CalcDamage(myHero,minion,0,Qdmg)) then
					CastTargetSpell(minion,_Q)
				end
			end
		end
	end
end
-- 

-- Buff Checks
OnUpdateBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == "pyromania" then
			pstacks = buff.Count
		elseif buff.Name == "pyromania_particle" then
			pstun = true
		-- elseif buff.Nameg == "itemmagicshankchare" then
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
			if ValidTarget(unit, 5000) then
				local enemyhp = GetCurrentHP(unit) + GetDmgShield(unit) + GetMagicShield(unit)
				DrawDmgOverHpBar(unit,enemyhp,0,apdmg,ARGB(255,255,0,0))
			end
		end
	end
end)

-- Tick
OnTick(function(myHero)
	if not IsDead(myHero) then
		local target = ts:GetTarget()
		Combo(target)
		Harass(target)
		KS()
		LastHit(minion)
	end
end)
-- 
PrintChat("<font color=\"#00FFFF\">[Annie Loaded]</font>")
