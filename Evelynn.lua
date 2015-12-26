if GetObjectName(GetMyHero()) ~= "Evelynn" then return end

require('Inspired')

Evelynn = Menu("Evelynn", "Evelynn")
Evelynn:SubMenu("Combo", "Combo")
Evelynn:SubMenu("AutoQ", "AutoQ")
Evelynn:SubMenu("LaneClear", "LaneClear")
Evelynn:SubMenu("JungleClear", "JungleClear")

Evelynn.Combo:Boolean("CQ", "Use Q", true)
Evelynn.Combo:Boolean("CW", "Use W", true)
Evelynn.Combo:Boolean("CE", "Use E", true)
Evelynn.Combo:Boolean("CR", "Use R", true)
Evelynn.Combo:Slider("ECR", "Use R at min enemies", 3, 1, 5, 1)

Evelynn.LaneClear:Boolean("LCQ", "Use Q", true)
Evelynn.LaneClear:Boolean("LCE", "Use E", true)
Evelynn.LaneClear:Slider("MLC", "LaneClear if mana% is >", 30, 0, 100, 5)

Evelynn.JungleClear:Boolean("JCQ", "Use Q", true)
Evelynn.JungleClear:Boolean("JCE", "Use E", true)
Evelynn.JungleClear:Slider("MJC", "JungleClear if mana% is >", 30, 0, 100, 5)

local QRange = GetCastRange(myHero, _Q)
local ERange = GetCastRange(myHero, _E)
local RRange = GetCastRange(myHero, _R)

local function CastR(unit)
	local Rpred = GetPredictionForPlayer(GetOrigin(myHero), unit, GetMoveSpeed(unit), 1300, 250, 650, 350, false, true)
	if Rpred.HitChance == 1 then
		CastSkillShot(_R,Rpred.PredPos.x,Rpred.PredPos.y,Rpred.PredPos.z)
	end
end

local function Combo(unit)
	if IOW:Mode() == "Combo" then
		local unit = GetCurrentTarget()

		if Evelynn.Combo.CQ:Value() and IsReady(_Q) and ValidTarget(unit, QRange) then
			CastSpell(_Q)
		end

		if Evelynn.Combo.CW:Value() and IsReady(_W) and ValidTarget(unit, 700) then
			CastSpell(_W)
		end

		if Evelynn.Combo.CE:Value() and IsReady(_E) and ValidTarget(unit, ERange) then
			CastTargetSpell(unit, _E)
		end

		if Evelynn.Combo.CR:Value() and EnemiesAround(GetOrigin(myHero), RRange) >= Evelynn.Combo.ECR:Value() and IsReady(_R) and ValidTarget(unit, RRange) then
			CastR(unit)
		end
	end
end

local function JungleClear(jminion)
	if IOW:Mode() == "LaneClear" and GetPercentMP(myHero) >= Evelynn.JungleClear.MJC:Value() then
		for _,jminion in pairs(minionManager.objects) do

			if IsReady(_Q) and Evelynn.JungleClear.JCQ:Value() and ValidTarget(jminion, QRange) then
				CastSpell(_Q)
			end

			if IsReady(_E) and Evelynn.JungleClear.JCE:Value() and ValidTarget(jminion, ERange) then
				CastSpell(_E)
			end
		end
	end
end

local function LaneClear(minion)
 	if IOW:Mode() == "LaneClear" and GetPercentMP(myHero) >= Evelynn.LaneClear.MLC:Value() then
		for i=1,IOW.mobs.maxObjects do 
		 local minion = IOW.mobs.objects[i]

		 	if IsReady(_Q) and Evelynn.LaneClear.LCQ:Value() and ValidTarget(minion, QRange) then
		 		CastSpell(_Q)
			end
			
			if IsReady(_E) and Evelynn.LaneClear.LCE:Value() and ValidTarget(minion, ERange) then
				CastTargetSpell(minion, _E)
			end
		end
	end
end

OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		Combo(unit)
		LaneClear(minion)
		JungleClear(jminion)
	end
end)
