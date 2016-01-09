if GetObjectName(GetMyHero()) ~= then return end

require('Inspired')

menu = Menu("Urgot", "Ugly Urgot")
menu:SubMenu("Combo", "Combo")
menu:SubMenu("Items", "Items")
menu:SubMenu("Interrupt", "Interrupt")

menu.Combo:Boolean("CQ", "Use Q", true)
menu.Combo:Boolean("CW", "Use W", true)
menu.Combo:Boolean("CE", "Use E", true)

menu.Items:Boolean("Cutless", "Bilgewater Cutlass", true)
menu.Items:Boolean("botrk", "Blade of the Ruined King", true)

menu.Interrupt:Menu("SupportedSpells", "Supported Spells")
menu.Interrupt.SupportedSpells:Boolean("R", "Use R", true)

local extraRange = 0
local collision = false

CHANELLING_SPELLS = {
    ["CaitlynAceintheHole"]         = {Name = "Caitlyn",      Spellslot = _R},
    ["Crowstorm"]                   = {Name = "FiddleSticks", Spellslot = _R},
    ["GalioIdolOfDurand"]           = {Name = "Galio",        Spellslot = _R},
    ["ReapTheWhirlwind"]            = {Name = "Janna",        Spellslot = _R},
    ["KarthusFallenOne"]            = {Name = "Karthus",      Spellslot = _R},
    ["KatarinaR"]                   = {Name = "Katarina",     Spellslot = _R},
    ["LucianR"]                     = {Name = "Lucian",       Spellslot = _R},
    ["AlZaharNetherGrasp"]          = {Name = "Malzahar",     Spellslot = _R},
    ["MissFortuneBulletTime"]       = {Name = "MissFortune",  Spellslot = _R},
    ["AbsoluteZero"]                = {Name = "Nunu",         Spellslot = _R},                        
    ["PantheonRJump"]               = {Name = "Pantheon",     Spellslot = _R},
    ["PantheonRFall"]               = {Name = "Pantheon",     Spellslot = _R},
    ["ShenStandUnited"]             = {Name = "Shen",         Spellslot = _R},
    ["Destiny"]                     = {Name = "TwistedFate",  Spellslot = _R},
    ["UrgotSwap2"]                  = {Name = "Urgot",        Spellslot = _R},
    ["VelkozR"]                     = {Name = "Velkoz",       Spellslot = _R},
    ["InfiniteDuress"]              = {Name = "Warwick",      Spellslot = _R},
    ["XerathLocusOfPower2"]         = {Name = "Xerath",       Spellslot = _R}   
}

DelayAction(function()
	local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
  	for i, spell in pairs(CHANELLING_SPELLS) do
    	for _,k in pairs(GetEnemyHeroes()) do
        	if spell["Name"] == GetObjectName(k) then
        		menu.Interrupt:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        	end
    	end
  	end
end

OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) then
      	if CHANELLING_SPELLS[spell.name] then
        	if ValidTarget(unit, 600) and IsReady(_R) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and menu.Interrupt[GetObjectName(unit).."Inter"]:Value() and menu.Interrupt.SupportedSpells.R:Value() then
        		CastTargetSpell(unit,_R)
        	end
      	end
    end
end

local target1 = TargetSelector(GetCastRange(myHero, _E),TARGET_LESS_CAST_PRIORITY,DAMAGE_PHYSICAL,true,false)

OnTick(function(myHero)
	local target = target1:GetTarget()
	local QPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),1800,250,1000+extraRange,80,collision,true)
	local EPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),0,875,1100,250,false,true)

------CHECK Q RANGE
	if GotBuff(target, "urgotcorrosivedebuff") >= 1 then
		extraRange = 200
		collision = false
	else
		extraRange = 0
		collision = true
	end
------CHECK Q RANGE END------

------COMBO------
	if IOW:Mode() == "Combo" then
		if IsReady(_Q) and QPred.HitChance == 1 and ValidTarget(target, 1000+extraRange) and menu.Combo.CQ:Value()then
			CastSkillShot(_Q, QPred.PredPos.x, QPred.PredPos.y, QPred.PredPos.z)
		end

		if IsReady(_W) and ValidTarget(target, 750) and menu.Combo.CW:Value() then
			CastSpell(_W)
		end

		if IsReady(_E) and EPred.HitChance == 1 and ValidTarget(target, GetCastRange(myHero,_E)-50) and menu.Combo.CE:Value() then
			CastSkillShot(_E, EPred.PredPos.x, EPred.PredPos.y, EPred.PredPos.z)
		end
	
------COMBO END------

------USE ITEMS------
	local Cutless = GetItemSlot(myHero,3144)
	local botrk = GetItemSlot(myHero,3153)

		if Cutless >= 1 and GoS:ValidTarget(target, 550) and Urgot.Items.Cutless:Value() and (GetCurrentHP(myHero)/GetMaxHP(myHero))*100 <= Urgot.Items.CHP:Value() then
			CastTargetSpell(target, GetItemSlot(myHero,3144))
		elseif botrk >= 1 and GoS:ValidTarget(target,550) and Urgot.Items.botrk:Value() and (GetCurrentHP(myHero)/GetMaxHP(myHero))*100 <= Urgot.Items.botrkHP:Value() then
			CastTargetSpell(target, GetItemSlot(myHero,3153))
		end
------USE ITEMS END------	
	end
end)
