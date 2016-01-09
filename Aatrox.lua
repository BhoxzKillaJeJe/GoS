if GetObjectName(GetMyHero()) ~= "Aatrox" then return end

require('Inspired')

Aatrox = MenuConfig("Aatrox", "Aatrox")
Aatrox:SubMenu("Combo", "Combo")
Aatrox:SubMenu("Drawings", "Drawings")

Aatrox.Combo:Boolean("CQ", "Use Q", true)
Aatrox.Combo:Boolean("CW", "Use W", true)
Aatrox.Combo:Boolean("CE", "Use E", true)
Aatrox.Combo:Boolean("CR", "Use R", true)
Aatrox.Combo:Slider("HPCR", "R if HP% are >", 30, 10, 100, 5)

if Ignite ~= nil then
Aatrox.Combo:Boolean("AutoIgnite", "Ignite", true)
end

Aatrox.Drawings:Boolean("DQ", "Draw Q", true)
Aatrox.Drawings:Boolean("DE", "Draw E", true)
Aatrox.Drawings:Boolean("DR", "Draw R", true)

OnTick(function(myHero)
---COMBO---
	if IOW:Mode() == "Combo" then

 	local target = GetCurrentTarget()
 	local QPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),2000,670,650,250,false,true)
 	local EPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),1250,300,1075,35,false,false)    

 		if IsReady(_Q) and ValidTarget(target, GetCastRange(myHero, _Q)-50) and QPred.HitChance == 1 and Aatrox.Combo.CQ:Value() then
 			CastSkillShot(_Q, QPred.PredPosx, QPred.PredPos.y, QPred.PredPos.z)
 		end

 		if IsReady(_W) and ValidTarget(target, 600) and Aatrox.Combo.CW:Value() then
 			if GotBuff(myHero, "aatroxwlife") and GetPercentHP(myHero) > 0.5 then
 				CastSpell(_W)
			elseif GotBuff(myHero, "aatroxwpower") and GetPercentHP(myHero) < 0.5 then
				CastSpell(_W)
			end
		end

		if IsReady(_E) and ValidTarget(target, GetCastRange(myHero, _E)-50) and EPred.HitChance == 1 and Aatrox.Combo.CE:Value() then
			CastSkillShot(_E, EPred.PredPos.x, EPred.PredPos.y, EPred.PredPos.z)
		end

		if IsReady(_R) and ValidTarget(target, GetCastRange(myHero, _R)) and Aatrox.Combo.CR:Value() then
			if GetPercentHP(myHero) < Aatrox.Combo.HCR:Value() then
				CastSpell(_R)
			end
		end
	end
---COMBO END---
	AutoIgnite()
end)

function AutoIgnite()
    for _,enemy in pairs(GetEnemyHeroes()) do
        if Ignite and Aatrox.Combo.AutoIgnite:Value() then
			local HPShield = GetCurrentHP(enemy)+GetDmgShield(enemy)
            if IsReady(Ignite) and 20*GetLevel(myHero)+50 > HPShield+(GetHPRegen(enemy)*3) and ValidTarget(enemy, 600) then
              CastTargetSpell(enemy, Ignite)
          end
        end 
    end
end

OnDraw(function(myHero)
	if Aatrox.Drawings.DQ:Value() and IsReady(_Q) then
		DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,Qrange,1,80,0xff00ff00)
	end

	if Teemo.Drawings.DE:Value() and IsReady(_E) then
		DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,GetCastRange(myHero, _R),1,80,0xff00ff00)
	end

	if Teemo.Drawings.DR:Value() and IsReady(_R) then
		DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,GetCastRange(myHero, _R),1,80,0xff00ff00)
	end
end)
