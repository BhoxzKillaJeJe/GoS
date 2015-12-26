if GetObjectName(GetMyHero()) ~= "Urgot" then return end

require('Inspired')

local Urgot = Menu("Urgot", "Ugly Urgot")
Urgot:SubMenu("Combo", "Combo")
Urgot:SubMenu("Items", "Use Items")
Urgot:SubMenu("Misc", "Misc")
--Urgot:SubMenu("Drawings", "Drawings")

Urgot.Combo:Boolean("CQ", "Use Q", true)
Urgot.Combo:Boolean("CW", "Use W", true)
Urgot.Combo:Boolean("CE", "Use E", true)

Urgot.Items:Boolean("Cutless", "Bilgewater Cutlass", true)
Urgot.Items:Boolean("botrk", "Blade of the Ruined King", true)
Urgot.Items:Boolean("Murumana", "Murumana", true)

Urgot.Misc:Boolean("Interrupter", "Interrupt w/ R", true)

--Urgot.Drawings:Boolean("DQ", "Draw Q", true)
--Urgot.Drawings:Boolean("DW", "Draw W", true)
--Urgot.Drawings:Boolean("DE", "Draw E", true)
--Urgot.Drawings:Boolean("DR", "Draw R", true)

local Qrange = GetCastRange(myHero, _Q)
local Erange = GetCastRange(myHero, _E)
local Rrange = GetCastRange(myHero, _R)
local target = GetCurrentTarget()
local unit = GetCurrentTarget()

CHANELLING_SPELLS = {
    ["CaitlynAceintheHole"]         = {Name = "Caitlyn",      Spellslot = _R},
    ["Crowstorm"]                   = {Name = "FiddleSticks", Spellslot = _R},
    ["Drain"]                       = {Name = "FiddleSticks", Spellslot = _W},
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
    ["VarusQ"]                      = {Name = "Varus",        Spellslot = _Q},
    ["VelkozR"]                     = {Name = "Velkoz",       Spellslot = _R},
    ["InfiniteDuress"]              = {Name = "Warwick",      Spellslot = _R},
    ["XerathLocusOfPower2"]         = {Name = "Xerath",       Spellslot = _R}
    
}

local callback = nil

OnProcessSpell(function(unit, spell)
	if not callback or not unit or GetObjectType(unit) ~= Obj_AI_Hero or GetTeam(unit) == GetTeam(GetMyHero()) then return end
	local unitChanellingSpells = CHANELLING_SPELLS[GetObjectName(unit)]

	if unitChanellingSpells then 
		for _, spellSlot in pairs(unitChanellingSpells) do
            if spell.name == GetCastName(unit, spellSlot) then 
            	callback(unit, CHANELLING_SPELLS) 
            end
        end
	end
end)

function addInterrupterCallback(callback0)	
	callback = callback0
end

--Check for Q Range
local extraRange=0
local collision=false
if GotBuff(target, "urgotcorrosivedebuff") >= 1 then
	extraRange = 200
	collision = false
else
	extraRange = 0
	collision = true
end


local function CastQ(unit)
	local QPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),1800,250,Qrange+extraRange,80,collision,true)
	if QPred.HitChance == 1 then
		CastSkillShot(_Q, QPred.PredPos)
	end
end

local function CastE(unit)
	local EPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),0,875,1100,250,false,true)
	if EPred.HitChance == 1 then 
		CastSkillShot(_E, EPred.PredPos.x, EPred.PredPos.y, EPred.PredPos.z)
	end
end

local function Combo(unit)
	if IOW:Mode() == "Combo" then

		if Urgot.Combo.CQ:Value() and IsReady(_Q) and ValidTarget(target, Qrange) then
			CastQ(unit)
		end

		if Urgot.Combo.CW:Value() and IsReady(_W) and ValidTarget(target, 900) then
			CastSpell(_W)
		end

		if Urgot.Combo.CE:Value() and IsReady(_E) and ValidTarget(target, Erange) then
			CastE(unit)
		end

		addInterrupterCallback(function(target, spellType)
			if Urgot.Misc.Interrupter:Value() and IsReady(_R) and ValidTarget(target, Rrange) and spellType(CHANELLING_SPELLS) then
				CastSpell(_R)
			end
		end)
	end
end

local function UseItems(unit)
	local Muramana = GetItemSlot(myHero,3042)
	local Cutless = GetItemSlot(myHero,3144)
	local botrk = GetItemSlot(myHero,3153)

	if IOW:Mode() == "Combo" then

		if Cutless >= 1 and ValidTarget(target, 550) and Urgot.Items.Cutless:Value() then
			CastTargetSpell(target, GetItemSlot(myHero,3144))

		elseif botrk >= 1 and ValidTarget(target,550) and Urgot.Items.botrk:Value() then
			CastTargetSpell(target, GetItemSlot(myHero,3153))
		end

		if ValidTarget(target,Qrange) and Muramana >= 1 and GotBuff(myHero,"Muramana") == 0 then
			CastSpell(GetItemSlot(myHero,3042))
		elseif GotBuff(myHero,"Muramana") == 1 and not ValidTarget(target, 1500) then
			CastSpell(GetItemSlot(myHero,3042))
		end
	end
end

OnTick(function(myHero)
	if not IsDead(myHero) then
		Combo(unit)
		UseItems(unit)
	end
end)
