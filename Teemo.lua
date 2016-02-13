if GetObjectName(myHero) ~= "Teemo" then return end

require('Inspired')

menu = Menu("Teemo", "Cpt. Teemo")
menu:SubMenu("c", "Combo")
menu:SubMenu("ks", "KillSteal")
menu:SubMenu("js", "JungleSteal")
menu:SubMenu("m", "Misc")
menu:SubMenu("d", "Drawings")

menu.c:Boolean("cq", "Use Q", true)

menu.ks:Boolean("ksq", "KS w/ Q", true)

menu.js:Boolean("jsq", "JS w/ Q", true)

Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
menu.m:Boolean("ign", "Auto Ignite", true)
menu.m:Boolean("qign", "Q+Ignite", true)

menu.d:Boolean("dq", "Draw Q", true)
menu.d:Boolean("dr", "Draw R", true)
menu.d:Boolean("dmg", "Draw Dmg", true)

-- Vars
local target = TargetSelector(580,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local range = GetCastRange(myHero,_Q)
-- 

function Combo()
	if IOW:Mode() == "Combo" then
		local qtarget = target:GetTarget()

		if Ready(_Q) and ValidTarget(qtarget,range) and menu.c.cq:Value() then
			CastTargetSpell(qtarget,_Q)
			IOW:ResetAA()
		end
	end
end

function KS()
	for i,enemy in pairs(GetEnemyHeroes()) do
		local qdmg = CalcDamage(myHero,enemy,0,(45+45*GetCastLevel(myHero,_Q)+0.8*GetBonusAP(myHero)))
		local ignitedmg = 20*GetLevel(myHero)+50
		local hp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		if IsReady(_Q) and ValidTarget(enemy,range) and qdmg > hp and menu.ks.ksq:Value() then
			CastTargetSpell(enemy,_Q)
		elseif CanUseSpell(myHero,Ignite) == READY and ValidTarget(enemy,600) and ignitedmg > GetCurrentHP(enemy)+GetDmgShield(enemy) and menu.m.ign:Value() then
			CastTargetSpell(enemy,Ignite)
		elseif CanUseSpell(myHero,Ignite) == READY and IsReady(_Q) and ValidTarget(enemy,600) and qdmg+ignitedmg > hp and menu.m.qign:Value() then
			CastTargetSpell(enemy,Ignite)
			CastTargetSpell(enemy,_Q)
		end
	end
end

function JS()
	for _,jminions in pairs(minionManager.objects) do
		if GetTeam(jminions) == 300 then
			local jsqdmg = CalcDamage(myHero,jminions,0,(45+45*GetCastLevel(myHero,_Q)+0.8*GetBonusAP(myHero)))

			if Ready(_Q) and ValidTarget(jminions,range) and jsqdmg > GetCurrentHP(jminions) and menu.js.jsq:Value() then
				if GetObjectName(jminions) == "SRU_Dragon" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Baron" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Blue" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Red" then
					CastTargetSpell(jminions,_Q)
				end
			end
		end
	end
end

OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		KS()
		JS()
	end
end)

OnDraw(function(myHero)

	if menu.d.dq:Value() then
		DrawCircle(GetOrigin(myHero),range,1,70,ARGB(255,0,255,0))
	end

	if menu.d.dr:Value() then
		DrawCircle(GetOrigin(myHero),GetCastRange(myHero,_R),1,70,ARGB(255,255,255,0))
	end

	for k,v in pairs(GetEnemyHeroes()) do
		local qdmg = CalcDamage(myHero,v,0,(45+45*GetCastLevel(myHero,_Q)+0.8*GetBonusAP(myHero)))
		local enemyhp = GetCurrentHP(v) + GetMagicShield(v) + GetDmgShield(v)

		if menu.d.dmg:Value() and ValidTarget(v,5000) then
			DrawDmgOverHpBar(v,enemyhp,0,qdmg,ARGB(255,0,255,0))
		end
	end
end)

PrintChat("<font color=\"#990000\"><b>[Teemo Loaded]</b></font>")
