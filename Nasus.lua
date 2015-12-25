if GetObjectName(GetMyHero()) ~= "Nasus" then return end

require('Inspired')

local Qstack = 0
local NasusMenu = Menu("Nasus", "Nasus")

NasusMenu:SubMenu("Combo", "Combo")
NasusMenu.Combo:Boolean("Q","Use Q",true)
NasusMenu.Combo:Boolean("W","Use W",true)
NasusMenu.Combo:Boolean("E","Use E",true)
NasusMenu.Combo:Boolean("R","Use R",true)
NasusMenu.Combo:Slider("RHP", "Use R if my HP < x%", 20, 5, 80, 1)

NasusMenu:SubMenu("Harass", "Harass")
NasusMenu.Harass:Boolean("Q","Use Q",true)
NasusMenu.Harass:Boolean("W","Use W",true)
NasusMenu.Harass:Boolean("E","Use E",false)
NasusMenu.Harass:Boolean("R","Use R",true)
NasusMenu.Harass:Slider("RHP", "Use R if my HP < x%", 20, 5, 80, 1)

NasusMenu:SubMenu("Stacks", "LastHit/LaneClear/Jungle")
NasusMenu.Stacks:Boolean("Q","Use LastHit Q",true)
NasusMenu.Stacks:Boolean("AQ","Auto LastHit Q if",true)
NasusMenu.Stacks:Slider("AQR", "Minion Range < x (Def.250)", 250, 50, 1500, 1)
NasusMenu.Stacks:Boolean("QLC","Use LaneClear Q",true)

NasusMenu:SubMenu("KS", "KillSteal")
NasusMenu.KS:Boolean("Q","Use Q KS",true)
NasusMenu.KS:Boolean("E","Use E KS",true)
NasusMenu.KS:Boolean("WQ","Use W+Q KS",false)
NasusMenu.KS:Boolean("WEQ","Use W+E+Q KS",false)

NasusMenu:SubMenu("Misc", "Misc")
NasusMenu.Misc:Boolean("QAA","Draw QAA",true)
NasusMenu.Misc:Boolean("DMG","Draw DMG over HP",true)

function Stacking()
  nasusQstacks = GetBuffData(myHero,"nasusqstacks")
  QStack = nasusQstacks.Stacks
end

OnTick(function(myHero)
    target = GetCurrentTarget()
    Stacking() 
    Killsteal()    
  if NasusMenu.Misc.QAA:Value() then  
    QAA()
  end  
	if IOW:Mode() == "Combo" then 
    	Combo()
  end  
	if IOW:Mode() == "Harass" then 
    	Harass()
  end
  if IOW:Mode() == "LastHit" and NasusMenu.Stacks.Q:Value() then 
      LastHit(minion)
      JungleClear(jminion)
  end   
  if KeyIsDown(0x10) then  
      DrawText(string.format("QStack = %f", QStack),20,100,300,0xffffffff); 
  end
end)

function Combo()
    local unit = GetCurrentTarget()
  local target = GetCurrentTarget()
if target == nil or GetOrigin(target) == nil or IsImmune(target,myHero) or IsDead(target) or not IsVisible(target) or GetTeam(target) == GetTeam(myHero) then return false end
if ValidTarget(target, 1000) then
  if NasusMenu.Combo.W:Value() then
    if CanUseSpell(myHero, _W) == READY and IsInDistance(target, 600) then --and IsObjectAlive(target) 
      CastTargetSpell(target, _W)
    end
  end  
  if NasusMenu.Combo.E:Value() then           
    local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),1700,250,650,70,true,false)
    if CanUseSpell(myHero, _E) == READY  and IsInDistance(target, 650) then --and IsObjectAlive(target)
      CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
    end
  end  
  if NasusMenu.Combo.Q:Value() then
    if CanUseSpell(myHero, _Q) == READY and IsInDistance(target, 300) then --and IsObjectAlive(target) 
      CastSpell(_Q)
    end  
  end
  if NasusMenu.Combo.R:Value() then
    if CanUseSpell(myHero, _R) == READY  and (GetCurrentHP(myHero)/GetMaxHP(myHero)) < (NasusMenu.Combo.RHP:Value()/100) then --and IsObjectAlive(target)
      CastSpell(_R)
    end  
  end
end
end

function Harass()
    local unit = GetCurrentTarget()
  local target = GetCurrentTarget()
if target == nil or GetOrigin(target) == nil or IsImmune(target,myHero) or IsDead(target) or not IsVisible(target) or GetTeam(target) == GetTeam(myHero) then return false end
if ValidTarget(target, 1000) then
  if NasusMenu.Harass.W:Value() then
    if CanUseSpell(myHero, _W) == READY and IsInDistance(target, 600) then --and IsObjectAlive(target) 
      CastTargetSpell(target, _W)
    end
  end  
  if NasusMenu.Harass.E:Value() then           
    local EPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),1700,250,650,70,true,false)
    if CanUseSpell(myHero, _E) == READY  and IsInDistance(target, 650) then --and IsObjectAlive(target)
      CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
    end
  end  
  if NasusMenu.Harass.Q:Value() then
    if CanUseSpell(myHero, _Q) == READY  and IsInDistance(target, 300) then --and IsObjectAlive(target)
      CastSpell(_Q)
    end  
  end
  if NasusMenu.Combo.R:Value() then
    if CanUseSpell(myHero, _R) == READY and IsObjectAlive(target) and (GetCurrentHP(myHero)/GetMaxHP(myHero)) < (NasusMenu.Harass.RHP:Value()/100) then
      CastSpell(_R)
    end  
  end
end
end

OnDraw(function(myHero)
    for _,unit in pairs(GetEnemyHeroes()) do    
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GetItemSlot(myHero,3078) then
        sheendmg2 = sheendmg2 + 1
      end
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end        
  local Qdmg = 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack
	if ValidTarget(unit,20000) and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) then
		DrawDmgOverHpBar(unit,GetCurrentHP(unit) + GetMagicShield(unit) + GetDmgShield(unit),0,CalcDamage(myHero, unit, Qdmg, lichbane),0xffffffff)	
  end
  end  
end)

function LastHit(minion)
 for _,minion in pairs(minionManager.objects) do
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end  
  local minionpos = GetOrigin(minion)
    if ValidTarget(minion, GetRange(myHero)+100) and CalcDamage(myHero, minion, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > GetCurrentHP(minion) and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) then
        CastSpell(_Q) DelayAction(function() AttackUnit(minion) end, 100)
    end
  end
end

OnTick(function()
  if not (IOW:Mode() == "Combo" or IOW:Mode() == "Harass") and NasusMenu.Stacks.AQ:Value() then 
------AutoLastHit------
 for _,minion in pairs(minionManager.objects) do
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end   
  local minionpos = GetOrigin(minion)
    if ValidTarget(minion, NasusMenu.Stacks.AQR:Value()) and CalcDamage(myHero, minion, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > GetCurrentHP(minion) and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) and GotBuff(myHero,"recall") == 0 then
        CastSpell(_Q) DelayAction(function() AttackUnit(minion) end, 100)
    end
  end
end
end)

function AutoJungleClear(jminion)
 for _,jminion in pairs(minionManager.objects) do
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end   
  local minionpos = GetOrigin(jminion)
    if ValidTarget(jminion, NasusMenu.Stacks.AQR:Value()) and CalcDamage(myHero, jminion, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > GetCurrentHP(jminion) and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) then
        CastSpell(_Q) DelayAction(function() AttackUnit(jminion) end, 100)
    end
  end
end

function JungleClear(jminion)
 for _,jminion in pairs(minionManager.objects) do
  if GetTeam(minion) == 400 then
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end   
  local minionpos = GetOrigin(jminion)
    if ValidTarget(jminion, GetRange(myHero)+100) and CalcDamage(myHero, jminion, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > GetCurrentHP(jminion) and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) then
        CastSpell(_Q) DelayAction(function() AttackUnit(jminion) end, 100)
    end
  end
  end
end

function Killsteal()
    local target = GetCurrentTarget()
  if target == nil or GetOrigin(target) == nil or IsImmune(target,myHero) or IsDead(target) or not IsVisible(target) or GetTeam(target) == GetTeam(myHero) then return false end
	for i,enemy in pairs(GetEnemyHeroes()) do
	local enemyhp = GetCurrentHP(enemy) + GetHPRegen(enemy) + GetMagicShield(enemy) + GetDmgShield(enemy)
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0   
    local Edmg = (15 + 40*GetCastLevel(myHero,_E) + 0.6*GetBonusDmg(myHero))
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end   
      if NasusMenu.KS.Q:Value() and ValidTarget(enemy, GetRange(myHero)+50) and CalcDamage(myHero, enemy, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > enemyhp and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) and IsInDistance(enemy, GetRange(myHero)+50) and GetDistance(myHero, enemy) <= (GetRange(myHero)+50) and GetDistance(myHero, enemy) >= 10 and IsInDistance(target, GetRange(myHero)+50) then
        CastSpell(_Q) DelayAction(function() AttackUnit(enemy) end, 100)
      end
      local EPred = GetPredictionForPlayer(GetOrigin(myHero),enemy,GetMoveSpeed(enemy),1700,250,650,70,true,false)
      if NasusMenu.KS.E:Value() and ValidTarget(enemy, 650) and CalcDamage(myHero, enemy, 0, Edmg) > enemyhp and (CanUseSpell(myHero, _E) == READY) and IsInDistance(enemy, 650) then
      CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
      end
    if NasusMenu.KS.WEQ:Value() and ValidTarget(enemy, 500) and CalcDamage(myHero, enemy, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane + Edmg) > enemyhp and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) and CanUseSpell(myHero, _W) == READY and IsInDistance(enemy, GetRange(myHero)+50) and GetDistance(myHero, enemy) <= 500 and GetDistance(myHero, enemy) >= 10 and IsInDistance(target, 500) and IsObjectAlive(enemy) then
        CastTargetSpell(enemy, _W) DelayAction(function() CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z) DelayAction(function() CastSpell(_Q) DelayAction(function() AttackUnit(enemy) end, 100) end, 200) end, 300)
    end
    if NasusMenu.KS.WQ:Value() and ValidTarget(enemy, 500) and CalcDamage(myHero, enemy, 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack, lichbane) > enemyhp and (CanUseSpell(myHero, _Q) == READY or GotBuff(myHero,"NasusQ") == 1) and CanUseSpell(myHero, _W) == READY and IsInDistance(enemy, GetRange(myHero)+50) and GetDistance(myHero, enemy) <= 500 and GetDistance(myHero, enemy) >= 10 and IsInDistance(target, 500) then
        CastTargetSpell(enemy, _W) DelayAction(function() CastSpell(_Q) DelayAction(function() AttackUnit(enemy) end, 100) end, 200)
    end    
  end
end    

function QAA()
	for i,unit in pairs(GetEnemyHeroes()) do
    local sheendmg = 0
    local sheendmg2 = 1
    local frozendmg = 0
    local lichbane = 0  
      if GetItemSlot(myHero,3078) > 0 then
        sheendmg2 = sheendmg2 + 1
      end    
      if GotBuff(myHero, "sheen") >= 1 then
        sheendmg = sheendmg + GetBaseDamage(myHero)*sheendmg2
      end 
      if GotBuff(myHero, "itemfrozenfist") >= 1 and GetItemSlot(myHero,3025) > 0 then
        frozendmg = frozendmg + GetBaseDamage(myHero)*1.25
      end 
      if GotBuff(myHero, "lichbane") >= 1 and GetItemSlot(myHero,3100) > 0 then
        lichbane = lichbane + GetBaseDamage(myHero)*0.75 + GetBonusAP(myHero)*0.5
      end         
		local unitPos = GetOrigin(unit)
		local dmgQ = 10 + 20*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) + GetBaseDamage(myHero) + sheendmg + frozendmg + QStack
		local dmg = CalcDamage(myHero, unit, dmgQ, lichbane)
		local hp = GetCurrentHP(unit) + GetMagicShield(unit) + GetDmgShield(unit)
		local hPos = GetHPBarPos(unit)
    	local drawPos = WorldToScreen(1,unitPos.x,unitPos.y,unitPos.z)
        if dmg > 0 then 
          DrawText(math.ceil(hp/dmg).." QAA", 15, hPos.x, hPos.y+20, 0xffffffff)
	 	end 	
end
end
