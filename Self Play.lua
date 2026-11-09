local selfPlay = {}

local catalog = require("self_play.catalog")
local planner = require("self_play.planner")
local combat = require("self_play.combat")
local shop = require("self_play.shop")
local lastHit = require("self_play.last_hit")
local consumables = require("self_play.consumables")
local objectives = require("self_play.objectives")
local positioning = require("self_play.positioning")
local intent = require("self_play.intent")
local laneRules = require("self_play.lane_rules")
local recovery = require("self_play.recovery")
local runes = require("self_play.runes")
local heroModules = require("self_play.heroes.registry")
local towerSafety = require("self_play.tower_safety")
local navigation = require("self_play.navigation")
local engagement = require("self_play.engagement")
local teamplay = require("self_play.teamplay")
local helpRotation = require("self_play.help_rotation")
local supportPolicy = require("self_play.support_policy")
local fights = require("self_play.fights")
local awareness = require("self_play.awareness")
local neutralItems = require("self_play.neutral_items")
local jungle = require("self_play.jungle")
local baseDefense = require("self_play.base_defense")
local teleports = require("self_play.teleports")
local deward = require("self_play.deward")
local detection = require("self_play.detection")
local supportCamps = require("self_play.support_camps")
local unitControl = require("self_play.units")
local camera = require("self_play.camera")
local matchmaking = require("self_play.matchmaking")
local draft = require("self_play.draft")
local localization = require("self_play.localization")
local taskPolicy = require("self_play.task_policy")
local mapFarm = require("self_play.map_farm")
local fightSim = require("self_play.fight_sim")
local waveGroups = require("self_play.waves")
local strategy = require("self_play.strategy")
local decide = require("self_play.decide")
local travel = require("self_play.travel")
local laneChoice = require("self_play.lane_choice")
local initiate = require("self_play.initiate")
local winModel = require("self_play.win_model")
local hud = require("self_play.hud")
local coordination = require("self_play.coordination")

local cfg = {
	buy = true, online = true, level = true, spells = true, block = true, pull = true, stack = true, sell = true, simulate = true,
	wards = true, units = true, objectives = true, manaReserve = 22, aggression = 50, mode = 0,
	blockLater = true, blockRanged = true, teleport = true, buyback = true, dodge = true, runes = true, fights = true, dispelItems = true,
	tick = 0.033, scanInterval = 0.15, moveInterval = 0.12, manualPause = 4,
	laneEnd = 600, blockEnd = 45, memoryLifetime = 6,
	home = {[2] = Vector(-7200, -6600, 256), [3] = Vector(7100, 6500, 256)},
	anchors = {
		[2] = {Vector(-5800, 1400, 128), Vector(-850, -700, 128), Vector(1700, -5900, 128)},
		[3] = {Vector(-1600, 5800, 128), Vector(600, 560, 128), Vector(5800, -1600, 128)},
	},
	lanes = {"top", "mid", "bot"},
}

local modes = {full = 0, lane = 1, block = 2, stack = 3, pull = 4}

local presets = {
	{aggression = 25, manaReserve = 30, retreat = 55, resume = 75},
	{aggression = 50, manaReserve = 22, retreat = 50, resume = 68},
	{aggression = 80, manaReserve = 12, retreat = 40, resume = 60},
}

local ui, renderContext
do
	localization.init()
	local text = localization.text
	local tab = localization.group(Menu.Create("Scripts", "Self Play", "Main"))
	local page = tab:Create(text("Bot"))
	local general = page:Create("Control", Enum.GroupSide.Left)
	ui = {
		enabled = general:Switch("Enabled", false),
		pause = general:Bind("Pause while held", Enum.ButtonCode.KEY_SPACE),
		mode = general:Combo("Bot mode", {"Full game", "Lane farming only", "Creep block only", "Stack jungle camps", "Pull lane wave"}, 0),
		role = general:Combo("Role", {"Auto", "1 Carry", "2 Mid", "3 Offlane", "4 Soft support", "5 Hard support"}, 0),
		lane = general:Combo("Lane", {"Auto", "Top", "Mid", "Bottom"}, 0),
		control = general:Combo("Heroes to control", {"My hero", "My hero + departed allies", "Departed allies only"}, 0),
	}
	local style = page:Create("Preset", Enum.GroupSide.Right)
	ui.preset = style:Combo("Preset", {"Careful", "Optimal", "Aggressive", "Custom"}, 1)
	localization.bind(ui.preset, "Preset", {"Careful", "Optimal", "Aggressive", "Custom"}, "Preset tooltip")
	ui.custom = page:Create("Custom preset", Enum.GroupSide.Right)
	ui.aggression = ui.custom:Slider("How eagerly to fight", 0, 100, 50, "%d%%")
	ui.manaReserve = ui.custom:Slider("Mana to keep for fights", 0, 60, 22, "%d%%")
	ui.retreat = ui.custom:Slider("Leave to heal below", 20, 80, 50, "%d%%")
	ui.resume = ui.custom:Slider("Come back at", 40, 100, 68, "%d%%")
	local display = page:Create("Display", Enum.GroupSide.Right)
	ui.draw = display:Switch("Show status", true)
	ui.winGraph = display:Switch("Show win chance graph", true)
	ui.markers = display:Switch("Show movement markers", true)
	ui.camera = display:Switch("Follow hero camera", false)
	ui.debug = display:Switch("Write decision diagnostics", false)
	local automation = tab:Create(text("Queue and draft"))
	ui.matchmaking = matchmaking.create(automation:Create("Matchmaking", Enum.GroupSide.Left))
	ui.draft = draft.create(automation:Create("Hero selection", Enum.GroupSide.Right))
	local behaviors = tab:Create(text("Behaviors"))
	ui.behaviors = {}
	for _, section in ipairs({
		{"Combat and control", Enum.GroupSide.Left, {
			{"spells", "Abilities, active items and consumables"},
			{"fights", "Join allied fights"},
			{"simulate", "Predict fight outcomes"},
			{"dispelItems", "Use BKB and Manta in fights"},
			{"dodge", "Dodge projectiles with movement"},
			{"units", "Control summoned units"},
			{"level", "Learn abilities and talents"},
		}},
		{"Lane and support", Enum.GroupSide.Right, {
			{"block", "Creep blocking"},
			{"blockLater", "Block later waves"},
			{"blockRanged", "Include ranged creeps when blocking"},
			{"stack", "Stack jungle camps"},
			{"pull", "Pull lane wave into camps"},
			{"wards", "Warding and dewarding"},
			{"runes", "Take runes"},
			{"objectives", "Collect lotus and wisdom"},
		}},
		{"Economy and travel", Enum.GroupSide.Left, {
			{"buy", "Buy items and manage courier"},
			{"online", "Draft Helper builds and skill orders"},
			{"sell", "Sell and disassemble items by build"},
			{"teleport", "Use hero TP scrolls"},
			{"buyback", "Use buyback"},
		}},
	}) do
		local group = behaviors:Create(section[1], section[2])
		for _, entry in ipairs(section[3]) do
			local key = entry[1]
			ui.behaviors[key] = group:Switch(entry[2], cfg[key])
			localization.bind(ui.behaviors[key], entry[2], nil, entry[2] .. " tooltip")
			cfg[key] = ui.behaviors[key]:Get()
		end
	end
	local function showCustom() ui.custom:Visible(ui.preset:Get() == 3) end
	ui.preset:SetCallback(showCustom)
	showCustom()
	renderContext = {font = Render.LoadFont("Tahoma", Enum.FontCreate.FONTFLAG_ANTIALIAS, 500)}
end

local state = {ctx = nil, allies = {}, nextRoster = 0}
local helpers, core = {}, {}

function helpers.settings()
	local preset = presets[ui.preset:Get() + 1]
	if preset then
		cfg.aggression, cfg.manaReserve = preset.aggression, preset.manaReserve
		cfg.retreatHealth, cfg.resumeHealth = preset.retreat / 100, preset.resume / 100
	else
		cfg.aggression, cfg.manaReserve = ui.aggression:Get(), ui.manaReserve:Get()
		cfg.retreatHealth = ui.retreat:Get() / 100
		cfg.resumeHealth = math.max(cfg.retreatHealth + 0.1, ui.resume:Get() / 100)
	end
	if cfg.mode ~= ui.mode:Get() then
		cfg.mode = ui.mode:Get()
		for _, ctx in ipairs(helpers.contexts()) do
			ctx.campTask, ctx.blockState, ctx.teamTask, ctx.fightSession, ctx.intent = nil, nil, nil, nil, nil
			ctx.mapFarm, ctx.jungleState, ctx.runeTask, ctx.riverTask = nil, nil, nil, nil
		end
	end
	for key, control in pairs(ui.behaviors) do
		local enabled = control:Get()
		if cfg[key] ~= enabled then
			cfg[key] = enabled
			for _, ctx in ipairs(not enabled and helpers.contexts() or {}) do
				if key == "block" or key == "blockLater" and ctx.blockState and ctx.blockState.later then ctx.blockState = nil end
				if key == "pull" then ctx.campTask = nil end
				if key == "wards" then ctx.wardTask, ctx.dewardTask = nil, nil end
				if key == "objectives" then ctx.objectiveTask = nil end
				if key == "spells" then ctx.aimTask, ctx.spellFinish = nil, nil end
			end
		end
	end
end

function helpers.distance(a, b)
	local x, y = a.x - b.x, a.y - b.y
	return math.sqrt(x * x + y * y)
end

function helpers.toward(a, b, distance)
	local length = helpers.distance(a, b)
	if length < 1 then return a end
	local fraction = math.min(1, distance / length)
	return Vector(a.x + (b.x - a.x) * fraction, a.y + (b.y - a.y) * fraction, a.z + (b.z - a.z) * fraction)
end

function helpers.valid(unit)
	return unit and Entity.IsEntity(unit) and Entity.IsAlive(unit) and not Entity.IsDormant(unit)
end

function helpers.visible(unit)
	return helpers.valid(unit) and NPC.IsVisible(unit)
end

function helpers.reset()
	if state.ctx then state.ctx.active = false end
	state.ctx = nil
	for _, ctx in pairs(state.allies) do ctx.active = false end
	state.allies = {}
	coordination.set({})
end

function helpers.contexts()
	local list = {}
	if state.ctx then list[#list + 1] = state.ctx end
	local keys = {}
	for key in pairs(state.allies) do keys[#keys + 1] = key end
	table.sort(keys)
	for _, key in ipairs(keys) do list[#list + 1] = state.allies[key] end
	return list
end

function helpers.departed(localHero)
	local assigned = {}
	for _, player in ipairs(Players.GetAll()) do
		local hero = Player.GetAssignedHero and Player.GetAssignedHero(player)
		if hero and Entity.IsEntity(hero) then assigned[Entity.GetIndex(hero)] = true end
	end
	local result, seen = {}, {}
	for _, hero in ipairs(Heroes.GetAll()) do
		local id = Entity.IsEntity(hero) and Hero.GetPlayerID(hero)
		if hero ~= localHero and id and id >= 0 and not seen[id]
			and not assigned[Entity.GetIndex(hero)] and Entity.IsSameTeam(hero, localHero)
			and not NPC.IsIllusion(hero) and not NPC.IsMeepoClone(hero) and Hero.GetReplicatingOtherHeroModel(hero) == nil then
			seen[id] = true
			result[#result + 1] = hero
		end
	end
	return result
end

function helpers.allyRole(hero, team)
	local taken = {}
	for _, ctx in ipairs(helpers.contexts()) do if ctx.hero ~= hero then taken[ctx.role] = true end end
	local scores = planner.roleScores(catalog.heroes[NPC.GetUnitName(hero)])
	local best, bestScore
	for role = 1, 5 do
		local score = (scores[role] or 0) - (taken[role] and 1000 or 0)
		if not bestScore or score > bestScore then best, bestScore = role, score end
	end
	return best or 5
end

function helpers.role(hero, team)
	if ui.draft.enabled:Get() then
		local pickedRole = draft.role(ui.role:Get())
		if pickedRole then return pickedRole end
	end
	if ui.role:Get() > 0 then return ui.role:Get() end
	local entries = {}
	for _, ally in ipairs(Heroes.GetAll()) do
		if Entity.GetTeamNum(ally) == team and not NPC.IsIllusion(ally) and not NPC.IsMeepoClone(ally) then
			entries[#entries + 1] = {id = Entity.GetIndex(ally), scores = planner.roleScores(catalog.heroes[NPC.GetUnitName(ally)])}
			if #entries == 5 then break end
		end
	end
	return planner.assignRoles(entries)[Entity.GetIndex(hero)] or 5
end

function helpers.lane(role, team, ally)
	if not ally and ui.lane:Get() > 0 then return ui.lane:Get() end
	if role == 2 then return 2 end
	local safe = team == 2 and 3 or 1
	return (role == 1 or role == 5) and safe or 4 - safe
end

function helpers.init(hero, player, ally)
	local team = Entity.GetTeamNum(hero)
	if team ~= 2 and team ~= 3 then return nil end
	local role = ally and helpers.allyRole(hero, team) or helpers.role(hero, team)
	local settings = cfg
	if ally then settings = setmetatable({buy = false, sell = false, buyback = false, mode = 0}, {__index = cfg}) end
	local ctx = {
		hero = hero, heroName = NPC.GetUnitName(hero), player = player, playerId = Player.GetPlayerID(player),
		ally = ally == true, ownerId = Hero.GetPlayerID(hero),
		team = team, role = role, lane = helpers.lane(role, team, ally), active = true,
		ui = ui, settings = settings, catalog = catalog, planner = planner, home = cfg.home[team], enemyHome = cfg.home[5 - team],
		now = GameRules.GetGameTime(), clock = 0, nextTick = 0, nextScan = 0, nextMove = 0,
		busyUntil = 0, attackNext = 0, nextLevel = 0, pauseUntil = 0, nextUnits = 0, nextWard = 0,
		mode = "Starting", lastAbility = "", history = {}, memory = {}, projectiles = {}, hazards = {}, abilityAttempts = {},
		allies = {}, enemies = {}, creeps = {}, neutrals = {}, towers = {}, structures = {}, summons = {},
		campAttempts = {}, roleSetting = ui.role:Get(), laneSetting = ui.lane:Get(),
		distance = helpers.distance, toward = helpers.toward,
	}
	ctx.position = Entity.GetAbsOrigin(hero)
	ctx.clock = GameRules.GetGameStartTime() > 0 and ctx.now - GameRules.GetGameStartTime() or -1
	ctx.unsafePosition = function(position) return helpers.unsafePosition(ctx, position) end
	ctx.predict = function(unit, delay) return helpers.predict(ctx, unit, delay) end
	ctx.move = function(position, mode, tolerance) return helpers.move(ctx, position, mode, false, tolerance) end
	ctx.stop = function() return helpers.stop(ctx) end
	ctx.attack = function(target, mode) return helpers.attack(ctx, target, mode) end
	ctx.pushSafe = function(target) return helpers.pushSafe(ctx, target) end
	ctx.teleport = function(position, purpose) return core.teleport(ctx, position, purpose) end
	ctx.fightAbilities = function() return heroModules.update(ctx, combat, false) or combat.run(ctx, false) end
	ctx.clearAbilities = function(units, defending) return combat.farm(ctx, units, defending) end
	lastHit.init(ctx)
	heroModules.attach(ctx)
	shop.init(ctx)
	return ctx
end

function helpers.predict(ctx, unit, delay)
	if NPC.IsCreep(unit) or NPC.IsLaneCreep(unit) then return Entity.GetAbsOrigin(unit) end
	local record = ctx.history[Entity.GetIndex(unit)]
	local position = Entity.GetAbsOrigin(unit)
	if not record or not NPC.IsRunning(unit) then return position end
	local x, y = helpers.displacement(record, delay)
	for _, share in ipairs({1, 0.75, 0.5, 0.25}) do
		local point = Vector(position.x + x * share, position.y + y * share, position.z)
		if share == 0.25 or not GridNav or GridNav.IsTraversable(point) then return point end
	end
	return position
end

function helpers.smoothVelocity(record, old, dt)
	local alpha = math.min(1, dt / 0.35)
	record.svx = (old.svx or 0) + (record.vx - (old.svx or 0)) * alpha
	record.svy = (old.svy or 0) + (record.vy - (old.svy or 0)) * alpha
	local speed = math.sqrt(record.vx * record.vx + record.vy * record.vy)
	local smooth = math.sqrt(record.svx * record.svx + record.svy * record.svy)
	if speed > 60 and smooth > 60 and (record.vx * record.svx + record.vy * record.svy) / (speed * smooth) > 0.85 then
		record.steady = (old.steady or 0) + dt
	else
		record.steady = 0
	end
	return record
end

function helpers.displacement(record, delay)
	local near = math.min(delay, 0.4)
	local x, y = record.vx * near, record.vy * near
	if delay > 0.4 then
		local tau = math.max(0.35, math.min(1.6, 0.35 + (record.steady or 0)))
		local extra = tau * (1 - math.exp(-(delay - 0.4) / tau))
		x, y = x + (record.svx or record.vx) * extra, y + (record.svy or record.vy) * extra
	end
	return x, y
end

function helpers.scan(ctx)
	ctx.allies, ctx.enemies, ctx.creeps, ctx.neutrals, ctx.summons = {}, {}, {}, {}, {}
	ctx.towers, ctx.structures = {}, {}
	ctx.waves, ctx.mapObjectives = {{}, {}, {}}, {}
	ctx.worldNPCs = NPCs.GetAll()
	for _, unit in ipairs(ctx.worldNPCs) do
		if helpers.valid(unit) and not NPC.IsWaitingToSpawn(unit) then
			local same = Entity.IsSameTeam(ctx.hero, unit)
			local visible = same or NPC.IsVisible(unit)
			local position = Entity.GetAbsOrigin(unit)
			if same and NPC.GetUnitName(unit) == "dota_fountain" then ctx.home, ctx.fountain = position, unit end
			local distance = helpers.distance(ctx.position, position)
			local name = NPC.GetUnitName(unit)
			if name == "npc_dota_lotus_pool" or name == "npc_dota_xp_fountain" then
				ctx.mapObjectives[#ctx.mapObjectives + 1] = unit
			end
			if same and NPC.IsLaneCreep(unit) then
				local lane = math.abs(position.x - position.y) < 2000 and 2 or position.y > position.x and 1 or 3
				ctx.waves[lane][#ctx.waves[lane] + 1] = unit
			end
			if NPC.IsTower(unit) and visible then ctx.towers[#ctx.towers + 1] = unit end
			if NPC.IsStructure(unit) and visible then ctx.structures[#ctx.structures + 1] = unit end
			if NPC.IsHero(unit) and not NPC.IsIllusion(unit) and not NPC.IsMeepoClone(unit) and visible then
				local list = same and ctx.allies or ctx.enemies
				list[#list + 1] = unit
			elseif visible and distance < 2400 then
				if NPC.IsLaneCreep(unit) then ctx.creeps[#ctx.creeps + 1] = unit
				elseif NPC.IsNeutral(unit) and NPC.IsCreep(unit) and not NPC.IsRoshan(unit) and not NPC.IsTormentor(unit) then
					ctx.neutrals[#ctx.neutrals + 1] = unit
				end
			end
			if unitControl.eligible(ctx, unit) then ctx.summons[#ctx.summons + 1] = unit end
		end
	end
	local grouped = waveGroups.allied(ctx)
	if grouped then ctx.waves = grouped end
	local heroes = Heroes.GetAll()
	awareness.observe(ctx, heroes)
	detection.observe(ctx, heroes)
	ctx.nextScan = ctx.now + cfg.scanInterval
end

function helpers.sample(ctx)
	for _, list in ipairs({ctx.creeps, ctx.enemies, ctx.allies}) do
		for _, unit in ipairs(list) do
			if helpers.visible(unit) then
				local id, position, health = Entity.GetIndex(unit), Entity.GetAbsOrigin(unit), Entity.GetHealth(unit)
				local old = ctx.history[id]
				local record = {time = ctx.now, health = health, position = position, rate = 0, vx = 0, vy = 0, svx = 0, svy = 0, steady = 0}
				if old and ctx.now > old.time then
					local dt = ctx.now - old.time
					local rate = math.max(0, (old.health - health) / dt)
					record.rate = old.rate * 0.65 + rate * 0.35
					if helpers.distance(position, old.position) < NPC.GetMoveSpeed(unit) * dt * 1.4 then
						record.vx, record.vy = (position.x - old.position.x) / dt, (position.y - old.position.y) / dt
					end
					helpers.smoothVelocity(record, old, dt)
				end
				ctx.history[id] = record
			end
		end
	end
	for id, entry in pairs(ctx.history) do if ctx.now - entry.time > 3 then ctx.history[id] = nil end end
	for id, entry in pairs(ctx.memory) do if ctx.now - entry.time > cfg.memoryLifetime then ctx.memory[id] = nil end end
	for handle, entry in pairs(ctx.projectiles) do if entry.impact < ctx.now then ctx.projectiles[handle] = nil end end
	for handle, entry in pairs(ctx.hazards) do if entry.expires < ctx.now then ctx.hazards[handle] = nil end end
	for name, expiry in pairs(ctx.abilityAttempts) do if expiry < ctx.now then ctx.abilityAttempts[name] = nil end end
end

function helpers.unsafePosition(ctx, position)
	for _, tower in ipairs(ctx.towers) do
		if helpers.valid(tower) and not Entity.IsSameTeam(ctx.hero, tower) then
			local towerPosition, range = Entity.GetAbsOrigin(tower), NPC.GetAttackRange(tower)
			if helpers.distance(position, towerPosition) < range + 160 then
				if not towerSafety.position(ctx, tower, position) then return true end
			end
		end
	end
	return false
end

function helpers.threat(ctx)
	teleports.update(ctx)
	local allies, enemies, nearest, nearestDistance = 0, 0, nil, math.huge
	for _, ally in ipairs(ctx.allies) do
		if helpers.valid(ally) and helpers.distance(ctx.position, Entity.GetAbsOrigin(ally)) < 1100 then allies = allies + 1 end
	end
	for _, enemy in ipairs(ctx.enemies) do
		if helpers.visible(enemy) then
			local distance = helpers.distance(ctx.position, Entity.GetAbsOrigin(enemy))
			if distance < 1400 then enemies = enemies + 1 end
			if distance < nearestDistance then nearest, nearestDistance = enemy, distance end
		end
	end
	local health = Entity.GetHealth(ctx.hero) / math.max(1, Entity.GetMaxHealth(ctx.hero))
	local projectileDamage = 0
	for _, entry in pairs(ctx.projectiles) do
		if entry.target == ctx.hero and entry.impact > ctx.now and entry.impact < ctx.now + 1.5 then projectileDamage = projectileDamage + entry.damage end
	end
	local barriers = NPC.GetBarriers(ctx.hero)
	if barriers then projectileDamage = math.max(0, projectileDamage - barriers.all.current) end
	local towerAggro = false
	for _, tower in ipairs(ctx.towers) do
		if helpers.valid(tower) and not Entity.IsSameTeam(ctx.hero, tower) and Tower.GetAttackTarget(tower) == ctx.hero then towerAggro = true end
	end
	local remembered = 0
	for _, entry in pairs(ctx.memory) do
		if ctx.now - entry.time > cfg.scanInterval + 0.1 and ctx.now - entry.time < 4
			and helpers.distance(ctx.position, entry.position) < 1000 then remembered = remembered + 0.5 end
	end
	local losing = enemies + remembered + ctx.incomingEnemies > allies and nearestDistance < 900
	local hurt = Hero.GetRecentDamage(ctx.hero) > Entity.GetMaxHealth(ctx.hero) * 0.18
	ctx.nearEnemies, ctx.nearAllies = enemies + ctx.incomingEnemies, allies
	ctx.health = health
	awareness.update(ctx)
	fights.plan(ctx)
	local counterattack = baseDefense.prepare(ctx)
	local committed = intent.target(ctx)
	local attacker = ctx.laneThreat.attacked and ctx.laneThreat.enemy
	ctx.target = counterattack and counterattack.target or ctx.fightSession and helpers.visible(ctx.fightSession.target) and ctx.fightSession.target or committed and NPC.IsHero(committed) and committed or helpers.visible(attacker) and attacker or nearestDistance < 1100 and nearest or nil
	local teleportDanger = false
	for _, arrival in ipairs(ctx.teleportArrivals) do
		if arrival.remaining < 2.5 and helpers.distance(ctx.position, arrival.position) < 950
			and enemies + ctx.incomingEnemies > allies then teleportDanger = true; break end
	end
	local immediateFinish = committed and NPC.IsHero(committed) and health > 0.55
		and Entity.GetHealth(committed) <= NPC.GetTrueDamage(ctx.hero) * NPC.GetArmorDamageMultiplier(committed)
		and helpers.distance(ctx.position, Entity.GetAbsOrigin(committed)) < NPC.GetAttackRange(ctx.hero) + NPC.GetAttackRangeBonus(ctx.hero) + 60
	ctx.spellFinish = ctx.settings.spells and ctx.heroModule and ctx.heroModule.finish and ctx.heroModule.finish(ctx, combat) or nil
	ctx.combatDecision = engagement.assess(ctx, ctx.target)
	local wavering = committed and NPC.IsHero(committed) and helpers.visible(committed) and not engagement.keep(ctx.combatDecision)
		and not counterattack and not ctx.spellFinish and not (ctx.fightSession and ctx.fightSession.target == committed)
	if not wavering then ctx.releasePending = nil
	elseif not ctx.releasePending or ctx.releasePending.target ~= committed then ctx.releasePending = {target = committed, since = ctx.now} end
	local danger = ctx.health < 0.35 or ctx.laneThreat and (ctx.laneThreat.lethal or ctx.laneThreat.ambush)
		or not ctx.combatDecision or ctx.combatDecision.remaining < Entity.GetMaxHealth(ctx.hero) * 0.15
	if wavering and (danger or ctx.now - ctx.releasePending.since >= 0.6) then
		ctx.releasePending = nil
		ctx.combatRelease = {time = ctx.now, target = committed, reason = ctx.combatDecision and string.format("Fight reassessed: kill=%.2f incoming=%.0f remaining=%.0f", ctx.combatDecision.killTime, ctx.combatDecision.incoming, ctx.combatDecision.remaining) or "Target outside safe attack position or pursuit reach"}
		ctx.intent = nil
	end
	local fightSafe = ctx.fightSession and ctx.fightSession.distance < 1400
		and awareness.damage(ctx, ctx.position, 0.75) + awareness.forecast(ctx, ctx.position) * 0.2 + projectileDamage < Entity.GetHealth(ctx.hero) * 0.4
	local canFinish = (ctx.combatDecision and ctx.combatDecision.safe or fightSafe or ctx.spellFinish ~= nil) and not towerAggro
		and (not teleportDanger and not ctx.laneThreat.ambush or fightSafe or ctx.spellFinish ~= nil)
	local localFight = nil
	if (enemies > 0 or ctx.incomingEnemies > 0) and nearestDistance < 1600 then
		localFight = fightSim.evaluate(ctx, ctx.position, {radius = 1600, target = ctx.target})
	end
	ctx.localFight = localFight
	local engaged = ctx.laneThreat.attacked or teleportDanger or ctx.laneThreat.ambush
		or ctx.laneThreat.exposed and helpers.visible(ctx.laneThreat.enemy) and NPC.IsAttacking(ctx.laneThreat.enemy)
	local winningFight = localFight and localFight.favorable and localFight.targetDead
		and (not localFight.selfDead or (localFight.selfDeathTime or 0) > (localFight.targetDeathTime or math.huge) + 1.5)
	local doomed = localFight and localFight.selfDead and (localFight.selfDeathTime or math.huge) < 4.5 and engaged and not winningFight
	if localFight and localFight.selfDead and not engaged and not winningFight then
		ctx.disengage = ctx.disengage or {zones = {}}
		for _, enemy in ipairs(ctx.enemies) do
			if helpers.visible(enemy) and helpers.distance(ctx.position, Entity.GetAbsOrigin(enemy)) < 1600 then
				ctx.disengage.zones[Entity.GetIndex(enemy)] = {source = enemy, position = Entity.GetAbsOrigin(enemy),
					radius = NPC.GetAttackRange(enemy) + NPC.GetAttackRangeBonus(enemy) + 350, expires = ctx.now + 1.5}
			end
		end
	end
	local danger = towerAggro or projectileDamage > Entity.GetHealth(ctx.hero) * 0.4
		or not canFinish and (health < 0.55 and hurt and ctx.laneThreat.attacked or ctx.laneThreat.lethal)
		or (teleportDanger or ctx.laneThreat.ambush) and not immediateFinish and not fightSafe and not ctx.spellFinish
		or doomed and not immediateFinish and not ctx.spellFinish
	losing = losing and (ctx.laneThreat.incoming > Entity.GetHealth(ctx.hero) * 0.2 or health < 0.55)
	if doomed and not canFinish then losing = true end
	if winningFight or localFight and localFight.favorable and not localFight.selfDead and (localFight.selfFraction or 0) > 0.3 then losing = false end
	if canFinish then losing = false end
	if ctx.spellFinish and not danger then ctx.recoveryTask, ctx.retreating, ctx.hardRetreat = nil, false, false end
	if counterattack then
		ctx.recoveryTask, ctx.disengage, ctx.retreatUntil = nil, nil, nil
		ctx.retreating, ctx.hardRetreat, ctx.recovering = false, false, false
		intent.begin(ctx, counterattack.target, "hero", false)
	else
		ctx.baseCounterattack = nil
		recovery.update(ctx, danger, losing)
	end
	if canFinish and ctx.target and not ctx.retreating and not ctx.intent and (ctx.laneThreat.attacked or ctx.combatDecision and ctx.combatDecision.killTime < 2.5) then
		intent.begin(ctx, ctx.target, "hero", false)
		ctx.intent.opportunity = 110
	end
	ctx.health = health
end

function helpers.stop(ctx)
	if ctx.lastOrder == "hold" then return true end
	Player.HoldPosition(ctx.player, ctx.hero, false, false, true)
	ctx.lastOrder, ctx.attackTarget = "hold", nil
	return true
end

function helpers.move(ctx, position, mode, allowTower, tolerance)
	ctx.mode = mode
	if NPC.IsChannellingAbility(ctx.hero) or ctx.now < ctx.busyUntil then return true end
	if ctx.now < ctx.nextMove or NPC.HasState(ctx.hero, Enum.ModifierState.MODIFIER_STATE_ROOTED) then return true end
	local requestedGoal = position
	if not allowTower then
		local requested = position
		position = navigation.goal(ctx, requested)
		if not position then ctx.mode = mode .. ": no safe route"; return helpers.stop(ctx) end
		if helpers.distance(position, requested) > 90 then ctx.mode = "Wait at safe edge: " .. mode end
		if not ctx.retreating and not ctx.intent and not ctx.runeTask and not ctx.aggroTask and not (ctx.teamTask and ctx.teamTask.fighting) then
			local clipped
			position, clipped = awareness.moveGoal(ctx, position)
			if clipped then ctx.mode = "Keep lane access outside enemy threat" end
		end
	end
	local remaining = helpers.distance(ctx.position, position)
	if remaining < (tolerance or 60) then return helpers.stop(ctx) end
	if not allowTower and remaining < 140 and helpers.distance(position, requestedGoal) > 90
		and not ctx.retreating and not ctx.hardRetreat and not helpers.unsafePosition(ctx, ctx.position) then
		ctx.mode = "Wait at safe edge: " .. mode
		return helpers.stop(ctx)
	end
	local goal = Vector(position.x, position.y, World.GetGroundZ(position.x, position.y))
	local progressed = ctx.lastOrder ~= "move" or not ctx.moveGoal or helpers.distance(ctx.moveGoal, goal) > 120
		or not ctx.stuckPosition or helpers.distance(ctx.position, ctx.stuckPosition) >= 80
	if progressed then ctx.stuckPosition, ctx.stuckTime, ctx.stuckAttempts = ctx.position, ctx.now, 0 end
	if ctx.moveGoal and ctx.lastOrder == "move" and NPC.IsRunning(ctx.hero) and ctx.now - ctx.stuckTime < 2 then
		local length = helpers.distance(ctx.position, goal)
		local previous = helpers.distance(ctx.position, ctx.moveGoal)
		local precision = math.max(40, math.min(250, length * 0.2))
		if helpers.distance(ctx.moveGoal, goal) < precision then return true end
		local ax, ay = goal.x - ctx.position.x, goal.y - ctx.position.y
		local bx, by = ctx.moveGoal.x - ctx.position.x, ctx.moveGoal.y - ctx.position.y
		local aligned = (ax * bx + ay * by) / math.max(1, length * previous) > 0.98
		if aligned and previous > 150 and math.abs(length - previous) < math.max(120, length * 0.35)
			and ctx.now - (ctx.moveOrderAt or 0) < 1 then return true end
	end
	position = goal
	if not GridNav.IsTraversable(position) then
		local found
		for radius = 100, 600, 100 do
			for angle = 0, 7 do
				local theta = angle * math.pi / 4
				local x, y = position.x + math.cos(theta) * radius, position.y + math.sin(theta) * radius
				local candidate = Vector(x, y, World.GetGroundZ(x, y))
				if GridNav.IsTraversable(candidate) and (allowTower or not helpers.unsafePosition(ctx, candidate)) then found = candidate; break end
			end
			if found then break end
		end
		if not found then return false end
		position = found
	end

	if ctx.now - ctx.stuckTime > 2 then
		local path = GridNav.BuildPath(ctx.position, position, navigation.treeWalking(ctx))
		ctx.stuckAttempts = (ctx.stuckAttempts or 0) + 1
		if #path > 0 then
			for _, waypoint in ipairs(path) do
				if helpers.distance(ctx.position, waypoint) > 250 then position = waypoint; break end
			end
		else
			local detour = navigation.escape(ctx, navigation.coverAnchor(ctx))
			if not detour then ctx.mode = mode .. ": path obstructed"; return helpers.stop(ctx) end
			position = detour
		end
		ctx.stuckPosition, ctx.stuckTime = ctx.position, ctx.now
		ctx.mode = mode .. " (rerouting)"
	end
	if not allowTower then
		position = navigation.goal(ctx, position)
		if not position or helpers.distance(ctx.position, position) < 30 then return helpers.stop(ctx) end
	end
	NPC.MoveTo(ctx.hero, position, false, false, false, true)
	ctx.attackTarget = nil
	ctx.moveGoal, ctx.lastOrder, ctx.nextMove, ctx.moveOrderAt = goal, "move", ctx.now + cfg.moveInterval, ctx.now
	return true
end

function helpers.attackDelay(ctx, target)
	return lastHit.timing(ctx, target)
end

function helpers.attack(ctx, target, mode, allowTower)
	if not helpers.visible(target) or NPC.HasState(ctx.hero, Enum.ModifierState.MODIFIER_STATE_DISARMED)
		or NPC.IsWaitingToSpawn(target) or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_OUT_OF_GAME)
		or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_UNTARGETABLE)
		or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_ATTACK_IMMUNE)
		or NPC.HasState(target, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end
	if NPC.IsLaneCreep(target) and Entity.IsSameTeam(ctx.hero, target)
		and not laneRules.denyable(ctx.clock, Entity.GetHealth(target), Entity.GetMaxHealth(target),
			NPC.GetModifierProperty(target, Enum.ModifierFunction.MODIFIER_PROPERTY_CREEP_DENY_PERCENT)) then return false end
	local targetPosition = Entity.GetAbsOrigin(target)
	local attackRange = NPC.GetAttackRange(ctx.hero) + NPC.GetAttackRangeBonus(ctx.hero)
	local firingPosition = NPC.IsStructure(target) and engagement.attackPosition(ctx, target) or helpers.distance(ctx.position, targetPosition) <= attackRange and ctx.position
		or helpers.toward(targetPosition, ctx.position, math.max(50, attackRange - 35))
	if not allowTower and helpers.unsafePosition(ctx, firingPosition) then return false end
	if ctx.hits.blocked[Entity.GetIndex(target)] then return false end
	ctx.mode = mode
	local position = Entity.GetAbsOrigin(target)
	local range = NPC.GetAttackRange(ctx.hero) + NPC.GetAttackRangeBonus(ctx.hero)
	if NPC.IsStructure(target) and not NPC.IsEntityInRange(ctx.hero, target, range) then

		if ctx.attackTarget ~= target or ctx.lastOrder ~= "attack" or ctx.now >= (ctx.structureOrderAt or 0) + 2 then
			Player.AttackTarget(ctx.player, ctx.hero, target, false, false, true, "self_play_structure", false)
			ctx.attackTarget, ctx.lastOrder, ctx.structureOrderAt = target, "attack", ctx.now
		end
		return true, false
	end
	if ctx.now < ctx.attackNext then
		if NPC.IsHero(target) and ctx.attackTarget == target and ctx.lastOrder == "attack" and NPC.IsAttacking(ctx.hero) then return true, false end
		if NPC.IsHero(target) and not NPC.IsEntityInRange(ctx.hero, target, range) then
			return helpers.move(ctx, helpers.toward(ctx.predict(target, 0.2), ctx.position, math.max(50, range - 50)), mode, allowTower, 20), false
		end
		if ctx.lastOrder ~= "attack" then helpers.stop(ctx) end
		return true, false
	end
	if not NPC.IsEntityInRange(ctx.hero, target, range) then
		if NPC.IsHero(target) and ctx.attackTarget == target and ctx.lastOrder == "attack" and NPC.IsAttacking(ctx.hero)
			and helpers.distance(ctx.position, position) <= range + NPC.GetHullRadius(target) then return true, false end
		return helpers.move(ctx, helpers.toward(position, ctx.position, math.max(50, range - 65)), mode, allowTower, 15), false
	end
	if ctx.attackTarget == target and ctx.lastOrder == "attack" and NPC.IsAttacking(ctx.hero) then return true, false end
	local _, windup = helpers.attackDelay(ctx, target)
	if not windup then return false end
	Player.AttackTarget(ctx.player, ctx.hero, target, false, false, true, "self_play_attack", false)
	if NPC.IsHero(target) then ctx.nextAggro = ctx.now + 3.1 end
	lastHit.ordered(ctx, target, windup)
	ctx.busyUntil, ctx.attackNext = ctx.now + windup + 0.04, ctx.now + NPC.GetSecondsPerAttack(ctx.hero, false)
	ctx.lastOrder, ctx.attackTarget, ctx.mode = "attack", target, mode
	return true, true
end

function helpers.pushSafe(ctx, structure)
	if not helpers.visible(structure) or Entity.IsSameTeam(structure, ctx.hero) or ctx.nearEnemies > ctx.nearAllies
		or ctx.health < 0.60 or NPC.HasState(structure, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE)
		or NPC.HasState(structure, Enum.ModifierState.MODIFIER_STATE_ATTACK_IMMUNE)
		or helpers.unsafePosition(ctx, engagement.attackPosition(ctx, structure)) then return false end
	local cover = 0
	for _, wave in ipairs(ctx.waves) do
		for _, creep in ipairs(wave) do
			if helpers.visible(creep) and helpers.distance(Entity.GetAbsOrigin(creep), Entity.GetAbsOrigin(structure)) < 800 then cover = cover + 1 end
		end
	end
	return NPC.IsTower(structure) and towerSafety.position(ctx, structure, engagement.attackPosition(ctx, structure))
		or not NPC.IsTower(structure) and (cover >= 2 or towerSafety.attackers(ctx, structure) > 0)
end

function core.push(ctx)
	for _, structure in ipairs(ctx.structures) do
		if helpers.distance(ctx.position, Entity.GetAbsOrigin(structure)) < 1200 and helpers.pushSafe(ctx, structure) then
			intent.begin(ctx, structure, "structure", false)
			if intent.run(ctx) then return true end
		end
	end
	return false
end

function helpers.lanePath(ctx)
	return waveGroups.path(ctx, ctx.lane)
end

function helpers.laneAnchor(ctx)
	local best, score = nil, math.huge
	for _, creep in ipairs(ctx.waves[ctx.lane]) do
		if helpers.valid(creep) then
			local position = Entity.GetAbsOrigin(creep)
			local distance = helpers.distance(position, ctx.enemyHome)
			if distance < score then best, score = position, distance end
		end
	end
	for _, group in pairs(LaneGroupsManager.visible_ally) do
		if group.lane == ctx.lane then
			for _, creep in pairs(group.creeps) do
				if helpers.visible(creep.ref) then
					local position = Entity.GetAbsOrigin(creep.ref)
					local distance = helpers.distance(position, ctx.enemyHome)
					if distance < score then best, score = position, distance end
				end
			end
		end
	end
	local regroup = navigation.regroup(ctx, best, cfg.anchors[ctx.team][ctx.lane])
	if regroup then return regroup end
	if best then
		if ctx.clock > 35 then
			local previous = ctx.waveLane == ctx.lane and ctx.waveAnchor
			if previous and ctx.now - ctx.waveSeen < 35 and not helpers.unsafePosition(ctx, previous)
				and helpers.distance(best, ctx.home) < helpers.distance(previous, ctx.home) - 350 then return previous end
			if not previous and helpers.distance(best, ctx.home) < helpers.distance(ctx.position, ctx.home) - 500 then
				return helpers.distance(ctx.position, cfg.anchors[ctx.team][ctx.lane]) < 2200 and ctx.position or cfg.anchors[ctx.team][ctx.lane]
			end
		end
		ctx.waveSeen, ctx.wavePosition = ctx.now, best
		ctx.waveAnchor, ctx.waveLane = helpers.toward(best, ctx.home, ctx.role >= 4 and 350 or 180), ctx.lane
		return ctx.waveAnchor
	end
	if ctx.waveLane == ctx.lane and ctx.waveSeen and ctx.now - ctx.waveSeen < 35 then return ctx.waveAnchor end
	for _, tower in ipairs(ctx.towers) do
		if Entity.IsSameTeam(tower, ctx.hero) and NPC.GetUnitName(tower):find("tower1_" .. cfg.lanes[ctx.lane], 1, true) then
			return helpers.toward(Entity.GetAbsOrigin(tower), ctx.enemyHome, 400)
		end
	end
	return cfg.anchors[ctx.team][ctx.lane]
end

function core.block(ctx)
	if ctx.role >= 4 and cfg.mode ~= modes.block then return false end
	return positioning.block(ctx, cfg.blockEnd)
end

function core.lastHit(ctx)
	return lastHit.run(ctx)
end

function core.camp(ctx)
	return (cfg.pull or cfg.stack) and supportCamps.run(ctx) or false
end

function core.teleporting(ctx)
	local scroll = NPC.GetItem(ctx.hero, "item_tpscroll", false)
	local task = ctx.teleportOrder
	local active = NPC.HasModifier(ctx.hero, "modifier_teleporting") or scroll and Ability.IsChannelling(scroll)
		or task and task.ability and Entity.IsEntity(task.ability) and Ability.IsChannelling(task.ability)
	if active then
		if not task then task = {started = ctx.now}; ctx.teleportOrder = task end
		task.seen, task.lastActive = true, ctx.now
		ctx.mode = "Teleport: preserve channel until landing"
		return true
	end
	if not task then return false end
	if task.seen and ctx.now - task.lastActive < 0.15
		or not task.seen and ctx.now - task.started < 0.6 + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) then return true end
	ctx.teleportOrder = nil
	return false
end

function core.teleport(ctx, destination, purpose)
	return travel.teleport(ctx, destination, purpose)
end

function core.dodge(ctx)
	if ctx.settings.dodge == false then return false end
	for _, hazard in pairs(ctx.hazards) do
		local dt = ctx.now - hazard.created
		local x = hazard.origin.x + hazard.velocity.x * dt
		local y = hazard.origin.y + hazard.velocity.y * dt
		local time, distance = planner.closestApproach(x - ctx.position.x, y - ctx.position.y,
			hazard.velocity.x, hazard.velocity.y, math.min(0.65, hazard.expires - ctx.now))
		if time > 0 and distance < NPC.GetHullRadius(ctx.hero) + 160 then
			local speed = math.sqrt(hazard.velocity.x ^ 2 + hazard.velocity.y ^ 2)
			local best, bestScore = nil, math.huge
			for _, side in ipairs({-1, 1}) do
				local position = Vector(ctx.position.x - hazard.velocity.y / speed * 330 * side,
					ctx.position.y + hazard.velocity.x / speed * 330 * side, ctx.position.z)
				if GridNav.IsTraversable(position) and not helpers.unsafePosition(ctx, position) then
					local score = helpers.distance(position, ctx.home)
					if score < bestScore then best, bestScore = position, score end
				end
			end
			if best then
				ctx.campTask = nil
				return helpers.move(ctx, best, "Dodge linear projectile")
			end
		end
	end
	return false
end

function core.sustain(ctx, combatOnly)
	return consumables.run(ctx, combatOnly) or not combatOnly and neutralItems.use(ctx, combat)
end

function core.fighting(ctx)
	local task = ctx.teamTask
	return ctx.fightSession or task and task.fighting or ctx.intent and ctx.intent.kind == "hero"
end

function core.fight(ctx)
	if core.sustain(ctx, true) or combat.items(ctx, false) then return true end
	if ctx.fightSession and not ctx.helpRotation and fights.run(ctx) then return true end
	local task = ctx.teamTask
	if task and task.fighting and teamplay.run(ctx) then return true end
	return ctx.intent and ctx.intent.kind == "hero" and intent.run(ctx) or false
end

function core.teamObjective(ctx)
	local task = ctx.teamTask
	if not task then return false end
	if core.sustain(ctx) or combat.items(ctx, false) then return true end
	if task.kind == "push" and combat.farm(ctx, ctx.creeps, true) then return true end
	return teamplay.run(ctx)
end

function core.towerDefense(ctx)
	local tower = baseDefense.outer(ctx)
	if not tower or not supportPolicy.midTeleport(ctx, tower.position) then return false end
	ctx.farmCandidate, ctx.aggroTask, ctx.spacingTask, ctx.regroupTask = nil, nil, nil, nil
	if ctx.distance(ctx.position, tower.position) > 1100 then
		return core.teleport(ctx, tower.goal, "defend") or helpers.move(ctx, tower.goal, "Respond to tower siege")
	end
	if combat.farm(ctx, ctx.creeps, true) then return true end
	local target, distance
	for _, creep in ipairs(ctx.creeps) do
		if helpers.visible(creep) and NPC.IsLaneCreep(creep) and not Entity.IsSameTeam(ctx.hero, creep)
			and ctx.distance(Entity.GetAbsOrigin(creep), tower.position) < 1100
			and awareness.farmSafe(ctx, engagement.attackPosition(ctx, creep), 1) then
			local current = ctx.distance(ctx.position, Entity.GetAbsOrigin(creep))
			if not distance or current < distance then target, distance = creep, current end
		end
	end
	return target and ctx.attack(target, "Clear wave threatening allied tower") or false
end

function core.retreat(ctx)
	ctx.intent, ctx.farmCandidate, ctx.campTask, ctx.clearTask, ctx.teamTask = nil, nil, nil, nil, nil
	ctx.runeTask, ctx.riverTask, ctx.aggroTask, ctx.spacingTask, ctx.aimTask = nil, nil, nil, nil, nil
	if ctx.recoveryTask.phase == "escape" then
		ctx.defensiveCast = true
		local defended = heroModules.update(ctx, combat, true) or combat.run(ctx, true)
		ctx.defensiveCast = nil
		if defended then return true end
	end
	if ctx.recoveryTask.phase == "regen" and lastHit.recoveryFarm(ctx) then return true end
	recovery.run(ctx)
	return true
end

function core.active(ctx)
	return not ctx.retreating and not ctx.hardRetreat
end

function core.critical(structure)
	return not helpers.valid(structure) or NPC.IsFort(structure) or Entity.GetHealth(structure) < Entity.GetMaxHealth(structure) * 0.3
end

core.scores = {
	counterattack = function(ctx)
		return ctx.baseDefense and ctx.baseCounterattack and not baseDefense.yields(ctx) and 860 or nil
	end,
	retreat = function(ctx) return ctx.retreating and 850 or nil end,
	defend = function(ctx)
		local task = ctx.baseDefense
		if not task or baseDefense.yields(ctx) then return nil end
		if core.critical(task.structure) then return 780 end
		return 470 + math.min(100, task.heroes * 30 + task.creeps * 5)
	end,
	combo = function(ctx)
		return core.active(ctx) and ctx.heroModule and ctx.heroModule.locked and ctx.heroModule.locked(ctx) and 760 or nil
	end,
	fight = function(ctx)
		if not core.active(ctx) or not core.fighting(ctx) then return nil end
		local session = ctx.fightSession
		if session and session.stage == "engage" then return 640 + math.min(80, #session.members * 20) end
		if session then return 600 + math.min(80, #session.members * 20) end
		return 630
	end,
	objective = function(ctx)
		local task = ctx.teamTask
		return core.active(ctx) and task and (task.kind == "push" or task.kind == "roshan") and 560 or nil
	end,
	tower = function(ctx)
		if not core.active(ctx) then return nil end
		local tower = baseDefense.outer(ctx)
		return tower and supportPolicy.midTeleport(ctx, tower.position) and 550 + math.min(60, tower.attackers * 20 + tower.creeps * 5) or nil
	end,
	strategy = function(ctx)
		return ctx.settings.spells and ctx.heroModule and ctx.heroModule.strategy and 540 or nil
	end,
	mapFarm = function(ctx) return ctx.mapFarm and 530 or nil end,
	escape = function(ctx) return not ctx.hardRetreat and 525 or nil end,
	block = function(ctx) return ctx.role <= 3 and ctx.clock <= cfg.blockEnd and not ctx.laneThreat.avoid and 510 or nil end,
	initiate = function(ctx)
		if ctx.now >= (ctx.nextInitiatePlan or 0) then
			ctx.nextInitiatePlan = ctx.now + 0.25
			ctx.initiatePlan = initiate.plan(ctx, combat)
		end
		return ctx.initiatePlan and 790 or nil
	end,
	ward = function(ctx)
		if ctx.role < 4 or not core.active(ctx) or ctx.recovering or ctx.health < 0.55 or ctx.nearEnemies > 0
			or ctx.now < (ctx.nextWard or 0) or ctx.clock < 30 then return nil end
		local ward = NPC.GetItem(ctx.hero, "item_ward_observer", false) or NPC.GetItem(ctx.hero, "item_ward_dispenser", false)
		return ward and 330 or nil
	end,
	lane = function() return 300 end,
}

core.behaviors = {
	{name = "base counterattack", score = core.scores.counterattack, run = function(ctx) return baseDefense.run(ctx) end, sticky = true},
	{name = "retreat", score = core.scores.retreat, run = function(ctx) return core.retreat(ctx) end},
	{name = "defend base", score = core.scores.defend, run = function(ctx) return baseDefense.run(ctx) end, sticky = true},
	{name = "initiate", score = core.scores.initiate, run = function(ctx)
		local plan = ctx.initiatePlan
		ctx.initiatePlan, ctx.nextInitiatePlan = nil, ctx.now + 0.5
		return initiate.run(ctx, combat, plan)
	end},
	{name = "hero combo", score = core.scores.combo, run = function(ctx) return heroModules.update(ctx, combat, false) end},
	{name = "fight", score = core.scores.fight, run = function(ctx) return core.fight(ctx) end, sticky = true},
	{name = "team objective", score = core.scores.objective, run = function(ctx) return core.teamObjective(ctx) end, sticky = true},
	{name = "tower defense", score = core.scores.tower, run = function(ctx) return core.towerDefense(ctx) end, sticky = true},
	{name = "hero strategy", score = core.scores.strategy, run = function(ctx) return core.strategy(ctx) end},
	{name = "map farm", score = core.scores.mapFarm, run = function(ctx) return mapFarm.run(ctx, true) end, sticky = true},
	{name = "escape", score = core.scores.escape, run = function(ctx) return teamplay.escape(ctx) end},
	{name = "creep block", score = core.scores.block, run = function(ctx) return core.block(ctx) end},
	{name = "ward", score = core.scores.ward, run = function(ctx) return core.ward(ctx) end, sticky = true},
	{name = "lane", score = core.scores.lane, run = function(ctx) return core.lane(ctx) end},
}

function core.strategy(ctx)
	if not ctx.settings.spells or not ctx.heroModule or not ctx.heroModule.strategy or taskPolicy.farmBlocked(ctx) then return false end
	if core.sustain(ctx) or combat.items(ctx, false) then return true end
	return ctx.heroModule.strategy(ctx, combat)
end

function core.ward(ctx)
	local roaming = ctx.role >= 4 and ctx.clock >= cfg.laneEnd
	return objectives.ward(ctx, roaming and ctx.position or helpers.laneAnchor(ctx))
end

function core.units(ctx)
	if not cfg.units or ctx.now < ctx.nextUnits then return end
	ctx.nextUnits = ctx.now + 0.1
	for _, unit in ipairs(ctx.summons) do
		if helpers.valid(unit) and unitControl.eligible(ctx, unit) and not NPC.HasModifier(unit, "modifier_teleporting")
			and not NPC.IsChannellingAbility(unit) and not heroModules.unit(ctx, combat, unit) then unitControl.run(ctx, combat, unit) end
	end
	for id, actor in pairs(ctx.heroState.actors or {}) do
		if not Entity.IsEntity(actor.hero) or not Entity.IsAlive(actor.hero) then
			ctx.heroState.actors[id], ctx.heroState.unitOrders[id], ctx.heroState.unitBusy[id] = nil, nil, nil
		end
	end
end

function core.mode(ctx)
	local mode = cfg.mode
	ctx.teamTask, ctx.fightSession, ctx.mapFarm, ctx.runeTask, ctx.riverTask, ctx.objectiveTask = nil, nil, nil, nil, nil, nil
	if ctx.intent and ctx.intent.kind == "hero" and not (ctx.combatDecision and ctx.combatDecision.returnFire) then ctx.intent = nil end
	if ctx.retreating then
		ctx.campTask, ctx.aggroTask, ctx.spacingTask, ctx.aimTask = nil, nil, nil, nil
		if ctx.recoveryTask and ctx.recoveryTask.phase == "escape" then
			ctx.defensiveCast = true
			local defended = heroModules.update(ctx, combat, true) or combat.run(ctx, true)
			ctx.defensiveCast = nil
			if defended then return true end
		end
		recovery.run(ctx)
		return true
	end
	if core.sustain(ctx) then return true end
	if ctx.intent and intent.run(ctx) then return true end
	if mode == modes.lane then
		if ctx.clock <= cfg.blockEnd and not ctx.laneThreat.avoid and core.block(ctx) then return true end
		ctx.farmCandidate = lastHit.plan(ctx)
		local farm = ctx.farmCandidate
		if farm and farm.inRange and farm.start <= ctx.now + 1 / 30 and ctx.now >= ctx.attackNext and lastHit.execute(ctx, farm) then return true end
		if ctx.laneThreat.avoid and positioning.respond(ctx) then return true end
		if farm and farm.start <= ctx.now + math.max(0.4, farm.approach or 0) and lastHit.execute(ctx, farm) then return true end
		if positioning.aggro(ctx) or positioning.respond(ctx) then return true end
		if lastHit.execute(ctx, farm) then return true end
		local anchor = helpers.laneAnchor(ctx)
		return core.teleport(ctx, anchor, "lane") or helpers.move(ctx, anchor, "Lane farming mode: wait for last hit")
	elseif mode == modes.block then
		if not ctx.laneThreat.avoid and core.block(ctx) then return true end
		local wait = positioning.blockWait(ctx) or helpers.laneAnchor(ctx)
		return core.teleport(ctx, wait, "lane") or helpers.move(ctx, wait, "Creep block mode: wait for next wave", 80)
	elseif mode == modes.stack or mode == modes.pull then
		if core.camp(ctx) then return true end
		local stage = supportCamps.next(ctx)
		if stage then
			return helpers.move(ctx, stage, mode == modes.stack and "Stack mode: move to next camp" or "Pull mode: wait at pull camp", 60)
		end
		local anchor = mode == modes.pull and helpers.laneAnchor(ctx) or navigation.coverAnchor(ctx)
		return helpers.move(ctx, anchor, mode == modes.stack and "Stack mode: no camp reachable this minute" or "Pull mode: wait for allied wave", 120)
	end
	return false
end

function core.macro(ctx)
	if core.push(ctx) then return true end
	local siege = ctx.role <= 3 and strategy.siegeGoal(ctx)
	if siege and helpers.distance(ctx.position, siege.goal) > 300 then
		return core.teleport(ctx, siege.goal, "rotate") or helpers.move(ctx, siege.goal, "Push while enemies are dead", 120)
	end
	local lock = ctx.macroLock
	if lock and ctx.now > lock.expires then lock, ctx.macroLock = nil, nil end
	local function hold(kind)
		ctx.macroLock = {kind = kind, expires = ctx.now + 20}
		return true
	end
	if lock and lock.kind == "camp" then
		if jungle.travel(ctx, 5000) then return true end
		ctx.macroLock = nil
	elseif lock and lock.kind == "wave" then
		if mapFarm.run(ctx) then return true end
		ctx.macroLock = nil
	end
	if ctx.clock >= cfg.laneEnd and not ctx.mapFarm and jungle.travel(ctx, 2200) then return hold("camp") end
	if mapFarm.run(ctx) then return hold("wave") end
	if ctx.clock >= cfg.laneEnd and jungle.travel(ctx, 5000) then return hold("camp") end
	local fallback = ctx.waveFallback
	if fallback then
		if ctx.now < fallback.expires and helpers.distance(ctx.position, fallback.goal) > 120 then
			return helpers.move(ctx, fallback.goal, "Rotate away from blocked wave")
		end
		ctx.waveFallback = nil
	end
	if ctx.clock >= cfg.laneEnd and ctx.role <= 3 and ctx.nearEnemies == 0 and ctx.now >= (ctx.nextRotation or 0) then
		ctx.nextRotation = ctx.now + 20
		local chosen, bestScore = ctx.lane, -math.huge
		for lane, wave in ipairs(ctx.waves) do
			for _, creep in ipairs(wave) do
				if helpers.valid(creep) then
					local position = Entity.GetAbsOrigin(creep)
					local value = 2200 - helpers.distance(ctx.position, position) * 0.2 + (lane == ctx.lane and 350 or 0)
					for _, ally in ipairs(ctx.allies) do
						if ally ~= ctx.hero and helpers.valid(ally) and helpers.distance(Entity.GetAbsOrigin(ally), position) < 1500 then value = value - 800 end
					end
					for _, enemy in ipairs(ctx.enemies) do
						if helpers.visible(enemy) and helpers.distance(Entity.GetAbsOrigin(enemy), position) < 1800 then value = value - 2500 end
					end
					if value > bestScore then chosen, bestScore = lane, value end
				end
			end
		end
		ctx.lane = chosen
	end
	if ctx.clock < cfg.laneEnd then
		if ctx.nearEnemies == 0 and ctx.heroModule and ctx.heroModule.farmReady and ctx.heroModule.farmReady(ctx) then
			local laneAvailable = false
			for _, creep in ipairs(ctx.creeps) do
				if helpers.visible(creep) and not Entity.IsSameTeam(ctx.hero, creep)
					and helpers.distance(ctx.position, Entity.GetAbsOrigin(creep)) < 1100 then laneAvailable = true; break end
			end
			if not laneAvailable and jungle.run(ctx) then return true end
		end
		local best, score = nil, math.huge
		for _, creep in ipairs(ctx.creeps) do
			if helpers.visible(creep) then
				local allied = Entity.IsSameTeam(creep, ctx.hero)
				local distance = helpers.distance(ctx.position, Entity.GetAbsOrigin(creep))
				local fraction = Entity.GetHealth(creep) / math.max(1, Entity.GetMaxHealth(creep))
				if distance < 1100 and (not allied and laneRules.canLastHit(ctx, creep) or ctx.role >= 4 and allied and fraction < 0.5)
					and not helpers.unsafePosition(ctx, engagement.attackPosition(ctx, creep)) then
					local value = distance + fraction * 250
					if value < score then best, score = creep, value end
				end
			end
		end
		if best then
			if positioning.lane(ctx, best) then return true end
		end
		local anchor = helpers.laneAnchor(ctx)
		return core.teleport(ctx, anchor, "lane") or helpers.move(ctx, anchor, ctx.regroupTask and "Regroup with incoming wave"
			or ctx.role >= 4 and "Support lane: deny and protect" or "Lane: wait for last hit")
	end
	local defense = baseDefense.outer(ctx)
	if defense and supportPolicy.midTeleport(ctx, defense.position) then
		return core.teleport(ctx, defense.goal, "defend") or helpers.move(ctx, defense.goal, "Respond to tower siege")
	end
	if ctx.role >= 4 then
		local coreHero, score = nil, math.huge
		for _, ally in ipairs(ctx.allies) do
			if supportPolicy.follow(ctx, ally) then
				local value = helpers.distance(ctx.position, Entity.GetAbsOrigin(ally)) - NPC.GetTrueDamage(ally) * 5
				if value < score then coreHero, score = ally, value end
			end
		end
		if coreHero then
			local anchor = helpers.toward(Entity.GetAbsOrigin(coreHero), ctx.home, 350)
			return core.teleport(ctx, anchor, "rotate") or helpers.move(ctx, anchor, "Protect allied core")
		end
		local escort = strategy.escort(ctx)
		if escort then
			local point = Entity.GetAbsOrigin(escort)
			if helpers.distance(ctx.position, point) > 750 then
				local anchor = helpers.toward(point, ctx.home, 550)
				return core.teleport(ctx, anchor, "rotate") or helpers.move(ctx, anchor, "Escort allied core", 150)
			end
			ctx.mode = "Escort allied core: hold behind"
			return helpers.stop(ctx)
		end
		local cover = navigation.coverAnchor(ctx)
		if helpers.distance(cover, ctx.home) < helpers.distance(ctx.position, ctx.home) then
			return helpers.move(ctx, cover, "Support: hold safe position near allies", 150)
		end
	end
	if ctx.role <= 3 and ctx.nearEnemies == 0 then
		local target, nearest = nil, math.huge
		for _, creep in ipairs(ctx.creeps) do
			if helpers.visible(creep) and not Entity.IsSameTeam(creep, ctx.hero) and not helpers.unsafePosition(ctx, engagement.attackPosition(ctx, creep)) then
				local current = helpers.distance(ctx.position, Entity.GetAbsOrigin(creep))
				if current < nearest then target, nearest = creep, current end
			end
		end
		if target and nearest < 1000 then
			if combat.farm(ctx, ctx.creeps, false) or helpers.attack(ctx, target, "Farm lane wave") then return true end
		end
		if jungle.run(ctx) then return true end
	end
	local anchor = helpers.laneAnchor(ctx)
	local blocked = ctx.waveBlocked
	if ctx.lastOrder == "hold" and not NPC.IsAttacking(ctx.hero) and helpers.distance(ctx.position, anchor) > 150 then
		if not blocked or helpers.distance(ctx.position, blocked.position) > 100 then
			blocked = {position = ctx.position, since = ctx.now}
			ctx.waveBlocked = blocked
		end
		if ctx.now - blocked.since > 3 then
			local best, nearest, chosenLane = nil, 6000, nil
			for lane, wave in ipairs(ctx.waves) do
				if lane ~= ctx.lane then
					for _, creep in ipairs(wave) do
						if helpers.valid(creep) then
							local point = helpers.toward(Entity.GetAbsOrigin(creep), ctx.home, 400)
							local distance = helpers.distance(ctx.position, point)
							if distance > 800 and distance < nearest and awareness.farmSafe(ctx, point, 0)
								and navigation.safePath(ctx, point, 40) then best, nearest, chosenLane = point, distance, lane end
						end
					end
				end
			end
			if not best then
				local point = navigation.coverAnchor(ctx)
				if helpers.distance(ctx.position, point) > 450 and navigation.safePath(ctx, point, 40) then best = point end
			end
			if best then
				ctx.waveFallback, ctx.waveBlocked, ctx.regroupTask = {goal = best, expires = ctx.now + 12}, nil, nil
				if chosenLane then ctx.lane, ctx.waveAnchor, ctx.waveLane, ctx.nextRotation = chosenLane, nil, nil, ctx.now + 15 end
				return helpers.move(ctx, best, "Rotate away from blocked wave")
			end
		end
	elseif ctx.lastOrder == "attack" or blocked and helpers.distance(ctx.position, blocked.position) > 100 then ctx.waveBlocked = nil end
	return core.teleport(ctx, anchor, "lane") or helpers.move(ctx, anchor, ctx.regroupTask and "Regroup with incoming wave" or "Advance with wave")
end

function core.reflex(ctx)
	if core.dodge(ctx) then return true end
	if combat.items(ctx, true) then return true end
	if detection.run(ctx, combat) then return true end
	if ctx.settings.spells and ctx.heroModule and ctx.heroModule.emergency and ctx.heroModule.emergency(ctx, combat) then return true end
	if ctx.spellFinish and ctx.heroModule.finishCast(ctx, combat) then return true end
	return false
end

function core.lane(ctx)
	local hero = ctx.hero
	ctx.farmCandidate = nil
	local profileLocked = cfg.spells and ctx.heroModule and ctx.heroModule.locked and ctx.heroModule.locked(ctx)
	if not ctx.retreating and not ctx.campTask and not ctx.objectiveTask and not profileLocked and not jungle.active(ctx)
		and not (ctx.teamTask and ctx.teamTask.kind == "roshan") then ctx.farmCandidate = lastHit.plan(ctx) end
	if ctx.settings.spells and not profileLocked and ctx.heroModule and ctx.heroModule.opportunity
		and ctx.heroModule.opportunity(ctx, combat) then return true end
	if not profileLocked and not ctx.hardRetreat and ctx.teamTask and ctx.teamTask.fighting and teamplay.run(ctx) then return true end
	if ctx.aggroTask and positioning.aggro(ctx) then return true end
	if not ctx.hardRetreat and not ctx.intent and not profileLocked then
		local opportunity = engagement.choose(ctx)
		if opportunity then
			local farm = ctx.farmCandidate
			local timeNeeded = NPC.GetSecondsPerAttack(hero, false) + (opportunity.approach or 0) + 0.4
			local reserved = farm and farm.start <= ctx.now + timeNeeded
			if opportunity.urgent or not reserved and not ctx.campTask and not ctx.teamTask and not ctx.runeTask and not ctx.objectiveTask then
				ctx.target, ctx.retreating, ctx.retreatUntil = opportunity.target, false, nil
				ctx.campTask, ctx.spacingTask, ctx.aggroTask = nil, nil, nil
				intent.begin(ctx, opportunity.target, "hero", false)
				ctx.intent.opportunity = opportunity.score
			end
		end
	end
	if not profileLocked and jungle.active(ctx) then
		if core.sustain(ctx) then return true end
		if ctx.settings.spells and ctx.heroModule and ctx.heroModule.farm and ctx.heroModule.farm(ctx, combat) then return true end
		if combat.farm(ctx, ctx.neutrals, false) then return true end
		if jungle.run(ctx, true) then return true end
	end
	local farmPriority = not ctx.teamTask or (ctx.teamTask.kind == "protect" or ctx.teamTask.kind == "group") and not ctx.teamTask.fighting
	local farmAccess = not ctx.laneThreat.avoid or positioning.reserve(ctx)
	if not ctx.retreating and not ctx.campTask and not ctx.intent and not profileLocked and farmPriority and farmAccess then
		local candidate = ctx.farmCandidate
		if not ctx.clearTask and not ctx.runeTask and candidate and candidate.inRange and candidate.start <= ctx.now + 1 / 30 and ctx.now >= ctx.attackNext
			and lastHit.execute(ctx, candidate) then return true end
	end
	if ctx.runeTask and ctx.runeTask.travelUntil and ctx.now < ctx.runeTask.travelUntil and not ctx.hardRetreat
		and runes.run(ctx, ctx.farmCandidate) then return true end
	local imminentFarm = ctx.farmCandidate
	if not ctx.intent and not profileLocked and farmPriority and farmAccess and not ctx.runeTask
		and imminentFarm and imminentFarm.start <= ctx.now + math.max(0.4, imminentFarm.approach or 0)
		and lastHit.execute(ctx, imminentFarm) then return true end
	if core.sustain(ctx) then return true end
	if not profileLocked and combat.items(ctx, false) then return true end
	if not profileLocked and not ctx.retreating and not ctx.intent and ctx.laneThreat.avoid then
		ctx.defensiveCast = true
		local defended = heroModules.update(ctx, combat, true) or combat.run(ctx, true)
		ctx.defensiveCast = nil
		if defended or positioning.respond(ctx) then return true end
	end
	if not profileLocked and not ctx.retreating and positioning.aggro(ctx) then return true end
	if not profileLocked and not ctx.retreating and positioning.respond(ctx) then return true end
	if not profileLocked and ctx.campTask and core.camp(ctx) then return true end
	if not ctx.intent and not profileLocked and not ctx.retreating then
		if ctx.teamTask and ctx.teamTask.kind == "push" and teamplay.run(ctx) then return true end
		if ctx.teamTask and ctx.teamTask.kind == "roshan" and teamplay.run(ctx) then return true end
		if teamplay.loot(ctx) then return true end
	end
	if not ctx.intent and not profileLocked and ctx.objectiveTask and objectives.collect(ctx) then return true end
	if not ctx.intent and not profileLocked and not ctx.objectiveTask and runes.run(ctx, ctx.farmCandidate) then return true end
	if heroModules.update(ctx, combat, ctx.retreating) then return true end
	if ctx.aimTask and combat.run(ctx, ctx.retreating) then return true end
	if not ctx.intent and ctx.target and not ctx.hardRetreat and ctx.health > 0.45
		and Entity.GetHealth(ctx.target) <= NPC.GetTrueDamage(hero) * NPC.GetArmorDamageMultiplier(ctx.target) * 2
		and helpers.distance(ctx.position, Entity.GetAbsOrigin(ctx.target)) < NPC.GetAttackRange(hero) + NPC.GetAttackRangeBonus(hero) + 300 then
		intent.begin(ctx, ctx.target, "hero", true)
	end
	if intent.run(ctx) then return true end
	if unitControl.summon(ctx, combat) then return true end
	if NPC.HasModifier(hero, "modifier_fountain_aura_buff") and recovery.fountainNeeded(ctx) then
		ctx.mode = "Recover at fountain"
		helpers.stop(ctx)
		return true
	end
	if not profileLocked and core.camp(ctx) then return true end
	if teamplay.run(ctx) then return true end
	if deward.run(ctx) then return true end
	if objectives.collect(ctx, true) then return true end
	if lastHit.recover(ctx) then return true end
	if jungle.run(ctx, true) then return true end
	if positioning.aggro(ctx) then return true end
	if positioning.fightCreeps(ctx) then return true end
	local farm = ctx.farmCandidate
	if not ctx.runeTask and farm and farm.inRange and farm.start <= ctx.now + 1 / 30 and ctx.now >= ctx.attackNext then
		if lastHit.execute(ctx, farm) then return true end
	end
	if ctx.target and not helpers.unsafePosition(ctx, Entity.GetAbsOrigin(ctx.target))
		and ctx.nearEnemies <= ctx.nearAllies and combat.run(ctx, false) then ctx.mode = "Combat ability"; return true end
	if core.push(ctx) then return true end
	if positioning.evade(ctx) then return true end
	if lastHit.execute(ctx, ctx.farmCandidate) then return true end
	if ctx.clock > cfg.blockEnd and not profileLocked and not ctx.laneThreat.avoid and core.block(ctx) then return true end
	if ctx.target and not helpers.unsafePosition(ctx, Entity.GetAbsOrigin(ctx.target))
		and (ctx.nearEnemies <= ctx.nearAllies or NPC.IsChannellingAbility(ctx.target)) then
		if combat.run(ctx, false) then ctx.mode = "Combat ability"; return true end
		local distance = helpers.distance(ctx.position, Entity.GetAbsOrigin(ctx.target))
		local killable = Entity.GetHealth(ctx.target) <= NPC.GetTrueDamage(hero) * NPC.GetArmorDamageMultiplier(ctx.target) * 2
		if (ctx.tradeSafe or killable and ctx.health > 0.45) and (distance < NPC.GetAttackRange(hero) + NPC.GetAttackRangeBonus(hero) + 80
			or Hero.GetRecentDamage(hero) > 0 and distance < 450) then
			intent.begin(ctx, ctx.target, "hero", true)
			if intent.run(ctx) then return true end
		end
	end
	if objectives.collect(ctx) or core.ward(ctx) then return true end
	if combat.run(ctx, false) then ctx.mode = "Utility ability"; return true end
	return core.macro(ctx)
end

function core.sync(hero, player)
	local control = ui.control:Get()
	local ctx = state.ctx
	if control ~= 2 then
		if not ctx or ctx.hero ~= hero or ctx.roleSetting ~= ui.role:Get() or ctx.laneSetting ~= ui.lane:Get() then
			if ctx then ctx.active = false end
			state.ctx = helpers.init(hero, player)
		end
	elseif ctx then
		ctx.active, state.ctx = false, nil
	end
	local now = GameRules.GetGameTime()
	if now >= state.nextRoster then
		state.nextRoster = now + 1
		local wanted = {}
		if control ~= 0 then
			for _, ally in ipairs(helpers.departed(hero)) do wanted[Entity.GetIndex(ally)] = ally end
		end
		for key, allyCtx in pairs(state.allies) do
			if wanted[key] ~= allyCtx.hero then allyCtx.active, state.allies[key] = false, nil end
		end
		for key, ally in pairs(wanted) do
			if not state.allies[key] then state.allies[key] = helpers.init(ally, player, true) end
		end
	end
	local list = helpers.contexts()
	coordination.set(list)
	return list
end

function core.run()
	if not ui.enabled:Get() or not Engine.IsInGame() then return end
	if GameRules.IsPaused() then return end
	local gameState = GameRules.GetGameState()
	if gameState ~= Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME and gameState ~= Enum.GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
	local hero, player = Heroes.GetLocal(), Players.GetLocal()
	if not hero or not player or not Entity.IsEntity(hero) then return end
	for _, ctx in ipairs(core.sync(hero, player)) do
		if ctx.active then core.tick(ctx, gameState) end
	end
end

function core.tick(ctx, gameState)
	local hero = ctx.hero
	ctx.now = GameRules.GetGameTime()
	if ctx.now < ctx.nextTick then return end
	ctx.nextTick = ctx.now + cfg.tick
	ctx.clock = gameState == Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME and -1 or ctx.now - GameRules.GetGameStartTime()
	ctx.position = Entity.GetAbsOrigin(hero)
	local currentHealth = Entity.GetHealth(hero)
	ctx.healthLost = ctx.previousHealth and math.max(0, ctx.previousHealth - currentHealth) or 0
	if ctx.healthLost > 0 then ctx.lastDamaged = ctx.now end
	ctx.previousHealth = currentHealth
	if Input.IsInputCaptured() or ui.pause:IsDown() or ctx.now < ctx.pauseUntil then
		ctx.mode = "Paused: manual control"
		return
	end
	if ctx.now >= ctx.nextScan then helpers.scan(ctx) end
	helpers.sample(ctx)
	strategy.update(ctx)
	laneChoice.update(ctx)
	if Entity.IsAlive(hero) and core.teleporting(ctx) then core.units(ctx); return end
	baseDefense.update(ctx)
	lastHit.update(ctx)
	combat.level(ctx)
	neutralItems.run(ctx)
	if not Entity.IsAlive(hero) then
		if not ctx.wasDead then heroModules.reset(ctx) end
		ctx.intent, ctx.teleportOrder = nil, nil
		ctx.clearTask, ctx.teamTask, ctx.regroupTask = nil, nil, nil
		ctx.runeTask, ctx.aggroTask, ctx.spacingTask, ctx.laneGoal, ctx.aimTask, ctx.wardTask = nil, nil, nil, nil, nil, nil
		ctx.riverTask, ctx.jungleState = nil, nil
		ctx.mapFarm, ctx.mapFarmBlocked = nil, nil
		ctx.recoveryTask, ctx.dewardTask = nil, nil
		ctx.disengage, ctx.waveFallback, ctx.waveBlocked = nil, nil, nil
		ctx.roshanState, ctx.roshanExit, ctx.roshanLoot = nil, nil, nil
		ctx.mode, ctx.campTask, ctx.wasDead = "Dead: wait for respawn", nil, true
		ctx.decisionTrace, ctx.decisionRan, ctx.decision = nil, nil, nil
		ctx.busyUntil, ctx.attackNext, ctx.moveGoal = 0, 0, nil
		core.units(ctx)
		if not cfg.buyback or not recovery.buyback(ctx) then shop.run(ctx) end
		return
	end
	if ctx.wasDead then
		ctx.wasDead, ctx.recovering, ctx.retreatUntil, ctx.nextTeleport = false, false, nil, 0
		ctx.lastOrder = nil
	end
	helpers.threat(ctx)
	shop.run(ctx)
	if ctx.settings.spells and ctx.heroModule and ctx.heroModule.background then ctx.heroModule.background(ctx, combat) end
	positioning.observe(ctx)
	runes.observe(ctx)
	coordination.update(ctx)
	teamplay.plan(ctx)
	jungle.update(ctx)
	core.units(ctx)
	if ctx.settings.spells and ctx.heroModule and ctx.heroModule.duringCast and ctx.heroModule.duringCast(ctx, combat) then return end
	if helpers.unsafePosition(ctx, ctx.position) and not NPC.IsChannellingAbility(hero) and not NPC.IsStunned(hero) then
		ctx.intent, ctx.hits.ordered, ctx.busyUntil, ctx.attackNext = nil, nil, ctx.now, ctx.now
		helpers.move(ctx, navigation.coverAnchor(ctx), "Exit exposed enemy tower range")
		return
	end
	if helpers.visible(ctx.attackTarget) and NPC.IsStructure(ctx.attackTarget) and not helpers.pushSafe(ctx, ctx.attackTarget)
		and not NPC.IsChannellingAbility(hero) then
		ctx.intent, ctx.hits.ordered, ctx.busyUntil = nil, nil, ctx.now
		if helpers.unsafePosition(ctx, ctx.position) then
			helpers.move(ctx, helpers.toward(ctx.position, ctx.home, 350), "Leave tower as wave cover expires")
		else helpers.stop(ctx) end
		return
	end
	if helpers.valid(ctx.attackTarget) and NPC.IsLaneCreep(ctx.attackTarget) and Entity.IsSameTeam(hero, ctx.attackTarget)
		and not laneRules.denyable(ctx.clock, Entity.GetHealth(ctx.attackTarget), Entity.GetMaxHealth(ctx.attackTarget),
			NPC.GetModifierProperty(ctx.attackTarget, Enum.ModifierFunction.MODIFIER_PROPERTY_CREEP_DENY_PERCENT)) then
		helpers.stop(ctx)
		ctx.hits.ordered, ctx.busyUntil = nil, ctx.now
	end
	if lastHit.yieldCore(ctx) then return end
	local pendingAttack = ctx.hits.ordered
	if pendingAttack and ctx.lastOrder == "attack" and not NPC.IsHero(pendingAttack.target)
		and (ctx.hardRetreat or baseDefense.interrupt(ctx, pendingAttack.target) or (ctx.fightSession or ctx.spellFinish) and (not pendingAttack.confirmed or pendingAttack.release > ctx.now + 0.12) or ctx.laneThreat.attacked and ctx.laneThreat.incoming > currentHealth * 0.3
			and (not pendingAttack.confirmed or pendingAttack.release > ctx.now + 0.12)) then
		helpers.stop(ctx)
		ctx.hits.ordered, ctx.busyUntil, ctx.attackNext = nil, ctx.now, ctx.now
	end
	if combat.channel(ctx) then return end
	if combat.busy(ctx) or NPC.IsStunned(hero) then return end
	if core.reflex(ctx) then return end
	if ctx.settings.mode ~= modes.full and core.mode(ctx) then return end
	decide.run(ctx, core.behaviors)
end

function selfPlay.OnUpdate()
	core.run()
	local now = GameRules.GetGameTime()
	if ui.debug:Get() and now >= (state.nextAllyDebug or 0) then
		state.nextAllyDebug = now + 3
		for _, allyCtx in ipairs(helpers.contexts()) do
			if allyCtx.ally and allyCtx.hero and Entity.IsEntity(allyCtx.hero) then
				Log.Write(string.format("[SelfPlay ally] hero=%s role=%d lane=%d mode=%s hp=%.2f pos=%.0f,%.0f order=%s",
					NPC.GetUnitName(allyCtx.hero), allyCtx.role, allyCtx.lane, allyCtx.mode or "", allyCtx.health or 0,
					allyCtx.position and allyCtx.position.x or 0, allyCtx.position and allyCtx.position.y or 0, allyCtx.lastOrder or "none"))
			end
		end
	end
	local ctx = state.ctx
	if ctx and ctx.hero and ui.enabled:Get() then winModel.update(ctx) end
	local now = GameRules.GetGameTime()
	if ctx and ui.debug:Get() and now >= (ctx.nextDebug or 0) then
		ctx.nextDebug = now + 3
		if ui.enabled:Get() and Entity.IsEntity(ctx.player) and now >= (ctx.nextScoreReport or 0) then
			ctx.nextScoreReport = now + 60
			local score = Player.GetTeamPlayer(ctx.player)
			Log.Write(string.format("[SelfPlay score] clock=%.1f hero=%s role=%d lane=%d lastHits=%d denies=%d networth=%d gold=%d xp=%d heroDamage=%.0f laneGold=%d jungleGold=%d observers=%d sentries=%d stacked=%d goldLostToDeath=%d",
				ctx.clock, NPC.GetUnitName(ctx.hero), ctx.role, ctx.lane, score.lasthit_count, score.deny_count, score.networth,
				score.totalearned_gold, score.totalearned_xp, score.hero_damage, score.creep_kill_gold, score.neutral_kill_gold,
				score.observer_wards_placed or 0, score.sentry_wards_placed or 0, score.camps_stacked or 0, score.gold_lost_to_death or 0))
			local win = ctx.winModel
			if win and win.smooth then
				local parts = {}
				for _, factor in ipairs(win.factors or {}) do parts[#parts + 1] = string.format("%s=%+.2f(%s)", factor.key, factor.value, factor.detail or "") end
				Log.Write(string.format("[SelfPlay win] chance=%.0f%% samples=%d worth=%.0f/%.0f correction=%.2f enemiesSeen=%d %s", win.smooth * 100, #win.history, win.allyItems or 0, win.enemyItems or 0, win.correction or 1, win.enemySeen or 0, table.concat(parts, " ")))
			end
			if ctx.winModelError then Log.Write("[SelfPlay win] error " .. ctx.winModelError) end
		end
		Log.Write(string.format("[SelfPlay] role=%d lane=%d mode=%s hp=%.2f pos=%.0f,%.0f busy=%.2f attacks=%d cancelled=%d build=%s buy=%s cast=%s provider=%s order=%s",
			ctx.role, ctx.lane, ctx.mode, ctx.health or 0, ctx.position.x, ctx.position.y,
			math.max(0, ctx.busyUntil - ctx.now), ctx.hits.confirmed, ctx.hits.cancelled, ctx.shop.source, ctx.shop.status, ctx.lastAbility,
			ctx.shop.providerError or ctx.shop.deferredSource or "ok", ctx.lastOrder or "none"))
		Log.Write(string.format("[SelfPlay actions] time=%.2f target=%s lock=%s creepAggro=%d candidates=%d lastSwing=%s",
			ctx.now, helpers.valid(ctx.attackTarget) and NPC.GetUnitName(ctx.attackTarget) or "none",
			ctx.intent and ctx.intent.kind or "none", ctx.creepPressure or 0, ctx.hits.candidateCount or 0,
			ctx.hits.lastConfirmedName or "none"))
		local farm = ctx.farmCandidate
		if farm and helpers.valid(farm.target) then
			Log.Write(string.format("[SelfPlay last hit] target=%s hp=%.0f damage=%d events=%d start=%.3f impact=%.3f approach=%.2f inRange=%s",
				NPC.GetUnitName(farm.target), Entity.GetHealth(farm.target), farm.damage, #farm.events,
				farm.start - ctx.now, farm.impact - ctx.now, farm.approach, tostring(farm.inRange)))
		end
		if ctx.blockState and not ctx.blockState.done then
			Log.Write(string.format("[SelfPlay block] phase=%s later=%s", ctx.blockState.phase, tostring(ctx.blockState.later == true)))
		end
		if ctx.teamTask and ctx.teamTask.kind == "group" then
			Log.Write(string.format("[SelfPlay group] members=%d fighting=%s objective=%s",
				#ctx.teamTask.members, tostring(ctx.teamTask.fighting), helpers.valid(ctx.teamTask.objective) and NPC.GetUnitName(ctx.teamTask.objective) or "Active fight"))
		end
		if ctx.fightStatus then Log.Write("[SelfPlay fight task] " .. ctx.fightStatus) end
		if ctx.baseDefense then Log.Write(string.format("[SelfPlay base defense] building=%s heroes=%d creeps=%d yieldToFight=%s", ctx.baseDefense.name, ctx.baseDefense.heroes, ctx.baseDefense.creeps, tostring(baseDefense.yields(ctx)))) end
		if ctx.baseCounterattack then
			Log.Write(string.format("[SelfPlay base counterattack] target=%s allies=%d critical=%s actionDamage=%.0f",
				NPC.GetUnitName(ctx.baseCounterattack.target), ctx.baseCounterattack.allies, tostring(ctx.baseCounterattack.critical), ctx.baseCounterattack.incoming))
		end
		if ctx.helpStatus then Log.Write("[SelfPlay help] " .. ctx.helpStatus) end
		if ctx.laneThreat then
			Log.Write(string.format("[SelfPlay threat] incoming=%.0f future=%d ambush=%s attacked=%s retreat=%s",
				ctx.laneThreat.incoming, ctx.laneThreat.futureCount, tostring(ctx.laneThreat.ambush), tostring(ctx.laneThreat.attacked), tostring(ctx.hardRetreat)))
		end
		if ctx.combatDecision then
			Log.Write(string.format("[SelfPlay fight] target=%s keep=%s returnFire=%s kill=%.2fs incoming=%.0f remainingHP=%.0f supportDamage=%.0f supportUnits=%d duel=%s",
				NPC.GetUnitName(ctx.combatDecision.target), tostring(engagement.keep(ctx.combatDecision)), tostring(ctx.combatDecision.returnFire), ctx.combatDecision.killTime,
				ctx.combatDecision.incoming, ctx.combatDecision.remaining, ctx.combatDecision.supportDamage, ctx.combatDecision.supportUnits, tostring(ctx.combatDecision.duel)))
		end
		if ctx.decisionTrace then
			Log.Write(string.format("[SelfPlay decide] ran=%s for=%.1fs top=%s", tostring(ctx.decisionRan),
				ctx.decision and ctx.now - ctx.decision.since or 0, ctx.decisionTrace))
		end
		if ctx.decisionFlip and ctx.now - ctx.decisionFlip.time < 4 then
			Log.Write(string.format("[SelfPlay decide] flip-flop %s <-> %s", ctx.decisionFlip.a, ctx.decisionFlip.b))
		end
		if ctx.decideError then
			Log.Write("[SelfPlay decide] score error " .. ctx.decideError)
			ctx.decideError = nil
		end
		if ctx.shop and ctx.shop.supplyNote and ctx.shop.supplyNote ~= ctx.loggedSupply then
			Log.Write("[SelfPlay supply] " .. ctx.shop.supplyNote)
			ctx.loggedSupply = ctx.shop.supplyNote
		end
		if ctx.initiateStatus and ctx.now - ctx.initiateStatus.time < 4 then
			Log.Write("[SelfPlay initiate] " .. ctx.initiateStatus.text)
		end
		if ctx.channelStatus and ctx.now - ctx.channelStatus.time < 4 then
			Log.Write("[SelfPlay channel] cancel " .. ctx.channelStatus.text)
		end
		if ctx.wardStatus and ctx.wardStatus ~= ctx.loggedWardStatus then
			Log.Write("[SelfPlay ward] " .. ctx.wardStatus)
			ctx.loggedWardStatus = ctx.wardStatus
		end
		if ctx.laneStatus and ctx.now - ctx.laneStatus.time < 4 then
			Log.Write("[SelfPlay lane] " .. ctx.laneStatus.text)
		end
		if ctx.travelStatus and ctx.now - ctx.travelStatus.time < 4 then
			Log.Write("[SelfPlay travel] " .. ctx.travelStatus.text)
		end
		if ctx.talentStatus and ctx.now - ctx.talentStatus.time < 4 then
			Log.Write("[SelfPlay talent] " .. ctx.talentStatus.text)
		end
		if ctx.combatRelease and ctx.now - ctx.combatRelease.time < 4 then
			Log.Write("[SelfPlay fight release] " .. ctx.combatRelease.reason)
		end
		for _, event in ipairs(ctx.heroState.invokerEvents or {}) do Log.Write("[SelfPlay Invoker] " .. event) end
		ctx.heroState.invokerEvents = nil
		if ctx.heroState.blastReason then
			Log.Write(string.format("[SelfPlay Techies] blast=%s stage=%s", ctx.heroState.blastReason,
				ctx.heroState.techiesCombo and ctx.heroState.techiesCombo.stage or "none"))
		end
		if ctx.neutralItems then
			Log.Write(string.format("[SelfPlay neutral] madstones=%d status=%s", ctx.neutralItems.madstones or 0,
				ctx.neutralItems.status or "Waiting for crafting currency"))
		end
		if ctx.jungleState and ctx.jungleState.status then Log.Write("[SelfPlay jungle] " .. ctx.jungleState.status) end
		if ctx.mapFarm and ctx.mapFarmNote then Log.Write("[SelfPlay map farm] " .. ctx.mapFarmNote) end
		if ctx.role >= 4 and not ctx.campTask and ctx.campPlanNote and ctx.campPlanNote ~= ctx.loggedCampPlan then
			Log.Write("[SelfPlay camp plan] " .. ctx.campPlanNote)
			ctx.loggedCampPlan = ctx.campPlanNote
		end
		if ctx.campTask or ctx.campStatus then
			Log.Write(string.format("[SelfPlay support camp] state=%s status=%s", ctx.campTask and ctx.campTask.phase or "idle", ctx.campStatus or "Timed camp task"))
		end
		if ctx.roshanAssessment then
			local estimate = ctx.roshanAssessment
			Log.Write(string.format("[SelfPlay Roshan] %s kill=%.1fs remainingHP=%.0f", estimate.reason, estimate.timeToKill, estimate.remainingHealth))
		end
		for id, actor in pairs(ctx.heroState.actors or {}) do
			if helpers.valid(actor.hero) and actor.temporaryUnit then
				local scroll = NPC.GetItem(actor.hero, "item_tpscroll", false)
				Log.Write(string.format("[SelfPlay Double control] id=%d hp=%.2f target=%s order=%s busy=%.2f stunned=%s",
					id, actor.health, helpers.valid(actor.target) and NPC.GetUnitName(actor.target) or "none", tostring(actor.lastOrder),
					math.max(0, actor.busyUntil - ctx.now, (ctx.heroState.unitBusy[id] or 0) - ctx.now), tostring(NPC.IsStunned(actor.hero))))
				Log.Write(string.format("[SelfPlay Double] id=%d task=%s tp=%s remaining=%.1f pos=%.0f,%.0f cast=%s attacking=%s", id, actor.heroState.travelReason or "Combat or local farm",
					scroll and tostring(Ability.CanBeExecuted(scroll)) or "missing", actor.heroState.remaining or 0,
					actor.position.x, actor.position.y, actor.lastAbility or "none", tostring(NPC.IsAttacking(actor.hero))))
			end
		end
	end
end

function selfPlay.OnPrepareUnitOrders(data)
	if not ui.enabled:Get() then return true end
	for _, ctx in ipairs(helpers.contexts()) do core.manual(ctx, data) end
	return true
end

function core.manual(ctx, data)
	if data.player ~= ctx.player then return end
	local controlsHero = data.npc == ctx.hero
	if data.orderIssuer == Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS then
		for _, unit in ipairs(Player.GetSelectedUnits(ctx.player)) do
			if unit == ctx.hero then controlsHero = true; break end
		end
	end
	if controlsHero then
		heroModules.reset(ctx)
		ctx.intent = nil
		ctx.pauseUntil = GameRules.GetGameTime() + cfg.manualPause
		ctx.campTask, ctx.aimTask, ctx.runeTask, ctx.clearTask, ctx.teamTask, ctx.regroupTask = nil, nil, nil, nil, nil, nil
		ctx.aggroTask, ctx.spacingTask, ctx.laneGoal, ctx.heroHarass = nil, nil, nil, nil
		ctx.riverTask, ctx.jungleState = nil, nil
		ctx.mapFarm = nil
		ctx.recoveryTask, ctx.dewardTask = nil, nil
		ctx.disengage, ctx.waveFallback, ctx.waveBlocked = nil, nil, nil
		ctx.roshanState, ctx.roshanExit, ctx.roshanLoot = nil, nil, nil
		ctx.lastOrder, ctx.moveGoal = "manual", nil
	end
end

function selfPlay.OnProjectile(data)
	if not ui.enabled:Get() or not data.source or not data.target or data.moveSpeed <= 0 then return end
	for _, ctx in ipairs(helpers.contexts()) do core.projectile(ctx, data) end
end

function core.projectile(ctx, data)
	lastHit.projectile(ctx, data)
	if data.isAttack and data.target == ctx.hero and helpers.visible(data.source) and NPC.IsHero(data.source)
		and not Entity.IsSameTeam(ctx.hero, data.source) then
		ctx.heroHarass = {source = data.source, time = GameRules.GetGameTime()}
	end
	if data.isAttack and data.target == ctx.hero and helpers.valid(data.source) and NPC.IsLaneCreep(data.source) then
		ctx.creepAggro = ctx.creepAggro or {}
		ctx.creepAggro[Entity.GetIndex(data.source)] = GameRules.GetGameTime()
			+ helpers.distance(Entity.GetAbsOrigin(data.source), ctx.position) / data.moveSpeed + 0.25
	end
	if not helpers.visible(data.source) or not helpers.valid(data.target) then return end
	if helpers.distance(ctx.position, Entity.GetAbsOrigin(data.target)) > 2500 then return end
	local damage = data.isAttack and NPC.GetTrueDamage(data.source) * NPC.GetArmorDamageMultiplier(data.target) or 0
	if not data.isAttack and data.ability then
		damage = Ability.GetDamage(data.ability)
		local damageType = Ability.GetDamageType(data.ability)
		if damageType == Enum.DamageTypes.DAMAGE_TYPE_MAGICAL then damage = damage * NPC.GetMagicalArmorDamageMultiplier(data.target)
		elseif damageType == Enum.DamageTypes.DAMAGE_TYPE_PHYSICAL then damage = damage * NPC.GetArmorDamageMultiplier(data.target) end
	end
	ctx.projectiles[data.handle] = {target = data.target, damage = damage,
		impact = GameRules.GetGameTime() + helpers.distance(Entity.GetAbsOrigin(data.source), Entity.GetAbsOrigin(data.target)) / data.moveSpeed}
end

function selfPlay.OnUnitAnimation(data)
	if not ui.enabled:Get() then return end
	for _, ctx in ipairs(helpers.contexts()) do
		lastHit.animation(ctx, data)
		positioning.animation(ctx, data)
	end
end

function selfPlay.OnUnitAnimationEnd(data)
	if not ui.enabled:Get() then return end
	for _, ctx in ipairs(helpers.contexts()) do lastHit.animationEnd(ctx, data) end
end

function selfPlay.OnEntityDestroy(entity)
	for _, ctx in ipairs(helpers.contexts()) do
		if Entity.IsEntity(entity) then heroModules.remove(ctx, entity) end
		lastHit.remove(ctx, entity)
		if ctx.intent and ctx.intent.target == entity then ctx.intent = nil end
	end
end

function selfPlay.OnNpcDying(npc)
	for _, ctx in ipairs(helpers.contexts()) do teamplay.dying(ctx, npc) end
	selfPlay.OnEntityDestroy(npc)
end

function selfPlay.OnEntityHurt(data)
	if not ui.enabled:Get() then return end
	for _, ctx in ipairs(helpers.contexts()) do
		lastHit.hurt(ctx, data)
		positioning.hurt(ctx, data)
		supportCamps.hurt(ctx, data)
		teamplay.hurt(ctx, data)
	end
end

function selfPlay.OnLinearProjectileCreate(data)
	if not ui.enabled:Get() or not helpers.visible(data.source) then return end
	local speed = math.sqrt(data.velocity.x ^ 2 + data.velocity.y ^ 2)
	for _, ctx in ipairs(helpers.contexts()) do
		if not Entity.IsSameTeam(ctx.hero, data.source) and speed >= 100 and data.distance > 0
			and helpers.distance(ctx.position, data.origin) <= 3500 then
			ctx.hazards[data.handle] = {origin = data.origin, velocity = data.velocity,
				created = GameRules.GetGameTime(), expires = GameRules.GetGameTime() + math.min(5, data.distance / speed)}
		end
	end
end

function selfPlay.OnParticleCreate(data)
	if not ui.enabled:Get() then return end
	for _, ctx in ipairs(helpers.contexts()) do teleports.create(ctx, data) end
end

function selfPlay.OnParticleUpdate(data)
	for _, ctx in ipairs(helpers.contexts()) do teleports.point(ctx, data) end
end

function selfPlay.OnParticleUpdateFallback(data)
	for _, ctx in ipairs(helpers.contexts()) do teleports.point(ctx, data) end
end

function selfPlay.OnParticleUpdateEntity(data)
	for _, ctx in ipairs(helpers.contexts()) do teleports.attach(ctx, data) end
end

function selfPlay.OnParticleDestroy(data)
	for _, ctx in ipairs(helpers.contexts()) do teleports.destroy(ctx, data) end
end

function selfPlay.OnLinearProjectileDestroy(data)
	for _, ctx in ipairs(helpers.contexts()) do ctx.hazards[data.handle] = nil end
end

function selfPlay.OnDraw()
	if not ui.enabled:Get() or not ui.draw:Get() then return end
	local ctx = state.ctx
	if ctx then hud.draw(ctx, ui.winGraph:Get() and ctx.winModel or nil, {panel = true, world = ui.markers:Get()}) end
	local line = 0
	for _, allyCtx in ipairs(helpers.contexts()) do
		if allyCtx.ally and allyCtx.active and allyCtx.hero and Entity.IsEntity(allyCtx.hero) then
			local name = NPC.GetUnitName(allyCtx.hero):gsub("^npc_dota_hero_", "")
			Render.Text(renderContext.font, 15, string.format("%s (pos %d): %s", name, allyCtx.role, localization.text(allyCtx.mode or "")),
				Vec2(30, 560 + line * 18), Color(200, 230, 255, 255))
			line = line + 1
		end
	end
end

function selfPlay.OnGameEnd()
	camera.release()
	matchmaking.gameEnd()
	draft.reset()
	helpers.reset()
end

function selfPlay.OnUpdateEx()
	localization.persist()
	helpers.settings()
	camera.update(ui.enabled:Get() and ui.camera:Get())
	local now = matchmaking.update(ui.matchmaking, ui.role:Get())
	if ui.enabled:Get() then draft.update(ui.draft, ui.role:Get(), now) end
end

function selfPlay.OnGCMessage(data)
	return matchmaking.message(data)
end

function selfPlay.OnScriptsLoaded()
	localization.init()
	Engine.ExecuteCommand("-dota_camera_center_on_hero")
end

return selfPlay
