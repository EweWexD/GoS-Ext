--╔═══╗╔══╗╔═╗╔═╗╔═══╗╔╗   ╔═══╗     ╔═══╗╔═══╗╔╗ ╔╗╔═══╗
--║╔═╗║╚╣─╝║║╚╝║║║╔═╗║║║   ║╔══╝     ║╔═╗║║╔═╗║║║ ║║║╔══╝
--║╚══╗ ║║ ║╔╗╔╗║║╚═╝║║║   ║╚══╗     ║║ ║║║╚══╗║╚═╝║║╚══╗
--╚══╗║ ║║ ║║║║║║║╔══╝║║ ╔╗║╔══╝     ║╚═╝║╚══╗║║╔═╗║║╔══╝
--║╚═╝║╔╣─╗║║║║║║║║   ║╚═╝║║╚══╗     ║╔═╗║║╚═╝║║║ ║║║╚══╗
--╚═══╝╚══╝╚╝╚╝╚╝╚╝   ╚═══╝╚═══╝     ╚╝ ╚╝╚═══╝╚╝ ╚╝╚═══╝
--
--
--
--
--
--
-- V1.0 Alpha released to GoS Ext


class "Ashe"

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
--else
	--PrintChat("TPred.lua missing!")
end

castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function CastSpell(spell, pos, range, delay)
	range = range or math.huge
	delay = delay or 250
	ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end, Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function Ashe:Menu()
	self.AsheMenu = MenuElement({type = MENU, id = "Ashe", name = "[Simple] Ashe"})
	-- [[ Combo ]]
	self.AsheMenu:MenuElement({id = "Combo", name = "Combo Settings", type = MENU})
	self.AsheMenu.Combo:MenuElement({id = "UseQ", name = "Use Q?", value = false})
	self.AsheMenu.Combo:MenuElement({id = "UseW", name = "Use W?", value = false})
	self.AsheMenu.Combo:MenuElement({id = "UseR", name = "Use R?", value = false})

	-- [[ Harass ]]
	self.AsheMenu:MenuElement({id = "Harass", name = "Harass Settings", type = MENU})
	self.AsheMenu.Harass:MenuElement({id = "UseW", name = "Use W?", value = true})
	self.AsheMenu.Harass:MenuElement({id = "ManaUse", name = "Min Mana", value = 40, min = 0, max = 100, step = 5})

	-- [[ Ks ]]
	self.AsheMenu:MenuElement({id = "KS", name = "KillSteal Settings", type = MENU})
	self.AsheMenu.KS:MenuElement({id = "UseW", name = "Use W?", value = true})
	self.AsheMenu.KS:MenuElement({id = "UseR", name = "Use R?", value = true})
	self.AsheMenu.KS:MenuElement({id = "Dist", name = "Distance for R ks", value = 2000, min = 100, max = 8000, step = 100})

	-- [[ Farm ]]
	self.AsheMenu:MenuElement({id = "Farm", name = "LaneClear Settings", type = MENU})
	self.AsheMenu.Farm:MenuElement({id = "UseQ", name = "Use Q?", value = true})
	self.AsheMenu.Farm:MenuElement({id = "UseW", name = "Use W?", value = false})
	self.AsheMenu.Farm:MenuElement({id = "ManaUse", name = "Min Mana", value = 40, max = 100, min = 0, step = 5})

	-- [[ Draw ]]
	self.AsheMenu:MenuElement({id = "Draw", name = "Draw Settings", type = MENU})
	self.AsheMenu.Draw:MenuElement({id = "DrawW", name = "Draw W range?", value = true})
end

-- [[ Spells ]]
function Ashe:Spells()
	AsheW = {speed = 1500, range = 1200, delay = 0.25, width = 20, collision = true, aoe = true, type = "line"}
	AsheR = {speed = 1600, range = 25000, delay = 0.25, width = 130, collision = false, aoe = false, type = "line"}
end

-- [[ Mode ]]
function Mode()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "Clear"
		end
	elseif _G.gsoSDK then
		return _G.gsoSDK.Orbwalker:GetMode()
	else
		return GOS.GetMode()
	end
end

-- [[ Valid Target (Noddy) ]]
function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

-- [[ Vector (Noddy) ]]
function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end

-- [[ Linear Pos (Noddy) ]]
function GetBestLinearFarmPos(range, width)
	local BestPos = nil
	local MostHit = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and not m.dead then
			local EndPos = myHero.pos + (m.pos - myHero.pos):Normalized() * range
			local Count = MinionsOnLine(myHero.pos, EndPos, width, 300-myHero.team)
			if Count > MostHit then
				MostHit = Count
				BestPos = m.pos
			end
		end
	end
	return BestPos, MostHit
end

-- [[ Minions (Noddy) ]]
function MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead and GetDistance(pos, m.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

function MinionsOnLine(startpos, endpos, width, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead then
			local w = width + m.boundingRadius
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startpos, endpos, m.pos)
			if isOnSegment and GetDistanceSqr(pointSegment, m.pos) < w^2 and GetDistanceSqr(startpos, endpos) > GetDistanceSqr(startpos, m.pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

-- [[ Mana (Noddy) ]]
function GetPercentMana(unit)
	return 100*unit.mana/unit.maxMana
end

-- [[ Tick ]]
function Ashe:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	self:KS()
	if Mode() == "Combo" then 
		self:Combo()
	elseif Mode() == "Harass" then 
		self:Harass()
	elseif Mode() == "Clear" then
		self:Farm()
	end
end

-- [[ Init ]]
function Ashe:__init()
	self:Menu()
	self:Spells()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

-- [[ EnemyHeroes (Noddy) ]]
function GetEnemyHeroes(range)
	local range = range or math.huge
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy and GetDistance(Hero.pos) <= range then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

-- [[ Target (Noddy) ]]
function GetTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.gsoSDK then
		return _G.gsoSDK.TargetSelector:GetTarget(GetEnemyHeroes(5000), false)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

-- [[ Ready (Noddy) ]]
function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

-- [[ Hp (Noddy) ]]
function GetPercentHP(unit)
	return 100*unit.health/unit.maxHealth
end

-- [[ GetDistanceSQR (Noddy) ]]
function GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local dx = Pos1.x - Pos2.x
	local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return dx^2 + dz^2
end

-- [[ GetDistance (Noddy) ]]
function GetDistance(Pos1, Pos2)
	return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

-- [[ Buff (Noddy) ]]
function GotBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff.count
		end
	end
	return 0
end

-- [[ Ashe W ]]
function Ashe:UseW(target)
	local castpos,HitChance, pos = TPred:GetBestCastPosition(target, AsheW.delay, AsheW.width, AsheW.range, AsheW.speed, myHero.pos, AsheW.collision, AsheW.type)
		Control.CastSpell(HK_W, castpos)
	end



-- [[ Ashe R ]]
function Ashe:UseR(target)
	local castpos,HitChance, pos = TPred:GetBestCastPosition(target, AsheR.delay, AsheR.width, AsheR.range, AsheR.speed, myHero.pos, AsheR.collision, AsheR.type)
		local RCastPos = myHero.pos-(myHero.pos-castpos):Normalized()*300
		CastSpell(HK_R, RCastPos, 300, AsheR.delay*1000)
	end


-- [[ Coombo ]]
function Ashe:Combo()
	if target == nil then return end
	-- [[ Use Q ]]
	if self.AsheMenu.Combo.UseQ:Value() then 
		if IsReady(_Q) then 
			if ValidTarget(target, myHero.range+100) then 
				if GotBuff(myHero, "asheqcastready") == 4 then 
					Control.CastSpell(HK_Q)
				end
			end
		end
	end
	-- [[ Use W ]]
	if self.AsheMenu.Combo.UseW:Value() then 
		if IsReady(_W) and myHero.attackData.state ~= STATE_WINDUP then 
			if ValidTarget(target, AsheW.range) then 
				self:UseW(target) 
			end
		end
	end
	-- [[ Use R ]]
	if self.AsheMenu.Combo.UseR:Value() then 
		if IsReady(_R) then 
			if ValidTarget(target , self.AsheMenu.Combo.Dist:Value()) then 
				self.UseR(traget)
			end
		end
	end
end

-- [[ KS ]]
function Ashe:KS()
	 -- [[ Use R ]]
	for i,enemy in pairs(GetEnemyHeroes(8000)) do
		if IsReady(_R) then 
			if self.AsheMenu.KS.UseR:Value() then
				if ValidTarget(enemy, self.AsheMenu.KS.Dist:Value()) then 
					local AsheRDmg = CalcMagicalDamage(myHero, enemy, (({200, 400, 600})[myHero:GetSpellData(_R).level] + myHero.ap))
					if (enemy.health + enemy.hpRegen * 6 ) < AsheRDmg then 
						self:UseR(enemy)
					end
				end
			end
			--  [[ Use W ]]
		elseif IsReady(_W) then 
			if self.AsheMenu.KS.UseW:Value() then
				local AsheWDmg = CalcPhysicalDamage(myHero, enemy, (({20, 35, 50, 65, 80})[myHero:GetSpellData(_W).level] + myHero.totalDamage)) 
				if (enemy.health + enemy.hpRegen * 4) < AsheWDmg then 
					self:UseW(enemy)
				end
			end
		end
	end
end

-- [[ Harass ]]
function Ashe:Harass()
	if target ==  nil then return end 
	-- [[ Use W ]]
	if self.AsheMenu.Harass.UseW:Value() then 
		if GetPercentMana(myHero) > self.AsheMenu.Harass.ManaUse:Value() then 
			if IsReady(_W) and myHero.attackData.state ~= STATE.WINDUP then 
				if ValidTarget(target, AsheW.range) then 
					self:UseW(target)
				end
			end
		end
	end
end

-- [[ Farm ]]
function Ashe:Farm()
	if self.AsheMenu.Farm.UseQ:Value() then 
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.isEnemy then
				if ValidTarget(minion, myHero.range) then 
					if GotBuff(myHero, "asheqcastready") == 4 then 
						Control.CastSpell(HK_Q)
					end
				end
			end
		end
	end
	if self.AsheMenu.Farm.UseW:Value() then 
		if GetPercentMana(myHero) > self.AsheMenu.Farm.ManaUse:Value() then 
			if IsReady(_W) then 
				local BestPos, BestHit = GetBestLinearFarmPos(AsheW.range, AsheW.width*9)
				if BestPos and BestHit >= 3 then 
					Control.SetCursorPos(BestPos)
					Control.CastSpell(HK_W, BestPos)
				end
			end
		end
	end
end

-- [[ Draw ]]
function Ashe:Draw()
	if myHero.dead then return end
	if self.AsheMenu.Draw.DrawW:Value() then Draw.Circle(myHero.pos, AsheW.range, 1, Draw.Color(0, 160, 239, 255))
end
end


-- [[ Load ]]
function OnLoad()
	Ashe() 
end
PrintChat("Welcome To Simple Ashe Alpha V1")
PrintChat("Made by EweEwe")