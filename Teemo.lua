if GetObjectName(myHero) ~= "Teemo" then return end

require('Inspired')
if not pcall(require,"DamageLib") then PrintChat("Need DamgeLib to Work!!!") end

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
menu.m:KeyBinding("qign", "Q+Ignite", string.byte("T"))

menu.d:Boolean("dq", "Draw Q", true)
menu.d:Boolean("dr", "Draw R", true)
menu.d:Boolean("dmg", "Draw Dmg", true)

menu:KeyBinding("help", "LastHit Helper", string.byte("X"))

-- Vars
local range = GetCastRange(myHero,_Q)
local ignitedmg = 20*GetLevel(myHero)+50
local passiveminion = nil
local target = TargetSelector(580,TARGET_LESS_CAST_PRIORITY,DAMAGE_MAGIC,true,false)
local windup = 200
local baseAS = GetBaseAttackSpeed(myHero)
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
		local qdmg = getdmg("Q",enemy,myHero)
		local edmg = getdmg("E",enemy,myHero)
		local hp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)

		-- Q
		if IsReady(_Q) and ValidTarget(enemy,range) and qdmg > hp and menu.ks.ksq:Value() then
			CastTargetSpell(enemy,_Q)
		-- Q+Ignite
		elseif IsReady(_Q) and CanUseSpell(myHero,Ignite) == READY and ValidTarget(enemy,range) and qdmg+ignitedmg > hp and menu.m.qign:Value() then
			CastTargetSpell(enemy,Ignite)
			CastTargetSpell(enemy,_Q)
		-- Ignite
		elseif CanUseSpell(myHero,Ignite) == READY and ValidTarget(enemy,600) and ignitedmg > hp and menu.m.ign:Value() then
			CastTargetSpell(enemy,Ignite)
		end
	end
end

function JS()
	for _,jminions in pairs(minionManager.objects) do
		if GetTeam(jminions) == 300 then
			local qdmg = getdmg("Q",jminions,myHero)
			local predhp = IOW:PredictHealth(jminions,GetDistance(jminions)*0.5+250)

			if Ready(_Q) and ValidTarget(jminions,range) and predhp+10 < qdmg and menu.js.jsq:Value() then
				if GetObjectName(jminions) == "SRU_Dragon" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Baron" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Blue" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_Red" then
					CastTargetSpell(jminions,_Q)
				elseif GetObjectName(jminions) == "SRU_RiftHerald" then
					CastTargetSpell(jminions,_Q)
				end
			end
		end
	end
end

function LastHit()
	if menu.help:Value() then
		for i,minions in pairs(minionManager.objects) do
			if GetTeam(minions) == 300 then
				local minionhp = IOW:PredictHealth(minions,((GetDistance(minions)/2000)*1000)+ GetWindUp(myHero))
				local edmg = (GetBaseDamage(myHero)+GetBonusDmg(myHero))+getdmg("E",minions)
				if atk == true and ValidTarget(minions,GetRange(myHero)) and GetDistance(myHero,minions) < GetRange(myHero) and edmg > minionhp+15 then
					IOW.movementEnabled = false
					DelayAction(function()
						AttackUnit(minions)
					end, 1)
					DelayAction(function()
						IOW.movementEnabled = true
					end, windup)
				end
			end
		end
	end
end

OnProcessSpellComplete(function(unit, spell)
	if unit == myHero and spell.name:lower():find("attack") then
		windup = spell.windUpTime*1000
		ASDelay = 1/(baseAS*GetAttackSpeed(myHero))
		atk = false
		IOW.movementEnabled = true
		DelayAction(function()
			atk = true
		end,ASDelay*1000 - spell.windUpTime*1000)
	end
end)


OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		KS()
		JS()
		LastHit()
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
		local qdmg = getdmg("Q",v,myHero)
		local enemyhp = GetCurrentHP(v) + GetMagicShield(v) + GetDmgShield(v)
		local vpos = WorldToScreen(1,GetOrigin(v))

		if menu.d.dmg:Value() and ValidTarget(v,5000) then
			DrawDmgOverHpBar(v,enemyhp,0,qdmg,ARGB(255,0,255,0))
		end

		if ignitedmg + qdmg > enemyhp and ValidTarget(v,2000) then
			DrawText("Can Q+Ignite Press T",15,vpos.x,vpos.y,ARGB(155,255,255,0))
		elseif enemyhp > ignitedmg + qdmg and ValidTarget(v,2000) then 
			DrawText("Can't kill yet!!!!",15,vpos.x,vpos.y,ARGB(155,255,255,0))
		end
	end
end)

PrintChat("<font color=\"#990000\"><b>[Teemo Loaded]</b></font>")
