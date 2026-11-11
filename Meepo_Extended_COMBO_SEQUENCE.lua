-- 8.3.7: opening group Poof to main hero, then single-caster round-robin Poof and net chaining.
-- Tested with Lua 5.4 mocks; live Umbrella verification is still required.
-- Meepo Extended 8.3.7-combo / нативные страницы меню, компактный HUD, единый ввод и ограниченные кеши.
-- Восстановление атаки по реальному прогрессу; прежние механики и профиль Meepo_RU_8 сохранены.
-- Требуется проверка в текущем клиенте: локальные Lua-тесты не подтверждают работу игрового API.
-- Сохранено исходное ядро Umbrella / UC.Zone API v2 (Lua 5.4).
-- Старые MeepoV2 и их копии необходимо отключить: одновременно загружайте один скрипт.
-- Проверки в mock-среде не заменяют проверку внутри текущей сборки Umbrella.
local M = { NAME = "Meepo Extended", VERSION = "8.3.7-combo", CONFIG_NAME = "Meepo_RU_8" }
local A, UI, Combat, Farm, Orders, HUD = {}, {}, {}, {}, {}, {}
local S = {}
local Econ = {}
local Stable, Stack = {}, {}
local Tower, Finance = {}, {}
M.tower, M.finance = Tower, Finance
M.stable, M.stack = Stable, Stack
M.economy = Econ
local Hunt, Items, Heal = {}, {}, {}
local RunesAI, Push, Mega, Echo = {}, {}, {}, {}
M.runes, M.push, M.mega, M.echo = RunesAI, Push, Mega, Echo
M.hunt, M.items, M.heal = Hunt, Items, Heal
local D = {
    enabled = true, combo_all = true, combo_net = true, combo_poof = true,
    combo_radius = 260, combo_world_radius = 550, net_overlap_ms = 120,
    net_max_lead_ms = 1100, poof_require_root = false, combo_blink = true,
    combo_hex = true, combo_silence = true, combo_slow = true,
    farm_enabled = true, farm_mode = 0, farm_side = 0, farm_poof = true,
    farm_min_creeps = 2, farm_mana_pct = 30, farm_retreat_hp = 30,
    farm_resume_hp = 75, farm_avoid_enemies = true, manual_pause_ms = 2500,
    save_enabled = true, save_hp = 25, save_dig = true, save_mega = true,
    save_poof = true, hud = true, world_labels = true, debug_log = false,
    combo_key = "KEY_SPACE", farm_key = "KEY_F6", poof_cursor_key = "KEY_F",
    poof_self_key = "KEY_G",
    farm_strategy = 1, lane_safe_radius = 1800, lane_memory_sec = 12,
    lane_respect_allies = true, hunt_enabled = false, hunt_include_main = true,
    hunt_radius = 900, hunt_min_hp = 55, hunt_max_enemies = 1,
    hunt_timeout = 12, heal_mode = 2, items_enabled = true,
    items_offensive = true, items_defensive = true, items_resources = true,
    items_detection = true, items_unknown = true, items_refresher = false,
    items_toggles = false,
    combo_stops_farm = true, hex_mode = 0, hex_margin_ms = 180,
    runes_enabled = true, runes_radius = 600, runes_main = true,
    runes_bounty = true, runes_power = true, runes_wisdom = true,
    echo_enabled = true, echo_manta = true, echo_euls = true, echo_dig = true,
    echo_margin_ms = 60, mega_mode = 0, mega_group_hp = 40,
    mega_group_count = 2, push_enabled = false, push_min_hp = 60,
    push_danger_radius = 2200, push_response = 0, push_poof_escape = true,
    econ_enabled = true, econ_goal = 0, econ_xp_weight = 25,
    econ_ancients = true, econ_poof = true, econ_poof_save_ms = 350,
    econ_reserve_net = true, econ_travel_poof = true, econ_travel_save = 2,
    econ_resources = true, econ_midas = true, econ_watchdog = true,
    econ_stall_sec = 8, econ_details = true, econ_switch_pct = 20,
    stack_enabled = false, stack_second = 54, stack_distance = 1000,
    stack_min_hp = 45, stable_trace = false,
    tower_exit_margin = 140, finance_show = true, finance_x = 570, finance_y = 250,
    finance_start_sec = 60,
    hud_auto_position = true, hud_scale = 100, hud_right_margin = 24,
    hud_bottom_margin = 270, hud_hide_captured = true, hud_details = false,
}
M.defaults, M.state, M.ui = D, S, UI
M.combat, M.farm, M.orders, M.api = Combat, Farm, Orders, A

function A.call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    S.api_errors=S.api_errors or {}
    local text=tostring(a)
    local last=S.api_errors[#S.api_errors]
    if last and last.fn==tostring(fn) and last.text==text then
        last.count=last.count+1;last.time=S.now or 0
    else
        if #S.api_errors>=64 then table.remove(S.api_errors,1) end
        S.api_errors[#S.api_errors+1]={fn=tostring(fn),text=text,count=1,time=S.now or 0}
    end
    S.last_api_error=text
    return nil
end
function A.method(obj, name, ...)
    if not obj then return nil end
    local ok,fn=pcall(function() return obj[name] end)
    if not ok then S.last_api_error=tostring(fn);return nil end
    return A.call(fn,obj,...)
end
function A.number(v, fallback)
    local n = tonumber(v)
    if n and n == n and n ~= math.huge and n ~= -math.huge then return n end
    return fallback or 0
end
function A.now() return A.number(A.call(GameRules and GameRules.GetGameTime), 0) end
function A.enum(group, name)
    return Enum and Enum[group] and Enum[group][name] or nil
end
function A.vec(x, y, z) return Vector(x or 0, y or 0, z or 0) end
function A.copy(p) return p and A.vec(p.x, p.y, p.z) or nil end
function A.valid_position(p)
    if p==nil then return false end
    local ok,x,y,z=pcall(function() return p.x,p.y,p.z end)
    return ok and type(x)=="number" and type(y)=="number" and type(z)=="number"
        and x==x and y==y and z==z and math.abs(x)<50000 and math.abs(y)<50000 and math.abs(z)<50000
end
function A.manual(u,now)
    local id=A.id(u)
    return id~=nil and (now or S.now or A.now())<(S.manual_until[id] or -math.huge)
end
function A.distance2(a, b)
    if not a or not b then return math.huge end
    local x, y = a.x - b.x, a.y - b.y
    return x*x + y*y
end
function A.distance(a, b) return math.sqrt(A.distance2(a, b)) end
function A.pos(u) return u and A.call(Entity and Entity.GetAbsOrigin, u) or nil end
function A.id(u) return u and (A.call(Entity and Entity.GetIndex, u) or u) or nil end
function A.alive(u) return u ~= nil and A.call(Entity and Entity.IsAlive, u) == true end
function A.visible(u) return A.alive(u) and A.call(Entity.IsDormant, u) ~= true end
function A.team(u) return A.call(Entity and Entity.GetTeamNum, u) end
function A.name(u) return A.call(NPC and NPC.GetUnitName, u) or "" end
function A.hp(u)
    local max = A.number(A.call(Entity.GetMaxHealth, u), 0)
    return max > 0 and math.max(0, A.number(A.call(Entity.GetHealth, u), 0) / max * 100) or 0
end
function A.mana(u) return A.number(A.call(NPC.GetMana, u), 0) end
function A.mana_pct(u)
    local max = A.number(A.call(NPC.GetMaxMana, u), 0)
    return max > 0 and A.mana(u)/max*100 or 0
end
function A.has(u, name) return A.call(NPC.HasModifier, u, name) == true end
function A.state(u, name)
    local e = A.enum("ModifierState", name)
    return e ~= nil and A.call(NPC.HasState, u, e) == true
end
function A.disabled(u, item)
    if A.state(u,"MODIFIER_STATE_STUNNED") or A.state(u,"MODIFIER_STATE_HEXED")
        or A.state(u,"MODIFIER_STATE_COMMAND_RESTRICTED") then return true end
    if item then return A.state(u,"MODIFIER_STATE_MUTED") end
    return A.state(u,"MODIFIER_STATE_SILENCED") or A.call(NPC.IsSilenced,u) == true
end
function A.spell(u, name) return A.call(NPC.GetAbility, u, name) end
function A.item(u, name) return A.call(NPC.GetItem, u, name, true) end
function A.special(ab, names, fallback)
    for _, name in ipairs(names) do
        local v = A.number(A.call(Ability.GetSpecialValueFor, ab, name), 0)
        if v <= 0 then v = A.number(A.call(Ability.GetLevelSpecialValueFor, ab, name, -1), 0) end
        if v > 0 then return v end
    end
    return fallback
end
function A.ready(u, ab, item)
    if not A.alive(u) then return false, "Мипо мёртв" end
    if not ab then return false, "Способность не найдена" end
    if A.disabled(u, item) then return false, "Оглушение / безмолвие" end
    if A.call(Ability.IsHidden, ab) == true then return false, "Способность скрыта" end
    if A.call(Ability.IsActivated, ab) == false then return false, "Способность недоступна" end
    local level = A.call(Ability.GetLevel, ab)
    if not item and type(level)~="number" then return false,"API: неизвестен уровень способности" end
    if not item and level < 1 then return false, "Способность не изучена" end
    if A.call(Ability.IsInAbilityPhase, ab) == true or A.call(Ability.IsChannelling, ab) == true then
        return false, "Уже применяется"
    end
    local cooldown=A.call(Ability.GetCooldown,ab)
    local mana=A.call(NPC.GetMana,u)
    local cost=A.call(Ability.GetManaCost,ab)
    if type(cooldown)~="number" or cooldown~=cooldown or math.abs(cooldown)==math.huge
        or type(mana)~="number" or mana~=mana or math.abs(mana)==math.huge
        or type(cost)~="number" or cost~=cost or cost<0 or cost==math.huge then
        return false,"API: нет достоверных данных о готовности"
    end
    if cooldown > 0.04 then return false, "Перезарядка" end
    if mana < cost then return false, "Не хватает маны" end
    if type(Ability.IsCastable)~="function" then return false,"API: IsCastable недоступен" end
    local castable=A.call(Ability.IsCastable,ab,mana)
    if castable~=true then return false,"Система: применение недоступно" end
    return true
end
function A.range(u, ab, fallback)
    local r = A.number(A.call(Ability.GetCastRange, ab), fallback)
    if r <= 0 then r = fallback end
    return r + math.max(0, A.number(A.call(NPC.GetCastRangeBonus, u), 0))
end
function A.poof_time(ab)
    return A.special(ab, {"poof_cast_duration", "cast_duration"}, 1.5)
end
function A.poof_radius(ab) return A.special(ab, {"radius", "poof_radius"}, 375) end
function A.net_speed(ab) return A.special(ab, {"speed", "projectile_speed"}, 900) end
function A.mod_remaining(mod, now)
    if not mod then return 0 end
    local die = A.call(Modifier and Modifier.GetDieTime, mod)
    if type(die) == "number" and die >= now and die - now < 30 then return die - now end
    local duration = A.number(A.call(Modifier and Modifier.GetDuration, mod), 0)
    local applied = A.call(Modifier and Modifier.GetLastAppliedTime, mod)
        or A.call(Modifier and Modifier.GetCreationTime, mod)
    if type(applied) == "number" and duration > 0 then return math.max(0, applied + duration - now) end
    return 0
end
function A.root_remaining(target, now)
    local max = 0
    for _, name in ipairs({"modifier_meepo_earthbind", "modifier_meepo_earthbind_debuff", "modifier_meepo_earthbind_root"}) do
        local mod = A.call(NPC.GetModifier, target, name)
        if mod then max = math.max(max, A.mod_remaining(mod, now)) end
    end
    return max
end
function A.control_remaining(target, now)
    local max = A.root_remaining(target, now)
    for _, name in ipairs({"modifier_sheepstick_debuff", "modifier_abyssal_blade_stun", "modifier_rod_of_atos_debuff", "modifier_gleipnir_root"}) do
        max = math.max(max, A.mod_remaining(A.call(NPC.GetModifier,target,name),now))
    end
    return max
end
function A.enemy(u)
    return A.visible(u) and A.call(NPC.IsVisible,u) ~= false and A.team(u) ~= S.team and A.team(u) ~= nil
        and A.call(Entity.IsHero,u) == true and A.call(NPC.IsIllusion,u) ~= true
end
function A.enemy_count_at(pos, radius)
    if not pos then return math.huge end
    if not S.heroes_valid then return math.huge end
    local count, r2 = 0, radius*radius
    for _, u in ipairs(S.heroes or {}) do
        if A.enemy(u) and A.distance2(pos,A.pos(u)) <= r2 then count = count + 1 end
    end
    return count
end
function A.log(text, force)
    if not force and not UI.get("debug_log") then return end
    local now = A.now()
    if force and text == S.last_log and now < (S.next_log or -math.huge) then return end
    S.last_log, S.next_log = text, now + 3
    if type(print) == "function" then print("["..M.NAME.."] " .. tostring(text)) end
end
function M.reset()
    for k in pairs(S) do S[k] = nil end
    S.units, S.unit_ids, S.heroes, S.acted, S.locks = {}, {}, {}, {}, {}
    S.spell_next, S.orders, S.manual_until, S.hp_samples = {}, {}, {}, {}
    S.camps, S.camp_empty, S.assignment, S.healing, S.failures = {}, {}, {}, {}, {}
    S.camp_knowledge = {}
    S.combo_status, S.farm_status = "Ожидание клавиши комбо", "Ожидание клонов"
    S.metrics = {orders=0, nets=0, poofs=0, failures=0, hero_scans=0, npc_scans=0}
    S.key_prev, S.key_pending = {}, {}
    S.enemy_memory, S.heal_records, S.tango_until, S.item_diagnostics = {}, {}, {}, {}
    S.metrics.items = 0
    S.parking, S.rune_claims, S.rune_busy, S.push_escape, S.rune_retry = {}, {}, {}, {}, {}
    S.echo_casts, S.echo_seen, S.attack_commit = {}, {}, {}
    S.econ_cache, S.econ_profiles, S.econ_info, S.econ_watch = {}, {}, {}, {}
    S.econ_blacklist, S.econ_retries, S.econ_route_cache = {}, {}, {}
    S.econ_plan, S.econ_metrics = {}, {evaluations=0,plans=0,nodes=0,stalls=0,travel_poofs=0,midas=0}
    S.econ_cycle=0
    S.creep_owner,S.farm_retreat,S.stack_units,S.stack_camps,S.stack_attempts={},{},{},{},{}
    S.stack_results,S.farm_trace={},{}
    S.stack_claims,S.ally_camp,S.poof_watch,S.poof_block={},{},{},{}
    S.tower_shots,S.tower_evade,S.tower_seq,S.tower_hits={},{},0,{}
    S.finance,S.finance_buffer={},{}
    S.motion,S.order_next,S.inventory_cache,S.item_next={},{},{},{}
    S.econ_retry_time,S.net_misses,S.net_retry_until={},{},{}
    S.api_errors={}
    S.combo_blocked=false
end
M.reset()

-- Настройки: новое имя профиля не подхватывает ошибочные значения MeepoV2.
function UI.default(key)
    local d = D[key]
    if type(d) == "string" and key:find("_key$",1) then
        return A.enum("ButtonCode", d) or A.enum("ButtonCode", "KEY_NONE")
            or A.enum("ButtonCode", "BUTTON_CODE_INVALID")
    end
    return d
end
function UI.load(key)
    local d = UI.default(key)
    if type(d) == "boolean" then
        local v = A.call(Config and Config.ReadInt,M.CONFIG_NAME,key,d and 1 or 0)
        if v == nil then return d end
        return v ~= 0
    elseif type(d) == "number" then
        return A.number(A.call(Config and Config.ReadInt,M.CONFIG_NAME,key,d),d)
    end
    return d
end
function UI.get(key)
    local w = UI[key]
    local v = w and A.method(w,"Get")
    if v ~= nil then return v end
    if UI.values and UI.values[key] ~= nil then return UI.values[key] end
    return UI.default(key)
end
function UI.save(key)
    local v = UI.get(key)
    if type(v) == "boolean" then v = v and 1 or 0 end
    if type(v) == "number" then A.call(Config and Config.WriteInt,M.CONFIG_NAME,key,v) end
end
-- Одна точка записи: виджет, резервное значение, профиль и индикатор клавиши.
function UI.sync_farm_bind()
    local value=UI.get("farm_enabled")==true
    A.method(UI.farm_key,"SetToggled",value)
    A.method(UI.farm_key,"Properties","Автофарм",value and "Включён" or "Выключен",true)
end
function UI.changed(key)
    UI.values[key]=UI.get(key)
    if key=="farm_enabled" then
        S.farm_next=-math.huge
        S.farm_status=UI.values[key] and "Автофарм включён" or "Автофарм выключен"
        UI.sync_farm_bind()
    elseif key=="farm_key" then
        S.key_prev[key]=UI.down(key);S.key_pending[key]=nil
        UI.sync_farm_bind()
    end
    if key=="farm_enabled" or key=="push_enabled" then UI.sync_push() end
    UI.save(key)
end
function UI.set(key,value)
    if UI.get(key)==value then return false end
    UI.values[key]=value
    UI.setting=true
    A.method(UI[key],"Set",value)
    UI.setting=false
    UI.changed(key)
    return true
end
-- Отключается только главный переключатель сплитпуша, не его настройки.
function UI.push_active()
    return UI.get("farm_enabled")==true and UI.get("push_enabled")==true
end
function UI.sync_push()
    if UI.syncing_push then return end
    local farm,push=UI.get("farm_enabled")==true,UI.get("push_enabled")==true
    if UI.last_push_farm==farm and UI.last_push_value==push and UI.last_push_widget==UI.push_enabled then return end
    UI.syncing_push=true
    if not farm then
        if push then
            UI.set("push_enabled",false)
            push=false
        end
        S.tower_evade,S.push_escape={},{}
    end
    A.method(UI.push_enabled,"Disabled",not farm)
    UI.last_push_farm,UI.last_push_value,UI.last_push_widget=farm,push,UI.push_enabled
    UI.syncing_push=false
end
-- Локализация вывода: внутренние фазы и имена сущностей остаются прежними.
UI.phase_names = {
    idle="Ожидание", approach="Подход", combat="Атака", search="Поиск",
    confirm_empty="Проверка лагеря", done="Завершено", lane="Линия", push="Сплитпуш",
    stack_pull="Отвод", stack_verify="Проверка стака", tower_exit="Отход от башни",
    tag="Агро", pull="Отвод", verify="Проверка", root_wait="Ожидание сетки",
    gather="Сбор", fight="Бой",
}
function UI.phase_name(phase)
    return UI.phase_names[phase] or "Ожидание"
end
UI.hero_names = {
    abaddon="Абаддон", abyssal_underlord="Андерлорд", alchemist="Алхимик", ancient_apparition="Древний призрак",
    antimage="Антимаг", arc_warden="Арк Варден", axe="Акс", bane="Бэйн", batrider="Бэтрайдер",
    beastmaster="Повелитель зверей", bloodseeker="Бладсикер", bounty_hunter="Охотник за головами",
    brewmaster="Пивовар", bristleback="Бристлбек", broodmother="Праматерь", centaur="Кентавр",
    chaos_knight="Рыцарь хаоса", chen="Чен", clinkz="Клинкз", crystal_maiden="Кристал Мэйден",
    dark_seer="Дарк Сир", dark_willow="Тёмная ива", dawnbreaker="Заря", dazzle="Даззл",
    death_prophet="Пророк смерти", disruptor="Дизраптор", doom_bringer="Дум", dragon_knight="Драконий рыцарь",
    drow_ranger="Дроу Рейнджер", earth_spirit="Дух земли", earthshaker="Шейкер", elder_titan="Древний титан",
    ember_spirit="Дух огня", enchantress="Чаровница", enigma="Энигма", faceless_void="Безликий",
    furion="Лесной пророк", grimstroke="Гримстроук", gyrocopter="Гирокоптер", hoodwink="Худвинк",
    huskar="Хускар", invoker="Инвокер", jakiro="Джакиро", juggernaut="Джаггернаут",
    keeper_of_the_light="Хранитель света", kez="Кез", kunkka="Кункка", legion_commander="Командир легиона",
    leshrac="Лешрак", lich="Лич", life_stealer="Лайфстилер", lina="Лина", lion="Лион",
    lone_druid="Одинокий друид", luna="Луна", lycan="Ликан", magnataur="Магнус", marci="Марси",
    mars="Марс", medusa="Медуза", meepo="Мипо", mirana="Мирана", monkey_king="Король обезьян",
    morphling="Морфлинг", muerta="Муэрта", naga_siren="Нага", necrolyte="Некрофос",
    nevermore="Шэдоу Финд", night_stalker="Ночной охотник", nyx_assassin="Никс", obsidian_destroyer="Астральный разрушитель",
    ogre_magi="Огр-маг", omniknight="Омникнайт", oracle="Оракул", pangolier="Пангольер",
    phantom_assassin="Фантомная убийца", phantom_lancer="Фантомный копейщик", phoenix="Феникс",
    primal_beast="Первобытный зверь", puck="Пак", pudge="Пудж", pugna="Пугна", queenofpain="Королева боли",
    rattletrap="Клокверк", razor="Разор", riki="Рики", ringmaster="Рингмастер", rubick="Рубик",
    sand_king="Песчаный король", shadow_demon="Теневой демон", shadow_shaman="Теневой шаман",
    shredder="Лесоруб", silencer="Сайленсер", skeleton_king="Король-призрак", skywrath_mage="Небесный маг",
    slardar="Слардар", slark="Сларк", snapfire="Снэпфайр", sniper="Снайпер", spectre="Спектра",
    spirit_breaker="Баратрум", storm_spirit="Дух бури", sven="Свен", techies="Минёры", templar_assassin="Храмовница",
    terrorblade="Террорблейд", tidehunter="Тайдхантер", tinker="Тинкер", tiny="Тини", treant="Энт",
    troll_warlord="Полководец троллей", tusk="Туск", undying="Андаинг", ursa="Урса", vengefulspirit="Мстительный дух",
    venomancer="Веномансер", viper="Вайпер", visage="Визаж", void_spirit="Дух пустоты", warlock="Чернокнижник",
    weaver="Ткач", windrunner="Виндрейнджер", winter_wyvern="Зимняя виверна", wisp="Ио",
    witch_doctor="Знахарь", zuus="Зевс",
}
function UI.hero_name(unit)
    local name=A.name(unit):gsub("npc_dota_hero_","")
    return UI.hero_names[name] or ("Герой №"..tostring(A.id(unit) or "—"))
end

function UI.group(name, section)
    -- Скрипты → секция Meepo → Meepo Extended → самостоятельная категория → группа.
    local page=section or "ОБЩИЕ"
    return A.call(Menu and Menu.Create,"Scripts","Meepo",M.NAME,page,name)
end
function UI.add(group, kind, key, label, a, b)
    local v, w = UI.load(key), nil
    UI.values[key] = v
    if kind == "Switch" then w = A.method(group,kind,label,v)
    elseif kind == "Slider" then
        v = math.max(a,math.min(b,A.number(v,UI.default(key))))
        UI.values[key] = v; w = A.method(group,kind,label,a,b,v,"%d")
    elseif kind == "Combo" then
        v = math.max(0,math.min(#a-1,A.number(v,0)));UI.values[key] = v
        w = A.method(group,kind,label,a,v)
    elseif kind == "Bind" then w = A.method(group,kind,label,v) end
    UI[key] = w
    if w then A.method(w,"SetCallback",function()
        if not UI.setting then UI.changed(key) end
    end) end
    return w
end
function UI.reset_defaults()
    for key in pairs(D) do
        local v = UI.default(key)
        UI.values[key] = v
        A.method(UI[key],"Set",v)
        UI.save(key)
    end
    M.reset()
    UI.last_push_farm=nil;UI.sync_push();UI.sync_farm_bind()
    A.log("Загружен стартовый профиль: фармят клоны; сетка и Пуф включены.",true)
end
function UI.init()
    UI.values = {}
    local g

    g = UI.group("Основное","ОБЩИЕ")
    UI.add(g,"Switch","enabled","Включить скрипт")
    A.method(g,"Button","Сбросить к стартовому профилю",UI.reset_defaults)

    g = UI.group("Горячие клавиши","ОБЩИЕ")
    UI.add(g,"Bind","combo_key","Комбо — удерживать [Пробел]")
    UI.add(g,"Bind","farm_key","Автофарм — переключить [F6]")
    UI.add(g,"Bind","poof_cursor_key","Пуф к Мипо у курсора [F]")
    UI.add(g,"Bind","poof_self_key","Пуф на месте [G]")

    g = UI.group("Режим и маршруты","ФАРМ")
    UI.add(g,"Switch","farm_enabled","Включить автофарм")
    UI.add(g,"Combo","farm_mode","Кто фармит",{"Только клоны","Все Мипо","Только невыбранные"})
    UI.add(g,"Combo","farm_strategy","Режим фарма",{"Только нейтралы","Адаптивный","Только линии"})
    UI.add(g,"Combo","farm_side","Сторона карты",{"Своя половина карты","Вся карта"})
    UI.add(g,"Switch","farm_avoid_enemies","Избегать видимых врагов")
    UI.add(g,"Slider","lane_safe_radius","Безопасность линии: радиус, ед.",900,3000)
    UI.add(g,"Slider","lane_memory_sec","Память о замеченном враге, с",3,30)
    UI.add(g,"Switch","lane_respect_allies","Не мешать союзникам на линии")

    g = UI.group("Урон и запас маны","ФАРМ")
    UI.add(g,"Switch","farm_poof","Пуф для урона нейтралам")
    UI.add(g,"Slider","farm_min_creeps","Минимум нейтралов для Пуф",1,6)
    UI.add(g,"Slider","farm_mana_pct","Мана после Пуф: минимум, %",0,80)
    UI.add(g,"Switch","econ_poof","Оценивать выгоду Пуф")
    UI.add(g,"Slider","econ_poof_save_ms","Пуф: минимум экономии, мс",100,1500)
    UI.add(g,"Switch","econ_reserve_net","Беречь ману на аварийную сетку")

    g = UI.group("Экономический план","ФАРМ")
    UI.add(g,"Switch","econ_enabled","Включить планировщик фарма")
    UI.add(g,"Combo","econ_goal","Цель планировщика",{"Баланс золота и опыта","Максимум золота","Максимум опыта"})
    UI.add(g,"Slider","econ_xp_weight","Вес опыта в балансе, %",0,100)
    UI.add(g,"Switch","econ_ancients","Древние: оценивать силу и ОЗ")
    UI.add(g,"Slider","econ_switch_pct","Порог смены маршрута, %",10,50)

    g = UI.group("Автостак","ФАРМ")
    UI.add(g,"Switch","stack_enabled","Стакать текущий лагерь")
    UI.add(g,"Slider","stack_second","Секунда начала агро",50,57)
    UI.add(g,"Slider","stack_distance","Дистанция отвода, ед.",800,1500)
    UI.add(g,"Slider","stack_min_hp","Минимум ОЗ для стака, %",30,75)

    g = UI.group("Сплитпуш","ФАРМ")
    UI.add(g,"Switch","push_enabled","Линии и атака строений")
    UI.add(g,"Slider","push_min_hp","Минимум ОЗ для сплитпуша, %",40,90)
    UI.add(g,"Slider","push_danger_radius","Радиус реакции на врага, ед.",1200,3500)
    UI.add(g,"Combo","push_response","Реакция на защитника",{"Отступать","Преимущество: сетка и сбор"})
    UI.add(g,"Switch","push_poof_escape","Уходить Пуф к безопасному Мипо")
    UI.add(g,"Slider","tower_exit_margin","Запас выхода от башни, ед.",80,300)

    g = UI.group("Управление Мипо","ПЕРЕДВИЖЕНИЕ")
    UI.add(g,"Slider","manual_pause_ms","Пауза после ручной команды, мс",500,6000)

    g = UI.group("Лечение и возврат","ПЕРЕДВИЖЕНИЕ")
    UI.add(g,"Combo","heal_mode","Способ лечения",{"Фонтан","Танго, иначе фонтан","По оценке выгоды"})
    UI.add(g,"Slider","farm_retreat_hp","Уходить лечиться при ОЗ, %",10,60)
    UI.add(g,"Slider","farm_resume_hp","Возобновлять фарм при ОЗ, %",50,100)
    UI.add(g,"Switch","econ_resources","Ресурсы вместо похода на базу")
    UI.add(g,"Switch","econ_travel_poof","Пуф для выгодного перехода")
    UI.add(g,"Slider","econ_travel_save","Переход Пуф: экономия пути, с",1,8)

    g = UI.group("Подбор рун","ПЕРЕДВИЖЕНИЕ")
    UI.add(g,"Switch","runes_enabled","Подбирать руны вне боя")
    UI.add(g,"Slider","runes_radius","Максимальный крюк к руне, ед.",150,1000)
    UI.add(g,"Switch","runes_main","Разрешить главному Мипо")
    UI.add(g,"Switch","runes_bounty","Руны богатства")
    UI.add(g,"Switch","runes_power","Боевые руны и вода")
    UI.add(g,"Switch","runes_wisdom","Руны мудрости")

    g = UI.group("Комбо и способности","БОЙ")
    UI.add(g,"Switch","combo_all","Комбо всеми Мипо")
    UI.add(g,"Switch","combo_net","Цепочка сеток")
    UI.add(g,"Switch","combo_poof","Пуф в комбо")
    UI.add(g,"Switch","poof_require_root","Пуф только под контроль")
    UI.add(g,"Switch","combo_blink","Прыжок для сближения")
    UI.add(g,"Switch","combo_hex","Использовать Хекс")
    UI.add(g,"Switch","combo_silence","Орчид / Бладторн")
    UI.add(g,"Switch","combo_slow","Диффузал / Дисперсер / Атос")

    g = UI.group("Цель и цепочка контроля","БОЙ")
    UI.add(g,"Slider","net_overlap_ms","Запас цепочки сеток, мс",50,350)
    UI.add(g,"Combo","hex_mode","Момент применения Хекс",{"Умно: угроза / конец контроля","При первой возможности","К концу контроля"})
    UI.add(g,"Slider","hex_margin_ms","Запас передачи контроля, мс",80,350)

    g = UI.group("Активные предметы","БОЙ")
    UI.add(g,"Switch","items_enabled","Автоматические активные слоты")
    UI.add(g,"Switch","items_offensive","Урон и контроль")
    UI.add(g,"Switch","items_defensive","Защитные предметы")
    UI.add(g,"Switch","items_resources","Лечение и мана")
    UI.add(g,"Switch","items_detection","Пыль по невидимой цели")
    UI.add(g,"Switch","econ_midas","Свой Мидас по выгодной цели")

    g = UI.group("Спасение","БОЙ")
    UI.add(g,"Switch","save_enabled","Включить автоспасение")
    UI.add(g,"Slider","save_hp","Порог спасения: ОЗ, %",5,45)
    UI.add(g,"Switch","save_dig","Использовать закопку")
    UI.add(g,"Switch","save_mega","Использовать Мегамипо")
    UI.add(g,"Combo","mega_mode","Приоритет закопки / мегамипо",{"Умно: группе нужен мегамипо","Закопка, затем мегамипо","Мегамипо, затем закопка"})
    UI.add(g,"Slider","mega_group_hp","Спасение группы: порог ОЗ, %",25,60)
    UI.add(g,"Slider","mega_group_count","Раненых для группового мегамипо",2,4)
    UI.add(g,"Switch","save_poof","Пуф к безопасному Мипо")

    g = UI.group("Автонападение","БОЙ")
    UI.add(g,"Switch","hunt_enabled","Нападать во время фарма")
    UI.add(g,"Switch","hunt_include_main","Подключать главного через Пуф")
    UI.add(g,"Slider","hunt_radius","Радиус поиска клоном, ед.",400,1600)
    UI.add(g,"Slider","hunt_min_hp","Минимум ОЗ участника, %",35,90)
    UI.add(g,"Slider","hunt_max_enemies","Максимум врагов рядом",1,3)
    UI.add(g,"Slider","hunt_timeout","Лимит одного нападения, с",5,25)

    g = UI.group("Защита от Эхо","БОЙ")
    UI.add(g,"Switch","echo_enabled","Уклоняться от предкаста Эхо")
    UI.add(g,"Switch","echo_manta","Манта: окно неуязвимости")
    UI.add(g,"Switch","echo_euls","Эул / Винд Вейкер на себя")
    UI.add(g,"Switch","echo_dig","Закопка, если успевает")
    UI.add(g,"Slider","echo_margin_ms","Запас времени уклонения, мс",30,90)

    g = UI.group("Панели и размещение","ВИЗУАЛЫ")
    UI.add(g,"Switch","hud","Панель состояния")
    UI.add(g,"Switch","hud_details","Подробные статусы в панели")
    UI.add(g,"Switch","hud_auto_position","Автоматическое размещение справа")
    UI.add(g,"Slider","hud_scale","Масштаб панелей, %",80,150)
    UI.add(g,"Slider","hud_right_margin","Отступ от правого края, пикс.",8,600)
    UI.add(g,"Slider","hud_bottom_margin","Запас над нижним интерфейсом, пикс.",160,500)
    UI.add(g,"Switch","hud_hide_captured","Скрывать при открытии магазина / меню")

    g = UI.group("Надписи над Мипо","ВИЗУАЛЫ")
    UI.add(g,"Switch","world_labels","Показывать статусы над Мипо")
    UI.add(g,"Switch","econ_details","Показывать прогноз и причины действий")

    g = UI.group("Статистика золота","ВИЗУАЛЫ")
    UI.add(g,"Switch","finance_show","Показывать панель золота")
    UI.add(g,"Slider","finance_x","Ручное положение: по горизонтали",0,7680)
    UI.add(g,"Slider","finance_y","Ручное положение: по вертикали",0,4320)
    UI.add(g,"Slider","finance_start_sec","Начало замера после старта, с",0,180)
    A.method(g,"Button","Начать новый замер",function() Finance.restart() end)

    g = UI.group("Восстановление фарма","ДОПОЛНИТЕЛЬНО")
    UI.add(g,"Switch","econ_watchdog","Проверять прогресс задания")
    UI.add(g,"Slider","econ_stall_sec","Порог отсутствия прогресса, с",5,15)

    g = UI.group("Редкие активные предметы","ДОПОЛНИТЕЛЬНО")
    UI.add(g,"Switch","items_unknown","Другие боевые предметы")
    UI.add(g,"Switch","items_refresher","Разрешить Рефрешер")
    UI.add(g,"Switch","items_toggles","Разрешить Армлет / Радианс")

    g = UI.group("Информация и диагностика","ДОПОЛНИТЕЛЬНО")
    UI.add(g,"Switch","debug_log","Подробности в консоль")
    UI.add(g,"Switch","stable_trace","Фазы и приказы фарма в консоль")
    -- Пояснения не занимают строки среди активных настроек.
    local tips={
        enabled="Одновременно загружайте только одну версию скрипта.",
        farm_key="Каждое новое нажатие меняет состояние один раз. Удержание не повторяет переключение.",
        farm_enabled="Выключение прекращает выдачу новых приказов фарма. Уже отданный игровой приказ сам по себе не отменяется.",
        farm_poof="Пуф не отменяет защищённый замах атаки.",
        econ_enabled="Прогноз награды, пути, ресурсов и риска — не измеренный доход.",
        stack_enabled="Удар → отвод → проверка → свой лагерь. Геометрия отвода подходит не всем лагерям.",
        push_enabled="Требуется автофарм. Башня атакуется после подтверждённого снаряда по крипу. При агро: переагр, затем выход; первый снаряд уже может лететь в Мипо.",
        manual_pause_ms="Ручной приказ приостанавливает этого Мипо. Во время комбо ручная команда отменяет удерживаемое комбо до отпускания клавиши.",
        runes_enabled="Только видимые руны и безопасный крюк вне боя.",
        net_overlap_ms="Следующая сетка планируется к завершению действующего контроля.",
        items_enabled="Рюкзак, телепорт, варды и дым не используются. Редкие активные предметы — в разделе «ДОПОЛНИТЕЛЬНО».",
        save_enabled="Полное здоровье и один враг рядом сами по себе не запускают спасение.",
        hunt_enabled="Сетка → подтверждение попадания → сбор → бой.",
        echo_enabled="Только наблюдаемый незавершённый предкаст. Мгновенный Эхо нельзя гарантированно избежать. БКБ не даёт неуязвимости.",
        econ_watchdog="Восстановление по реальному отсутствию прогресса задания.",
        items_unknown="Допуск по данным игрового интерфейса, без выдуманных свойств предметов.",
        finance_show="Статистика игрока; клоны не умножают доход. Не прогноз маршрута.",
        finance_x="Используется при выключенном автоматическом размещении. Координаты ограничиваются экраном.",
        finance_y="Ручная координата панели золота; панель состояния размещается рядом без наложения.",
        hud_auto_position="Панели справа над нижним интерфейсом. На низком экране могут стоять рядом. Отступы настраиваются под ваш игровой масштаб.",
        hud_hide_captured="Ввод занят чатом, магазином, меню или окном игры — панели скрываются, чтобы не перекрывать управление.",
        hud_details="Полные статусы сетки, Пуф, лечения, башен, нападения и экономического планировщика.",
    }
    for key,text in pairs(tips) do A.method(UI[key],"ToolTip",text) end
    if not UI.combo_key then A.log("Меню недоступно: используется резервная клавиша Пробел.",true) end
end
UI.init()
UI.sync_push()
UI.sync_farm_bind()
function UI.down(key)
    local w=UI[key]
    local first,second=A.method(w,"Buttons")
    if first==nil then first=UI.get(key) end
    local none=A.enum("ButtonCode","KEY_NONE")
    local invalid=A.enum("ButtonCode","BUTTON_CODE_INVALID")
    if type(first)=="number" and first~=none and first~=invalid and Input and type(Input.IsKeyDown)=="function" then
        local a=A.call(Input.IsKeyDown,first,true)
        if a~=nil then
            if type(second)=="number" and second~=none and second~=invalid then
                return a==true and A.call(Input.IsKeyDown,second,true)==true
            end
            return a==true
        end
    end
    return A.method(w,"IsDown")==true
end
function UI.input_captured()
    return A.call(Input and Input.IsInputCaptured)==true or A.call(Input and Input.IsPopupOpen)==true
        or A.call(Menu and Menu.Opened)==true
end
function UI.poll_keys(captured)
    -- До кадрового/логического ограничителя: отпускание нельзя пропустить на паузе.
    -- Захваченные клавиши отслеживаются физически, но не запускают действия после закрытия чата.
    for _,key in ipairs({"farm_key","poof_cursor_key","poof_self_key"}) do
        local down=UI.down(key)
        local was=S.key_prev[key]==true
        S.key_prev[key]=down
        if captured then S.key_pending[key]=nil
        elseif down and not was then S.key_pending[key]=true end
    end
end
function UI.pressed(key)
    local pressed=S.key_pending[key]==true
    S.key_pending[key]=nil
    return pressed
end
function M.collect(now)
    if now<(S.next_collect or -math.huge) then return end
    S.next_collect=now+.075
    local list = A.call(Heroes and Heroes.GetAll)
    S.heroes_valid = type(list) == "table"
    S.heroes = S.heroes_valid and list or {}
    S.metrics.hero_scans = S.metrics.hero_scans + 1
    local units, ids = {}, {}
    local pid = S.player and A.call(Player and Player.GetPlayerID,S.player)
    local function add(u)
        if not A.alive(u) or A.name(u) ~= "npc_dota_hero_meepo" or A.team(u) ~= S.team
            or A.call(NPC.IsIllusion,u) == true then return end
        if u ~= S.hero then
            local owner = A.call(NPC.GetOwnerNPC,u)
            local controllable = pid and pid >= 0 and A.call(NPC.IsControllableByPlayer,u,pid)
            if controllable == false then return end
            -- Missing controllability metadata is not permission to command an allied Meepo.
            if controllable~=true and (not owner or A.id(owner)~=A.id(S.hero)) then return end
            if owner and A.name(owner) == "npc_dota_hero_meepo" and A.id(owner) ~= A.id(S.hero) then return end
        end
        local id = A.id(u)
        if id and not ids[id] then units[#units+1] = u; ids[id] = true end
    end
    add(S.hero)
    for _, u in ipairs(S.heroes) do add(u) end
    table.sort(units,function(a,b)
        if a == S.hero then return b ~= S.hero end
        if b == S.hero then return false end
        return tostring(A.id(a)) < tostring(A.id(b))
    end)
    S.units, S.unit_ids = units, ids
    for id in pairs(S.locks) do if not ids[id] then S.locks[id] = nil end end
    for _, name in ipairs({"assignment","healing","manual_until","orders","hp_samples"}) do
        for id in pairs(S[name]) do if not ids[id] then S[name][id] = nil end end
    end
    for _,enemy in ipairs(S.heroes) do

        if A.enemy(enemy) then
            local id,pos=A.id(enemy),A.pos(enemy)
            if A.valid_position(pos) then
                S.enemy_memory[id]={pos=A.copy(pos),time=now}
                local old=S.motion[id];local rec={unit=enemy,pos=A.copy(pos),time=now}
                local dt=old and now-old.time or 0
                if old and old.unit==enemy and dt>=.025 and dt<=.4 then
                    local dx,dy=pos.x-old.pos.x,pos.y-old.pos.y
                    local speed=math.max(1,A.number(A.call(NPC.GetMoveSpeed,enemy),300))
                    if dx*dx+dy*dy<=(speed*dt*1.8+24)^2 then
                        local vx,vy=dx/dt,dy/dt
                        local length=math.sqrt(vx*vx+vy*vy)
                        if length>speed and length>0 then vx,vy=vx*speed/length,vy*speed/length end
                        rec.vx,rec.vy=vx,vy
                    end
                end
                S.motion[id]=rec
            end
        end
    end

    for id,rec in pairs(S.enemy_memory) do if now-rec.time>35 then S.enemy_memory[id]=nil end end
    for id,rec in pairs(S.motion) do if now-rec.time>.5 then S.motion[id]=nil end end
    if now>=(S.next_prune or -math.huge) then
        S.next_prune=now+5
        for key,t in pairs(S.econ_blacklist) do if now>=t then S.econ_blacklist[key]=nil end end
        for key,t in pairs(S.rune_retry) do if now>=t then S.rune_retry[key]=nil end end
        for key,t in pairs(S.spell_next) do if now>t+10 then S.spell_next[key]=nil end end
        for key,t in pairs(S.econ_retry_time) do
            if now-t>90 then S.econ_retry_time[key],S.econ_retries[key]=nil,nil end
        end
        for _,name in ipairs({"order_next","inventory_cache","item_next"}) do
            for id in pairs(S[name]) do if not ids[id] then S[name][id]=nil end end
        end
    end
    S.selected = {}
    for _,u in ipairs(A.call(Player and Player.GetSelectedUnits,S.player) or {}) do S.selected[A.id(u)] = true end
end
function Orders.busy(u, priority, now)
    local id = A.id(u)
    if S.acted[id] or A.manual(u,now) then return true end
    if priority<100 and priority~=80 and now<(S.order_next[id] or -math.huge) then return true end
    local lock = S.locks[id]
    if lock then
        local phase = A.call(Ability.IsInAbilityPhase,lock.ability) == true
            or A.call(Ability.IsChannelling,lock.ability) == true
        if phase then lock.observed = true end
        if phase and priority<=lock.priority then return true end
        local cooldown=A.call(Ability.GetCooldown,lock.ability)
        local spent=type(cooldown)=="number" and cooldown>.05
        local unconfirmed=not phase and not spent and not lock.observed
            and now>=(lock.ack_until or lock.until_time)
        if not phase and (unconfirmed or now>=lock.until_time or (lock.observed and now>lock.sent+.12)) then
            S.locks[id]=nil
            if unconfirmed then
                S.last_cast_notice="Применение не подтверждено: "..tostring(lock.tag or "способность")
                S.metrics.unconfirmed_casts=(S.metrics.unconfirmed_casts or 0)+1
            end
        elseif priority <= lock.priority then return true end
    end
    -- Не отменяем настоящий TP или ручной канал из-за устаревшего локального таймера.
    local channel = A.call(NPC.GetChannellingAbility,u)
    if channel and A.call(Ability.IsChannelling,channel) == true and priority < 100 then return true end
    for _,name in ipairs({"meepo_poof","meepo_petrify","item_tpscroll"}) do
        local ab = name == "item_tpscroll" and A.item(u,name) or A.spell(u,name)
        if ab and (A.call(Ability.IsInAbilityPhase,ab) == true or A.call(Ability.IsChannelling,ab) == true)
            and priority < 100 then return true end
    end
    if A.has(u,"modifier_meepo_petrify") or A.state(u,"MODIFIER_STATE_OUT_OF_GAME") then return true end
    return false
end
function Orders.issue(u, kind, target, pos, ability, priority, tag, duration, item)
    local now, id = S.now or A.now(), A.id(u)
    if not UI.get("enabled") or not S.player or not A.alive(u) or not S.unit_ids[id] then return false end
    if pos and not A.valid_position(pos) then S.last_error="Некорректная позиция приказа";return false end
    if Orders.busy(u,priority,now) then return false end
    if ability then
        local ready, reason = A.ready(u,ability,item)
        if not ready then S.failures[id] = reason; return false end
        local owner = A.call(Ability.GetOwner,ability)
        if owner and A.id(owner) ~= id then S.failures[id] = "Чужая способность"; return false end
        local key = tostring(id)..":"..tostring(A.call(Ability.GetName,ability) or ability)
        if now < (S.spell_next[key] or -math.huge) then return false end
    end
    local tree_target = target and item and
        (A.call(Ability.GetName,ability)=="item_tango" or A.call(Ability.GetName,ability)=="item_tango_single")
        and A.call(Tree and Tree.IsActive,target)==true
    local rune_target = target and kind=="DOTA_UNIT_ORDER_PICKUP_RUNE"
        and A.call(Runes and Runes.Contains,target)==true
    if target and not tree_target and not rune_target and not A.alive(target) then return false end
    local order = A.enum("UnitOrder",kind)
    local issuer = A.enum("PlayerOrderIssuer","DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY")
    if not order or issuer == nil or not Player or type(Player.PrepareUnitOrders) ~= "function" then
        S.last_error = "Отправка одиночных приказов недоступна"; return false
    end
    -- The documented identifier distinguishes this script from human orders.
    -- The issuing flag is only a synchronous re-entrancy guard.
    S.issuing=(S.issuing or 0)+1
    local ok,result = pcall(Player.PrepareUnitOrders,S.player,order,target,pos or A.pos(u) or A.vec(),
        ability,issuer,u,false,false,true,false,"meepo_ru8:"..tag,false)
    S.issuing=S.issuing-1
    if not ok or result == false then
        S.metrics.failures = S.metrics.failures+1
        S.last_error = not ok and ("Ошибка приказа: "..tostring(result)) or "Игровой интерфейс отклонил приказ"
        A.log(S.last_error,true)
        return false
    end
    -- Любой принятый приказ заменяет предыдущий, не только способность.
    -- Иначе, например, подбор руны оставляет фиктивную «атаку» в кеше.
    S.orders[id],S.attack_commit[id] = nil,nil
    S.acted[id] = true
    S.order_next[id]=now+.10
    S.metrics.orders = S.metrics.orders+1
    S.failures[id] = nil
    if priority<=45 then Stable.trace(u,tag,target,pos) end
    if ability then
        local key = tostring(id)..":"..tostring(A.call(Ability.GetName,ability) or ability)
        -- Failed/unacknowledged casts must not be retried every few frames.
        S.spell_next[key] = now + (A.call(Ability.GetName,ability)=="meepo_earthbind" and .75 or .45)
        local turn=math.max(0,math.min(.65,A.number(A.call(NPC.GetTimeToFacePosition,u,
            pos or (target and A.pos(target)) or A.pos(u)),0)))
        local hold=math.max(.12,duration or .15)
        S.locks[id] = {ability=ability,priority=priority,sent=now,
            ack_until=now+math.min(hold,turn+.38),until_time=now+hold,tag=tag}
    end
    return true
end
function Orders.cast(u, ab, target, pos, priority, tag, duration, item)
    local kind = pos and "DOTA_UNIT_ORDER_CAST_POSITION"
        or target and "DOTA_UNIT_ORDER_CAST_TARGET" or "DOTA_UNIT_ORDER_CAST_NO_TARGET"
    return Orders.issue(u,kind,target,pos,ab,priority,tag,duration,item)
end
function Orders.walk(u,pos,priority,tag)
    if not pos then return false end
    local now,id=S.now,A.id(u);local last=S.orders[id]
    if last and last.kind=="move" and A.distance2(last.pos,pos)<120*120 then
        local distance=A.distance(A.pos(u),pos)
        if distance<85 then return false end
        if now-last.time<.7 then return false end
        if A.call(NPC.IsRunning,u)==true and now-last.time<3 then return false end
    end
    if Orders.issue(u,"DOTA_UNIT_ORDER_MOVE_TO_POSITION",nil,pos,nil,priority,tag) then
        S.orders[id]={kind="move",time=now,pos=A.copy(pos)};return true
    end
    return false
end
function Orders.attack(u,target,priority,tag)
    if not A.alive(target) or A.state(target,"MODIFIER_STATE_ATTACK_IMMUNE")
        or A.state(target,"MODIFIER_STATE_INVULNERABLE") or A.state(target,"MODIFIER_STATE_OUT_OF_GAME") then return false end
    local now,id=S.now,A.id(u);local last=S.orders[id]
    local attack_time=math.max(.15,A.number(A.call(NPC.GetAttackTime,u),1.1))
    local distance=A.distance(A.pos(u),A.pos(target))
    local hit=A.number(A.call(NPC.GetLastAttackTime,u),-math.huge)
    if last and last.kind=="attack" and last.target==target then
        -- IsRunning/IsAttacking can remain true for a blocked or replaced order.
        -- Only our approach or an own attack advances this watchdog; ally damage does not.
        if (last.distance and distance<last.distance-32) or hit>(last.last_hit or -math.huge) then
            last.progress,last.distance,last.last_hit=now,distance,hit
        end
        if now-last.time<math.max(.65,attack_time+.1)
            or now-(last.progress or last.time)<math.max(1.5,attack_time*1.75) then return false end
    end
    if Orders.issue(u,"DOTA_UNIT_ORDER_ATTACK_TARGET",target,A.pos(target),nil,priority,tag) then
        S.orders[id]={kind="attack",time=now,target=target,progress=now,distance=distance,last_hit=hit}
        S.attack_commit[id]=now+math.min(.9,math.max(.22,A.number(A.call(NPC.GetAttackAnimPoint,u),.35)+.08))
        return true
    end
    return false
end

function Combat.units()
    local result={}
    for _,u in ipairs(S.units) do
        if (UI.get("combo_all") or S.selected[A.id(u)]) and A.alive(u) and not A.manual(u) then result[#result+1]=u end
    end
    return result
end

function Combat.release(reason)
    S.target,S.net_pending,S.hex_pending,S.last_net=nil,nil,nil,nil
    S.net_status,S.poof_status=nil,nil
    if reason then S.combo_status=reason end
end

function Combat.target_valid(u)
    if not A.enemy(u) or A.state(u,"MODIFIER_STATE_INVULNERABLE")
        or A.state(u,"MODIFIER_STATE_OUT_OF_GAME") then return false end
    for _,meepo in ipairs(S.units) do if A.distance2(A.pos(u),A.pos(meepo)) < 4000*4000 then return true end end
    return false
end
function Combat.pick_target()
    -- Cursor chooses a target once. Tracking the enemy with the mouse is NOT required.
    -- Manual key release/new press clears S.target in M.logic; lost targets may be reacquired.
    if Combat.target_valid(S.target) then return S.target end
    local cx,cy=A.call(Input and Input.GetCursorPos)
    local world=A.call(Input and Input.GetWorldCursorPos)
    local screen_best,screen_d=nil,math.huge
    local world_best,world_d=nil,math.huge
    for _,u in ipairs(S.heroes) do
        if Combat.target_valid(u) then
            local pos=A.pos(u)
            if A.valid_position(pos) then
                local screen,on_screen=A.call(Render and Render.WorldToScreen,pos)
                if type(cx)=="number" and cx==cx and type(cy)=="number" and cy==cy
                    and screen and on_screen and type(screen.x)=="number" and type(screen.y)=="number" then
                    local d=(screen.x-cx)^2+(screen.y-cy)^2
                    if d<screen_d or (d==screen_d and screen_best and A.id(u)<A.id(screen_best)) then
                        screen_best,screen_d=u,d
                    end
                end
                if A.valid_position(world) then
                    local d=A.distance2(world,pos)
                    if d<world_d or (d==world_d and world_best and A.id(u)<A.id(world_best)) then
                        world_best,world_d=u,d
                    end
                end
            end
        end
    end
    -- No tiny cursor leash. The existing 4000-unit combat reach/visibility guard still applies.
    return screen_best or world_best
end
function Combat.predict(target,horizon)
    local pos=A.pos(target)
    if not A.valid_position(pos) then return nil end
    horizon=math.max(0,math.min(1.6,A.number(horizon,0)))
    local controlled=A.control_remaining(target,S.now)
    local moving_time=math.max(0,horizon-controlled)
    if moving_time<=0 then return pos end
    local running=A.call(NPC.IsRunning,target)==true
    if not running and controlled<=.05 then return pos end
    local speed=math.max(0,A.number(A.call(NPC.GetMoveSpeed,target),0))
    local vx,vy=nil,nil
    local motion=S.motion[A.id(target)]
    if running and motion and motion.unit==target and S.now-motion.time<=.25
        and motion.vx and motion.vx^2+motion.vy^2>speed^2*.04 then vx,vy=motion.vx,motion.vy end
    if not vx then
        local rot=A.call(Entity.GetRotation,target)
        local forward=rot and A.method(rot,"GetForward")
        if not forward then return pos end
        local length=math.sqrt(forward.x^2+forward.y^2)
        if length<.01 then return pos end
        vx,vy=forward.x/length*speed,forward.y/length*speed
    end
    local dx,dy=vx*moving_time,vy*moving_time
    local length=math.sqrt(dx*dx+dy*dy)
    if length>600 then dx,dy=dx*600/length,dy*600/length end
    return A.vec(pos.x+dx,pos.y+dy,pos.z)
end
function Combat.net_candidate(units,target,exclude)
    if not Combat.target_valid(target) then return nil,"Цель недоступна" end
    local best,score,reason=nil,math.huge,"Сетки не готовы"
    for _,u in ipairs(units) do
        if u~=exclude and not Orders.busy(u,60,S.now) then
            local net=A.spell(u,"meepo_earthbind")
            local ready,why=A.ready(u,net,false)
            if ready then
                local origin=A.pos(u)
                local speed=math.max(1,A.net_speed(net))
                local cast=math.max(0,A.number(A.call(Ability.GetCastPoint,net,true),.3))
                local eta=cast+A.distance(origin,A.pos(target))/speed
                local point,turn
                for _=1,3 do
                    point=Combat.predict(target,eta)
                    if not A.valid_position(point) then break end
                    turn=math.max(0,math.min(.65,A.number(A.call(NPC.GetTimeToFacePosition,u,point),0)))
                    eta=turn+cast+A.distance(origin,point)/speed
                end
                if A.valid_position(point) and A.distance(origin,point)<=A.range(u,net,700) then
                    local penalty=S.last_net and S.last_net.unit==u and .30 or 0
                    if eta+penalty<score then
                        best={unit=u,ability=net,pos=point,eta=eta,cast=cast,turn=turn or 0};score=eta+penalty
                    end
                else reason="Прогноз вне дальности сетки" end
            else reason=why end
        end
    end
    return best,reason
end
function Combat.pending_net(target)
    local p = S.net_pending
    if not p then return false end
    if not A.alive(p.unit) or not Combat.target_valid(p.target) then S.net_pending=nil;return false end
    local remaining=A.root_remaining(p.target,S.now)
    local observed_until=S.now+remaining
    -- Clock advancement alone is not a root. Require a positive modifier and an extension.
    if remaining>.025 and observed_until>(p.baseline_until or S.now)+0.10 and S.now>=p.arrival-0.10 then
        S.net_misses[A.id(p.target)]=nil;S.net_retry_until[A.id(p.target)]=nil
        S.net_pending=nil;return false
    end
    if S.now > p.arrival+0.45 then
        local id=A.id(p.target)
        S.net_misses[id]=math.min(4,(S.net_misses[id] or 0)+1)
        S.net_retry_until[id]=S.now+math.min(.8,.2*S.net_misses[id])
        S.net_pending=nil
        S.combo_status="Попадание сетки не подтверждено — повторный выбор"
        return false
    end
    return p.target == target
end
function Combat.net(units,target)
    if not UI.get("combo_net") then S.net_status="Выключено в настройках";return false end
    if not Combat.target_valid(target) then S.net_status="Нет допустимой цели";return false end
    if S.now<(S.net_retry_until[A.id(target)] or -math.huge) then
        S.net_status="Короткая пауза после неподтверждённой сетки";return false
    end
    if S.hex_pending and S.hex_pending.target==target and S.now<S.hex_pending.until_time then
        S.net_status="Ожидание применения Хекс";return false
    end
    if A.state(target,"MODIFIER_STATE_DEBUFF_IMMUNE") or A.state(target,"MODIFIER_STATE_MAGIC_IMMUNE") then
        S.net_status="Цель невосприимчива к контролю";return false
    end
    if Combat.pending_net(target) then S.net_status="Ожидание попадания сетки";return false end
    if S.last_net and S.now-S.last_net.sent<.12 then S.net_status="Сетка уже отправлена";return false end
    local candidate,why = Combat.net_candidate(units,target)
    if not candidate then S.net_status=why;return false end
    local remaining = A.control_remaining(target,S.now)
    local overlap = UI.get("net_overlap_ms")/1000
    -- A fixed lead cap must never delay launch beyond the real projectile ETA.
    local handoff=candidate.eta+math.max(.06,overlap)+.04
    if remaining > handoff then
        S.net_status=string.format("Ждём конец контроля: %.2f с",remaining)
        return false
    end
    if Orders.cast(candidate.unit,candidate.ability,nil,candidate.pos,60,"сетка",candidate.turn+candidate.cast+0.16,false) then
        S.last_net={unit=candidate.unit,target=target,sent=S.now}
        S.net_pending={unit=candidate.unit,target=target,sent=S.now,arrival=S.now+candidate.eta,
            baseline_until=S.now+A.root_remaining(target,S.now)}
        S.metrics.nets=S.metrics.nets+1
        S.net_status=string.format("Сетка отправлена; полёт %.2f с",candidate.eta)
        return true
    end
    S.net_status="Сетка: приказ не отправлен"
    return false
end
function Combat.poof_anchor(units,target)
    local best,dist=nil,math.huge
    local point=A.pos(target)
    for _,u in ipairs(units) do
        if A.visible(u) and not A.has(u,"modifier_meepo_petrify") and not A.state(u,"MODIFIER_STATE_OUT_OF_GAME") then
            local d=A.distance(A.pos(u),point)
            if d<dist then best,dist=u,d end
        end
    end
    return best,dist
end
function Combat.blink(units,target)
    if not UI.get("combo_blink") then return false end
    local hero=S.hero
    local included=false
    for _,u in ipairs(units) do if u==hero then included=true end end
    if not included or Orders.busy(hero,60,S.now) then return false end
    local target_pos,origin=A.pos(target),A.pos(hero)
    local distance=A.distance(origin,target_pos)
    if distance<460 then return false end
    for _,name in ipairs({"item_blink","item_overwhelming_blink","item_arcane_blink","item_swift_blink"}) do
        local item=A.item(hero,name)
        if item and A.ready(hero,item,true) then
            local range=A.range(hero,item,1200)
            if distance<=range+160 then
                local ratio=math.max(0,math.min(range,distance-150)/distance)
                local point=A.vec(origin.x+(target_pos.x-origin.x)*ratio,origin.y+(target_pos.y-origin.y)*ratio,target_pos.z)
                return Orders.cast(hero,item,nil,point,60,"блинк",0.18,true)
            end
        end
    end
    return false
end
function Combat.tick(provided_units,provided_target)
    Combat.opening_gather()
    local allowed={}
    for _,u in ipairs(provided_units or Combat.units()) do
        if A.alive(u) and not A.manual(u) then allowed[#allowed+1]=u end
    end
    local units=allowed
    if #units==0 then S.combo_status="Ручная пауза / нет доступных Мипо";return end
    local target=provided_target or Combat.pick_target()
    if not Combat.target_valid(target) then
        Combat.release("Нет видимой цели в пределах боя — подведите Мипо ближе");return
    end
    if S.target~=target then Combat.release();S.target=target;S.net_status="Цель выбрана по курсору" end
    -- Survival items keep their old priority; ordinary damage items cannot starve skills.
    Items.tick(units,target,"survival")
    local hex=Combat.hex(units,target)
    local blink=Combat.blink(units,target)
    local net=Combat.net(units,target)
    -- Initial group gather is followed by net chaining and the one-caster Poof queue.
    local poof=Combat.poof(units,target)
    Items.tick(units,target,"regular")
    for _,u in ipairs(units) do
        if not Orders.busy(u,60,S.now) then Orders.attack(u,target,60,"атака-комбо") end
    end
    S.combo_status=poof and "Пуф по очереди / цепочка сеток" or net and "Сетка → Пуф → атака"
        or blink and "Сближение прыжком" or hex and "Хекс → навыки"
        or "Цель зафиксирована: сближение / атака"
end

function M.utility()
    local cursor=UI.pressed("poof_cursor_key")
    local self_cast=UI.pressed("poof_self_key")
    if not cursor and not self_cast then return false end
    local anchor=nil
    if cursor then
        local point=A.call(Input.GetWorldCursorPos)
        local best=math.huge
        for _,u in ipairs(S.units) do
            local d=A.distance2(A.pos(u),point)
            if d<best then anchor,best=u,d end
        end
    end
    local sent=false
    for _,u in ipairs(Combat.units()) do
        local destination=self_cast and u or anchor
        if destination then
            local ab=A.spell(u,"meepo_poof")
            if ab and A.ready(u,ab,false) and Orders.cast(u,ab,destination,nil,80,"пуф-клавиша",A.poof_time(ab)+0.2,false) then
                S.metrics.poofs=S.metrics.poofs+1;sent=true
            end
        end
    end
    return sent
end

-- Автофарм: один снимок нейтралов, распределение лагерей, лечение и ручной приоритет.
function Farm.clock()
    local start=A.number(A.call(GameRules.GetGameStartTime),0)
    return S.now-start
end
function Farm.spawn_deadline()
    local clock=Farm.clock()
    local wait=clock<0 and 60-clock or 60-clock%60
    return S.now+wait+0.4
end
function Farm.refresh_camps()
    if S.now<(S.camps_next or -math.huge) then return end
    S.camps_next=S.now+8
    local camps={}
    for i,raw in ipairs(A.call(Camps and Camps.GetAll) or {}) do
        local box=A.call(Camp and Camp.GetCampBox,raw)
        local pos
        if box and box.min and box.max then pos=A.vec((box.min.x+box.max.x)/2,(box.min.y+box.max.y)/2,(box.min.z+box.max.z)/2)
        else pos=A.pos(raw) end
        if pos then camps[#camps+1]={id=A.id(raw) or i,raw=raw,pos=pos,box=box} end
    end
    S.camps=camps;S.camps_version=(S.camps_version or 0)+1
end
function Farm.nearby(pos,radius)
    local out={}
    if not pos then return out end
    local cell=760
    for x=math.floor((pos.x-radius)/cell),math.floor((pos.x+radius)/cell) do
        for y=math.floor((pos.y-radius)/cell),math.floor((pos.y+radius)/cell) do
            for _,rec in ipairs((S.neutral_bins or {})[x..":"..y] or {}) do
                if A.visible(rec.unit) and A.distance2(rec.pos,pos)<=radius*radius then out[#out+1]=rec.unit end
            end
        end
    end
    return out
end
function Farm.own_side(camp)
    if UI.get("farm_side")==1 then return true end
    -- Геометрическая эвристика, а не скрытые данные о владельце лагеря.
    local radiant=A.enum("TeamNum","TEAM_RADIANT") or 2
    local lower=camp.pos.x+camp.pos.y<0
    return S.team==radiant and lower or S.team~=radiant and not lower
end
function Farm.available(camp,unit)
    if not camp or not Farm.own_side(camp) then return false end
    local stack=S.stack_camps[camp.id]
    if stack and stack.unit~=unit then return false end
    -- Заявка после подтверждённого стака принадлежит одному Мипо; остальные этот кемп не берут.
    local claim=S.stack_claims[camp.id]
    local claimed=claim~=nil and unit~=nil and claim.id==A.id(unit)
    if claim and not claimed then return false end
    -- Кемп, который уже фармит союзник, не выбираем (если мы сами уже не в бою на нём).
    if Farm.ally_busy(camp) and not Farm.engaged_here(unit,camp) then return false end
    if unit and not claimed and S.now<(S.econ_blacklist[tostring(A.id(unit))..":лагерь:"..tostring(camp.id)] or 0) then return false end
    local neutrals=Farm.nearby(camp.pos,760)
    if #neutrals>0 then S.camp_empty[camp.id]=nil end
    -- Для заявки старые флаги «пусто» устарели: после стака в кемпе новая пачка, даже если она в тумане.
    if not claimed and S.now<(S.camp_empty[camp.id] or -math.huge) then return false end
    if UI.get("farm_avoid_enemies") and A.enemy_count_at(camp.pos,1300)>0 then return false end
    local known=not claimed and A.call(Camp and Camp.IsKnownClear,camp.raw)
    if known==true and #neutrals==0 then
        local learned=S.camp_knowledge[camp.id]
        if not learned then
            learned={until_time=Farm.spawn_deadline()};S.camp_knowledge[camp.id]=learned
        end
        if S.now<learned.until_time then
            S.camp_empty[camp.id]=learned.until_time;return false
        end
        -- После нового спавна старый флаг IsKnownClear в тумане не доказывает пустоту.
    else S.camp_knowledge[camp.id]=nil end
    for _,n in ipairs(neutrals) do
        if A.call(NPC.IsAncient,n)==true and (not UI.get("econ_enabled") or not UI.get("econ_ancients") or not Econ.ancient_safe(unit,neutrals)) then return false end
    end
    return true
end
function Farm.fountain()
    if S.fountain and S.now<(S.fountain_next or 0) then return S.fountain end
    S.fountain_next=S.now+5
    local flags=A.enum("UnitTypeFlags","TYPE_STRUCTURE")
    for _,u in ipairs(A.call(NPCs and NPCs.GetAll,flags) or {}) do
        if A.team(u)==S.team and A.name(u):find("fountain",1,true) then S.fountain=A.pos(u);return S.fountain end
    end
    return S.fountain
end

-- ===== Кемпы союзников =====
function Farm.in_camp(pos,camp,margin)
    local box=camp.box
    if box and box.min and box.max then
        return pos.x>=box.min.x-margin and pos.x<=box.max.x+margin and pos.y>=box.min.y-margin and pos.y<=box.max.y+margin
    end
    return A.distance(pos,camp.pos)<=500+margin
end
-- Союзник фармит кемп: стоит/бьёт внутри кемпа и рядом есть видимые нейтралы. Пробегающий мимо (бежит, не бьёт) не считается.
function Farm.scan_allies()
    if not S.heroes_valid then return end
    local mode=UI.get("farm_mode")
    for _,hero in ipairs(S.heroes) do
        local id=A.id(hero)
        local foreign=not S.unit_ids[id] or (hero==S.hero and mode==0) or (mode==2 and S.selected[id])
        if foreign and A.visible(hero) and A.team(hero)==S.team and A.call(NPC.IsIllusion,hero)~=true
            and A.call(Entity.IsHero,hero)==true then
            local pos=A.pos(hero)
            local attacking=A.call(NPC.IsAttacking,hero)==true
            if pos and (attacking or A.call(NPC.IsRunning,hero)~=true) then
                for _,camp in ipairs(S.camps) do
                    if Farm.in_camp(pos,camp,120) and #Farm.nearby(pos,600)>0 then
                        S.ally_camp[camp.id]={time=S.now,id=id};break
                    end
                end
            end
        end
    end
end
function Farm.ally_busy(camp)
    local rec=camp and S.ally_camp[camp.id]
    return rec~=nil and S.now-rec.time<2.5
end
-- Наш Мипо уже в контакте с нейтралами этого кемпа: союзник, пришедший позже, его не вытесняет.
function Farm.engaged_here(u,camp)
    local rec=u and S.assignment[A.id(u)]
    return rec~=nil and rec.kind=="neutral" and rec.camp==camp.id and rec.contact_at~=nil and S.now-rec.contact_at<8
end

-- ===== Возврат на кемп после стака =====
function Farm.claim_task(u)
    local claim=Stack.claim_for(u)
    if not claim then return nil end
    local camp=Farm.find_camp(claim.camp)
    if not camp or not Farm.own_side(camp) or Farm.under_tower(camp.pos)
        or (UI.get("farm_avoid_enemies") and A.enemy_count_at(camp.pos,1300)>0) then return nil end
    if Farm.ally_busy(camp) then S.stack_claims[claim.camp]=nil;return nil end
    return {kind="neutral",key="лагерь:"..tostring(camp.id),camp=camp,pos=camp.pos}
end

-- ===== Poof в фарме: только с реальной пользой =====
function Farm.poof_targets(u,creeps,poof,record)
    local id=A.id(u)
    local block=S.poof_block[id]
    if block and S.now<block.until_time then return nil end
    if S.stack_units[id] then return nil end
    local result=S.stack_results[id]
    if result and S.now-result.time<10 and record and record.kind=="neutral" then
        local camp=Farm.find_camp(record.camp)
        if not camp or A.distance(A.pos(u),camp.pos)>500 then return nil end
    end
    local radius=A.poof_radius(poof)-35
    local mine=A.pos(u);local list={}
    for _,c in ipairs(creeps) do
        if A.visible(c) then
            local d=A.distance(mine,A.pos(c))
            -- Бегущие дальше от нас нейтралы (отвод после стака) к моменту урона из радиуса уйдут.
            if d<=radius and (d<=radius*.6 or A.call(NPC.IsRunning,c)~=true) then list[#list+1]=c end
        end
    end
    return list
end
function Farm.poof_watch(u,list,poof)
    local hp=0
    for _,c in ipairs(list) do hp=hp+A.number(A.call(Entity.GetHealth,c),0) end
    S.poof_watch[A.id(u)]={check=S.now+A.poof_time(poof)+.12,list=list,hp=hp,ability=poof}
end
-- Если после Poof здоровье тех же нейтралов не изменилось, Poof ушёл «в пустоту»: временно запрещаем фарм-Poof.
function Farm.poof_audit()
    for id,w in pairs(S.poof_watch) do
        if S.now>=w.check then
            S.poof_watch[id]=nil
            local hp,known=0,true
            for _,c in ipairs(w.list) do
                if A.alive(c) then
                    if not A.visible(c) then known=false end
                    hp=hp+A.number(A.call(Entity.GetHealth,c),0)
                end
            end
            local spent=w.ability and A.number(A.call(Ability.GetCooldown,w.ability),0)>.1
            if known and spent and hp>=w.hp-1 then
                local strikes=(S.poof_block[id] and S.poof_block[id].strikes or 0)+1
                S.poof_block[id]={until_time=S.now+(strikes>=3 and 6 or 0),strikes=math.min(3,strikes)}
            elseif known and hp<w.hp-1 then S.poof_block[id]=nil end
        end
    end
end
function M.context()
    if A.call(Engine and Engine.IsInGame)~=true then
        if S.session then M.reset() end
        return false
    end
    local hero=A.call(Heroes and Heroes.GetLocal)
    if not hero or A.name(hero)~="npc_dota_hero_meepo" then
        if S.session then M.reset() end
        return false
    end
    local now=A.now()
    local match=A.call(GameRules and GameRules.GetMatchID)
    if not S.session or S.hero~=hero or (S.last_now and now<S.last_now-0.1)
        or (match and match>0 and S.match and S.match>0 and match~=S.match) then M.reset() end
    S.session,S.hero,S.player,S.team,S.now,S.last_now,S.match=true,hero,A.call(Players and Players.GetLocal),A.team(hero),now,now,match
    return true
end
function M.logic()
    UI.sync_push()
    if not M.context() then return end
    Finance.tick()
    local captured=UI.input_captured()
    UI.poll_keys(captured)
    if UI.pressed("farm_key") then UI.set("farm_enabled",not UI.get("farm_enabled")) end
    local down=UI.down("combo_key")
    local combo_edge=down and not S.combo_was_down
    local combo_release=not down and S.combo_was_down
    S.combo_was_down=down
    if combo_release or captured or not UI.get("enabled") then
        Combat.release();S.combo_blocked=false;S.combo_active=false
    end
    if combo_edge and not captured and UI.get("enabled") then
        S.combo_press=(S.combo_press or 0)+1
        Combat.release();S.combo_blocked=false
        -- A fresh explicit combo press reclaims control; holding an old press does not.
        local selected={}
        for _,u in ipairs(A.call(Player and Player.GetSelectedUnits,S.player) or {}) do selected[A.id(u)]=true end
        for id in pairs(S.manual_until) do
            if UI.get("combo_all") or selected[id] then S.manual_until[id]=nil end
        end
    end
    if not captured and UI.get("enabled") and down and not S.combo_blocked then
        -- Mandatory: F6/settings must not silently restart farming while combo is held.
        UI.set("farm_enabled",false)
        if combo_edge then
            S.assignment,S.parking,S.rune_claims,S.rune_busy,S.push_escape={},{},{},{},{}
            S.farm_retreat,S.tower_evade,S.econ_plan={},{},{}
            Stack.cancel_all("Комбо: автофарм отключён")
            if S.hunt then Hunt.finish("Запущено комбо") end
            for _,u in ipairs(S.units) do
                local id=A.id(u)
                if UI.get("combo_all") or S.selected[id] then
                    -- Discard old farming move/attack bookkeeping, not real ability channels.
                    S.orders[id],S.order_next[id],S.attack_commit[id]=nil,nil,nil
                end
            end
        end
    end
    if not UI.get("enabled") then
        S.key_pending.poof_cursor_key,S.key_pending.poof_self_key=nil,nil
        S.combo_status="Скрипт выключен";S.combo_active=false;S.combo_blocked=down;return
    end
    if captured then
        S.combo_status="Ввод занят: закройте чат / магазин / меню";S.combo_active=false
        S.combo_blocked=down;return
    end
    if A.call(GameRules and GameRules.IsPaused)==true then
        S.key_pending.poof_cursor_key,S.key_pending.poof_self_key=nil,nil
        S.combo_status="Пауза игры";S.combo_active=false;S.combo_blocked=down;return
    end
    local frame=A.call(GlobalVars and GlobalVars.GetFrameCount)
    if frame~=nil and S.last_frame==frame then return end
    if frame==nil and S.now<(S.next_fallback_tick or -math.huge) then return end
    S.last_frame,S.next_fallback_tick=frame,S.now+0.02
    if S.now<(S.next_logic or -math.huge) then return end
    S.next_logic=S.now+0.033
    S.acted={};S.safety_status=nil
    M.collect(S.now)
    S.combo_active=down
    if S.combo_blocked and down then
        S.combo_status="Ручное управление: отпустите комбо и нажмите снова"
        return
    end
    Echo.tick()
    M.safety()
    local utility=M.utility()
    if S.combo_active or utility or not UI.get("farm_enabled") then Stack.cancel_all("Ручное комбо / фарм выключен") end
    if S.combo_active then
        if S.hunt then Hunt.finish("Ручное комбо") end
        if not utility then Combat.tick() end
    elseif not utility then
        if not Hunt.tick() then
            S.target=nil;S.combo_status="Ожидание клавиши комбо"
            S.net_status,S.poof_status=nil,nil
        end
    end
    if not utility then Tower.tick();RunesAI.tick();Farm.tick() end
end
function M.run()
    local ok,err=xpcall(M.logic,function(e)
        return debug and debug.traceback and debug.traceback(tostring(e),2) or tostring(e)
    end)
    if not ok then S.last_error=tostring(err);A.log(S.last_error,true) end
end
-- Logic only on game updates, not both rendering and update callbacks.
M.OnUpdate=M.run
function M.OnPrepareUnitOrders(data)
    if type(data)~="table" or not S.session then return true end
    if tostring(data.identifier or ""):sub(1,10)=="meepo_ru8:" or (S.issuing or 0)>0 then return true end
    if data.player and data.player~=S.player then return true end
    local units={}
    if data.npc then
        if type(data.npc)=="table" and data.npc[1]~=nil then units=data.npc else units={data.npc} end
    elseif data.orderIssuer==A.enum("PlayerOrderIssuer","DOTA_ORDER_ISSUER_HERO_ONLY") then units={S.hero}
    else units=A.call(Player and Player.GetSelectedUnits,S.player) or {} end
    local touched=false
    for _,u in ipairs(units) do
        local id=A.id(u)
        if id and S.unit_ids[id] then
            touched=true
            S.manual_until[id]=A.now()+UI.get("manual_pause_ms")/1000
            S.orders[id],S.locks[id],S.attack_commit[id],S.order_next[id]=nil,nil,nil,nil
            S.assignment[id],S.parking[id],S.healing[id]=nil,nil,nil
            Stack.cancel(id,"Ручное управление");Tower.cancel(id)
        end
    end
    if touched then
        if S.combo_was_down or S.combo_active or UI.down("combo_key") then S.combo_blocked=true end
        if S.hunt then Hunt.finish("Ручное управление") end
        Combat.release("Ручной приказ имеет приоритет")
    end
    return true
end
function M.OnEntityDestroy(entity)
    local dead_id=A.id(entity)
    local relevant=entity==S.target or (dead_id and S.unit_ids[dead_id])
    if dead_id then
        S.econ_cache[dead_id],S.creep_owner[dead_id]=nil,nil
        S.motion[dead_id],S.net_misses[dead_id],S.net_retry_until[dead_id]=nil,nil,nil
        S.order_next[dead_id],S.inventory_cache[dead_id],S.item_next[dead_id]=nil,nil,nil
        if S.unit_ids[dead_id] then
            Stack.cancel(dead_id,"Мипо недоступен")
            for _,name in ipairs({"econ_watch","econ_info","parking","farm_retreat","poof_watch","poof_block","attack_commit","tower_evade","tower_hits","heal_records","tango_until"}) do S[name][dead_id]=nil end
            for camp_id,claim in pairs(S.stack_claims) do if claim.id==dead_id then S.stack_claims[camp_id]=nil end end
        end
    end
    for id,order in pairs(S.orders) do
        if order.target==entity then S.orders[id]=nil;S.attack_commit[id]=nil;relevant=true end
    end
    for _,rec in pairs(S.assignment) do
        if rec.target==entity then rec.target=nil;relevant=true end
        for _,member in ipairs(rec.members or {}) do if member==entity then relevant=true;break end end
    end
    if relevant then S.npcs_next=-math.huge end -- события одной группы сводятся к следующему проходу
    if entity==S.target then S.target=nil end
    for _,name in ipairs({"locks","orders","assignment","healing","manual_until","hp_samples"}) do
        local id=A.id(entity);if id then S[name][id]=nil end
    end
    if S.net_pending and (S.net_pending.unit==entity or S.net_pending.target==entity) then S.net_pending=nil end
end

function HUD.text(x,y,text,color,size)
    if not HUD.font then return end
    A.call(Render.Text,HUD.font,size or 14,tostring(text),Vec2(x,y),color or HUD.colors.text)
end
function HUD.theme()
    if HUD.colors then return end
    HUD.colors={text=Color(232,238,245,255),muted=Color(166,181,197,255),
        blue=Color(115,181,237,255),gold=Color(230,198,122,255),
        warning=Color(242,184,111,255),error=Color(242,133,132,255),bg=Color(17,23,31,224)}
end
function HUD.screen()
    local size=A.call(Render and Render.ScreenSize)
    if not size or type(size.x)~="number" or type(size.y)~="number" or size.x<320 or size.y<240 then return nil end
    return size.x,size.y
end
function HUD.visible()
    return S.session and (not UI.get("hud_hide_captured") or not UI.input_captured())
end
function HUD.prepare()
    HUD.theme()
    if not HUD.font then HUD.font=A.call(Render.LoadFont,"Arial",0,500) end
    return HUD.font~=nil
end
function HUD.width(text,size)
    local box=A.call(Render.TextSize,HUD.font,size,text)
    if box and type(box.x)=="number" then return box.x end
    local length=utf8.len(text) or #text
    return length*size*.7
end
function HUD.wrap_uncached(text,size,width)
    local rows,line={},""
    for word in tostring(text):gmatch("%S+") do
        local joined=line=="" and word or line.." "..word
        if HUD.width(joined,size)<=width then line=joined
        else
            if line~="" then rows[#rows+1]=line;line="" end
            if HUD.width(word,size)<=width then line=word
            else
                for _,cp in utf8.codes(word) do
                    local ch=utf8.char(cp)
                    if line~="" and HUD.width(line..ch,size)>width then rows[#rows+1]=line;line="" end
                    line=line..ch
                end
            end
        end
    end
    if line~="" or #rows==0 then rows[#rows+1]=line end
    return rows
end
function HUD.wrap(text,size,width)
    -- Ограниченный кеш только геометрии текста; игровые наблюдения здесь не хранятся.
    local key=tostring(HUD.font)..":"..size..":"..width..":"..tostring(text)
    HUD.wrap_cache=HUD.wrap_cache or {}
    local rows=HUD.wrap_cache[key]
    if rows then return rows end
    if (HUD.wrap_count or 0)>=256 then HUD.wrap_cache={};HUD.wrap_count=0 end
    rows=HUD.wrap_uncached(text,size,width)
    HUD.wrap_cache[key]=rows;HUD.wrap_count=(HUD.wrap_count or 0)+1
    return rows
end
function HUD.status_rows()
    local c=HUD.colors
    local rows={
        {M.NAME.."  "..M.VERSION,c.blue},
        {S.combo_status or "Ожидание",c.text},
        {"Автофарм: "..(UI.get("farm_enabled") and "вкл." or "выкл.").."  ·  Мипо: "..#S.units,c.muted},
        {"Сетки "..S.metrics.nets.."  ·  Пуфы "..S.metrics.poofs.."  ·  Предметы "..(S.metrics.items or 0),c.muted},
    }
    if UI.get("hud_details") then
        rows[#rows+1]={"Сетка: "..tostring(S.net_status or "готовность по цели")}
        rows[#rows+1]={"Пуф: "..tostring(S.poof_status or "готовность по цели")}
        rows[#rows+1]={S.farm_status or "Ожидание фарма"}
        rows[#rows+1]={S.tower_status or (UI.push_active() and "Башни: ожидание снаряда по крипу" or "Сплитпуш выключен")}
        rows[#rows+1]={S.hunt_status or (UI.get("hunt_enabled") and "Автонападение: поиск" or "Автонападение выключено")}
        rows[#rows+1]={S.heal_status or "Лечение: по выбранному режиму"}
        rows[#rows+1]={UI.get("econ_enabled") and "Экономика: прогноз, не доход" or "Планировщик выключен",c.muted}
    else
        local contextual=S.safety_status or S.tower_status or S.hunt_status or S.heal_status
        if contextual then rows[#rows+1]={contextual,c.warning} end
    end
    if S.target then rows[#rows+1]={string.format("Цель: %s · контроль %.2f с",UI.hero_name(S.target),A.control_remaining(S.target,A.now()))} end
    if S.combo_active and S.gather_status then rows[#rows+1]={S.gather_status,c.muted} end
    if S.combo_active and not UI.get("hud_details") then
        rows[#rows+1]={"Сетка: "..tostring(S.net_status or "проверка готовности"),c.muted}
        rows[#rows+1]={"Пуф: "..tostring(S.poof_status or "проверка готовности"),c.muted}
    end
    if S.last_cast_notice and UI.get("debug_log") then rows[#rows+1]={S.last_cast_notice,c.warning} end
    if S.safety_status and UI.get("hud_details") then rows[#rows+1]={S.safety_status,c.warning} end
    if S.last_error then rows[#rows+1]={"Ошибка интерфейса — см. консоль",c.error} end
    if S.last_api_error and UI.get("debug_log") then rows[#rows+1]={"API: "..S.last_api_error,c.error} end
    if UI.get("hud_details") and not S.net_pending and S.combo_active then
        for _,u in ipairs(S.units) do
            local ready,why=A.ready(u,A.spell(u,"meepo_earthbind"),false)
            if not ready then rows[#rows+1]={"Мипо "..tostring(A.id(u))..": сетка — "..why};break end
        end
    end
    return rows
end
function HUD.panel(rows,width,font,gap,pad,accent)
    local out={rows={},w=width,font=font,gap=gap,pad=pad,accent=accent}
    for i,row in ipairs(rows) do
        for _,text in ipairs(HUD.wrap(row[1],font,width-pad*2)) do
            out.rows[#out.rows+1]={text,row[2] or HUD.colors.text,header=i==1}
        end
    end
    out.h=pad*2+#out.rows*gap
    return out
end
function HUD.layout()
    local sw,sh=HUD.screen();if not sw or not HUD.prepare() then return nil end
    local base=math.max(.8,math.min(1.5,sw/1920,sh/1080))
    local scale=base*UI.get("hud_scale")/100
    local pad=math.max(8,math.floor(12*scale))
    local font=math.max(14,math.floor(14*scale))
    local width=math.min(sw-pad*2,math.max(280,math.floor(320*scale)))
    local gap=math.ceil(font*1.4)
    local status=UI.get("hud") and HUD.panel(HUD.status_rows(),width,font,gap,pad,HUD.colors.blue) or nil
    local finance=UI.get("finance_show") and HUD.panel(Finance.rows(),width,font,gap,pad,HUD.colors.gold) or nil
    local gutter=math.max(8,math.floor(8*scale))
    local total=(status and status.h or 0)+(finance and finance.h or 0)+(status and finance and gutter or 0)
    local right=math.max(pad,UI.get("hud_right_margin")*base)
    local bottom=UI.get("hud_bottom_margin")*base
    local x=math.max(pad,math.min(sw-width-pad,sw-width-right))
    local y=math.max(pad,sh-bottom-total)
    if UI.get("hud_auto_position") then
        if status and finance and total>sh-bottom-pad and width*2+gutter+pad*2<=sw then
            -- Две невысокие соседние панели лучше, чем перекрытие нижних кнопок.
            local height=math.max(status.h,finance.h)
            y=math.max(pad,sh-bottom-height)
            status.x,status.y=x-width-gutter,y
            finance.x,finance.y=x,y
        else
            if status then status.x,status.y=x,y end
            if finance then finance.x,finance.y=x,y+(status and status.h+gutter or 0) end
        end
    else
        local fx=math.max(pad,math.min(sw-width-pad,UI.get("finance_x")))
        local fy=math.max(pad,math.min(sh-(finance and finance.h or 0)-pad,UI.get("finance_y")))
        if finance then finance.x,finance.y=fx,fy end
        if status then
            status.x,status.y=fx,fy-status.h-gutter
            if status.y<pad then
                status.y=fy
                status.x=fx-width-gutter
                if status.x<pad then status.x=math.min(sw-width-pad,fx+width+gutter) end
                if finance and status.x<fx+width+gutter and status.x+width>fx-gutter then
                    -- Ручная точка у края: возвращаем обе панели в безопасную общую колонку.
                    status.x,status.y=x,y
                    finance.x,finance.y=x,y+status.h+gutter
                end
            end
        end
    end
    -- Итоговая привязка общей компоновки к экрану без независимого сдвига панелей друг на друга.
    local minx,miny,maxx,maxy=sw,sh,0,0
    for _,p in pairs({status=status,finance=finance}) do
        minx=math.min(minx,p.x);miny=math.min(miny,p.y)
        maxx=math.max(maxx,p.x+p.w);maxy=math.max(maxy,p.y+p.h)
    end
    local dx=math.max(0,pad-minx)-math.max(0,maxx-(sw-pad))
    local dy=math.max(0,pad-miny)-math.max(0,maxy-(sh-pad))
    for _,p in pairs({status=status,finance=finance}) do p.x,p.y=p.x+dx,p.y+dy end
    return {status=status,finance=finance,screen_w=sw,screen_h=sh}
end
function HUD.paint(panel)
    if not panel then return end
    local x,y,w,h=panel.x,panel.y,panel.w,panel.h
    A.call(Render.FilledRect,Vec2(x,y),Vec2(x+w,y+h),HUD.colors.bg,6)
    A.call(Render.FilledRect,Vec2(x+panel.pad,y+panel.pad),Vec2(x+panel.pad+3,y+panel.pad+panel.font),panel.accent,1)
    for i,row in ipairs(panel.rows) do
        HUD.text(x+panel.pad+(row.header and 9 or 0),y+panel.pad+(i-1)*panel.gap,row[1],row[2],panel.font)
    end
end
function HUD.draw()
    if not HUD.visible() or not HUD.prepare() then return end
    local layout=HUD.current_layout or HUD.layout()
    if layout then HUD.paint(layout.status) end
    -- Надписи над юнитами независимы от переключателя основной панели.
    if UI.get("world_labels") then
        for i,u in ipairs(S.units) do
            local p=A.pos(u)
            if p then
                local screen,visible=A.call(Render.WorldToScreen,A.vec(p.x,p.y,p.z+145))
                if screen and visible then
                    local id=A.id(u)
                    local mode=u==S.hero and "Главный" or "Клон"
                    local status=S.healing[id] and "Лечение" or S.locks[id] and "Применение"
                        or S.combo_active and "Комбо" or S.stack_units[id] and ("Стак: "..UI.phase_name(S.stack_units[id].phase))
                        or S.assignment[id] and (S.assignment[id].phase and UI.phase_name(S.assignment[id].phase) or "Фарм") or "Ожидание"
                    HUD.text(screen.x-65,screen.y,string.format("%s %d · %s · ОЗ %.0f%%",mode,i,status,A.hp(u)),nil,13)
                    local info=S.econ_info[id]
                    if UI.get("econ_details") and UI.get("econ_enabled") and info then
                        HUD.text(screen.x-100,screen.y+17,string.format("≈%.0f зол/мин · %.1f с · %s",info.gold_rate or 0,info.total or 0,info.reason or "оценка"),HUD.colors.muted,12)
                    end
                end
            end
        end
    end
end
function M.OnDraw()
    local prepared,layout=pcall(function()
        if not HUD.visible() or not HUD.prepare() then return nil end
        return HUD.layout()
    end)
    if not prepared then A.log("Ошибка компоновки: "..tostring(layout),true);return end
    if not layout then return end
    HUD.current_layout=layout
    -- Ошибка одной панели не отключает отрисовку второй.
    local ok,err=pcall(HUD.draw)
    if not ok then A.log("Ошибка панели: "..tostring(err),true) end
    local finance_ok,finance_error=pcall(Finance.draw)
    if not finance_ok then A.log("Ошибка статистики: "..tostring(finance_error),true) end
    HUD.current_layout=nil
end
-- RU4: последовательный урон, автонападение, адаптивные задания, предметы и лечение.
function A.flag(value, group, name)
    local flag=A.enum(group,name)
    local n,f=math.tointeger(value or 0),math.tointeger(flag or 0)
    return n~=nil and f~=nil and f~=0 and (n & f)~=0
end
function Combat.poof_in_progress()
    for _,u in ipairs(S.units) do
        if A.alive(u) then
            local ab=A.spell(u,"meepo_poof")
            local phase=ab and (A.call(Ability.IsChannelling,ab)==true or A.call(Ability.IsInAbilityPhase,ab)==true)
            local lock=S.locks[A.id(u)]
            if phase then
                S.poof_last_caster=A.id(u)
                if lock and lock.ability==ab then lock.observed=true end
                return true
            end
            if lock and lock.ability==ab and not lock.observed
                and S.now<(lock.ack_until or lock.until_time) then return true end
        end
    end
    return false
end
function Combat.net_keeper(units,target)
    local best,best_eta=nil,math.huge
    for _,u in ipairs(units) do
        if not Orders.busy(u,60,S.now) then
            local ab=A.spell(u,"meepo_earthbind")
            local cooldown=ab and A.call(Ability.GetCooldown,ab)
            local level=ab and A.call(Ability.GetLevel,ab)
            local mana=ab and A.call(NPC.GetMana,u)
            local cost=ab and A.call(Ability.GetManaCost,ab)
            local poof=A.spell(u,"meepo_poof")
            local window=(poof and A.poof_time(poof) or 1.5)+.20
            local valid=type(cooldown)=="number" and cooldown==cooldown and cooldown>=0 and cooldown<=window
                and type(level)=="number" and level>=1 and type(mana)=="number" and type(cost)=="number"
                and mana>=cost and not A.disabled(u,false)
                and A.call(Ability.IsHidden,ab)~=true and A.call(Ability.IsActivated,ab)~=false
                and A.call(Ability.IsInAbilityPhase,ab)~=true and A.call(Ability.IsChannelling,ab)~=true
            if valid and cooldown<=.04 then valid=A.ready(u,ab,false) end
            local owner=ab and A.call(Ability.GetOwner,ab)
            if owner and A.id(owner)~=A.id(u) then valid=false end
            if valid then
                local origin,point=A.pos(u),A.pos(target)
                if A.distance(origin,point)<=A.range(u,ab,700) then
                    local cast=math.max(0,A.number(A.call(Ability.GetCastPoint,ab,true),.3))
                    local turn=math.max(0,math.min(.65,A.number(A.call(NPC.GetTimeToFacePosition,u,point),0)))
                    local eta=cooldown+turn+cast+A.distance(origin,point)/math.max(1,A.net_speed(ab))
                    if eta<best_eta then best,best_eta=u,eta end
                end
            end
        end
    end
    return best
end
function Combat.opening_gather()
    if not S.combo_active or not S.combo_press or S.gather_press==S.combo_press then return false end
    S.gather_press=S.combo_press
    local anchor=S.hero
    if not A.alive(anchor) or A.has(anchor,"modifier_meepo_petrify") or A.state(anchor,"MODIFIER_STATE_OUT_OF_GAME") then
        S.gather_status="Стартовый сбор: главный Мипо недоступен";return false
    end
    local sent,total=0,0
    for _,u in ipairs(S.units) do
        if u~=anchor and A.alive(u) then
            total=total+1
            local id=A.id(u)
            local ab=A.spell(u,"meepo_poof")
            if A.ready(u,ab,false) then
                -- Reclaim only a unit that can actually participate in this explicit group cast.
                local old_pause,old_next=S.manual_until[id],S.order_next[id]
                S.manual_until[id],S.order_next[id]=nil,nil
                if not Orders.busy(u,70,S.now)
                    and Orders.cast(u,ab,anchor,nil,70,"стартовый-сбор",A.poof_time(ab)+.12,false) then
                    sent=sent+1;S.metrics.poofs=S.metrics.poofs+1
                else S.manual_until[id],S.order_next[id]=old_pause,old_next end
            end
        end
    end
    S.gather_status=string.format("Стартовый сбор к главному: %d/%d клонам отправлен Пуф",sent,total)
    return sent>0
end
-- After the one-shot opening gather: one Poof at a time, rotating across eligible Meepos.
function Combat.poof(units,target)
    if not UI.get("combo_poof") then S.poof_status="Выключено в настройках";return false end
    if not Combat.target_valid(target) then S.poof_status="Нет допустимой цели";return false end
    if Combat.poof_in_progress() then
        S.poof_status="Очередь Пуфа: ждём завершения текущего применения / сбора";return false
    end
    local anchor,dist=Combat.poof_anchor(units,target)
    if not anchor then S.poof_status="Нет доступного Мипо для Пуфа";return false end
    local root=A.control_remaining(target,S.now)
    local reserved=nil
    local can_root=UI.get("combo_net") and not A.state(target,"MODIFIER_STATE_DEBUFF_IMMUNE")
        and not A.state(target,"MODIFIER_STATE_MAGIC_IMMUNE")
    if can_root and #units>1 and (root>.05 or Combat.pending_net(target)) then reserved=Combat.net_keeper(units,target) end
    local start=1
    for i,u in ipairs(units) do if A.id(u)==S.poof_last_caster then start=i%#units+1;break end end
    local busy,why=0,"Нужен Мипо в зоне урона Пуфа"
    for offset=0,#units-1 do
        local u=units[(start+offset-1)%#units+1]
        if u==reserved then why="Один Мипо держит следующую сетку"
        elseif Orders.busy(u,60,S.now) then busy=busy+1
        else
            local ab=A.spell(u,"meepo_poof")
            local ready,reason=A.ready(u,ab,false)
            if not ready then why=reason
            else
                local duration=A.poof_time(ab)
                local radius=math.max(50,A.poof_radius(ab)-45)
                local predicted=root>=duration and A.pos(target) or Combat.predict(target,duration)
                local destination=nil
                if A.valid_position(predicted) then
                    if A.distance(A.pos(u),A.pos(target))<=radius and A.distance(A.pos(u),predicted)<=radius then destination=u
                    elseif dist<=radius and A.distance(A.pos(anchor),predicted)<=radius then destination=anchor end
                end
                if not destination then why="Сближение: цель вне зоны урона Пуфа"
                elseif UI.get("poof_require_root") and root<duration+.08 then why="Включён Пуф только под контроль"
                elseif Orders.cast(u,ab,destination,nil,60,"пуф-комбо-очередь",duration+.12,false) then
                    S.poof_last_caster=A.id(u);S.metrics.poofs=S.metrics.poofs+1
                    S.poof_status="По очереди: Пуфует Мипо №"..tostring(A.id(u))
                        ..(reserved and "; следующий контроль сохранён" or "")
                    return true
                else why=S.failures[A.id(u)] or "Пуф: приказ пока недоступен" end
            end
        end
    end
    if busy==#units then S.poof_status="Мипо применяют способности / заняты приказом" else S.poof_status=why end
    return false
end

-- Сканируются все индексы; GetItem(...,true) отсеивает рюкзак и склад.
Items.rules={}
function Items.rule(names,mode,range,category,condition)
    for name in names:gmatch("%S+") do Items.rules[name]={mode=mode,range=range,category=category,condition=condition} end
end
Items.rule("item_sheepstick item_abyssal_blade","enemy",700,"items_offensive","control")
Items.rule("item_orchid item_bloodthorn","enemy",900,"items_offensive","silence")
Items.rule("item_diffusal_blade item_disperser item_rod_of_atos item_nullifier item_ethereal_blade item_heavens_halberd item_harpoon","enemy",600,"items_offensive")
Items.rule("item_dagon item_dagon_2 item_dagon_3 item_dagon_4 item_dagon_5 item_urn_of_shadows item_spirit_vessel","enemy",700,"items_offensive")
Items.rule("item_gleipnir","point",1100,"items_offensive","control")
Items.rule("item_shivas_guard","none",850,"items_offensive")
Items.rule("item_manta item_mask_of_madness item_phase_boots","none",650,"items_offensive","attack_buff")
Items.rule("item_mjollnir item_solar_crest","self",900,"items_offensive","attack_buff")
Items.rule("item_black_king_bar","none",1000,"items_defensive","bkb")
Items.rule("item_blade_mail","none",650,"items_defensive","blade_mail")
Items.rule("item_satanic","none",650,"items_defensive","low_hp")
Items.rule("item_ghost item_ethereal_ghost","none",600,"items_defensive","critical_hp")
Items.rule("item_glimmer_cape item_lotus_orb","self",900,"items_defensive","low_hp")
Items.rule("item_force_staff","self",1000,"items_defensive","safe_force")
Items.rule("item_hurricane_pike","enemy",450,"items_defensive","critical_hp")
Items.rule("item_shadow_blade item_silver_edge item_invis_sword","none",1200,"items_defensive","invisibility")
Items.rule("item_magic_wand item_magic_stick item_holy_locket","self_or_none",900,"items_resources","wand")
Items.rule("item_mekansm item_guardian_greaves","none",900,"items_resources","team_heal")
Items.rule("item_arcane_boots","none",900,"items_resources","low_mana")
Items.rule("item_soul_ring","none",900,"items_resources","soul_ring")
Items.rule("item_dust","none",1000,"items_detection","dust")
Items.rule("item_refresher item_refresher_shard","none",1200,"items_refresher","refresh")
Items.rule("item_armlet item_radiance","none",800,"items_toggles","toggle_on")
Items.blocked={item_tpscroll=true,item_travel_boots=true,item_travel_boots_2=true,
    item_smoke_of_deceit=true,item_ward_observer=true,item_ward_sentry=true,item_ward_dispenser=true,
    item_tango=true,item_tango_single=true,item_flask=true,item_clarity=true,item_bottle=true,
    item_enchanted_mango=true,item_faerie_fire=true,item_tome_of_knowledge=true,
    item_cheese=true,item_aghanims_shard=true,item_ultimate_scepter_2=true,item_moon_shard=true,
    item_branches=true,item_quelling_blade=true,item_bfury=true}
function Items.inventory(u)
    local id=A.id(u);local cached=S.inventory_cache[id]
    if cached and cached.unit==u and S.now<cached.until_time then return cached.list end
    local out,seen={},{}
    if NPC.GetItemByIndex then
        for index=0,20 do
            local item=A.call(NPC.GetItemByIndex,u,index)
            local name=item and A.call(Ability.GetName,item)
            if item and name and not seen[item] and A.item(u,name)==item then
                seen[item]=true;out[#out+1]={ability=item,name=name,index=index}
            end
        end
    else
        for name in pairs(Items.rules) do
            local item=A.item(u,name)
            if item and not seen[item] then seen[item]=true;out[#out+1]={ability=item,name=name,index=-1} end
        end
    end
    S.inventory_cache[id]={unit=u,list=out,until_time=S.now+.20}
    return out
end
function Items.usable(u,item,name)
    if A.item(u,name)~=item then return false,"Предмет больше не в активном слоте" end
    if Items.blocked[name] or name:find("item_recipe_",1,true)==1 then return false,"Утилитарный предмет" end
    if name:find("blink",1,true) then return false,"Прыжок используется для сближения" end
    if A.call(Ability.IsPassive,item)==true then return false,"Пассивный предмет" end
    if A.call(Item and Item.IsItemEnabled,item)==false then return false,"Временная блокировка слота" end
    if A.call(Item and Item.IsMarkedForSell,item)==true then return false,"Отмечен для продажи" end
    if A.call(Item and Item.RequiresCharges,item)==true and A.number(A.call(Item and Item.GetCurrentCharges,item),0)<=0 then return false,"Нет зарядов" end
    return A.ready(u,item,true)
end
function Items.condition(rule,u,item,target)
    local condition=rule.condition
    if not condition then return true end
    local hp,mana,dist=A.hp(u),A.mana_pct(u),A.distance(A.pos(u),A.pos(target))
    if condition=="control" then
        if A.call(Ability.GetName,item)=="item_sheepstick" then return Combat.hex_wanted(u,item,target) end
        return A.control_remaining(target,S.now)<0.25 and not Combat.pending_net(target)
    end
    if condition=="silence" then return not A.has(target,"modifier_orchid_malevolence_debuff") and not A.has(target,"modifier_bloodthorn_debuff") end
    if condition=="attack_buff" then
        if A.call(Ability.GetName,item)=="item_manta" and UI.get("echo_enabled") and UI.get("echo_manta") then
            for _,enemy in ipairs(S.heroes) do
                local echo=A.spell(enemy,"earthshaker_echo_slam")
                if A.enemy(enemy) and echo and A.number(A.call(Ability.GetLevel,echo),0)>0
                    and A.number(A.call(Ability.GetCooldown,echo),0)<.05
                    and A.distance(A.pos(u),A.pos(enemy))<1600 then return false end
            end
        end
        if A.call(Ability.GetName,item)=="item_mask_of_madness" then
            for _,name in ipairs({"meepo_poof","meepo_earthbind"}) do
                local ab=A.spell(u,name)
                if ab and A.number(A.call(Ability.GetCooldown,ab),0)<3 then return false end
            end
        end
        return dist<=rule.range
    end
    if condition=="bkb" then return A.enemy_count_at(A.pos(u),1000)>0 and not A.has(u,"modifier_black_king_bar_immune") end
    if condition=="blade_mail" then return hp<85 and dist<=650 end
    if condition=="low_hp" then return hp<55 end
    if condition=="critical_hp" then return hp<38 end
    if condition=="wand" then return (hp<65 or mana<35) and A.number(A.call(Item and Item.GetCurrentCharges,item),0)>0 end
    if condition=="low_mana" then
        for _,ally in ipairs(S.units) do if A.distance(A.pos(u),A.pos(ally))<900 and A.mana_pct(ally)<55 then return true end end
        return false
    end
    if condition=="team_heal" then
        for _,ally in ipairs(S.units) do if A.distance(A.pos(u),A.pos(ally))<900 and A.hp(ally)<70 and not A.has(ally,"modifier_item_mekansm_noheal") then return true end end
        return false
    end
    if condition=="soul_ring" then return mana<40 and hp>65 end
    if condition=="dust" then return A.state(target,"MODIFIER_STATE_INVISIBLE") or A.has(target,"modifier_item_shadow_amulet_fade") end
    if condition=="invisibility" then return (dist>500 or hp<35) and not A.state(u,"MODIFIER_STATE_INVISIBLE") end
    if condition=="toggle_on" then return A.call(Ability.GetToggleState,item)==false and hp>40 end
    if condition=="safe_force" then
        if hp>35 then return false end
        local base=Farm.fountain();local pos=A.pos(u)
        local rotation=A.call(Entity.GetRotation,u);local forward=rotation and A.method(rotation,"GetForward")
        if not base or not pos or not forward then return false end
        local dx,dy=base.x-pos.x,base.y-pos.y;local len=math.sqrt(dx*dx+dy*dy)
        return len>0 and (forward.x*dx+forward.y*dy)/len>0.5
    end
    if condition=="refresh" then
        local spent=0
        for _,name in ipairs({"meepo_poof","meepo_earthbind"}) do
            local ab=A.spell(u,name);if ab and A.number(A.call(Ability.GetCooldown,ab),0)>2 then spent=spent+1 end
        end
        return spent>=2
    end
    return false
end
function Items.generic(item)
    if not UI.get("items_unknown") then return nil end
    local behavior=A.call(Ability.GetBehavior,item)
    local team=A.call(Ability.GetTargetTeam,item)
    local target_type=A.call(Ability.GetTargetType,item)
    if A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_PASSIVE")
        or A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_TOGGLE") then return nil end
    if not A.flag(team,"TargetTeam","DOTA_UNIT_TARGET_TEAM_ENEMY") then return nil end
    local hero=A.flag(target_type,"TargetType","DOTA_UNIT_TARGET_HERO")
    if not hero then return nil end
    if A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then return {mode="enemy",range=600,category="items_offensive"} end
    if A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_POINT") then return {mode="point",range=600,category="items_offensive"} end
    return nil
end
function Items.apply(u,rec,target)
    local item,name=rec.ability,rec.name
    local ready,why=Items.usable(u,item,name)
    if not ready then S.item_diagnostics[name]=why;return false end
    local rule=Items.rules[name] or Items.generic(item)
    if not rule then S.item_diagnostics[name]="Нет безопасной политики / метаданных";return false end
    if not UI.get(rule.category) then return false end
    if name=="item_sheepstick" and not UI.get("combo_hex") then return false end
    if (name=="item_orchid" or name=="item_bloodthorn") and not UI.get("combo_silence") then return false end
    if (name=="item_diffusal_blade" or name=="item_disperser" or name=="item_rod_of_atos") and not UI.get("combo_slow") then return false end
    if not Items.condition(rule,u,item,target) then return false end
    local mode=rule.mode
    if mode=="self_or_none" then
        local behavior=A.call(Ability.GetBehavior,item)
        mode=A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") and "self" or "none"
    end
    local victim,point=nil,nil
    if mode=="enemy" or mode=="point" then
        if A.state(target,"MODIFIER_STATE_INVULNERABLE") or A.state(target,"MODIFIER_STATE_OUT_OF_GAME") then return false end
        if A.state(target,"MODIFIER_STATE_MAGIC_IMMUNE") or A.state(target,"MODIFIER_STATE_DEBUFF_IMMUNE") then return false end
        if mode=="enemy" and (A.has(target,"modifier_item_sphere_target") or A.has(target,"modifier_item_sphere")) then return false end
        if A.distance(A.pos(u),A.pos(target))>A.range(u,item,rule.range) then return false end
        victim=mode=="enemy" and target or nil;point=mode=="point" and A.pos(target) or nil
    elseif mode=="self" then victim=u
    elseif A.distance(A.pos(u),A.pos(target))>rule.range then return false end
    local cast=math.max(0,A.number(A.call(Ability.GetCastPoint,item,true),0))
    if Orders.cast(u,item,victim,point,60,"предмет:"..name,cast+0.15,true) then
        S.metrics.items=S.metrics.items+1;S.item_diagnostics[name]="Применён";return true
    end
    return false
end
function Items.tick(units,target,stage)
    if not UI.get("items_enabled") then return end
    for _,u in ipairs(units) do
        local id=A.id(u)
        if not Orders.busy(u,60,S.now) and S.now>=(S.item_next[id] or -math.huge) then
            local inventory=Items.inventory(u)
            table.sort(inventory,function(a,b)
                local ra,rb=Items.rules[a.name],Items.rules[b.name]
                local pa=ra and ra.category=="items_defensive" and 0 or ra and ra.category=="items_resources" and 1 or 2
                local pb=rb and rb.category=="items_defensive" and 0 or rb and rb.category=="items_resources" and 1 or 2
                return pa==pb and a.index<b.index or pa<pb
            end)
            local sent=false
            for _,rec in ipairs(inventory) do
                local rule=Items.rules[rec.name]
                local defensive=rule and rule.category=="items_defensive"
                local allowed=not stage or (stage=="survival" and defensive)
                    or (stage=="regular" and not defensive)
                if allowed and Items.apply(u,rec,target) then sent=true;break end
            end
            -- An empty survival pass must NOT hide regular items for another .1 seconds.
            if sent or stage~="survival" then S.item_next[id]=S.now+.10 end
        end
    end
end
local old_blink=Combat.blink
function Combat.blink(units,target)
    if not UI.get("items_enabled") then return false end
    return old_blink(units,target)
end

-- Единый снимок фарма: нейтралы, вражеские волны и известные башни.
function Farm.snapshot()
    if S.now<(S.npcs_next or -math.huge) then return end
    S.npcs_next=S.now+0.25;S.snapshot_time=S.now;S.metrics.npc_scans=S.metrics.npc_scans+1
    S.snapshot_version=(S.snapshot_version or 0)+1
    local list=A.call(NPCs and NPCs.GetAll)
    S.neutrals_valid=type(list)=="table";S.snapshot_valid=S.neutrals_valid
    S.neutral_bins,S.lane_creeps,S.towers,S.ally_creeps,S.buildings={},{},{},{},{}
    for _,u in ipairs(list or {}) do
        if A.alive(u) then
            local pos,team=A.pos(u),A.team(u)
            if pos then
                local allied=team==S.team
                local name=A.name(u)
                local tower=not allied and A.call(NPC.IsTower,u)==true
                local visible=A.call(Entity.IsDormant,u)~=true
                local lane=visible and A.call(NPC.IsLaneCreep,u)==true
                if allied and name:find("fountain",1,true) then S.fountain=A.copy(pos) end
                if tower then S.towers[#S.towers+1]=u end
                if not allied and (tower or name:find("barracks",1,true)) then S.buildings[#S.buildings+1]=u end
                if allied and lane then S.ally_creeps[#S.ally_creeps+1]=u end
                if visible and A.call(NPC.IsWaitingToSpawn,u)~=true then
                    if A.call(NPC.IsNeutral,u)==true then
                        local key=math.floor(pos.x/760)..":"..math.floor(pos.y/760)
                        local bin=S.neutral_bins[key] or {};S.neutral_bins[key]=bin;bin[#bin+1]={unit=u,pos=pos}
                    elseif lane and not allied then S.lane_creeps[#S.lane_creeps+1]=u end
                end
            end
        end
    end
end
function Farm.under_tower(pos)
    for _,tower in ipairs(S.towers or {}) do
        if A.alive(tower) then
            local range=A.number(A.call(NPC.GetAttackRange,tower),700)+350
            if A.distance(pos,A.pos(tower))<range then return true end
        end
    end
    return false
end
function Farm.safe_position(pos,radius,allies)
    if A.enemy_count_at(pos,radius)>0 or Farm.under_tower(pos) then return false end
    for _,rec in pairs(S.enemy_memory) do
        if S.now-rec.time<UI.get("lane_memory_sec") and A.distance(pos,rec.pos)<radius then return false end
    end
    if allies and UI.get("lane_respect_allies") then
        for _,hero in ipairs(S.heroes) do
            if A.visible(hero) and A.team(hero)==S.team and not S.unit_ids[A.id(hero)] and A.distance(pos,A.pos(hero))<1200 then return false end
        end
    end
    return true
end
function Farm.eligible(u,ignore_busy)
    local id,mode=A.id(u),UI.get("farm_mode")
    local include=(mode==0 and u~=S.hero) or mode==1 or (mode==2 and not S.selected[id])
    return include and A.alive(u) and S.now>=(S.manual_until[id] or -math.huge)
        and S.now>=(S.rune_busy[id] or -math.huge)
        and (ignore_busy or not Orders.busy(u,20,S.now))
end
function Farm.waves()
    local waves={}
    for _,creep in ipairs(S.lane_creeps or {}) do
        local pos=A.pos(creep)
        if A.visible(creep) and (Farm.own_side({pos=pos}) or UI.push_active())
            and (Farm.safe_position(pos,UI.get("lane_safe_radius"),true)
                or (UI.push_active() and Push.position_safe(pos) and Push.covered(pos))) then
            local wave=nil
            for _,w in ipairs(waves) do if A.distance(w.pos,pos)<650 then wave=w;break end end
            if not wave then wave={id="волна:"..tostring(A.id(creep)),pos=A.copy(pos),creeps={}};waves[#waves+1]=wave end
            wave.creeps[#wave.creeps+1]=creep
        end
    end
    return waves
end

function Heal.tango(u)
    local item=A.item(u,"item_tango") or A.item(u,"item_tango_single")
    if not item or not A.ready(u,item,true) or A.call(Item and Item.IsItemEnabled,item)==false then return nil end
    local charges=A.call(Item and Item.GetCurrentCharges,item)
    if charges~=nil and charges<=0 then return nil end
    local owner=A.call(Ability.GetOwner,item)
    if owner and A.id(owner)~=A.id(u) then return nil end
    return item,A.number(charges,1)
end
function Heal.regen_active(u)
    for _,name in ipairs({"modifier_tango_heal","modifier_item_tango_heal"}) do
        local mod=A.call(NPC.GetModifier,u,name)
        if mod then
            S.tango_until[A.id(u)]=S.now+math.max(0.2,A.mod_remaining(mod,S.now));return true
        end
    end
    local record=S.heal_records[A.id(u)]
    -- После отправки ждём короткое подтверждение, а не выдумываем 16 секунд лечения.
    return record and record.await_until and S.now<record.await_until or false
end
function Heal.cheaper_tango(u,item,charges,base)
    local maxhp=A.number(A.call(Entity.GetMaxHealth,u),0)
    local need=math.max(0,maxhp*UI.get("farm_resume_hp")/100-A.number(A.call(Entity.GetHealth,u),0))
    local regen=A.special(item,{"health_regen","health_regen_per_second"},7)
    local duration=A.special(item,{"buff_duration","duration"},16)
    local uses=math.ceil(need/math.max(1,regen*duration))
    if uses>charges then return false end
    if not base then return true end
    local speed=math.max(200,A.number(A.call(NPC.GetMoveSpeed,u),300))
    local base_seconds=2*A.distance(A.pos(u),base)/speed+need/math.max(1,maxhp*0.13)
    return uses*duration<base_seconds
end
function Heal.wait_point(u,base)
    local record=S.heal_records[A.id(u)] or {};S.heal_records[A.id(u)]=record
    if record.wait then return record.wait end
    local pos=A.pos(u)
    if base and pos then
        local distance=A.distance(pos,base)
        local ratio=math.min(1,650/math.max(1,distance))
        record.wait=A.vec(pos.x+(base.x-pos.x)*ratio,pos.y+(base.y-pos.y)*ratio,pos.z)
    else record.wait=A.copy(pos) end
    return record.wait
end
function Heal.handle(u)
    local id,hp=A.id(u),A.hp(u)
    if hp<=UI.get("farm_retreat_hp") then S.healing[id]=true end
    if not S.healing[id] then return false end
    if hp>=math.max(UI.get("farm_resume_hp"),UI.get("farm_retreat_hp")+10) then
        S.healing[id],S.heal_records[id],S.tango_until[id]=nil,nil,nil;return false
    end
    S.assignment[id]=nil
    local mode,base=UI.get("heal_mode"),Farm.fountain()
    local safe=hp>12 and A.enemy_count_at(A.pos(u),1200)==0 and not Farm.under_tower(A.pos(u))
    if mode~=0 and safe then
        if Heal.regen_active(u) then
            S.heal_status="Мипо №"..id..": восстанавливается от танго"
            Orders.walk(u,Heal.wait_point(u,base),25,"отойти-для-танго");return true
        end
        local item,charges=Heal.tango(u)
        local record=S.heal_records[id]
        local retry=not record or S.now>=(record.next_attempt or -math.huge)
        if item and retry and (mode==1 or Heal.cheaper_tango(u,item,charges,base)) then
            local range=A.range(u,item,165)
            local best,dist=nil,math.huge
            for _,tree in ipairs(A.call(Trees and Trees.InRadius,A.pos(u),range+12,true) or {}) do
                local d=A.distance(A.pos(u),A.pos(tree))
                if A.call(Tree and Tree.IsActive,tree)==true and d<=range+12 and d<dist then best,dist=tree,d end
            end
            if best and Orders.cast(u,item,best,nil,30,"лечение-танго",0.3,true) then
                S.metrics.items=S.metrics.items+1
                S.heal_records[id]={await_until=S.now+0.6,next_attempt=S.now+1.5,wait=record and record.wait}
                S.heal_status="Мипо №"..id..": танго на дерево";return true
            end
        end
    end
    S.heal_status="Мипо №"..id..": фонтан"..(mode~=0 and " (танго недоступно / невыгодно / опасно)" or "")
    if base then Orders.walk(u,base,25,"лечение-фонтан") else S.heal_status="Не найдена своя база для лечения" end
    return true
end

-- Автонападение: отдельная начальная сборка всех готовых Мипо, не обычная очередь Poof.
function Hunt.finish(reason)
    S.hunt=nil;S.hunt_next=S.now+4;S.hunt_status="Автонападение: "..tostring(reason)
end
function Hunt.members(anchor)
    local out={}
    for _,u in ipairs(S.units) do
        if (u~=S.hero or UI.get("hunt_include_main") or u==anchor) and A.hp(u)>=UI.get("hunt_min_hp")
            and not S.healing[A.id(u)] and S.now>=(S.manual_until[A.id(u)] or -math.huge) then out[#out+1]=u end
    end
    return out
end
function Hunt.begin()
    if S.now<(S.hunt_next or -math.huge) or not UI.get("combo_net") then return false end
    if S.now<(S.hunt_scan_next or -math.huge) then return false end
    S.hunt_scan_next=S.now+0.20;Farm.snapshot()
    local best,score=nil,math.huge
    for _,u in ipairs(S.units) do
        if Farm.eligible(u,true) and not S.healing[A.id(u)] and A.hp(u)>=UI.get("hunt_min_hp") and not Orders.busy(u,60,S.now) then
            local net=A.spell(u,"meepo_earthbind")
            if net and A.ready(u,net,false) then
                for _,target in ipairs(S.heroes) do
                    if Combat.target_valid(target) then
                        local distance=A.distance(A.pos(u),A.pos(target))
                        local count=A.enemy_count_at(A.pos(target),1200)
                        if distance<=UI.get("hunt_radius") and count<=UI.get("hunt_max_enemies") and not Farm.under_tower(A.pos(target)) then
                            local value=distance+A.hp(target)*2
                            if value<score then best,score={anchor=u,target=target,started=S.now,phase="approach",joined={}},value end
                        end
                    end
                end
            end
        end
    end
    S.hunt=best
    return best~=nil
end
function Hunt.tick()
    if (not UI.get("hunt_enabled") and not (S.hunt and S.hunt.origin=="split")) or not UI.get("farm_enabled") then
        if S.hunt then Hunt.finish("выключено") end
        return false
    end
    if not S.hunt and not Hunt.begin() then return false end
    local h=S.hunt
    Farm.snapshot()
    if not Combat.target_valid(h.target) or not A.alive(h.anchor) then Hunt.finish("цель потеряна");return false end
    if S.now-h.started>UI.get("hunt_timeout") then Hunt.finish("истёк лимит времени");return false end
    if A.hp(h.anchor)<UI.get("hunt_min_hp") or S.healing[A.id(h.anchor)]
        or S.now<(S.manual_until[A.id(h.anchor)] or -math.huge) then Hunt.finish("клон отступает / ручное управление");return false end
    if Farm.under_tower(A.pos(h.target)) or A.enemy_count_at(A.pos(h.target),1200)>UI.get("hunt_max_enemies") then
        Hunt.finish("слишком опасно");return false
    end
    S.target=h.target
    local members=Hunt.members(h.anchor)
    S.combo_status="Автонападение клоном"
    if h.phase=="approach" then
        if Combat.net({h.anchor},h.target) then
            h.phase="root_wait";h.confirm_deadline=(S.net_pending and S.net_pending.arrival or S.now+1)+0.5
            h.arrival=S.net_pending and S.net_pending.arrival or S.now
            h.baseline=S.net_pending and S.net_pending.baseline_until or S.now
            S.hunt_status="Клон бросил сетку — ждём реальное попадание"
        else
            Orders.attack(h.anchor,h.target,60,"охота-сближение")
            S.hunt_status="Клон сближается для сетки"
        end
        return true
    end
    if h.phase=="root_wait" then
        local root=A.root_remaining(h.target,S.now)
        if root>0 and S.now+root>(h.baseline or S.now)+0.10 and S.now>=(h.arrival or 0)-0.1 then
            h.phase="gather";h.gather_until=S.now+2.1
        elseif S.now>(h.confirm_deadline or 0) then Hunt.finish("сетка не попала — сбор отменён");return false
        else Orders.attack(h.anchor,h.target,60,"охота-ждём-сетку");return true end
    end
    if h.phase=="gather" then
        S.hunt_status="Сетка попала — пуфуем готовых Мипо к клону"
        for _,u in ipairs(members) do
            if u~=h.anchor and not h.joined[A.id(u)] then
                local poof=A.spell(u,"meepo_poof")
                if poof and A.ready(u,poof,false) and Orders.cast(u,poof,h.anchor,nil,70,"пуф-сбор",A.poof_time(poof)+0.15,false) then
                    h.joined[A.id(u)]=true;S.metrics.poofs=S.metrics.poofs+1
                end
            end
        end
        Orders.attack(h.anchor,h.target,60,"охота-якорь-атакует")
        local waiting=false
        for _,u in ipairs(members) do
            if u~=h.anchor and not h.joined[A.id(u)] then
                local poof=A.spell(u,"meepo_poof")
                if poof and A.ready(u,poof,false) then waiting=true end
            end
        end
        if S.now>=h.gather_until or (not waiting and not Combat.poof_in_progress()) then h.phase="fight" end
        return true
    end
    local engaged={}
    for _,u in ipairs(members) do
        if u==h.anchor or h.joined[A.id(u)] or A.distance(A.pos(u),A.pos(h.target))<1500 then engaged[#engaged+1]=u end
    end
    S.hunt_status="Автобой: очередь пуфов и цепочка сеток"
    Combat.tick(engaged,h.target)
    return true
end

-- RU5: постоянные задания и цели вместо повторного выбора каждые 200 мс.
function Farm.record_creeps(camp,record)
    local list,seen={},{}
    for _,u in ipairs(Farm.nearby(camp.pos,760)) do
        local owner=S.creep_owner[A.id(u)]
        if A.alive(u) and (not owner or owner.unit~=u or owner.camp==camp.id) then list[#list+1]=u;seen[A.id(u)]=true end
    end
    for _,u in ipairs(record and record.members or {}) do
        if A.alive(u) and not seen[A.id(u)] and A.distance(A.pos(u),camp.pos)<2400 then list[#list+1]=u;seen[A.id(u)]=true end
    end
    -- Доп. юниты (осколки големов, скелеты и т.п.) появляются там, где стоял/погиб основной крип:
    -- берём нейтралов рядом с последними позициями членов пачки, даже если они числятся за соседним лагерем.
    for _,p in pairs(record and record.trail or {}) do
        if S.now-p.time<12 then
            for _,u in ipairs(Farm.nearby(p.pos,520)) do
                if A.alive(u) and not seen[A.id(u)] then list[#list+1]=u;seen[A.id(u)]=true end
            end
        end
    end
    return list
end
-- Зачистка засчитывается, только если после гибели последнего видимого крипа прошёл свежий снимок NPC:
-- доп. юниты рождаются в момент смерти основного, а старый снимок их ещё не содержит.
function Farm.confirmed_clear(rec)
    if not rec.clear_since then
        rec.clear_since=S.now;rec.clear_snapshot=S.snapshot_version or 0
    end
    -- Подтверждение — новый успешный снимок после наблюдения пустоты, не произвольный таймер.
    return S.snapshot_valid==true and (S.snapshot_version or 0)>(rec.clear_snapshot or 0)
        and (S.snapshot_time or -math.huge)>rec.clear_since
end

function Farm.find_camp(id)
    for _,c in ipairs(S.camps) do if c.id==id then return c end end
end
function Farm.legacy_choose(u,taken,waves)
    local previous=S.assignment[A.id(u)]
    local strategy=UI.get("farm_strategy")
    if previous and previous.kind=="neutral" and strategy~=2 then
        local camp=Farm.find_camp(previous.camp)
        local key="лагерь:"..tostring(previous.camp)
        if camp and not taken[key] and Farm.own_side(camp) and not Farm.under_tower(camp.pos)
            and (not S.stack_claims[camp.id] or S.stack_claims[camp.id].id==A.id(u))
            and (not Farm.ally_busy(camp) or Farm.engaged_here(u,camp))
            and (not UI.get("farm_avoid_enemies") or A.enemy_count_at(camp.pos,1300)==0) then
            local members=Farm.record_creeps(camp,previous)
            local uncleared=#members>0 or S.now<(previous.hold_until or 0)
                or (previous.empty_since and S.now-previous.empty_since<1.3)
            if uncleared then return {kind="neutral",key=key,camp=camp,pos=camp.pos} end
        end
    end
    if previous and previous.kind=="push" and UI.push_active() and strategy~=0 then
        local b=previous.building
        if Push.valid(u,b) and not taken["строение:"..tostring(A.id(b))] then
            return {kind="push",key="строение:"..tostring(A.id(b)),building=b,pos=A.pos(b)}
        end
    end
    if previous and previous.kind=="lane" and strategy~=0 then
        local live={}
        for _,c in ipairs(previous.members or {}) do
            if A.visible(c) and A.distance(A.pos(u),A.pos(c))<1500
                and Push.lane_safe(A.pos(c)) then live[#live+1]=c end
        end
        if #live>0 and not taken[previous.wave] then
            return {kind="lane",key=previous.wave,wave={id=previous.wave,pos=A.pos(live[1]),creeps=live},pos=A.pos(live[1])}
        end
    end
    local best,score=nil,math.huge
    if strategy~=2 then
        for _,camp in ipairs(S.camps) do
            local key="лагерь:"..tostring(camp.id)
            if not taken[key] and Farm.available(camp,u) and not Farm.under_tower(camp.pos) then
                local value=A.distance(A.pos(u),camp.pos)+250-math.min(#Farm.nearby(camp.pos,760),6)*80
                if previous and previous.camp==camp.id then value=value-550 end
                if value<score then best,score={kind="neutral",key=key,camp=camp,pos=camp.pos},value end
            end
        end
    end
    if strategy~=0 then
        for _,wave in ipairs(waves) do
            if not taken[wave.id] then
                local value=A.distance(A.pos(u),wave.pos)+200-math.min(#wave.creeps,7)*180
                if previous and previous.wave==wave.id then value=value-550 end
                if value<score then best,score={kind="lane",key=wave.id,wave=wave,pos=wave.pos},value end
            end
        end
        if UI.push_active() then
            for _,b in ipairs(S.buildings or {}) do
                local key="строение:"..tostring(A.id(b))
                local distance=A.distance(A.pos(u),A.pos(b))
                if not taken[key] and Push.valid(u,b) then
                    local value=distance+150
                    if previous and previous.kind=="lane" then value=value-450 end
                    if value<score then best,score={kind="push",key=key,building=b,pos=A.pos(b)},value end
                end
            end
        end
    end
    return best
end
function Farm.target_valid(c)
    return A.visible(c) and A.team(c)~=nil and A.team(c)~=S.team
        and not A.state(c,"MODIFIER_STATE_ATTACK_IMMUNE")
        and not A.state(c,"MODIFIER_STATE_INVULNERABLE")
        and not A.state(c,"MODIFIER_STATE_OUT_OF_GAME")
end
function Farm.damage_creeps(u,creeps,tag)
    local id=A.id(u);local record=S.assignment[id] or {}
    local target,score=nil,math.huge
    for _,c in ipairs(creeps) do
        if Farm.target_valid(c) then
            if c==record.target then target=c;break end
            local value=A.distance(A.pos(u),A.pos(c))+A.number(A.call(Entity.GetHealth,c),1000)*0.1
            if value<score then target,score=c,value end
        end
    end
    if UI.get("econ_enabled") then target=Econ.target(u,creeps,record,target) end
    if not target then return false end
    record.target=target;record.members=record.members or creeps
    -- Окно «замаха» защищает только живую цель последнего приказа атаки; после её смерти следующий приказ уходит сразу.
    local last=S.orders[id]
    if S.now<(S.attack_commit[id] or 0) and last and last.kind=="attack" and last.target~=nil and Farm.target_valid(last.target) then return false end
    if Econ.midas(u,creeps) then return true end
    local poof=A.spell(u,"meepo_poof")
    if UI.get("farm_poof") and poof and A.ready(u,poof,false) then
        local list=Farm.poof_targets(u,creeps,poof,record)
        local cost=A.number(A.call(Ability.GetManaCost,poof),0)
        local maxmana=A.number(A.call(NPC.GetMaxMana,u),0)
        if list and #list>=UI.get("farm_min_creeps") and maxmana>0 and (A.mana(u)-cost)/maxmana*100>=UI.get("farm_mana_pct")
            and Econ.poof_worth(u,list,poof) then
            if Orders.cast(u,poof,u,nil,20,"пуф-фарм",A.poof_time(poof)+0.12,false) then
                S.metrics.poofs=S.metrics.poofs+1;Farm.poof_watch(u,list,poof);return true
            end
        end
    end
    return Orders.attack(u,target,20,tag)
end
function Farm.outside_boxes(pos)
    for _,camp in ipairs(S.camps) do
        local box=camp.box
        if box then
            if pos.x>=box.min.x-250 and pos.x<=box.max.x+250 and pos.y>=box.min.y-250 and pos.y<=box.max.y+250 then return false end
        elseif A.distance(pos,camp.pos)<800 then return false end
    end
    return true
end
function Farm.unblock(u)
    local id,pos=A.id(u),A.pos(u)
    local park=S.parking[id]
    if park and S.now<park.until_time then
        if A.distance(pos,park.pos)>100 then Orders.walk(u,park.pos,20,"ожидать-вне-лагерей") end
        return
    end
    local nearest,distance=nil,math.huge
    for _,camp in ipairs(S.camps) do
        local d=A.distance(pos,camp.pos)
        if d<distance then nearest,distance=camp,d end
    end
    if not nearest or distance>900 then return end
    local best,score=nil,math.huge
    -- Однократный выбор точки вне ВСЕХ спавн-боксов. Не перевычисляем вектор от движущегося клона.
    for ring=1,3 do
        for i=0,15 do
            local angle=i*math.pi/8
            local point=A.vec(nearest.pos.x+math.cos(angle)*(800+ring*250),nearest.pos.y+math.sin(angle)*(800+ring*250),pos.z)
            local d=A.distance(pos,point)
            if d<score and Farm.outside_boxes(point) and Farm.safe_position(point,1200,false) then best,score=point,d end
        end
        if best then break end
    end
    if best then
        S.parking[id]={pos=best,until_time=Farm.spawn_deadline()}
        Orders.walk(u,best,20,"ожидать-вне-лагерей")
    end
end
function Farm.neutral_step(u,task,rec)
    local camp=task.camp;local previous=rec.members or {}
    local creeps=Farm.record_creeps(camp,rec);rec.members=creeps
    local all_dead=#previous>0
    for _,c in ipairs(previous) do if A.call(Entity.IsAlive,c)~=false then all_dead=false;break end end
    if all_dead then rec.deaths_confirmed=true end
    -- Заявка после стака: пока Мипо далеко от кемпа, «пусто» не засчитывается (новая пачка может быть в тумане).
    local claim=S.stack_claims[camp.id]
    if claim and claim.id~=A.id(u) then claim=nil end
    local returning=claim~=nil and A.distance(A.pos(u),camp.pos)>350
    if S.snapshot_valid and rec.engaged and #creeps==0 and rec.deaths_confirmed and not S.stack_units[A.id(u)] and not returning then
        -- Смерть всех членов пачки подтверждена через IsAlive; ждём один свежий снимок, чтобы не пропустить доп. юнитов.
        if Farm.confirmed_clear(rec) then
            rec.phase="done";S.camp_empty[camp.id]=Farm.spawn_deadline()
            if claim then S.stack_claims[camp.id]=nil end
            S.assignment[A.id(u)],S.econ_watch[A.id(u)]=nil,nil
            S.farm_next=-math.huge
        else rec.phase="confirm_empty" end
        return
    end
    local visible={}
    for _,c in ipairs(creeps) do if A.visible(c) then visible[#visible+1]=c end end
    -- Последние позиции членов пачки: основа для поиска доп. юнитов после гибели.
    rec.trail=rec.trail or {}
    for _,c in ipairs(visible) do rec.trail[A.id(c)]={pos=A.copy(A.pos(c)),time=S.now} end
    for id,p in pairs(rec.trail) do if S.now-p.time>12 then rec.trail[id]=nil end end
    if #creeps>0 then rec.clear_since,rec.clear_snapshot=nil,nil end
    if #visible>0 then
        rec.empty_since,rec.unseen_since,rec.deaths_confirmed=nil,nil,nil
        if not rec.target or not A.visible(rec.target) then
            local best,distance=nil,math.huge
            for _,c in ipairs(visible) do local d=A.distance(A.pos(u),A.pos(c));if d<distance then best,distance=c,d end end
            rec.target=best
        end
        rec.last_target_pos=A.copy(A.pos(rec.target))
        local range=A.number(A.call(NPC.GetAttackRange,u),150)
        local contact=A.distance(A.pos(u),rec.last_target_pos)<=range+90
        if contact then
            rec.engaged=true;rec.contact_at=S.now
            if claim then S.stack_claims[camp.id]=nil end -- дальше кемп удерживает обычное задание
        end
        rec.phase=contact and "combat" or "approach"
        if Stack.tick(u,task,rec) then return end
        -- The same ATTACK command owns approach and combat. No MOVE-to-centre is inserted between them.
        Farm.damage_creeps(u,visible,"атака-нейтрала")
        return
    end
    if S.stack_units[A.id(u)] then Stack.tick(u,task,rec);return end
    if not S.snapshot_valid then return end
    if returning then
        rec.phase="approach";rec.unseen_since,rec.search_pos=nil,nil
        Orders.walk(u,camp.pos,20,"возврат-на-стак");return
    end
    if #creeps>0 then
        rec.phase="search";rec.unseen_since=rec.unseen_since or S.now
        rec.search_pos=rec.search_pos or A.copy(rec.last_target_pos or camp.pos)
        if S.now-rec.unseen_since<4 then
            if A.distance(A.pos(u),rec.search_pos)>100 then Orders.walk(u,rec.search_pos,20,"проверить-последнюю-позицию") end
        else
            -- Unknown is NOT empty. Exclude just this unit/task briefly instead of dragging it backwards.
            S.econ_blacklist[tostring(A.id(u))..":"..task.key]=S.now+8
            S.assignment[A.id(u)]=nil
        end
        return
    end
    if A.distance(A.pos(u),camp.pos)>350 then
        rec.phase="approach";Orders.walk(u,camp.pos,20,"переход-к-лагерю");return
    end
    rec.phase="confirm_empty";rec.empty_since=rec.empty_since or S.now
    -- Нужен один новый успешный снимок NPC; парковка — только если следующего задания нет.
    if Farm.confirmed_clear(rec) then
        rec.phase="done";S.camp_empty[camp.id]=Farm.spawn_deadline()
        if claim then S.stack_claims[camp.id]=nil end
        S.assignment[A.id(u)],S.econ_watch[A.id(u)]=nil,nil
        S.farm_next=-math.huge
    end
end
function Farm.tick()
    if not UI.get("farm_enabled") then Stack.cancel_all("Фарм выключен");S.farm_status="Автофарм выключен; F6 — включить";return end
    if S.combo_active or S.hunt then Stack.cancel_all("Бой");S.farm_status="Пауза фарма: идёт бой";return end
    if S.now<(S.farm_next or -math.huge) then return end
    S.farm_next=S.now+.06
    Farm.refresh_camps();Farm.snapshot();Stable.ownership();Econ.observe()
    Stack.prune_claims();Farm.scan_allies();Farm.poof_audit()
    local waves,taken,active=Farm.waves(),{},0
    for id,rec in pairs(S.assignment) do
        if S.unit_ids[id] then local key=Econ.key(rec);if key then taken[key]=id end
        else S.assignment[id]=nil;Stack.cancel(id,"Мипо недоступен") end
    end
    Econ.plan(waves,taken)
    for camp_id,claim in pairs(S.stack_claims) do
        local key="лагерь:"..tostring(camp_id);if not taken[key] then taken[key]=claim.id end
    end
    for _,u in ipairs(S.units) do
        local id=A.id(u)
        if Farm.eligible(u,true) then
            if S.stack_units[id] and (A.hp(u)<UI.get("stack_min_hp") or not UI.get("stack_enabled")) then Stack.cancel(id,"Мало здоровья / выключено") end
            if Heal.handle(u) then Stack.cancel(id,"Лечение");S.parking[id]=nil
            elseif Push.danger(u) then Stack.cancel(id,"Защитник линии");if S.hunt then return end
            elseif S.tower_evade[id] then
                -- Tower exit/wait owns this unit; farm orders cannot pull it back in.
            elseif Stable.retreat(u) then Stack.cancel(id,"Опасность")
            elseif S.stack_units[id] then
                local task=Stable.current(u)
                if task then Stack.tick(u,task,S.assignment[id]) else Stack.cancel(id,"Потеря задания") end
            elseif Orders.busy(u,20,S.now) then
                -- No economic reevaluation, movement recovery, or empty-camp move during a real channel.
            elseif Econ.resources(u) then
                -- The resource active owns this pass.
            elseif Econ.watchdog(u) then
                -- Retry only the same order. Never add a speculative sideways move into an ongoing attack.
            else
                local reservations={}
                for key,owner in pairs(taken) do if owner~=id then reservations[key]=true end end
                local task=Farm.choose(u,reservations,waves)
                if task then
                    taken[task.key]=id;S.parking[id]=nil;active=active+1
                    local rec=Stable.bind(u,task)
                    if task.kind=="neutral" then
                        if not rec.engaged and Econ.travel(u,task) then
                            -- Economic travel preserves this same assignment.
                        else Farm.neutral_step(u,task,rec) end
                    elseif task.kind=="lane" then
                        rec.members=task.wave.creeps;rec.phase="lane";Farm.damage_creeps(u,rec.members,"атака-линии")
                    else rec.phase="push";Orders.attack(u,task.building,20,"сплитпуш-строение") end
                else
                    S.assignment[id]=nil
                    Stable.idle(u)
                end
            end
        end
    end
    S.farm_status=string.format("Фарм: занято %d; стадия фиксируется до конца задания",active)
end

-- Руны: один ближайший свободный Мипо на одну реальную видимую руну.
function RunesAI.allowed(rune)
    if A.call(Runes and Runes.Contains,rune)~=true or A.call(Entity.IsDormant,rune)==true then return false end
    local t=A.call(Rune and Rune.GetRuneType,rune)
    if t==nil then return false end
    if t==A.enum("RuneType","DOTA_RUNE_BOUNTY") then return UI.get("runes_bounty") end
    if t==A.enum("RuneType","DOTA_RUNE_XP") then return UI.get("runes_wisdom") end
    return UI.get("runes_power")
end
function RunesAI.tick()
    if not UI.get("runes_enabled") or not UI.get("farm_enabled") or S.combo_active or S.hunt then return end
    if S.now<(S.runes_next or -math.huge) then return end
    S.runes_next=S.now+.12;Farm.snapshot()
    local used={}
    for _,rune in ipairs(A.call(Runes and Runes.GetAll) or {}) do
        local safety_radius=UI.push_active() and math.max(1300,UI.get("push_danger_radius")) or 1300
        if RunesAI.allowed(rune) and Farm.safe_position(A.pos(rune),safety_radius,false) and S.now>=(S.rune_retry[A.id(rune)] or 0) then
            local rid=A.id(rune);local claim=S.rune_claims[rid]
            if claim and S.now-(claim.started or S.now)>4 then
                S.rune_retry[rid]=S.now+8;S.rune_claims[rid]=nil;claim=nil
            end
            local best,dist=nil,math.huge
            for _,u in ipairs(S.units) do
                local id=A.id(u);local record=S.assignment[id]
                local finishing=record and record.kind=="neutral" and #Farm.record_creeps(Farm.find_camp(record.camp) or {pos=A.pos(u)},record)>0
                if S.now>=(S.rune_retry[rid] or 0) and not used[id] and (u~=S.hero or UI.get("runes_main")) and not finishing
                    and not S.tower_evade[id] and not S.stack_units[id] and not S.push_escape[id] and not (record and record.kind=="push")
                    and (not UI.push_active() or Push.position_safe(A.pos(u)))
                    and not S.healing[id] and A.hp(u)>UI.get("farm_retreat_hp")
                    and S.now>=(S.manual_until[id] or 0) and not Orders.busy(u,15,S.now) then
                    local distance=A.distance(A.pos(u),A.pos(rune))
                    if distance<=UI.get("runes_radius") then
                        if claim and claim.unit==u and S.now<claim.until_time then best,dist=u,distance;break end
                        if distance<dist then best,dist=u,distance end
                    end
                end
            end
            if best then
                local id=A.id(best);used[id]=true;S.rune_busy[id]=S.now+.35
                if not claim or claim.unit~=best or S.now>=(claim.next_order or 0) then
                    if Orders.issue(best,"DOTA_UNIT_ORDER_PICKUP_RUNE",rune,A.pos(rune),nil,15,"подобрать-руну") then
                        S.rune_claims[rid]={unit=best,next_order=S.now+.8,until_time=S.now+4,started=claim and claim.started or S.now}
                    end
                end
            end
        end
    end
    for id,rec in pairs(S.rune_claims) do if S.now>rec.until_time then S.rune_claims[id]=nil end end
end

-- Hex не ждёт летящую сетку, когда надо запретить эскейп/защитный предмет или сбить канал.
function Combat.hex_wanted(u,item,target)
    if not Combat.target_valid(target) then return false end
    if S.hex_pending and S.hex_pending.target==target and S.now<S.hex_pending.until_time then return false end
    local cast=A.number(A.call(Ability.GetCastPoint,item,true),0)
    local margin=cast+UI.get("hex_margin_ms")/1000
    local remaining=A.control_remaining(target,S.now)
    local hard=math.max(A.mod_remaining(A.call(NPC.GetModifier,target,"modifier_sheepstick_debuff"),S.now),
        A.mod_remaining(A.call(NPC.GetModifier,target,"modifier_abyssal_blade_stun"),S.now),
        A.mod_remaining(A.call(NPC.GetModifier,target,"modifier_stunned"),S.now))
    if hard>margin then return false end
    local mode=UI.get("hex_mode")
    if mode==1 then return true end
    if mode==2 then return remaining<=margin and not Combat.pending_net(target) end
    local channel=A.call(NPC.GetChannellingAbility,target)
    if channel and A.call(Ability.IsChannelling,channel)==true then return true end
    if remaining<=margin then return true end
    for _,name in ipairs({"item_black_king_bar","item_manta","item_cyclone","item_wind_waker"}) do
        local escape=A.item(target,name)
        if escape and A.ready(target,escape,true) then return true end
    end
    for _,name in ipairs({"antimage_blink","queenofpain_blink","puck_phase_shift","slark_dark_pact","juggernaut_blade_fury","life_stealer_rage","morphling_waveform"}) do
        local escape=A.spell(target,name)
        if escape and (A.call(Ability.IsInAbilityPhase,escape)==true or A.ready(target,escape,false)) then return true end
    end
    return false
end
function Combat.hex(units,target)
    if not UI.get("items_enabled") or not UI.get("items_offensive") or not UI.get("combo_hex") then return false end
    for _,u in ipairs(units) do
        local item=A.item(u,"item_sheepstick")
        if item and not Orders.busy(u,60,S.now) and Combat.hex_wanted(u,item,target)
            and Items.apply(u,{ability=item,name="item_sheepstick"},target) then
            S.hex_pending={target=target,until_time=S.now+.35};return true
        end
    end
    return false
end

-- Сплитпуш: только с прикрытием крипов, без захода под backdoor / видимого защитника.
function Push.position_safe(pos)
    local radius=UI.get("push_danger_radius")
    if A.enemy_count_at(pos,radius)>0 then return false end
    for _,m in pairs(S.enemy_memory) do
        if S.now-m.time<UI.get("lane_memory_sec") and A.distance(pos,m.pos)<radius then return false end
    end
    return true
end
function Push.covered(pos)
    local count=0
    for _,c in ipairs(S.ally_creeps or {}) do if A.visible(c) and A.distance(pos,A.pos(c))<900 then count=count+1 end end
    return count>=2
end
function Push.lane_safe(pos)
    return Farm.safe_position(pos,UI.get("lane_safe_radius"),true)
        or (UI.push_active() and Push.position_safe(pos) and Push.covered(pos))
end
function Push.valid(u,b)
    if not UI.push_active() or not A.visible(b) or A.hp(u)<UI.get("push_min_hp") then return false end
    if A.distance(A.pos(u),A.pos(b))>2500 or not Push.position_safe(A.pos(b)) then return false end
    if A.call(NPC.IsTower,b)==true then
        if not Tower.creep_target(b) then return false end
    elseif not Push.covered(A.pos(b)) then return false end
    if A.state(b,"MODIFIER_STATE_INVULNERABLE") or A.state(b,"MODIFIER_STATE_ATTACK_IMMUNE") then return false end
    for _,name in ipairs({"modifier_backdoor_protection_active","modifier_fountain_glyph","modifier_invulnerable"}) do if A.has(b,name) then return false end end
    -- Не мешаем союзному герою, если такая политика выбрана для фарма.
    if UI.get("lane_respect_allies") then
        for _,h in ipairs(S.heroes) do
            if A.visible(h) and A.team(h)==S.team and not S.unit_ids[A.id(h)] and A.distance(A.pos(h),A.pos(b))<1200 then return false end
        end
    end
    return true
end
function Push.counter(u,target)
    if UI.get("push_response")~=1 or not target or Farm.under_tower(A.pos(u)) then return false end
    if A.enemy_count_at(A.pos(u),UI.get("push_danger_radius"))~=1 or A.distance(A.pos(u),A.pos(target))>700 then return false end
    local net=A.spell(u,"meepo_earthbind")
    if not UI.get("combo_net") or not A.ready(u,net,false) or Orders.busy(u,60,S.now) then return false end
    local ready=0
    for _,ally in ipairs(S.units) do
        local poof=A.spell(ally,"meepo_poof")
        if A.hp(ally)>=UI.get("push_min_hp") and not S.healing[A.id(ally)]
            and S.now>=(S.manual_until[A.id(ally)] or 0) and not Orders.busy(ally,70,S.now)
            and (ally==u or (poof and A.ready(ally,poof,false))) then ready=ready+1 end
    end
    if ready<3 then return false end
    S.hunt={anchor=u,target=target,started=S.now,phase="approach",joined={},origin="split"}
    S.assignment[A.id(u)]=nil;S.hunt_status="Сплитпуш: один защитник — сетка и сбор"
    return true
end
function Push.danger(u)
    local id=A.id(u);local rec=S.assignment[id]
    local escaping=S.push_escape[id]
    local relevant=UI.push_active() and rec and (rec.kind=="lane" or rec.kind=="push")
    if not relevant and not escaping then return false end
    if relevant and Push.position_safe(A.pos(u)) and (rec.kind~="push" or Push.position_safe(A.pos(rec.building))) then return false end
    if escaping and S.now>escaping.until_time and Push.position_safe(A.pos(u)) then S.push_escape[id]=nil;return false end
    local target,distance=nil,math.huge
    for _,h in ipairs(S.heroes) do
        local d=A.distance(A.pos(u),A.pos(h))
        if A.enemy(h) and d<distance then target,distance=h,d end
    end
    if not escaping and target and Push.counter(u,target) then return true end
    S.assignment[id],S.parking[id]=nil,nil
    S.push_escape[id]=escaping or {until_time=S.now+4}
    if UI.get("push_poof_escape") then
        local best,score=nil,-math.huge
        for _,ally in ipairs(S.units) do
            local d=A.distance(A.pos(u),A.pos(ally))
            if ally~=u and d>900 and A.hp(ally)>55 and Push.position_safe(A.pos(ally))
                and not Farm.under_tower(A.pos(ally)) and d>score then best,score=ally,d end
        end
        local poof=A.spell(u,"meepo_poof")
        if best and poof and A.ready(u,poof,false)
            and Orders.cast(u,poof,best,nil,85,"сплитпуш-уход-пуф",A.poof_time(poof)+.15,false) then return true end
    end
    local base=Farm.fountain()
    if base then Orders.walk(u,base,45,"сплитпуш-отступление") end
    S.farm_status="Сплитпуш: замечен противник — отход"
    return true
end

-- MegaMeepo: несколько раненых спасаются одним сбором; одиночный раненый сначала использует Dig.
function Mega.find(victim)
    if not UI.get("save_mega") or S.now<(S.mega_pending or 0) then return nil end
    local best,score=nil,-math.huge
    for _,caster in ipairs(S.units) do
        for _,name in ipairs({"meepo_megameepo","meepo_mega_meepo"}) do
            local ab=A.spell(caster,name)
            if ab and A.ready(caster,ab,false) and not Orders.busy(caster,100,S.now)
                and not A.has(caster,"modifier_meepo_megameepo") and not A.has(caster,"modifier_meepo_mega_meepo") then
                local radius=A.special(ab,{"radius","pull_radius"},600)
                local count,wounded,healthy=0,0,0
                for _,ally in ipairs(S.units) do
                    if ally~=caster and A.distance(A.pos(caster),A.pos(ally))<=radius and not A.has(ally,"modifier_meepo_petrify")
                        and not A.state(ally,"MODIFIER_STATE_OUT_OF_GAME") then
                        count=count+1;if A.hp(ally)<UI.get("mega_group_hp") then wounded=wounded+1 else healthy=healthy+1 end
                    end
                end
                if A.hp(caster)<UI.get("mega_group_hp") then wounded=wounded+1 end
                local in_range=not victim or A.distance(A.pos(caster),A.pos(victim))<=radius
                local can_save=count>0 and (A.hp(caster)>=30 or healthy>=2)
                local value=wounded*100+count*15+A.hp(caster)
                if in_range and can_save and value>score then best,score={unit=caster,ability=ab,radius=radius,wounded=wounded},value end
            end
        end
    end
    return best
end
function Mega.cast(rec,tag)
    if not rec then return false end
    if Orders.cast(rec.unit,rec.ability,nil,nil,100,tag,.65,false) then
        S.mega_pending=S.now+.8
        for _,ally in ipairs(S.units) do
            if ally~=rec.unit and A.distance(A.pos(rec.unit),A.pos(ally))<=rec.radius then
                S.locks[A.id(ally)]={ability=rec.ability,priority=100,sent=S.now,until_time=S.now+.65,tag="сборка-Mega"}
            end
        end
        S.safety_status="Мегамипо: сбор группы для спасения";return true
    end
    return false
end
function M.safety()
    if not UI.get("save_enabled") then return end
    local danger={}
    for _,u in ipairs(S.units) do
        local id,hp=A.id(u),A.hp(u);local previous=S.hp_samples[id]
        local drop=previous and previous.drop_until or 0
        if previous and previous.hp-hp>=4 then drop=S.now+1.2 end
        S.hp_samples[id]={hp=hp,drop_until=drop}
        if hp<=UI.get("save_hp") and not A.has(u,"modifier_meepo_petrify")
            and (hp<=12 or drop>S.now or A.enemy_count_at(A.pos(u),1000)>0) then danger[#danger+1]=u end
    end
    if UI.get("mega_mode")==0 then
        local group=Mega.find()
        if group and group.wounded>=UI.get("mega_group_count") and A.enemy_count_at(A.pos(group.unit),1000)>0 then
            if Mega.cast(group,"спасение-Mega-группа") then return end
        end
    end
    table.sort(danger,function(a,b)return A.hp(a)<A.hp(b) end)
    for _,u in ipairs(danger) do
        if not Orders.busy(u,100,S.now) then
            local saved=false
            if UI.get("mega_mode")==2 then saved=Mega.cast(Mega.find(u),"спасение-Mega") end
            local dig=A.spell(u,"meepo_petrify")
            if not saved and UI.get("save_dig") and dig and A.ready(u,dig,false) then
                saved=Orders.cast(u,dig,nil,nil,100,"спасение-Dig",math.max(.5,A.number(A.call(Ability.GetCastPoint,dig,true),0)+.15),false)
            end
            if not saved then saved=Mega.cast(Mega.find(u),"спасение-Mega") end
            if not saved and UI.get("save_poof") then
                local best,score=nil,-math.huge
                for _,other in ipairs(S.units) do
                    local d=A.distance(A.pos(u),A.pos(other))
                    if other~=u and d>800 and A.hp(other)>50 and A.enemy_count_at(A.pos(other),1200)==0
                        and not Orders.busy(other,100,S.now) and not Farm.under_tower(A.pos(other)) and d>score then best,score=other,d end
                end
                local poof=A.spell(u,"meepo_poof")
                if best and poof and A.ready(u,poof,false) then
                    saved=Orders.cast(u,poof,best,nil,100,"спасение-пуф",A.poof_time(poof)+.25,false)
                    if saved then S.metrics.poofs=S.metrics.poofs+1 end
                end
            end
            if saved then S.safety_status="Спасение Мипо №"..tostring(A.id(u)) end
        end
    end
end

-- Echo: используем ТОЛЬКО ещё не завершившийся наблюдаемый предкаст. Эффект урона уже слишком поздний сигнал.
function Echo.note(enemy,release,animation)
    if not A.enemy(enemy) or A.name(enemy)~="npc_dota_hero_earthshaker" then return end
    local now=A.now();local id=A.id(enemy)
    if type(release)~="number" or release<=now or release>now+1.5 then return end
    local rec=S.echo_casts[id]
    if not rec or math.abs(rec.release-release)>.02 then S.echo_casts[id]={source=enemy,release=release,handled={},animation=animation} end
end
function M.OnUnitAnimation(data)
    if type(data)~="table" or not data.unit or not UI.get("echo_enabled") then return end
    local name=tostring(data.sequenceName or ""):lower()
    if name:find("echo_slam",1,true) or name:find("echoslam",1,true) then
        local lead=A.number(data.castpoint,0)-math.max(0,A.number(data.lag_compensation_time,0))
        if lead>0 then Echo.note(data.unit,A.now()+lead,true) end
    end
end
function M.OnUnitAnimationEnd(data)
    if type(data)=="table" and data.unit and data.snap then S.echo_casts[A.id(data.unit)]=nil end
end
function Echo.protect(u,remaining)
    local margin=UI.get("echo_margin_ms")/1000
    if UI.get("items_enabled") and UI.get("echo_manta") then
        local manta=A.item(u,"item_manta")
        local window=manta and A.special(manta,{"invulnerability_duration","invuln_duration"},.1) or .1
        if manta and A.ready(u,manta,true) and A.call(Item and Item.IsItemEnabled,manta)~=false then
            -- Готовую Manta не обгоняет более ранний Eul: ждём её короткое окно.
            if remaining>math.min(window,margin) then return false end
            if remaining>.005 and Orders.cast(u,manta,nil,nil,110,"додж-Echo-Manta",math.max(.12,window),true) then return true end
        end
    end
    if UI.get("items_enabled") and UI.get("echo_euls") then
        for _,name in ipairs({"item_wind_waker","item_cyclone"}) do
            local item=A.item(u,name)
            if item and A.ready(u,item,true) then
                local cast=A.number(A.call(Ability.GetCastPoint,item,true),0)
                if remaining>cast+.025 and remaining<=cast+margin+.10
                    and Orders.cast(u,item,u,nil,110,"додж-Echo-циклон",cast+.25,true) then return true end
            end
        end
    end
    if UI.get("echo_dig") then
        local dig=A.spell(u,"meepo_petrify")
        local cast=dig and A.number(A.call(Ability.GetCastPoint,dig,true),.75) or .75
        if dig and A.ready(u,dig,false) and remaining>cast+.05 and remaining<=cast+margin+.12
            and Orders.cast(u,dig,nil,nil,110,"додж-Echo-Dig",cast+.2,false) then return true end
    end
    return false
end
function Echo.tick()
    if not UI.get("echo_enabled") then return end
    for _,enemy in ipairs(S.heroes) do
        if A.enemy(enemy) and A.name(enemy)=="npc_dota_hero_earthshaker" then
            local ab=A.spell(enemy,"earthshaker_echo_slam");local id=A.id(enemy)
            if ab and A.call(Ability.IsInAbilityPhase,ab)==true then
                local release=A.call(Ability.GetCastStartTime,ab)
                if type(release)=="number" and release>S.now then Echo.note(enemy,release,false)
                elseif not S.echo_seen[id] then
                    local cast=A.number(A.call(Ability.GetCastPoint,ab,true),0)
                    if cast>0 then Echo.note(enemy,S.now+cast,false) end
                end
                S.echo_seen[id]=true
            else
                S.echo_seen[id]=nil
                if S.echo_casts[id] and not S.echo_casts[id].animation then S.echo_casts[id]=nil end
            end
        end
    end
    for id,rec in pairs(S.echo_casts) do
        local left=rec.release-S.now
        if left<=0 or not A.enemy(rec.source) then S.echo_casts[id]=nil
        else
            local ab=A.spell(rec.source,"earthshaker_echo_slam")
            local radius=A.special(ab,{"echo_slam_echo_search_range","echo_slam_initial_radius","echo_slam_damage_range"},600)+200
            for _,u in ipairs(S.units) do
                local uid=A.id(u)
                if not rec.handled[uid] and A.distance(A.pos(u),A.pos(rec.source))<=radius and not Orders.busy(u,110,S.now) then
                    if Echo.protect(u,left) then rec.handled[uid]=true;S.safety_status="Попытка доджа Эхо: Мипо №"..tostring(uid) end
                end
            end
        end
    end
end

-- RU6: bounded economic allocation. All income/rates below are estimates, never measured GPM.
function Econ.stat(u)
    local id=A.id(u);local cached=S.econ_cache[id]
    if cached and cached.unit==u and S.now<cached.until_time then
        if cached.sampled_at~=S.now then
            cached.hp=math.max(1,A.number(A.call(Entity.GetHealth,u),cached.hp))
            cached.maxhp=math.max(1,A.number(A.call(Entity.GetMaxHealth,u),cached.maxhp))
            cached.pos=A.copy(A.pos(u));cached.sampled_at=S.now
        end
        return cached
    end
    local hero=A.call(Entity.IsHero,u)==true
    local min=A.call(NPC.GetTrueDamage,u);local max=A.call(NPC.GetTrueMaximumDamage,u)
    local attack=A.call(NPC.GetAttackTime,u)
    local armour=A.call(NPC.GetArmorDamageMultiplier,u)
    if type(armour)~="number" or armour<0 or armour>3 then
        local value=A.number(A.call(NPC.GetPhysicalArmorValue,u,false),0)
        armour=1-0.06*value/(1+0.06*math.abs(value))
    end
    local magic=A.number(A.call(NPC.GetMagicalArmorDamageMultiplier,u),.75)
    local lo,hi=A.call(NPC.GetGoldBountyMin,u),A.call(NPC.GetGoldBountyMax,u)
    local xp=A.call(NPC.GetBountyXP,u);local ancient=A.call(NPC.IsAncient,u)==true
    local lane=A.call(NPC.IsLaneCreep,u)==true
    local gold_known=type(lo)=="number" and type(hi)=="number"
    local gold=gold_known and math.max(0,(lo+hi)/2) or (ancient and 80 or lane and 45 or 40)
    local result={unit=u,until_time=S.now+.35,sampled_at=S.now,pos=A.copy(A.pos(u)),
        hp=math.max(1,A.number(A.call(Entity.GetHealth,u),1000)),maxhp=math.max(1,A.number(A.call(Entity.GetMaxHealth,u),1000)),
        damage=math.max(1,type(min)=="number" and (min+A.number(max,min))/2 or hero and 75 or 20),
        attack=math.max(.15,A.number(attack,1.5)),armour=math.max(.05,math.min(3,armour)),magic=math.max(0,math.min(2,magic)),
        regen=math.max(0,A.number(A.call(NPC.GetHealthRegen,u),0)),mana_regen=math.max(0,A.number(A.call(NPC.GetManaRegen,u),0)),
        speed=math.max(180,A.number(A.call(NPC.GetMoveSpeed,u),300)),gold=gold,xp=math.max(0,A.number(xp,ancient and 125 or 70)),
        ancient=ancient,lane=lane,trusted=type(min)=="number" and type(attack)=="number",
        confidence=gold_known and type(xp)=="number" and 1 or .72}
    S.econ_cache[id]=result;return result
end
function Econ.entries(creeps)
    local out={}
    for _,c in ipairs(creeps or {}) do if A.visible(c) then out[#out+1]=Econ.stat(c) end end
    return out
end
function Econ.observe()
    if not UI.get("econ_enabled") then return end
    S.econ_cycle=S.econ_cycle+1;S.econ_entries={}
    if S.econ_observed_snapshot==S.snapshot_version and S.econ_observed_camps==S.camps_version then return end
    S.econ_observed_snapshot,S.econ_observed_camps=S.snapshot_version,S.camps_version
    for _,camp in ipairs(S.camps) do
        local entries=Econ.entries(Farm.nearby(camp.pos,760))
        if #entries>0 then
            local memory={entries={},time=S.now}
            for _,e in ipairs(entries) do
                local copy={}
                for k,v in pairs(e) do if k~="unit" and k~="pos" then copy[k]=v end end
                copy.hp=copy.maxhp;copy.confidence=copy.confidence*.6
                memory.entries[#memory.entries+1]=copy
            end
            S.econ_profiles[camp.id]=memory
        end
    end
    -- Destroyed entities must not accumulate forever in long matches.
    for id,rec in pairs(S.econ_cache) do if S.now-rec.until_time>30 then S.econ_cache[id]=nil end end
end
function Econ.task_entries(task)
    local cache=S.econ_entries or {};S.econ_entries=cache
    if cache[task.key] then return cache[task.key] end
    local list=task.kind=="neutral" and Farm.record_creeps(task.camp,nil)
        or task.kind=="lane" and task.wave.creeps or {task.building}
    local entries=Econ.entries(list)
    if #entries==0 and task.kind=="neutral" then
        local previous=S.econ_profiles[task.camp.id]
        if previous and S.now-previous.time<180 then entries=previous.entries
        else entries={{hp=1400,maxhp=1400,damage=20,attack=1.5,armour=.85,magic=.75,
            regen=0,gold=85,xp=140,confidence=.4,trusted=false,ancient=false}} end
    end
    cache[task.key]=entries;return entries
end
function Econ.damage(ab,entry)
    if not ab then return 0 end
    local raw=A.special(ab,{"poof_damage","damage"},0)
    if raw<=0 then raw=A.number(A.call(Ability.GetDamage,ab),0) end
    if raw<=0 then return 0 end
    local dtype=A.call(Ability.GetDamageType,ab)
    local pure=A.enum("DamageTypes","DAMAGE_TYPE_PURE")
    local physical=A.enum("DamageTypes","DAMAGE_TYPE_PHYSICAL")
    local multiplier=pure and dtype==pure and 1 or physical and dtype==physical and entry.armour or entry.magic
    if entry.unit and A.state(entry.unit,"MODIFIER_STATE_INVULNERABLE") then return 0 end
    if entry.unit and not (pure and dtype==pure) and not (physical and dtype==physical)
        and A.state(entry.unit,"MODIFIER_STATE_MAGIC_IMMUNE") then return 0 end
    return raw*2*multiplier -- Self-Poof: departure and arrival at the same point.
end
function Econ.mana_reserve(u,ab)
    local percent=A.number(A.call(NPC.GetMaxMana,u),0)*UI.get("farm_mana_pct")/100
    local net=A.spell(u,"meepo_earthbind")
    local emergency=UI.get("econ_reserve_net") and net and A.number(A.call(Ability.GetLevel,net),0)>0
        and A.number(A.call(Ability.GetManaCost,net),0) or 0
    return math.max(percent,emergency)
end
function Econ.forecast(u,entries,allow_poof)
    local us=Econ.stat(u);local plain,after,incoming,gold,xp,confidence=0,0,0,0,0,1
    local ab=A.spell(u,"meepo_poof");local cost=ab and A.number(A.call(Ability.GetManaCost,ab),0) or 0
    local ready=allow_poof and UI.get("farm_poof") and ab and A.ready(u,ab,false)
        and A.mana(u)-cost>=Econ.mana_reserve(u,ab) and #entries>=UI.get("farm_min_creeps")
    local known,ancient,trusted=false,false,us.trusted
    for _,e in ipairs(entries) do
        local hit=math.max(1,us.damage*e.armour)
        local regen=math.min(hit/us.attack*.8,e.regen or 0)
        local health=e.hp*(1+regen/math.max(1,hit/us.attack-regen))
        plain=plain+math.ceil(health/hit)*us.attack
        local poof=ready and Econ.damage(ab,e) or 0
        if poof>0 then known=true end
        after=after+math.ceil(math.max(0,health-poof)/hit)*us.attack
        incoming=incoming+(e.trusted and e.damage/e.attack or 0)
        gold=gold+e.gold;xp=xp+e.xp;confidence=math.min(confidence,e.confidence or .5)
        ancient=ancient or e.ancient;trusted=trusted and e.trusted
    end
    local channel=ab and A.poof_time(ab) or 1.5
    local mana_cost_time=cost/math.max(1.5,us.mana_regen)*.03
    local saving=plain-(channel+after)
    local use=ready and known and saving>UI.get("econ_poof_save_ms")/1000+mana_cost_time
    local clear=use and channel+after or plain
    clear=math.max(.3,clear)
    local loss=math.max(0,(incoming*.55*us.armour-us.regen)*clear)
    local health=A.number(A.call(Entity.GetHealth,u),us.hp)
    local after_hp=(health-loss)/us.maxhp*100
    local heal_time=loss/math.max(10,us.maxhp*.025+us.regen)*.25
    if after_hp<UI.get("farm_retreat_hp")+8 then
        local base=Farm.fountain()
        heal_time=heal_time+(base and A.distance(A.pos(u),base)/us.speed*1.5 or 25)
    end
    return {clear=clear,plain=plain,poof=use,poof_gain=use and math.max(0,saving-mana_cost_time) or 0,
        mana_time=use and mana_cost_time or 0,heal_time=heal_time,loss=loss,after_hp=after_hp,
        gold=gold,xp=xp,confidence=confidence,ancient=ancient,trusted=trusted}
end
function Econ.ancient_safe(u,creeps)
    if not u or not UI.get("econ_ancients") then return false end
    local f=Econ.forecast(u,Econ.entries(creeps),true)
    return f.trusted and f.after_hp>=math.max(45,UI.get("farm_retreat_hp")+12) and f.clear<35
end
function Econ.route(u,task)
    local from,to=A.pos(u),task.pos
    if not from or not to or not S.heroes_valid then return nil end
    local risk=0
    for i=0,4 do
        local f=i/4;local p=A.vec(from.x+(to.x-from.x)*f,from.y+(to.y-from.y)*f,from.z)
        if UI.get("farm_avoid_enemies") and A.enemy_count_at(p,1100)>0 then return nil end
        if task.kind~="push" and Farm.under_tower(p) then
            if not (task.kind=="lane" and UI.push_active() and Push.covered(p)) then return nil end
        end
        for _,m in pairs(S.enemy_memory) do
            local age=S.now-m.time;local d=A.distance(p,m.pos)
            if age<UI.get("lane_memory_sec") and d<1200 then return nil end
            if age<30 and d<2400 then risk=math.max(risk,(1-age/30)*(1-d/2400)*18) end
        end
    end
    -- Straight-line distance + detour allowance, NOT a claim of a NavMesh shortest path.
    return A.distance(from,to)/Econ.stat(u).speed*1.15,risk
end
function Econ.evaluate(u,task)
    S.econ_metrics.evaluations=S.econ_metrics.evaluations+1
    if S.now<(S.econ_blacklist[tostring(A.id(u))..":"..task.key] or 0) then return nil end
    if task.kind=="neutral" and not Farm.available(task.camp,u) then return nil end
    if task.kind=="push" and not Push.valid(u,task.building) then return nil end
    local travel,risk=Econ.route(u,task);if not travel then return nil end
    local entries=Econ.task_entries(task);if #entries==0 then return nil end
    local forecast=Econ.forecast(u,entries,true)
    if forecast.ancient and (not UI.get("econ_ancients") or not forecast.trusted
        or forecast.after_hp<math.max(45,UI.get("farm_retreat_hp")+12)) then return nil end
    local gold,xp=forecast.gold,forecast.xp
    local expiry=1
    if task.kind=="lane" then
        -- A contested wave loses reward while we walk: approximate allied-creep pressure.
        local pressure=0
        for _,c in ipairs(S.ally_creeps or {}) do if A.visible(c) and A.distance(A.pos(c),task.pos)<800 then pressure=pressure+1 end end
        expiry=math.max(.15,1-travel*pressure*.016)
    elseif task.kind=="push" then
        -- Building rewards are shared; do not credit the whole team bounty to this caster.
        gold=gold*.25;xp=xp*.25
    end
    local goal=UI.get("econ_goal")
    local reward=goal==1 and gold or goal==2 and xp or gold+xp*UI.get("econ_xp_weight")/100
    local total=math.max(.8,travel+forecast.clear+forecast.heal_time+forecast.mana_time+(risk or 0))
    local score=reward*forecast.confidence*expiry/total
    local previous=S.assignment[A.id(u)]
    local oldkey=Econ.key(previous)
    if oldkey and oldkey~=task.key then score=score/(1+UI.get("econ_switch_pct")/100) end
    local lookahead=Econ.next_distance(task)
    if lookahead then score=score/(1+math.min(.18,lookahead/Econ.stat(u).speed/(total+5)*.18)) end
    forecast.total,forecast.travel,forecast.risk=total,travel,risk or 0
    forecast.score,forecast.gold_rate,forecast.xp_rate=score,gold*forecast.confidence*expiry/total*60,xp*forecast.confidence*expiry/total*60
    forecast.reason=forecast.confidence<.7 and "разведка / оценка" or forecast.poof and "выгоден Пуф" or "атаки выгоднее"
    forecast.expiry=expiry
    return forecast
end
function Econ.next_distance(task)
    if task.nearest_known then return task.nearest_distance end
    local best=math.huge
    for _,other in ipairs(S.econ_catalogue or {}) do
        if other.key~=task.key then best=math.min(best,A.distance(task.pos,other.pos)) end
    end
    task.nearest_known=true;task.nearest_distance=best<math.huge and best or nil
    return task.nearest_distance
end
function Econ.key(record)
    if not record then return nil end
    return record.kind=="neutral" and "лагерь:"..tostring(record.camp)
        or record.kind=="lane" and record.wave or record.kind=="push" and "строение:"..tostring(A.id(record.building)) or nil
end
function Econ.catalogue(waves)
    local all={}
    if UI.get("farm_strategy")~=2 then
        for _,c in ipairs(S.camps) do
            if Farm.own_side(c) and not Farm.under_tower(c.pos) then all[#all+1]={kind="neutral",key="лагерь:"..tostring(c.id),camp=c,pos=c.pos} end
        end
    end
    if UI.get("farm_strategy")~=0 then
        for _,w in ipairs(waves) do all[#all+1]={kind="lane",key=w.id,wave=w,pos=w.pos} end
        if UI.push_active() then
            for _,b in ipairs(S.buildings or {}) do all[#all+1]={kind="push",key="строение:"..tostring(A.id(b)),building=b,pos=A.pos(b)} end
        end
    end
    S.econ_catalogue=all;return all
end
function Econ.hold(u) return Stable.current(u) end

-- Small bounded maximum-weight matching; exact only inside the retained candidate shortlist.
function Econ.search(jobs,index,used,current,total,context)
    context.nodes=context.nodes+1;if context.nodes>20000 then return end
    if index>#jobs then
        if total>context.best_score then
            context.best_score=total;context.best={}
            for id,rec in pairs(current) do context.best[id]=rec end
        end
        return
    end
    if total+(context.upper[index] or 0)<=context.best_score then return end
    local job=jobs[index]
    for _,rec in ipairs(job.options) do
        if not used[rec.task.key] then
            used[rec.task.key]=true;current[job.id]=rec
            Econ.search(jobs,index+1,used,current,total+rec.eval.score,context)
            used[rec.task.key],current[job.id]=nil,nil
        end
    end
    Econ.search(jobs,index+1,used,current,total,context)
end
function Econ.match(jobs)
    table.sort(jobs,function(a,b)return #a.options==#b.options and tostring(a.id)<tostring(b.id) or #a.options<#b.options end)
    local context={nodes=0,best_score=-1,best={},upper={}}
    local upper=0
    for i=#jobs,1,-1 do upper=upper+(jobs[i].options[1] and jobs[i].options[1].eval.score or 0);context.upper[i]=upper end
    Econ.search(jobs,1,{},{},0,context)
    return context.best,context.best_score,context.nodes
end
function Econ.plan(waves,taken)
    S.econ_plan={};S.econ_planned_at=S.now
    if not UI.get("econ_enabled") then return end
    S.econ_metrics.plans=S.econ_metrics.plans+1
    local catalogue=Econ.catalogue(waves);local free,reserved,jobs={},{},{}
    for _,u in ipairs(S.units) do
        local id=A.id(u)
        if Farm.eligible(u,false) and not S.healing[id] and A.hp(u)>UI.get("farm_retreat_hp") and not S.push_escape[id] and not S.tower_evade[id] then free[id]=u end
    end
    for id,rec in pairs(S.assignment) do if not free[id] then local key=Econ.key(rec);if key then reserved[key]=id end end end
    for camp_id,claim in pairs(S.stack_claims) do
        local key="лагерь:"..tostring(camp_id);if not reserved[key] then reserved[key]=claim.id end
    end
    -- Мипо с заявкой возвращается на свой кемп (Farm.choose), в общий подбор не попадает.
    for id,u in pairs(free) do if Farm.claim_task(u) then free[id]=nil end end
    for id,u in pairs(free) do
        local task=Econ.hold(u)
        local eval=task and not reserved[task.key] and Stable.held_eval(u,task)
        if eval then
            S.econ_plan[id]={task=task,eval=eval};reserved[task.key]=id;free[id]=nil
        end
    end
    for id,u in pairs(free) do
        local options={}
        for _,task in ipairs(catalogue) do
            if not reserved[task.key] then
                local eval=Econ.evaluate(u,task)
                if eval and eval.score>0 then options[#options+1]={task=task,eval=eval} end
            end
        end
        table.sort(options,function(a,b)return a.eval.score==b.eval.score and a.task.key<b.task.key or a.eval.score>b.eval.score end)
        while #options>6 do table.remove(options) end
        jobs[#jobs+1]={id=id,options=options}
    end
    local assigned,score,nodes=Econ.match(jobs)
    S.econ_metrics.nodes=S.econ_metrics.nodes+nodes;S.econ_last_score=score
    for id,rec in pairs(assigned) do S.econ_plan[id]=rec;reserved[rec.task.key]=id end
    for key in pairs(taken) do taken[key]=nil end
    for key,id in pairs(reserved) do taken[key]=id end
end
function Farm.choose(u,taken,waves)
    local claimed=Farm.claim_task(u)
    if claimed then
        local current=Stable.current(u)
        local rec=S.assignment[A.id(u)]
        local fighting=current and current.key~=claimed.key and rec and rec.contact_at and S.now-rec.contact_at<8
        if fighting then return current end
        if not taken[claimed.key] then return claimed end
    end
    local opportunity=Tower.opportunity(u,taken)
    if opportunity then return opportunity end
    local task=Stable.current(u)
    if task and not taken[task.key] then return task end
    if not UI.get("econ_enabled") then return Farm.legacy_choose(u,taken,waves) end
    local id=A.id(u);local planned=S.econ_plan[id]
    if planned and not taken[planned.task.key] then S.econ_info[id]=planned.eval;return planned.task end
    return nil
end

function Econ.poof_worth(u,creeps,ab)
    if not UI.get("econ_enabled") then return true end
    if A.mana(u)-A.number(A.call(Ability.GetManaCost,ab),0)<Econ.mana_reserve(u,ab) then return false end
    if not UI.get("econ_poof") then return true end
    local in_range={}
    for _,c in ipairs(creeps) do if A.visible(c) and A.distance(A.pos(u),A.pos(c))<=A.poof_radius(ab)-35 then in_range[#in_range+1]=c end end
    local entries=Econ.entries(in_range)
    local raw=A.special(ab,{"poof_damage","damage"},0)
    if raw<=0 then raw=A.number(A.call(Ability.GetDamage,ab),0) end
    if raw<=0 then return true end -- Unknown damage metadata: preserve the established min-creeps/mana policy.
    local forecast=Econ.forecast(u,entries,true)
    S.econ_info[A.id(u)]=S.econ_info[A.id(u)] or {}
    S.econ_info[A.id(u)].reason=forecast.poof and "выгоден Пуф" or "берегу ману / атаки быстрее"
    return forecast.poof
end
function Econ.target(u,creeps,record,fallback)
    local last=S.orders[A.id(u)]
    if fallback and Farm.target_valid(fallback) and (record.kind~="lane"
        or (last and last.kind=="attack" and last.target==fallback)
        or A.call(NPC.IsAttacking,u)==true or S.now<(S.attack_commit[A.id(u)] or 0)) then return fallback end
    local us=Econ.stat(u);local best,score=nil,-math.huge
    for _,c in ipairs(creeps) do
        if Farm.target_valid(c) then
            local e=Econ.stat(c);local hp=A.number(A.call(Entity.GetHealth,c),e.hp)
            local hit=us.damage*e.armour;local walk=math.max(0,A.distance(A.pos(u),A.pos(c))-150)/us.speed
            local finish=math.ceil(hp/math.max(1,hit))*us.attack+walk
            local value=(e.gold+e.xp*.15)/math.max(.2,finish)
            if hp<=hit and walk<.5 then value=value*3 end
            if c==record.target then value=value*1.12 end
            if value>score then best,score=c,value end
        end
    end
    return best or fallback
end
function Econ.midas(u,creeps)
    if not UI.get("econ_enabled") or not UI.get("econ_midas") or not UI.get("items_enabled") then return false end
    local item=A.item(u,"item_hand_of_midas")
    if not item or not A.ready(u,item,true) or A.call(Item and Item.IsItemEnabled,item)==false then return false end
    local best,score=nil,-math.huge
    for _,c in ipairs(creeps) do
        if A.visible(c) and A.call(NPC.IsAncient,c)~=true and not A.state(c,"MODIFIER_STATE_MAGIC_IMMUNE")
            and A.distance(A.pos(u),A.pos(c))<=A.range(u,item,600) then
            local e=Econ.stat(c);local value=e.xp+math.min(400,e.hp)*.08
            if value>score then best,score=c,value end
        end
    end
    if best and Orders.cast(u,item,best,nil,24,"фарм-Midas",.25,true) then
        S.metrics.items=S.metrics.items+1;S.econ_metrics.midas=S.econ_metrics.midas+1;return true
    end
    return false
end
function Econ.resources(u)
    if not UI.get("econ_enabled") or not UI.get("econ_resources") or not UI.get("items_enabled") or not UI.get("items_resources")
        or Orders.busy(u,26,S.now) then return false end
    for _,name in ipairs({"item_magic_wand","item_magic_stick","item_guardian_greaves","item_mekansm","item_arcane_boots","item_soul_ring"}) do
        local item=A.item(u,name);local rule=Items.rules[name]
        if item and rule and A.ready(u,item,true) and A.call(Item and Item.IsItemEnabled,item)~=false then
            local need=(name=="item_arcane_boots" or name=="item_soul_ring") and A.mana_pct(u)<45
                or (name~="item_arcane_boots" and name~="item_soul_ring" and (A.hp(u)<60 or A.mana_pct(u)<30))
            if name=="item_soul_ring" then need=need and A.hp(u)>75 end
            if need and Items.condition(rule,u,item,u) then
                local behavior=A.call(Ability.GetBehavior,item)
                local target=(rule.mode=="self" or (rule.mode=="self_or_none" and A.flag(behavior,"AbilityBehavior","DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"))) and u or nil
                if Orders.cast(u,item,target,nil,26,"фарм-ресурсы:"..name,.2,true) then S.metrics.items=S.metrics.items+1;return true end
            end
        end
    end
    return false
end
function Econ.travel(u,task)
    if not UI.get("econ_enabled") or not UI.get("econ_travel_poof") or A.distance(A.pos(u),task.pos)<1600 then return false end
    local ab=A.spell(u,"meepo_poof")
    if not ab or not A.ready(u,ab,false) or A.mana(u)-A.number(A.call(Ability.GetManaCost,ab),0)<Econ.mana_reserve(u,ab) then return false end
    -- Пуф к кемпу без видимых нейтралов (после стака / пустой кемп) — в пустоту: идём пешком.
    if task.kind=="neutral" and (S.stack_claims[task.camp.id] or #Farm.nearby(task.pos,760)==0) then return false end
    local us=Econ.stat(u);local walking=A.distance(A.pos(u),task.pos)/us.speed
    local best,saving=nil,UI.get("econ_travel_save")
    local info=S.econ_info[A.id(u)] or {};local lost_clear=info.poof_gain or 0
    local mana_time=A.number(A.call(Ability.GetManaCost,ab),0)/math.max(1.5,us.mana_regen)*.03
    for _,ally in ipairs(S.units) do
        if ally~=u and A.hp(ally)>55 and not S.healing[A.id(ally)] and not S.push_escape[A.id(ally)]
            and not A.state(ally,"MODIFIER_STATE_OUT_OF_GAME") and A.call(NPC.IsRunning,ally)~=true
            and not S.stack_units[A.id(ally)] and not S.poof_watch[A.id(ally)]
            and A.call(Ability.IsChannelling,A.spell(ally,"meepo_poof"))~=true
            and A.distance(A.pos(ally),task.pos)<850 and Farm.safe_position(A.pos(ally),1300,false) then
            local gain=walking-A.poof_time(ab)-A.distance(A.pos(ally),task.pos)/us.speed-lost_clear-mana_time
            if gain>saving then best,saving=ally,gain end
        end
    end
    if best and Orders.cast(u,ab,best,nil,22,"пуф-переход-фарм",A.poof_time(ab)+.15,false) then
        local id=A.id(u);local old=S.assignment[id]
        local record=task.kind=="neutral" and {kind="neutral",camp=task.camp.id,hold_until=S.now+A.poof_time(ab)+1}
            or task.kind=="lane" and {kind="lane",wave=task.wave.id,members=task.wave.creeps}
            or {kind="push",building=task.building}
        if Econ.key(old)==task.key then record=old end
        S.assignment[id]=record;S.metrics.poofs=S.metrics.poofs+1;S.econ_metrics.travel_poofs=S.econ_metrics.travel_poofs+1
        S.econ_info[id]=info;info.reason=string.format("Пуф экономит ≈%.1f с",saving);return true
    end
    return false
end
function Econ.watchdog(u)
    if not UI.get("econ_enabled") or not UI.get("econ_watchdog") or Orders.busy(u,20,S.now)
        or S.stack_units[A.id(u)] or not S.snapshot_valid then return false end
    local id=A.id(u);local rec=S.assignment[id];local key=Econ.key(rec)
    if not rec or not key then S.econ_watch[id]=nil;return false end
    if rec.phase=="search" or rec.phase=="confirm_empty" then return false end
    local target=rec.kind=="push" and rec.building or rec.target
    -- Недоступную цель заменит обычный выбор фарма; не повторяем приказ в иммунитет.
    if target and rec.kind~="push" and not Farm.target_valid(target) then return false end
    local pos=target and A.visible(target) and A.pos(target)
        or rec.kind=="neutral" and Farm.find_camp(rec.camp) and Farm.find_camp(rec.camp).pos
    if not pos then return false end
    local health=0
    if rec.kind=="push" then health=A.number(A.call(Entity.GetHealth,target),0)
    else for _,c in ipairs(rec.members or {}) do if A.visible(c) then health=health+A.number(A.call(Entity.GetHealth,c),0) end end end
    local distance=A.distance(A.pos(u),pos);local watch=S.econ_watch[id]
    local last_hit=A.number(A.call(NPC.GetLastAttackTime,u),-math.huge)
    if not watch or watch.key~=key then
        S.econ_watch[id]={key=key,health=health,distance=distance,progress=S.now,last_hit=last_hit};return false
    end
    -- Только изменение наблюдений: застывший IsAttacking больше не маскирует зависание.
    local new_hit=last_hit>(watch.last_hit or -math.huge)
    watch.last_hit=last_hit
    if distance<watch.distance-70 or new_hit then
        if new_hit then S.econ_retries[tostring(id)..":"..key]=nil end
        watch.progress=S.now;watch.health=health;watch.distance=distance;return false
    end
    if S.now-watch.progress<UI.get("econ_stall_sec") then return false end
    local retry_key=tostring(id)..":"..key;local attempts=S.econ_retries[retry_key] or 0
    S.econ_retries[retry_key]=attempts+1;S.econ_retry_time[retry_key]=S.now
    watch.progress=S.now;S.econ_metrics.stalls=S.econ_metrics.stalls+1
    if attempts==0 then
        S.orders[id]=nil
        if target and A.visible(target) then return Orders.attack(u,target,23,"фарм-повтор-атаки") end
        return Orders.walk(u,pos,23,"фарм-повтор-подхода")
    end
    S.econ_blacklist[retry_key]=S.now+12
    S.assignment[id],S.econ_watch[id],S.econ_info[id]=nil,nil,nil
    return true
end

-- Stable execution owns an assignment; the economist only selects a NEW one.
function Stable.trace(u,tag,target,pos)
    local rec=S.assignment[A.id(u)];local line={time=S.now,unit=A.id(u),tag=tag,phase=rec and rec.phase or "idle",
        key=Econ.key(rec),target=target and A.id(target),x=pos and pos.x,y=pos and pos.y}
    S.farm_trace[#S.farm_trace+1]=line;if #S.farm_trace>128 then table.remove(S.farm_trace,1) end
    if UI.get("stable_trace") then
        A.log(string.format("%0.2f | Мипо %s | %s | %s | %s",S.now,tostring(line.unit),UI.phase_name(line.phase),tostring(line.key or "—"),tag),true)
    end
end
function Stable.ownership()
    if not S.snapshot_valid then return end
    if S.ownership_snapshot==S.snapshot_version and S.ownership_camps==S.camps_version then return end
    S.ownership_snapshot,S.ownership_camps=S.snapshot_version,S.camps_version
    for id,rec in pairs(S.creep_owner) do if not A.alive(rec.unit) then S.creep_owner[id]=nil end end
    for _,camp in ipairs(S.camps) do
        for _,u in ipairs(Farm.nearby(camp.pos,760)) do
            local id=A.id(u);local old=S.creep_owner[id]
            if not old or old.unit~=u then
                local best,distance=camp,A.distance(A.pos(u),camp.pos)
                for _,other in ipairs(S.camps) do local d=A.distance(A.pos(u),other.pos);if d<distance then best,distance=other,d end end
                S.creep_owner[id]={unit=u,camp=best.id}
            end
        end
    end
end
function Stable.bind(u,task)
    local id=A.id(u);local rec=S.assignment[id]
    if rec and Econ.key(rec)==task.key then return rec end
    rec={kind=task.kind,phase="approach",started=S.now,lease_until=S.now+math.min(120,10+A.distance(A.pos(u),task.pos)/math.max(180,A.number(A.call(NPC.GetMoveSpeed,u),300))*1.6)}
    if task.kind=="neutral" then rec.camp=task.camp.id
    elseif task.kind=="lane" then rec.wave=task.wave.id;rec.members=task.wave.creeps
    else rec.building=task.building end
    S.assignment[id]=rec;S.econ_watch[id]=nil;return rec
end
function Stable.current(u)
    local id=A.id(u);local rec=S.assignment[id];if not rec then return nil end
    if rec.kind=="neutral" and UI.get("farm_strategy")~=2 then
        local camp=Farm.find_camp(rec.camp)
        if not camp or not Farm.own_side(camp) then return nil end
        if Farm.ally_busy(camp) and not Farm.engaged_here(u,camp) and not S.stack_units[id] then
            -- Союзник начал фармить этот кемп раньше нас: отпускаем задание, выбор другого — в этом же тике.
            S.econ_blacklist[tostring(id)..":"..Econ.key(rec)]=S.now+6
            S.assignment[id],S.econ_watch[id]=nil,nil;return nil
        end
        if not rec.engaged and rec.lease_until and S.now>rec.lease_until and not S.stack_units[id] then
            S.econ_blacklist[tostring(id)..":"..Econ.key(rec)]=S.now+6;S.assignment[id]=nil;return nil
        end
        -- Admission forecasts, mana changes, stale IsKnownClear and a short score drop cannot revoke this command.
        return {kind="neutral",key=Econ.key(rec),camp=camp,pos=camp.pos}
    elseif rec.kind=="lane" and UI.get("farm_strategy")~=0 then
        local live={}
        for _,c in ipairs(rec.members or {}) do
            if A.visible(c) and A.distance(A.pos(u),A.pos(c))<1800 and Push.lane_safe(A.pos(c)) then live[#live+1]=c end
        end
        if #live>0 then return {kind="lane",key=rec.wave,wave={id=rec.wave,pos=A.pos(live[1]),creeps=live},pos=A.pos(live[1])} end
    elseif rec.kind=="push" and UI.get("farm_strategy")~=0 and Push.valid(u,rec.building) then
        return {kind="push",key=Econ.key(rec),building=rec.building,pos=A.pos(rec.building)}
    end
end
function Stable.held_eval(u,task)
    local old=S.econ_info[A.id(u)]
    if old then old.reason=S.stack_units[A.id(u)] and "стак: отдельный владелец" or "удерживаю начатое задание";return old end
    return {score=.01,gold_rate=0,xp_rate=0,total=0,reason="удерживаю начатое задание"}
end
function Stable.retreat(u)
    local id=A.id(u);local rec=S.assignment[id];local existing=S.farm_retreat[id]
    local danger=false
    if UI.get("farm_avoid_enemies") then
        local point=rec and rec.kind=="neutral" and Farm.find_camp(rec.camp)
        danger=A.enemy_count_at(A.pos(u),1000)>0 or (point and A.enemy_count_at(point.pos,1300)>0)
            or (Farm.under_tower(A.pos(u)) and not (UI.push_active() and (Push.covered(A.pos(u)) or Tower.covered_position(u)) and Push.position_safe(A.pos(u))))
    end
    if danger then
        existing=existing or {};existing.until_time=S.now+4;S.farm_retreat[id]=existing
        S.assignment[id],S.econ_watch[id],S.parking[id]=nil,nil,nil
    end
    if existing and S.now<existing.until_time then
        local base=Farm.fountain();if base then Orders.walk(u,base,30,"отход-фарм") end
        return true
    end
    S.farm_retreat[id]=nil;return false
end
function Stable.idle(u)
    -- A missing plan/temporary low score is NOT an instruction to reverse away from a living camp.
    for _,camp in ipairs(S.camps) do
        if A.distance(A.pos(u),camp.pos)<900 then
            local stack=S.stack_camps[camp.id]
            local empty=S.now<(S.camp_empty[camp.id] or 0)
            if empty or (stack and stack.unit~=u) then Farm.unblock(u);return end
        end
    end
end

-- A stack attempt is a separate owner, not a periodic farm MOVE override.
function Stack.cancel(id,reason)
    local state=S.stack_units[id];if not state then return end
    S.stack_camps[state.camp]=nil;S.stack_units[id]=nil
    S.stack_results[id]={camp=state.camp,time=S.now,success=false,reason=reason or "Отменено"}
end
function Stack.cancel_all(reason)
    local ids={};for id in pairs(S.stack_units or {}) do ids[#ids+1]=id end
    for _,id in ipairs(ids) do Stack.cancel(id,reason) end
end
function Stack.claim(u,state,confirmed)
    if not u or not state or not state.camp then return nil end
    local id=A.id(u)
    for camp_id,old in pairs(S.stack_claims) do if old.id==id then S.stack_claims[camp_id]=nil end end
    local claim={unit=u,id=id,camp=state.camp,minute=state.minute,initial_ids=state.initial_ids or {},
        confirmed=confirmed==true,created=S.now,expires=S.now+(confirmed and 75 or 30)}
    S.stack_claims[state.camp]=claim
    S.camp_empty[state.camp],S.camp_knowledge[state.camp]=nil,nil
    return claim
end
function Stack.claim_for(u)
    local id=A.id(u)
    for _,claim in pairs(S.stack_claims) do if claim.id==id then return claim end end
end
function Stack.prune_claims()
    for camp_id,claim in pairs(S.stack_claims) do
        if S.now>=claim.expires or not S.unit_ids[claim.id] or not A.alive(claim.unit) then S.stack_claims[camp_id]=nil end
    end
end
function Stack.point(u,camp)
    if not camp.box then return nil end
    local center,pos=camp.pos,A.pos(u);local dx,dy=pos.x-center.x,pos.y-center.y
    local preferred=math.atan(dy,dx);local best,score=nil,math.huge
    local width=math.max(math.abs(camp.box.max.x-camp.box.min.x),math.abs(camp.box.max.y-camp.box.min.y))*.5
    local radius=math.max(UI.get("stack_distance"),width+550)
    for i=0,15 do
        local angle=preferred+i*math.pi/8
        local candidate=A.vec(center.x+math.cos(angle)*radius,center.y+math.sin(angle)*radius,center.z)
        if Farm.outside_boxes(candidate) and Farm.safe_position(candidate,1300,false) and not Farm.under_tower(candidate) then
            local value=A.distance(pos,candidate)
            if value<score then best,score=candidate,value end
        end
    end
    return best
end
function Stack.begin(u,task,rec)
    if not UI.get("stack_enabled") or task.kind~="neutral" or not S.snapshot_valid or A.hp(u)<UI.get("stack_min_hp")
        or Orders.busy(u,35,S.now) then return nil end
    local clock=A.number(A.call(GameRules.GetGameTime),S.now)-A.number(A.call(GameRules.GetGameStartTime),0)
    if clock<0 then return nil end
    local minute=math.floor(clock/60);local second=clock-minute*60
    if second<UI.get("stack_second") or second>=57.8 or S.stack_attempts[task.camp.id]==minute then return nil end
    if A.distance(A.pos(u),task.pos)>650 then return nil end
    local visible={};for _,c in ipairs(rec.members or {}) do if A.visible(c) then visible[#visible+1]=c end end
    if #visible==0 then return nil end
    local point=Stack.point(u,task.camp);if not point then return nil end
    local target=rec.target or visible[1];if not A.visible(target) then target=visible[1] end
    local ids={};for _,c in ipairs(visible) do ids[A.id(c)]=true end
    local state={unit=u,camp=task.camp.id,minute=minute,phase="tag",point=A.copy(point),target=target,
        started=S.now,spawn=S.now+(60-second),initial_ids=ids,initial_hp=A.number(A.call(Entity.GetHealth,target),0),
        initial_hit=A.number(A.call(NPC.GetLastAttackTime,u),-math.huge),
        baseline=A.number(A.call(Camp and Camp.GetKnownStackCount,task.camp.raw or task.camp.handle or task.camp.data),0)}
    S.stack_units[A.id(u)],S.stack_camps[state.camp],S.stack_attempts[state.camp]=state,state,minute
    Stable.trace(u,"стак-начало",target,point);return state
end
function Stack.tick(u,task,rec)
    local id=A.id(u);local state=S.stack_units[id] or Stack.begin(u,task,rec)
    if not state then return false end
    if task.kind~="neutral" or state.camp~=task.camp.id or not UI.get("stack_enabled") then Stack.cancel(id,"Смена задания");return false end
    if A.hp(u)<UI.get("stack_min_hp") then Stack.cancel(id,"Мало здоровья");return false end
    if Orders.busy(u,35,S.now) then return true end
    if state.phase=="tag" then
        local last_hit=A.number(A.call(NPC.GetLastAttackTime,u),-math.huge)
        local hp=A.number(A.call(Entity.GetHealth,state.target),state.initial_hp)
        local recent=last_hit>state.initial_hit or (state.initial_hit>state.started-.65 and A.distance(A.pos(u),A.pos(state.target))<250)
        if hp<state.initial_hp or recent then
            state.phase="pull";state.tag_confirmed=S.now
        elseif S.now-state.started>2 or S.now>state.spawn-1.3 then
            Stack.cancel(id,"Агро не подтверждено; отвод не запускался");return true
        else
            Orders.attack(u,state.target,35,"стак-агро");return true
        end
    end
    if state.phase=="pull" then
        -- The point is captured ONCE. Do not recompute a vector from the moving clone.
        rec.phase="stack_pull";Orders.walk(u,state.point,35,"стак-фиксированный-отвод")
        if S.now>=state.spawn+1.0 then state.phase="verify" end
        return true
    end
    if state.phase=="verify" then
        rec.phase="stack_verify"
        local known=A.number(A.call(Camp and Camp.GetKnownStackCount,task.camp.raw or task.camp.handle or task.camp.data),0)
        local old_alive,new_visible=0,0
        for _,c in ipairs(Farm.record_creeps(task.camp,rec)) do
            if A.visible(c) then
                if state.initial_ids[A.id(c)] then old_alive=old_alive+1
                elseif A.distance(A.pos(c),task.pos)<650 then new_visible=new_visible+1 end
            end
        end
        local confirmed=known>state.baseline or (old_alive>0 and new_visible>0)
        if confirmed or S.now>=state.spawn+3 then
            S.stack_results[id]={camp=state.camp,time=S.now,success=confirmed,
                reason=confirmed and "Новый спавн подтверждён" or "Новый спавн не подтверждён"}
            Stable.trace(u,confirmed and "стак-подтверждён" or "стак-не-подтверждён",nil,state.point)
            S.stack_units[id],S.stack_camps[state.camp]=nil,nil
            rec.phase="combat";rec.engaged=true;rec.target=nil;rec.empty_since=nil
            rec.contact_at,rec.deaths_confirmed,rec.unseen_since,rec.search_pos=nil,nil,nil,nil
            Stack.claim(u,state,confirmed) -- вернуться на этот кемп и зачистить новую пачку
            return true
        end
        return true
    end
    return true
end



-- No undocumented GetAttackTarget API: use fresh, visible tower attack projectiles.
function Tower.range(b,u)
    return math.max(300,A.number(A.call(NPC.GetAttackRange,b),700))+math.max(0,A.number(A.call(NPC.GetAttackRangeBonus,b),0))
        +math.max(0,A.number(A.call(NPC.GetHullRadius,b),0))+math.max(0,A.number(A.call(NPC.GetHullRadius,u),0))
end
function Tower.creep_target(b)
    local shot=S.tower_shots[A.id(b)]
    if not shot or shot.source~=b or not A.visible(b) then return nil end
    local ttl=math.max(1.0,math.min(3,2*A.number(A.call(NPC.GetAttackTime,b),1)+.35))
    if A.now()-shot.time>ttl then return nil end
    local target=shot.target
    if not A.visible(target) or A.team(target)~=S.team or A.call(NPC.IsLaneCreep,target)~=true then return nil end
    if A.distance(A.pos(target),A.pos(b))>Tower.range(b,target)+100 then return nil end
    for _,c in ipairs(S.ally_creeps or {}) do if c==target then return target,shot end end
end
function Tower.covered_position(u)
    for _,b in ipairs(S.towers or {}) do
        if A.visible(b) and A.distance(A.pos(u),A.pos(b))<=Tower.range(b,u)+200 and Tower.creep_target(b) then return true end
    end
    return false
end
function Tower.cancel(id) S.tower_evade[id]=nil end
function Tower.exit_point(u,b)
    local center,pos=A.pos(b),A.pos(u);if not center or not pos then return nil end
    local angle=math.atan(pos.y-center.y,pos.x-center.x)
    local radius=Tower.range(b,u)+UI.get("tower_exit_margin")
    local best,score=nil,math.huge
    for i=0,15 do
        local a=angle+i*math.pi/8;local p=A.vec(center.x+math.cos(a)*radius,center.y+math.sin(a)*radius,pos.z)
        local safe=Push.position_safe(p) -- source tower uses its actual exit radius, not the generic +350 farming exclusion
        for _,other in ipairs(S.towers or {}) do
            if other~=b and A.visible(other) and A.distance(p,A.pos(other))<Tower.range(other,u)+80 then safe=false end
        end
        if safe then local d=A.distance(pos,p);if d<score then best,score=p,d end end
    end
    return best or Farm.fountain()
end
-- Агро = свежий снаряд ИМЕННО этой башни по ЭТОМУ Мипо (учёт по Мипо, а не по последней цели башни).
function Tower.aggro(u,b)
    local hit=S.tower_hits[A.id(u)]
    if not hit or A.id(hit.tower)~=A.id(b) then return false end
    return A.now()-hit.time<=math.max(1.0,math.min(3,A.number(A.call(NPC.GetAttackTime,b),1)*1.5+.25))
end
-- Союзный крип в радиусе башни, на которого можно попытаться перевести её цель.
function Tower.reaggro_target(u,b)
    local best,score=nil,math.huge
    local limit=Tower.range(b,u)+100
    for _,c in ipairs(S.ally_creeps or {}) do
        if A.visible(c) and A.distance(A.pos(c),A.pos(b))<=limit then
            local d=A.distance(A.pos(u),A.pos(c))
            if d<score then best,score=c,d end
        end
    end
    return best
end
-- Одна попытка переагра на союзного крипа (приказ следовать за ним); результат проверяется по следующему снаряду башни.
function Tower.reaggro(u,state)
    local b=state.tower
    if not state.sent then
        local creep=Tower.reaggro_target(u,b)
        if creep and Orders.issue(u,"DOTA_UNIT_ORDER_MOVE_TO_TARGET",creep,A.pos(creep),nil,88,"сплитпуш-переагр") then
            S.orders[A.id(u)]=nil
            state.sent=S.now;state.sent_serial=state.serial
            state.until_time=S.now+math.max(.5,A.number(A.call(NPC.GetAttackTime,b),1)+.25)
            S.tower_status="Башня бьёт Мипо: пробую переагрить на союзного крипа"
        else
            state.phase="exit";S.tower_status="Переагр невозможен: выхожу из радиуса башни"
        end
        return
    end
    if state.serial>state.sent_serial then
        state.phase="exit";S.tower_status="Башня снова бьёт Мипо: выхожу из радиуса"
    elseif S.now>=state.until_time then
        local creep,shot=Tower.creep_target(b)
        state.phase="exit"
        S.tower_status=(creep and shot.serial>state.sent_serial) and "Башня перешла на крипа: продолжаю отход"
            or "Переагр не подтверждён: выхожу из радиуса башни"
    end
end
function Tower.arm(u,b,serial,reason)
    local id=A.id(u);local old=S.tower_evade[id]
    if old and A.id(old.tower)==A.id(b) then
        if serial and serial>old.serial then
            old.serial=serial;old.outside=nil;old.resume_after=nil
            if old.phase=="wait" then old.phase="exit" end
        end
        return old
    end
    -- Первая реакция на агро — попытка переагра; нет крипа — сразу выход из радиуса.
    local state={tower=b,serial=serial or 0,started=A.now(),point=Tower.exit_point(u,b),
        phase=Tower.reaggro_target(u,b) and "reaggro" or "exit",reason=reason}
    S.tower_evade[id]=state;Stack.cancel(id,"Агро башни")
    local rec=S.assignment[id];if rec then rec.phase="tower_exit" end
    return state
end
function M.OnProjectile(data)
    if type(data)~="table" or not S.session or data.isAttack~=true then return end
    local b,target=data.source,data.target
    if not b or not target or not A.visible(b) or A.team(b)==S.team or A.call(NPC.IsTower,b)~=true then return end
    local old=S.tower_shots[A.id(b)]
    if data.handle and old and old.handle==data.handle then return end
    S.tower_seq=S.tower_seq+1
    local shot={source=b,target=target,time=A.now(),serial=S.tower_seq,handle=data.handle}
    S.tower_shots[A.id(b)]=shot
    if S.unit_ids[A.id(target)] then S.tower_hits[A.id(target)]={tower=b,time=shot.time,serial=shot.serial} end
    if UI.push_active() and UI.get("farm_enabled") and not S.combo_active and not S.hunt and S.unit_ids[A.id(target)]
        and Farm.eligible(target,true) then Tower.arm(target,b,shot.serial,"Башня стреляет в Мипо") end
end
function Tower.opportunity(u,taken)
    if not UI.push_active() or UI.get("farm_strategy")==0 or S.tower_evade[A.id(u)] then return nil end
    local rec=S.assignment[A.id(u)]
    if rec and rec.kind=="neutral" then return nil end -- never steal a committed camp
    for _,c in ipairs(S.lane_creeps or {}) do if A.visible(c) and A.distance(A.pos(u),A.pos(c))<900 then return nil end end
    local best,distance=nil,1150
    for _,b in ipairs(S.buildings or {}) do
        local key="строение:"..tostring(A.id(b));local d=A.distance(A.pos(u),A.pos(b))
        if not taken[key] and d<distance and A.call(NPC.IsTower,b)==true and Push.valid(u,b) then
            best,distance={kind="push",key=key,building=b,pos=A.pos(b)},d
        end
    end
    return best
end
function Tower.tick()
    if not UI.push_active() or not UI.get("farm_enabled") or S.combo_active or S.hunt then
        S.tower_evade={};return
    end
    for _,u in ipairs(S.units) do
        local id=A.id(u);local state=S.tower_evade[id];local rec=S.assignment[id]
        if S.now<(S.manual_until[id] or -math.huge) then Tower.cancel(id)
        elseif not Push.position_safe(A.pos(u)) then Tower.cancel(id) -- defender escape keeps priority
        elseif Farm.eligible(u,true) then
            -- Агро определяется только по реальному снаряду башни в этого Мипо, а не по отсутствию прикрытия.
            local hit=S.tower_hits[id]
            if not state and hit and A.alive(hit.tower) and A.visible(hit.tower) and Tower.aggro(u,hit.tower) then
                state=Tower.arm(u,hit.tower,hit.serial,"Башня бьёт Мипо")
            end
            if state then
                if not A.alive(state.tower) then Tower.cancel(id);S.assignment[id]=nil
                elseif not Orders.busy(u,88,S.now) then
                    local distance=A.distance(A.pos(u),A.pos(state.tower))
                    local outside=distance>=Tower.range(state.tower,u)+UI.get("tower_exit_margin")-25
                    if state.phase=="reaggro" then Tower.reaggro(u,state) end
                    if state.phase=="reaggro" then
                        -- ждём следующий снаряд башни; приказ следования уже отдан
                    elseif not outside then
                        state.phase="exit";state.outside=nil;state.resume_after=nil
                        if state.point then Orders.walk(u,state.point,88,"сплитпуш-выход-из-агро") end
                        S.tower_status="Башня выбрала Мипо: выхожу из радиуса"
                    else
                        if not state.outside then state.outside=S.now;state.resume_after=S.now+1.0 end
                        state.phase="wait"
                        local creep,shot=Tower.creep_target(state.tower)
                        if creep and shot.serial>state.serial and shot.time>=state.outside-.1 and S.now>=state.resume_after
                            and not Tower.aggro(u,state.tower) then
                            Tower.cancel(id);S.orders[id]=nil;S.tower_status="Башня снова бьёт крипа: возвращаюсь"
                        elseif S.now-state.started>10 then
                            Tower.cancel(id);S.assignment[id]=nil;S.tower_status="Агро на крипе не подтверждено: другое задание"
                        else
                            S.tower_status="Вне радиуса: жду снаряд башни по крипу"
                            if state.point and A.distance(A.pos(u),state.point)>100 then Orders.walk(u,state.point,88,"сплитпуш-ожидание-переагро") end
                        end
                    end
                end
            end
        end
    end
end

-- Player-scoped totals: clones must NOT multiply gold, last hits or net worth.
function Finance.number(v)
    return type(v)=="number" and v==v and v>=0 and v<math.huge and v or nil
end
function Finance.tick(force)
    if not S.session or not S.player then return end
    local f=S.finance
    if not force and S.now<(f.next_update or -math.huge) then return end
    f.next_update=S.now+1
    local data=A.call(Player and Player.GetTeamPlayer,S.player,S.finance_buffer)
    local clock=math.max(0,Farm.clock())
    f.time=clock;f.updated=S.now
    f.earned,f.networth,f.lasthits,f.denies=nil,nil,nil,nil
    if type(data)=="table" then
        f.earned=Finance.number(data.totalearned_gold);f.networth=Finance.number(data.networth)
        f.lasthits=Finance.number(data.lasthit_count);f.denies=Finance.number(data.deny_count)
    end
    f.wallet=Finance.number(A.call(Player and Player.GetTotalGold,S.player))
    if f.wallet==nil and type(data)=="table" then
        local a,b=Finance.number(data.reliable_gold),Finance.number(data.unreliable_gold)
        if a and b then f.wallet=a+b end
    end
    f.gpm=f.earned and clock>=1 and f.earned*60/clock or nil
    if f.base and f.earned and (clock<f.base.time or f.earned<f.base.gold) then f.base=nil end
    if not f.base and f.earned and clock>=UI.get("finance_start_sec") then
        f.base={time=clock,gold=f.earned,lasthits=f.lasthits}
    end
    f.measure_gpm,f.measure_hits,f.measure_seconds=nil,nil,nil
    if f.base then
        f.measure_seconds=math.max(0,clock-f.base.time)
        if f.earned and f.measure_seconds>=1 then f.measure_gpm=math.max(0,f.earned-f.base.gold)*60/f.measure_seconds end
        if f.lasthits and f.base.lasthits and f.lasthits>=f.base.lasthits then f.measure_hits=f.lasthits-f.base.lasthits end
    end
end
function Finance.restart()
    if not S.session then return end
    Finance.tick(true)
    local f=S.finance
    f.base=f.earned and {time=f.time,gold=f.earned,lasthits=f.lasthits} or nil
    f.measure_gpm,f.measure_hits,f.measure_seconds=nil,0,0
end
function Finance.text(v)
    return type(v)=="number" and string.format("%.0f",v) or "—"
end
function Finance.rows()
    local f=S.finance;local elapsed=f.measure_seconds or 0
    return {
        {"ЗОЛОТО",HUD.colors.gold},
        {"Доход "..Finance.text(f.gpm).." /мин · Капитал "..Finance.text(f.networth)},
        {"Кошелёк "..Finance.text(f.wallet).." · Крипы "..Finance.text(f.lasthits).." / "..Finance.text(f.denies).." своих"},
        {string.format("Замер %02d:%02d · +%s крипов",math.floor(elapsed/60),math.floor(elapsed%60),Finance.text(f.measure_hits))},
        {"Доход за замер: "..Finance.text(f.measure_gpm).." зол/мин"},
        {f.earned==nil and "Статистика игрока недоступна" or "Данные игрока · не прогноз",HUD.colors.muted},
    }
end
function Finance.draw()
    if not UI.get("finance_show") or not HUD.visible() or not HUD.prepare() then return end
    local layout=HUD.current_layout or HUD.layout()
    if layout then HUD.paint(layout.finance) end
end

function M.Diagnostics()
    return {version=M.VERSION,last_error=S.last_error,last_api_error=S.last_api_error,
        api_errors=S.api_errors,metrics=S.metrics,combo_blocked=S.combo_blocked}
end

A.log("Загружен Мипо РУ "..M.VERSION..". Комбо: Пробел. Фарм: только клоны. F6 — переключение фарма.",true)
return M
