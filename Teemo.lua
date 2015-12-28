if GetObjectName(GetMyHero()) ~= "Teemo"

require ('Inspired')
 
Teemo = Menu("Teemo", "Teemo")
Teemo:SubMenu("Combo", "Combo")
Teemo.Combo:Boolean("Q", "Use Q", true)

if Ignite ~= nil then
Teemo:SubMenu("Misc", "Misc")
Teemo.Misc:Boolean("Ign", "Ignite", true)
end

Teemo:SubMenu("Killsteal", "Killsteal")
Teemo.Killsteal:Boolean("KQ", "KS w/ Q", true) 
 
Teemo:SubMenu("Drawings", "Drawings")
Teemo.Drawings:Boolean("Q", "Draw Q", true)
Teemo.Drawings:Boolean("R", "Draw R", true)
Teemo.Drawings:Boolean("DQ", "Draw Dmg Q", true)
 
local Qrange = GetCastRange(myHero, _Q)
local Rrange = GetCastRange(myHero, _R)

 
local function Combo()
	local unit = GetCurrentTarget()
	if IOW:Mode() == "Combo" and ValidTarget(unit, Qrange) then
		CastTargetSpell(_Q, unit)
	end
end

local function Killsteal()
	local target = GetCurrentTarget()
	local truedmg = CalcDamage(myHero, enemy, 0, (45*GetCastLevel(myHero,_Q) + 35 + 0.8*(GetBonusAP(myHero))))
	for i,enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_Q) and ValidTarget(target, Qrange) and Teemo.Killsteal.KQ:Value() and GetCurrentHP(enemy) < truedmg then
			CastTargetSpell(_Q, target)
		end
	end
end
 
OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		Killsteal()
		Ignite()
	end
end)

OnDraw(function(myHero)
	if Teemo.Drawings.DQ:Value() then
		local target = GetCurrentTarget()
		if IsReady(_Q) and ValidTarget(target, 2000) then
			local truedmg = CalcDamage(myHero, enemy, 0, (45*GetCastLevel(myHero,_Q) + 35 + 0.8*(GetBonusAP(myHero))))
			DrawDmgOverHpBar(target, GetCurrentHP(target),0,truedmg,0xff00ff00)
		end
	end
	Drawings()
end)

local function Drawings()
myHeroP = GetOrigin(myHero)
	if Teemo.Drawings.Q:Value() then
		DrawCircle(myHeroP.x, myHeroP.y, myHeroP.z, Qrange, 1, 100,0xff00ff00)
	end

	if Teemo.Drawings.R:Value() then
		DrawCircle(myHeroP.x, myHeroP.y, myHeroP.z, Rrange, 1, 100,0xff00ff00)
	end
end

local function Ignite()
	for i,enemy in pairs(GetEnemyHeroes()) do
   	
        if Ignite and Teemo.Misc.Ign:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
        end
    end
end
--To Do JungleSteal
