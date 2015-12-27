if GetObjectName(GetMyHero()) ~= "Urgot" then return end

require('Inspired')

local Urgot = Menu("Urgot", "Ugly Urgot")
Urgot:SubMenu("Combo", "Combo")

Urgot.Combo:Boolean("CQ", "Use Q", true)
Urgot.Combo:Boolean("CW", "Use W", true)
Urgot.Combo:Boolean("CE", "Use E", true)

local Qrange = GetCastRange(myHero, _Q)
local Erange = GetCastRange(myHero, _E)
local Rrange = GetCastRange(myHero, _R)
local target = GetCurrentTarget()

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
		CastSkillShot(_E,EPred.PredPos)
	end
end

local function Combo(unit)
	if IOW:Mode() == "Combo" then
			local unit = GetCurrentTarget()

		if Urgot.Combo.CQ:Value() and IsReady(_Q) and ValidTarget(unit, Qrange+extraRange) then
			CastQ(unit)
		end

		if Urgot.Combo.CW:Value() and IsReady(_W) and ValidTarget(unit, 900) then
			CastSpell(_W)
		end

		if Urgot.Combo.CE:Value() and IsReady(_E) and ValidTarget(unit, Erange) then
			CastE(unit)
		end
	end
end

OnTick(function(myHero)
	if IsObjectAlive(myHero) then
		local unit = GetCurrentTarget()
		Combo(unit)
	end
end)
