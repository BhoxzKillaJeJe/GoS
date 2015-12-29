if GetObjectName(GetMyHero()) ~= "Teemo" then return end

require('Inspired')
 
Teemo = MenuConfig("El Capitan Teemo", "El Capitan Teemo")
Teemo:SubMenu("Combo", "Combo")
Teemo:SubMenu("Killsteal", "Killsteal")
Teemo:SubMenu("Drawings", "Drawings")

if Ignite ~= nil then
Teemo:SubMenu("Misc", "Misc")
Teemo.Misc:Boolean("AutoIgnite", "AutoIgnite", true)
end

Teemo.Combo:Boolean("Q", "Use Q", true)

Teemo.Killsteal:Boolean("KQ", "KS w/ Q", true) 
 
Teemo.Drawings:Boolean("Q", "Draw Q", true)
Teemo.Drawings:Boolean("R", "Draw R", true)
Teemo.Drawings:Boolean("DQ", "Draw Dmg Q", true)
 
local Qrange = GetCastRange(myHero, _Q)
local Rrange = GetCastRange(myHero, _R)

OnTick(function(myHero)
	local target = GetCurrentTarget()

	if IOW:Mode() == "Combo" then
---COMBO CODE---
		if CanUseSpell(myHero, _Q) == READY and ValidTarget(target, Qrange) and Teemo.Combo.Q:Value() then
			CastTargetSpell(_Q, target)
		end
	end
---COMBO CODE END---
---KILLSTEAL CODE---
	for i,enemy in pairs(GetEnemyHeroes()) do
		local Qdmg = 45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero)
			
		local Ludens = 0
---LUDENS ECHO CODE---        		
    		if GotBuff(myHero, "itemmagicshankcharge") == 100 then
        		Ludens = Ludens + 0.1*GetBonusAP(myHero) + 100
    		end 
---LUDENS ECHO CODE END---		
		if not IsImmune(enemy, myHero) and IsObjectAlive(enemy) then
			if CanUseSpell(myHero, _Q) == READY and Teemo.Killsteal.KQ:Value() and ValidTarget(enemy, Qrange) and CalcDamage (myHero, enemy, 0, Qdmg + Ludens) > GetCurrentHP(enemy) then
				CastTargetSpell(_Q, target)
			end
		end
	end
---KILLSTEAL CODE END---
	AutoIgnite()
end)

OnDraw(function(myHero)

	if Teemo.Drawings.Q:Value() and CanUseSpell(myHero, _Q) == READY then
		DrawCircle(myHeroPos()x,myHeroPos()y,myHeroPos()z,Qrange,1,100,0xff00ff00)
	end

	if Teemo.Drawings.R:Value() and CanUseSpell(myHero, _R) == READY then
		DrawCircle(myHeroPos()x,myHeroPos()y,myHeroPos()z,Rrange,1,100,0xff00ff00)
	end

	if Teemo.Drawings.DQ:Value() and CanUseSpell(myHero, _Q) == READY then
		local target = GetCurrentTarget()
		if ValidTarget(target, 2000) then
			DrawDmgOverHpBar(target, GetCurrentHP(target), 0, CalcDamage(myHero,enemy,0,Qdmg),0xff00ff00)
		end
	end
end)

function AutoIgnite()
    for _,Enemy in pairs(GetEnemyHeroes()) do
        if Ignite and Teemo.Misc.AutoIgnite:Value() then
			local EnemyDefStat = GetCurrentHP(Enemy)+GetDmgShield(Enemy)
            if IsReady(Ignite) and 20*GetLevel(myHero)+50 > EnemyDefStat+(GetHPRegen(Enemy)*3) and ValidTarget(Enemy, 600) then
              CastTargetSpell(Enemy, Ignite)
          end
        end 
    end
end
