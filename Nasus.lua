if GetObjectName(GetMyHero()) ~= "Nasus" then return end

require('Inspired')

NasusMenu = Menu("Nasus", "Nasus")
NasusMenu:SubMenu("Combo", "Combo")
NasusMenu.Combo:Boolean("Q","Use Q",true)
NasusMenu.Combo:Boolean("W","Use W",true)
NasusMenu.Combo:Boolean("E","Use E",true)
NasusMenu.Combo:Boolean("R","Use R",true)
NasusMenu.Combo:Slider("RHP", "Use R if my HP < x%", 20, 5, 80, 1)

NasusMenu:SubMenu("Stacks", "LastHit/AutoLastHit")
NasusMenu.Stacks:KeyBinding("TAQ", "Toggle AutoLastHit", string.byte("J"), true)

NasusMenu:SubMenu("KS", "KillSteal")
NasusMenu.KS:Boolean("Q","Use Q KS",true)
NasusMenu.KS:Boolean("E","Use E KS",true)
NasusMenu.KS:Boolean("WQ","Use W+Q KS",false)

NasusMenu:SubMenu("Misc", "Misc")
NasusMenu.Misc:Boolean("DMG","Draw DMG over HP",true)

------variables------
local Qstack = 0
local sheendmg = 0
local lichbane = 0
local frozendmg = 0
------end------

------Q stack check------
function Stacking()
  nasusstacks = GetBuffData(myHero, "nasusqstacks")
  Qstack = nasusstacks.Stacks
end
-------------------------

function Combo()
	if IOW:Mode() == "Combo" then
		local target = GetCurrentTarget()
		local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),1700,250,650,70,true,false)

		if NasusMenu.Combo.W:Value() and ValidTarget(target, GetCastRange(myHero,_W)) and IsReady(_W) then
			CastTargetSpell(target,_W)
		end

		if NasusMenu.Combo.E:Value() and ValidTarget(target, GetCastRange(myHero,_E)) and IsReady(_E) then
			CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
		end

		if NasusMenu.Combo.Q:Value() and ValidTarget(target, 250) and IsReady(_Q) then
			CastSpell(_Q)
		end
	end

--R if hp% is	
	if NasusMenu.Combo.R:Value() and GetPercentHP(myHero) < NasusMenu.Combo.RHP:Value() and IsReady(_R) and ValidTarget(target, 750) then
		CastSpell(_R)
	end
-----------------
end

function LastHit(minion)
	if NasusMenu.Stacks.TAQ:Value() and not (IOW:Mode() == "Combo" or IOW:Mode() == "Harass") then
		for _,minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then	
    			if ValidTarget(minion, GetRange(myHero)+125) and CalcDamage(myHero, minion, addmg, lichbane) > GetCurrentHP(minion) and IsReady(_Q) then
        			CastSpell(_Q)
              AttackUnit(minion)
    			end
    	end
    end
  end
end

function AutoJungle(jminion)
	if NasusMenu.Stacks.TAQ:Value() then
		for _,jminion in pairs(minionManager.objects) do
			if GetTeam(jminion) == 300 then    			
    			if ValidTarget(jminion, GetRange(myHero)+125) and CalcDamage(myHero, jminion, addmg, lichbane) > GetCurrentHP(jminion) and IsReady(_Q) then
        			CastSpell(_Q)
              AttackUnit(jminion)
    		  end
    	end
    end
  end
end


function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		local enemyhp = GetCurrentHP(enemy) + GetHPRegen(enemy) + GetMagicShield(enemy) + GetDmgShield(enemy)
		local Edmg = (15 + 40*GetCastLevel(myHero,_E) + 0.6*GetBonusDmg(myHero))
  		
  			 if NasusMenu.KS.Q:Value() and ValidTarget(enemy, GetRange(myHero)+50) and CalcDamage(myHero, enemy, addmg, lichbane) > enemyhp and IsReady(_Q) then
          CastSpell(_Q) DelayAction(function() AttackUnit(enemy) end, 100)
        end
      
        local EPred = GetPredictionForPlayer(GetOrigin(myHero),enemy,GetMoveSpeed(enemy),1700,250,650,70,true,false)
        if NasusMenu.KS.E:Value() and ValidTarget(enemy, 650) and CalcDamage(myHero, enemy, 0, Edmg) > enemyhp and IsReady(_E) then
          CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
        end
    
        if NasusMenu.KS.WQ:Value() and ValidTarget(enemy, 500) and CalcDamage(myHero, enemy, addmg, lichbane) > enemyhp and IsReady(_W) and IsReady(_Q) then
          CastTargetSpell(enemy, _W) DelayAction(function() CastSpell(_Q) DelayAction(function() AttackUnit(enemy) end, 100) end)
        end    
      end
   end
end

OnDraw(function(myHero)
    for _,unit in pairs(GetEnemyHeroes()) do    
  		if ValidTarget(unit,20000) and IsReady(_Q) then
			  DrawDmgOverHpBar(unit, GetCurrentHP(unit) + GetMagicShield(unit) + GetDmgShield(unit), addmg, lichbane,0xffffffff)
      end
      if ValidTarget(unit,20000) and IsReady(_E) then
        DrawDmgOverHpBar(unit, GetCurrentHP(unit) + GetMagicShield(unit) + GetDmgShield(unit), addmg, lichbane,0xff00ff00)
      end
  	end  
end)

------Qdmg + addmg------
function getaddmgq()
  qdmg = 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero)
  addmg = Qstack + frozendmg + sheendmg + qdmg
end
------------------------

OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo()
		LastHit(minion)
		AutoJungle(jminion)
		KillSteal()
    Stacking()
    getaddmgq()
  end
end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero then
    if buff.Name == "sheen" then
      sheen = GetBaseDamage(myHero)
    elseif buff.Name == "lichbane" then
      lichbane = 0.75*(GetBaseDamage(myHero))+.5*GetBonusAP(myHero)
    elseif buff.Name == "itemfrozenfist" then
      frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
    end 
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero then
    if buff.Name == "sheen" then
      sheen = 0
    elseif buff.Name == "lichbane" then
      lichbane = 0
    elseif buff.Name == "itemfrozenfist" then
      frozendmg = 0
    end
  end
end)

PrintChat("Nasus Loaded")
