if GetObjectName(GetMyHero()) ~= "Teemo" then return end

require('Inspired')
 
Teemo = MenuConfig("El Capitan Teemo", "El Capitan Teemo")
Teemo:SubMenu("Combo", "Combo")
Teemo:SubMenu("Killsteal", "Killsteal")
Teemo:SubMenu("JungleSteal", "JungleSteal")
Teemo:SubMenu("Drawings", "Drawings")

if Ignite ~= nil then
Teemo:SubMenu("Misc", "Misc")
Teemo.Misc:Boolean("AutoIgnite", "AutoIgnite", true)
Teemo.Misc:Boolean("QIgnite", "QIgnite", true)
end

Teemo.Combo:Boolean("Q", "Use Q", true)

Teemo.Killsteal:Boolean("KQ", "KS w/ Q", true) 

Teemo.JungleSteal:Boolean("JSQ", "JungleSteal w/ Q", true)
 
Teemo.Drawings:Boolean("Q", "Draw Q", true)
Teemo.Drawings:Boolean("R", "Draw R", true)
Teemo.Drawings:Boolean("DQ", "Draw Dmg Q", true)
 
local Qrange = GetCastRange(myHero, _Q)
local Rrange = GetCastRange(myHero, _R)
local LudensStacks = 0

OnTick(function(myHero)
	local target = GetCurrentTarget()

	if IOW:Mode() == "Combo" then
---COMBO CODE---
		if IsReady(_Q) and ValidTarget(target, Qrange) and Teemo.Combo.Q:Value() then
			CastTargetSpell(target, _Q)
		end
	end
---COMBO CODE END---
---KILLSTEAL CODE---
	for i,enemy in pairs(GetEnemyHeroes()) do

		if not IsImmune(enemy, myHero) and IsObjectAlive(enemy) then
			if IsReady(_Q) and Teemo.Killsteal.KQ:Value() and ValidTarget(enemy, Qrange) and CalcDamage(myHero, enemy, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())) > GetCurrentHP(enemy) then
				CastTargetSpell(enemy, _Q)
			end
		end
	end
---KILLSTEAL CODE END---
---JUNGLESTEAL CODE---
	for _,jungle in pairs(minionManager.objects) do
		if MINION_JUNGLE == GetTeam(jungle) then

			if IsReady(_Q) and ValidTarget(jungle, Qrange) and Teemo.JungleSteal.JSQ:Value() and CalcDamage(myHero, jungle, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())) > GetCurrentHP(jungle) and GetObjectName(jungle) == "Dragon" then
				CastTargetSpell(jungle, _Q)
			elseif IsReady(_Q) and ValidTarget(jungle, Qrange) and Teemo.JungleSteal.JSQ:Value() and CalcDamage(myHero, jungle, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())) > GetCurrentHP(jungle) and GetObjectName(jungle) == "Baron" then
				CastTargetSpell(jungle, _Q)
			elseif IsReady(_Q) and ValidTarget(jungle, Qrange) and Teemo.JungleSteal.JSQ:Value() and CalcDamage(myHero, jungle, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())) > GetCurrentHP(jungle) and GetObjectName(jungle) == "Blue" then
				CastTargetSpell(jungle, _Q)
			elseif IsReady(_Q) and ValidTarget(jungle, Qrange) and Teemo.JungleSteal.JSQ:Value() and CalcDamage(myHero, jungle, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())) > GetCurrentHP(jungle) and GetObjectName(jungle) == "Red" then
				CastTargetSpell(jungle, _Q)
			end
		end
	end
---JUNGLESTEAL CODE END---	
	AutoIgnite()
	QIgnite()
end)

OnDraw(function(myHero)
	local target = GetCurrentTarget()
	if Teemo.Drawings.Q:Value() and CanUseSpell(myHero, _Q) == READY then
		DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,Qrange,1,80,0xff00ff00)
	end

	if Teemo.Drawings.R:Value() and CanUseSpell(myHero, _R) == READY then
		DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,Rrange,1,80,0xff000000)
	end

	if Teemo.Drawings.DQ:Value() and CanUseSpell(myHero, _Q) == READY then
		local target = GetCurrentTarget()
		if ValidTarget(target, 5000) then
			DrawDmgOverHpBar(target, GetCurrentHP(target), 0, CalcDamage(myHero, target, 0,(45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens())),0xff00ff00)
		end
	end
end)

function AutoIgnite()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if Ignite and Teemo.Misc.AutoIgnite:Value() then
			local HPShield = GetCurrentHP(enemy)+GetDmgShield(enemy)
            if IsReady(Ignite) and 20*GetLevel(myHero)+50 > HPShield+(GetHPRegen(enemy)*3) and ValidTarget(enemy, 600) then
              CastTargetSpell(enemy, Ignite)
          end
        end 
    end
end

function QIgnite()
	for _,enemy in pairs(GetEnemyHeroes()) do
		local HPShield = GetCurrentHP(enemy)+GetDmgShield(enemy)
		local Ignitedmg = 20*GetLevel(myHero)
		local Qdmg = 45 + 45*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) + Ludens()

		if IsReady(Ignite) and IsReady(_Q) and ValidTarget(enemy, 600) and Ignitedmg + Qdmg > GetCurrentHP(enemy) and Teemo.Misc.QIgnite:Value() then
			CastTargetSpell(enemy, Ignite) 
			DelayAction(function() CastTargetSpell(enemy, _Q) end, 0.125)
		end
	end
end

---LUDENS ECHO CODE---
OnUpdateBuff(function(unit,buff) ---STOLE IT FROM DEFTLIB
  if unit == myHero then
    if buff.Name == "itemmagicshankcharge" then 
    LudensStacks = buff.Count
    end
end

function Ludens()
	return LudensStacks == 100 and 100+0.1*GetBonusAP(myHero) or 0
end
---LUDENS ECHO CODE END---
