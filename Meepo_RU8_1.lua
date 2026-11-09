-- Meepo RU 8.1 / Перезапуск, 2026-11-09.
-- Новое самостоятельное ядро для Umbrella / UC.Zone API v2 (Lua 5.4).
-- Старые MeepoV2 и их копии необходимо отключить: одновременно загружайте один скрипт.
-- Проверки в mock-среде не заменяют проверку внутри текущей сборки Umbrella.
local M = { VERSION = "8.1", CONFIG_NAME = "Meepo_RU_8" }
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
}
M.defaults, M.state, M.ui = D, S, UI
M.combat, M.farm, M.orders, M.api = Combat, Farm, Orders, A

function A.call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    return nil
end
function A.method(obj, name, ...)
    if not obj then return nil end
    return A.call(obj[name], obj, ...)
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
    if not item and level ~= nil and level < 1 then return false, "Способность не изучена" end
    if A.call(Ability.IsInAbilityPhase, ab) == true or A.call(Ability.IsChannelling, ab) == true then
        return false, "Уже применяется"
    end
    if A.number(A.call(Ability.GetCooldown, ab), 0) > 0.04 then return false, "Перезарядка" end
    local mana = A.mana(u)
    if mana < A.number(A.call(Ability.GetManaCost, ab), 0) then return false, "Не хватает маны" end
    if type(Ability.IsCastable) == "function" then
        local castable = A.call(Ability.IsCastable, ab, mana)
        if castable ~= true then return false, "API: каст недоступен" end
    end
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
    if type(print) == "function" then print("[Мипо RU 8] " .. tostring(text)) end
end
function M.reset()
    for k in pairs(S) do S[k] = nil end
    S.units, S.unit_ids, S.heroes, S.acted, S.locks = {}, {}, {}, {}, {}
    S.spell_next, S.orders, S.manual_until, S.hp_samples = {}, {}, {}, {}
    S.camps, S.camp_empty, S.assignment, S.healing, S.failures = {}, {}, {}, {}, {}
    S.camp_knowledge = {}
    S.combo_status, S.farm_status = "Ожидание клавиши комбо", "Ожидание клонов"
    S.metrics = {orders=0, nets=0, poofs=0, failures=0, hero_scans=0, npc_scans=0}
    S.key_prev = {}
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
    S.tower_shots,S.tower_evade,S.tower_seq={},{},0
    S.finance,S.finance_buffer={},{}
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
-- Disable only the push master, never its configuration group.
function UI.push_active()
    return UI.get("farm_enabled")==true and UI.get("push_enabled")==true
end
function UI.sync_push()
    if UI.syncing_push then return end
    UI.syncing_push=true
    local farm=UI.get("farm_enabled")==true
    if not farm then
        if UI.get("push_enabled")==true then
            UI.values.push_enabled=false
            A.method(UI.push_enabled,"Set",false)
            UI.save("push_enabled")
        end
        S.tower_evade,S.push_escape={},{}
    end
    A.method(UI.push_enabled,"Disabled",not farm)
    UI.syncing_push=false
end
function UI.group(name)
    return A.call(Menu and Menu.Create,"Heroes","Hero List","Мипо RU 8","Настройки",name)
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
        if key=="farm_enabled" or key=="push_enabled" then UI.sync_push() end
        UI.save(key)
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
    A.log("Загружен стартовый профиль: фармят клоны; сетка и Poof включены.",true)
end
function UI.init()
    UI.values = {}
    local g = UI.group("Основное")
    UI.add(g,"Switch","enabled","Скрипт включён")
    UI.add(g,"Bind","combo_key","Комбо — удерживать (Пробел)")
    UI.add(g,"Bind","farm_key","Включить / выключить фарм (F6)")
    UI.add(g,"Bind","poof_cursor_key","Пуф к ближайшему к курсору Мипо (F)")
    UI.add(g,"Bind","poof_self_key","Пуф на месте (G)")
    A.method(g,"Button","Вернуть стартовый профиль",UI.reset_defaults)
    A.method(g,"Label","Включайте только одну версию скрипта. Комбо работает по врагу у курсора.")
    g = UI.group("Комбо")
    UI.add(g,"Switch","combo_all","Управлять всеми Мипо")
    UI.add(g,"Switch","combo_net","Использовать сетки по цепочке")
    UI.add(g,"Switch","combo_poof","Использовать пуф")
    UI.add(g,"Slider","combo_radius","Радиус выбора цели, пиксели",80,600)
    UI.add(g,"Slider","combo_world_radius","Запасной радиус цели у курсора, ед.",150,1000)
    UI.add(g,"Slider","net_overlap_ms","Запас цепочки сеток, мс",50,350)
    UI.add(g,"Slider","net_max_lead_ms","Максимальное упреждение второй сетки, мс",300,1400)
    UI.add(g,"Switch","poof_require_root","Пуф только под подтверждённый контроль")
    UI.add(g,"Switch","combo_blink","Использовать Blink")
    UI.add(g,"Switch","combo_hex","Использовать Hex")
    UI.add(g,"Switch","combo_stops_farm","Комбо выключает фарм до повторного F6")
    UI.add(g,"Combo","hex_mode","Когда применять Hex",{"Умно: угроза или конец контроля","Сразу при возможности","К концу текущего контроля"})
    UI.add(g,"Slider","hex_margin_ms","Запас передачи контроля Hex, мс",80,350)
    UI.add(g,"Switch","combo_silence","Использовать Orchid / Bloodthorn")
    UI.add(g,"Switch","combo_slow","Использовать Diffusal / Disperser / Atos")
    A.method(g,"Label","Сначала одна сетка; следующая — к концу рута с учётом полёта.")
    g = UI.group("Фарм клонов")
    UI.add(g,"Switch","farm_enabled","Автофарм включён")
    UI.add(g,"Combo","farm_mode","Кто фармит",{"Только клоны","Все Мипо","Только невыбранные"})
    UI.add(g,"Combo","farm_strategy","Режим фарма",{"Только нейтралы","Адаптивный","Только линии"})
    UI.add(g,"Slider","lane_safe_radius","Радиус безопасности линии, ед.",900,3000)
    UI.add(g,"Slider","lane_memory_sec","Помнить увиденного врага, с",3,30)
    UI.add(g,"Switch","lane_respect_allies","Не мешать союзным героям на линии")
    UI.add(g,"Combo","heal_mode","Лечение после фарма",{"Фонтан","Танго, иначе фонтан","Автоматически выгоднее"})
    UI.add(g,"Combo","farm_side","Выбор половины карты",{"Своя половина карты","Вся карта"})
    UI.add(g,"Switch","farm_poof","Пуф для урона нейтралам")
    UI.add(g,"Slider","farm_min_creeps","Минимум нейтралов для пуфа",1,6)
    UI.add(g,"Slider","farm_mana_pct","Запас маны после пуфа, %",0,80)
    UI.add(g,"Slider","farm_retreat_hp","Отход на лечение при HP, %",10,60)
    UI.add(g,"Slider","farm_resume_hp","Возврат к фарму при HP, %",50,100)
    UI.add(g,"Switch","farm_avoid_enemies","Не идти к видимым врагам")
    UI.add(g,"Slider","manual_pause_ms","Пауза фарма после ручной команды, мс",500,6000)
    g = UI.group("Спасение")
    UI.add(g,"Switch","save_enabled","Автоспасение при низком HP")
    UI.add(g,"Slider","save_hp","Порог спасения, %",5,45)
    UI.add(g,"Switch","save_dig","Dig — приоритетный сейв")
    UI.add(g,"Switch","save_mega","Автоматический MegaMeepo")
    UI.add(g,"Combo","mega_mode","Приоритет Dig / Mega",{"Умно: группа в опасности → Mega","Сначала Dig, затем Mega","Сначала Mega, затем Dig"})
    UI.add(g,"Slider","mega_group_hp","Групповой сейв при HP ниже, %",25,60)
    UI.add(g,"Slider","mega_group_count","Раненых рядом для группового Mega",2,4)
    UI.add(g,"Switch","save_poof","Пуф к безопасному Мипо")
    A.method(g,"Label","Полный HP и просто враг рядом НЕ включают спасение.")
    g = UI.group("Автонападение")
    UI.add(g,"Switch","hunt_enabled","Нападать на врага во время фарма")
    UI.add(g,"Switch","hunt_include_main","Подключать главного Мипо через пуф")
    UI.add(g,"Slider","hunt_radius","Радиус поиска врага клоном, ед.",400,1600)
    UI.add(g,"Slider","hunt_min_hp","Минимальный HP участника, %",35,90)
    UI.add(g,"Slider","hunt_max_enemies","Допустимо врагов рядом",1,3)
    UI.add(g,"Slider","hunt_timeout","Предел одного нападения, с",5,25)
    A.method(g,"Label","Клон → сетка → подтверждение рута → сбор через пуф → бой. По умолчанию выключено.")
    g = UI.group("Предметы")
    UI.add(g,"Switch","items_enabled","Автоматически использовать активные слоты")
    UI.add(g,"Switch","items_offensive","Урон, контроль и усиление атаки")
    UI.add(g,"Switch","items_defensive","Защитные предметы по ситуации")
    UI.add(g,"Switch","items_resources","Лечение и мана от активок")
    UI.add(g,"Switch","items_detection","Dust по невидимой цели")
    UI.add(g,"Switch","items_unknown","Другие боевые активки по метаданным API")
    UI.add(g,"Switch","items_refresher","Разрешить Refresher при потраченных способностях")
    UI.add(g,"Switch","items_toggles","Разрешить включение Armlet / Radiance")
    A.method(g,"Label","Пассивки, рюкзак, TP, варды, Smoke и опасные неизвестные активки не прожимаются вслепую.")
    g = UI.group("Автостак")
    UI.add(g,"Switch","stack_enabled","Стакать текущий лагерь перед минутой")
    UI.add(g,"Slider","stack_second","Секунда начала агро",50,57)
    UI.add(g,"Slider","stack_distance","Длина отвода от центра, ед.",800,1500)
    UI.add(g,"Slider","stack_min_hp","Минимальный HP для стака, %",30,75)
    A.method(g,"Label","Один удар → фиксированный отвод → ожидание нового спавна. По умолчанию выключено; универсального направления для всех кемпов нет.")
    g = UI.group("Выгода фарма")
    UI.add(g,"Switch","econ_enabled","Экономический планировщик фарма")
    UI.add(g,"Combo","econ_goal","Главная цель",{"Баланс золота и опыта","Максимум золота","Максимум опыта"})
    UI.add(g,"Slider","econ_xp_weight","Вес опыта в сбалансированном режиме, %",0,100)
    UI.add(g,"Switch","econ_ancients","Разрешать древних после оценки силы и HP")
    UI.add(g,"Switch","econ_poof","Poof только при расчётной выгоде")
    UI.add(g,"Slider","econ_poof_save_ms","Минимальная экономия Poof, мс",100,1500)
    UI.add(g,"Switch","econ_reserve_net","Беречь ману на аварийную сетку")
    UI.add(g,"Switch","econ_travel_poof","Poof для выгодного перемещения между заданиями")
    UI.add(g,"Slider","econ_travel_save","Минимальная экономия дороги через Poof, с",1,8)
    UI.add(g,"Switch","econ_resources","Ресурсные активки вместо лишнего похода на базу")
    UI.add(g,"Switch","econ_midas","Использовать собственный Midas по выгодной цели")
    UI.add(g,"Switch","econ_watchdog","Проверять реальный прогресс задания")
    UI.add(g,"Slider","econ_stall_sec","Реакция на отсутствие прогресса, с",5,15)
    UI.add(g,"Slider","econ_switch_pct","Порог смены незавершённого маршрута, %",10,50)
    UI.add(g,"Switch","econ_details","Показывать расчётную выгоду и причину действий")
    A.method(g,"Label","Сравнение награды / (дорога + зачистка + ресурсы + риск). Это оценка, не измеренный GPM и не сведения из тумана.")
    g = UI.group("Руны")
    UI.add(g,"Switch","runes_enabled","Подбирать ближайшие видимые руны вне боя")
    UI.add(g,"Slider","runes_radius","Максимальный крюк за руной, ед.",150,1000)
    UI.add(g,"Switch","runes_main","Разрешить подбор главным Мипо")
    UI.add(g,"Switch","runes_bounty","Руны богатства")
    UI.add(g,"Switch","runes_power","Боевые руны и вода")
    UI.add(g,"Switch","runes_wisdom","Руны мудрости")
    g = UI.group("Echo Slam")
    UI.add(g,"Switch","echo_enabled","Пытаться уклониться от видимого предкаста Echo")
    UI.add(g,"Switch","echo_manta","Manta — короткая неуязвимость")
    UI.add(g,"Switch","echo_euls","Eul / Wind Waker на себя")
    UI.add(g,"Switch","echo_dig","Dig, только если успевает уйти под землю")
    UI.add(g,"Slider","echo_margin_ms","Временной запас, мс",30,90)
    A.method(g,"Label","Мгновенный Echo после Blink без доступного предкаста нельзя гарантированно доджить. BKB не считается неуязвимостью.")
    g = UI.group("Сплитпуш")
    UI.add(g,"Switch","push_enabled","Давить пустую линию и атаковать строения")
    A.method(g,"Label","Сплитпуш доступен только при включённом автофарме. Настройки можно менять всегда. Сплитпуш не включает автофарм.")
    UI.add(g,"Slider","push_min_hp","Минимальный HP для сплитпуша, %",40,90)
    UI.add(g,"Slider","push_danger_radius","Отход при замеченном враге, ед.",1200,3500)
    UI.add(g,"Combo","push_response","Реакция на противника",{"Отступать","При преимуществе: сетка → сбор, иначе отход"})
    UI.add(g,"Switch","push_poof_escape","Отступать пуфом к безопасному Мипо")
    UI.add(g,"Slider","tower_exit_margin","Запас выхода за радиус башни, ед.",80,300)
    A.method(g,"Label","Башню атакуем после свежего снаряда по союзному крипу. Если башня переключилась на Мипо — выход и ожидание нового подтверждения. Первый снаряд может уже лететь.")
    A.method(g,"Label","Нужны союзные крипы у строения. Туман не означает безопасность. После ручного комбо фарм включается снова через F6.")
    g = UI.group("Статистика золота")
    UI.add(g,"Switch","finance_show","Отдельная панель GPM и нетворса")
    UI.add(g,"Slider","finance_x","Положение панели X",0,3500)
    UI.add(g,"Slider","finance_y","Положение панели Y",0,2000)
    UI.add(g,"Slider","finance_start_sec","Автостарт замера после начала матча, с",0,180)
    A.method(g,"Button","Начать новый замер",function() Finance.restart() end)
    A.method(g,"Label","Нетворс и заработанное золото — данные игрока. GPM матча = заработано / время матча; отдельный замер исключает ожидание до старта.")
    g = UI.group("Информация")
    UI.add(g,"Switch","hud","Русская панель состояния")
    UI.add(g,"Switch","world_labels","Статус над клонами")
    UI.add(g,"Switch","debug_log","Подробные сообщения в консоль")
    UI.add(g,"Switch","stable_trace","Лог смены фаз и приказов фарма")
    if not UI.combo_key then A.log("Меню недоступно: используется резервная клавиша Пробел, если она есть в API.",true) end
end
UI.init()
UI.sync_push()
function UI.down(key)
    local w = UI[key]
    local v = A.method(w,"IsDown")
    if v ~= nil then return v == true end
    local code = UI.get(key)
    return type(code) == "number" and A.call(Input and Input.IsKeyDown,code) == true
end
function UI.pressed(key)
    local down = UI.down(key)
    local was = S.key_prev[key] == true
    S.key_prev[key] = down
    return down and not was
end
function M.collect(now)
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
        if A.enemy(enemy) then S.enemy_memory[A.id(enemy)]={pos=A.copy(A.pos(enemy)),time=now} end
    end
    for id,rec in pairs(S.enemy_memory) do if now-rec.time>35 then S.enemy_memory[id]=nil end end
    S.selected = {}
    for _,u in ipairs(A.call(Player and Player.GetSelectedUnits,S.player) or {}) do S.selected[A.id(u)] = true end
end
function Orders.busy(u, priority, now)
    local id = A.id(u)
    if S.acted[id] then return true end
    local lock = S.locks[id]
    if lock then
        local phase = A.call(Ability.IsInAbilityPhase,lock.ability) == true
            or A.call(Ability.IsChannelling,lock.ability) == true
        if phase then lock.observed = true end
        if phase and priority<=lock.priority then return true end
        if not phase and (now >= lock.until_time or (lock.observed and now > lock.sent + 0.12)) then
            S.locks[id] = nil
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
    if not S.player or not A.alive(u) or not S.unit_ids[id] then return false end
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
        S.last_error = "API одиночных приказов недоступно"; return false
    end
    local ok,result = pcall(Player.PrepareUnitOrders,S.player,order,target,pos or A.pos(u) or A.vec(),
        ability,issuer,u,false,false,true,false,"meepo_ru8:"..tag,false)
    if not ok or result == false then
        S.metrics.failures = S.metrics.failures+1
        S.last_error = not ok and ("Ошибка приказа: "..tostring(result)) or "API отклонил приказ"
        A.log(S.last_error,true)
        return false
    end
    S.acted[id] = true
    S.metrics.orders = S.metrics.orders+1
    S.failures[id] = nil
    if priority<=45 then Stable.trace(u,tag,target,pos) end
    if ability then
        S.orders[id]=nil -- an instant active/spell can replace the previous attack order
        local key = tostring(id)..":"..tostring(A.call(Ability.GetName,ability) or ability)
        S.spell_next[key] = now + 0.32
        S.locks[id] = {ability=ability, priority=priority, sent=now,
            until_time=now+math.max(0.12,duration or 0.15),tag=tag}
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
    local now,id=S.now,A.id(u);local last=S.orders[id]
    if last and last.kind=="attack" and last.target==target and A.alive(target) then
        if A.call(NPC.IsAttacking,u)==true or A.call(NPC.IsRunning,u)==true then return false end
        if now-last.time<math.max(1.1,A.number(A.call(NPC.GetAttackTime,u),1.1)+.1) then return false end
    end
    if Orders.issue(u,"DOTA_UNIT_ORDER_ATTACK_TARGET",target,A.pos(target),nil,priority,tag) then
        S.orders[id]={kind="attack",time=now,target=target}
        S.attack_commit[id]=now+math.min(.9,math.max(.22,A.number(A.call(NPC.GetAttackAnimPoint,u),.35)+.08));return true
    end
    return false
end

function Combat.units()
    local result = {}
    for _,u in ipairs(S.units) do
        if UI.get("combo_all") or S.selected[A.id(u)] then result[#result+1] = u end
    end
    return result
end
function Combat.target_valid(u)
    if not A.enemy(u) or A.state(u,"MODIFIER_STATE_INVULNERABLE")
        or A.state(u,"MODIFIER_STATE_OUT_OF_GAME") then return false end
    for _,meepo in ipairs(S.units) do if A.distance2(A.pos(u),A.pos(meepo)) < 4000*4000 then return true end end
    return false
end
function Combat.pick_target()
    if Combat.target_valid(S.target) then return S.target end
    local cx,cy = A.call(Input and Input.GetCursorPos)
    local world = A.call(Input and Input.GetWorldCursorPos)
    local best,score = nil,math.huge
    for _,u in ipairs(S.heroes) do
        if Combat.target_valid(u) then
            local pos = A.pos(u)
            local screen,visible = A.call(Render and Render.WorldToScreen,pos)
            local d
            if cx and cy and screen and visible then
                local px = (screen.x-cx)^2+(screen.y-cy)^2
                if px <= UI.get("combo_radius")^2 then d = px/UI.get("combo_radius")^2 end
            end
            if not d and world and A.distance2(world,pos) <= UI.get("combo_world_radius")^2 then
                d = 2+A.distance2(world,pos)/UI.get("combo_world_radius")^2
            end
            if d and d < score then best,score = u,d end
        end
    end
    return best
end
function Combat.predict(target, horizon)
    local pos = A.pos(target)
    if not pos then return nil end
    if A.control_remaining(target,S.now)>0.05 or A.call(NPC.IsRunning,target) ~= true then return pos end
    local rot = A.call(Entity.GetRotation,target)
    local forward = rot and A.method(rot,"GetForward")
    if not forward then return pos end
    local speed = A.number(A.call(NPC.GetMoveSpeed,target),0)
    local length = math.sqrt(forward.x^2+forward.y^2)
    if length < 0.01 then return pos end
    local shift = math.min(380,speed*math.max(0,math.min(1.5,horizon)))
    return A.vec(pos.x+forward.x/length*shift,pos.y+forward.y/length*shift,pos.z)
end
function Combat.net_candidate(units, target, exclude)
    local best,score,reason = nil,math.huge,"Сетки не готовы"
    for _,u in ipairs(units) do
        if u ~= exclude and not Orders.busy(u,60,S.now) then
            local net = A.spell(u,"meepo_earthbind")
            local ready,why = A.ready(u,net,false)
            if ready then
                local origin = A.pos(u)
                local cast = math.max(0,A.number(A.call(Ability.GetCastPoint,net,true),0.3))
                local speed = A.net_speed(net)
                local initial = A.distance(origin,A.pos(target))
                local lead = cast+initial/speed
                local point = Combat.predict(target,lead)
                local distance = A.distance(origin,point)
                local range = A.range(u,net,700)
                if distance <= range then
                    local turn = math.max(0,math.min(0.35,A.number(A.call(NPC.GetTimeToFacePosition,u,point),0)))
                    local eta = turn+cast+distance/speed
                    local rotation_penalty = S.last_net and S.last_net.unit == u and 0.30 or 0
                    if eta+rotation_penalty < score then
                        best={unit=u,ability=net,pos=point,eta=eta,cast=cast,turn=turn}
                        score=eta+rotation_penalty
                    end
                else reason="Цель вне дальности сетки" end
            else reason=why end
        end
    end
    return best,reason
end
function Combat.pending_net(target)
    local p = S.net_pending
    if not p then return false end
    if not A.alive(p.unit) or not Combat.target_valid(p.target) then S.net_pending=nil;return false end
    local observed_until=S.now+A.root_remaining(p.target,S.now)
    -- Старый рут не подтверждает попадание следующей летящей сетки.
    if observed_until>(p.baseline_until or S.now)+0.10 and S.now>=p.arrival-0.10 then
        S.net_pending=nil;return false
    end
    if S.now > p.arrival+0.45 then
        S.net_pending=nil
        S.combo_status="Попадание сетки не подтверждено — повторный выбор"
        return false
    end
    return p.target == target
end
function Combat.net(units,target)
    if not UI.get("combo_net") then return false end
    if S.hex_pending and S.hex_pending.target==target and S.now<S.hex_pending.until_time then return false end
    if A.state(target,"MODIFIER_STATE_DEBUFF_IMMUNE") or A.state(target,"MODIFIER_STATE_MAGIC_IMMUNE") then
        S.net_status="Цель невосприимчива к контролю";return false
    end
    if Combat.pending_net(target) then S.net_status="Ожидание попадания сетки";return false end
    if S.last_net and S.now-S.last_net.sent < 0.45 then return false end
    local candidate,why = Combat.net_candidate(units,target)
    if not candidate then S.net_status=why;return false end
    local remaining = A.control_remaining(target,S.now)
    local overlap = UI.get("net_overlap_ms")/1000
    local handoff = math.min(UI.get("net_max_lead_ms")/1000,candidate.eta+overlap)
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
                local ratio=math.max(0,(distance-150)/distance)
                local point=A.vec(origin.x+(target_pos.x-origin.x)*ratio,origin.y+(target_pos.y-origin.y)*ratio,target_pos.z)
                return Orders.cast(hero,item,nil,point,60,"блинк",0.18,true)
            end
        end
    end
    return false
end
function Combat.tick(provided_units, provided_target)
    local units=provided_units or Combat.units()
    if #units==0 then S.combo_status="Не выбран Мипо: включите управление всеми";return end
    local target=provided_target or Combat.pick_target()
    if not target then S.target=nil;S.combo_status="Наведите курсор на видимого врага";return end
    if S.target~=target then S.target=target;S.net_status="Новая цель" end
    local hex=Combat.hex(units,target)
    local blink=Combat.blink(units,target)
    local net=Combat.net(units,target)
    Items.tick(units,target)
    local poof=Combat.poof(units,target)
    -- Каждая единица получает не более одного приказа за проход; чужие каналы не перебиваются.
    for _,u in ipairs(units) do
        if not Orders.busy(u,60,S.now) then Orders.attack(u,target,60,"атака-комбо") end
    end
    S.combo_status=net and "Сетка → пуф → атака" or poof and "Пуф → атака"
        or blink and "Сближение через Blink" or "Цепочка контроля / атака"
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
    S.camps=camps
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
    if unit and S.now<(S.econ_blacklist[tostring(A.id(unit))..":лагерь:"..tostring(camp.id)] or 0) then return false end
    local neutrals=Farm.nearby(camp.pos,760)
    if #neutrals>0 then S.camp_empty[camp.id]=nil end
    if S.now<(S.camp_empty[camp.id] or -math.huge) then return false end
    if UI.get("farm_avoid_enemies") and A.enemy_count_at(camp.pos,1300)>0 then return false end
    local known=A.call(Camp and Camp.IsKnownClear,camp.raw)
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
    if A.call(GameRules and GameRules.IsPaused)==true then S.combo_status="Пауза игры";return end
    local frame=A.call(GlobalVars and GlobalVars.GetFrameCount)
    if frame~=nil and S.last_frame==frame then return end
    if frame==nil and S.now<(S.next_fallback_tick or -math.huge) then return end
    S.last_frame,S.next_fallback_tick=frame,S.now+0.02
    -- Дорогие снимки/логика ограничены 40 Гц; ручные клавиши опрашиваются каждый новый кадр.
    local captured=A.call(Input and Input.IsInputCaptured)==true or A.call(Input and Input.IsPopupOpen)==true
        or A.call(Menu and Menu.Opened)==true
    local farm_pressed=UI.pressed("farm_key")
    if not captured and farm_pressed then
        local value=not UI.get("farm_enabled")
        UI.values.farm_enabled=value;A.method(UI.farm_enabled,"Set",value);UI.save("farm_enabled")
    end
    local down=UI.down("combo_key")
    local combo_edge=down and not S.combo_was_down
    S.combo_was_down=down
    if not captured and UI.get("enabled") and combo_edge and UI.get("combo_stops_farm") then
        UI.values.farm_enabled=false;A.method(UI.farm_enabled,"Set",false);UI.save("farm_enabled")
        S.assignment,S.parking,S.rune_claims,S.rune_busy,S.push_escape={},{},{},{},{}
    end
    if not UI.get("enabled") then S.combo_status="Скрипт выключен";S.combo_active=false;return end
    if captured then S.combo_status="Ввод занят: закройте чат / магазин / меню";S.combo_active=false;return end
    if S.now<(S.next_logic or -math.huge) then return end
    S.next_logic=S.now+0.025
    S.acted={};S.safety_status=nil
    M.collect(S.now)
    S.combo_active=down
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
M.OnFrame=M.run
M.OnUpdate=M.run
function M.OnPrepareUnitOrders(data)
    if type(data)~="table" or not S.session then return true end
    if tostring(data.identifier or ""):sub(1,10)=="meepo_ru8:" then return true end
    if data.player and data.player~=S.player then return true end
    local units=data.npc and {data.npc} or A.call(Player and Player.GetSelectedUnits,S.player) or {}
    for _,u in ipairs(units) do
        local id=A.id(u)
        if S.unit_ids[id] then
            S.manual_until[id]=A.now()+UI.get("manual_pause_ms")/1000
            S.orders[id]=nil;Stack.cancel(id,"Ручное управление");Tower.cancel(id)
        end
    end
    return true
end
function M.OnEntityDestroy(entity)
    if entity==S.target then S.target=nil end
    for _,name in ipairs({"locks","orders","assignment","healing","manual_until","hp_samples"}) do
        local id=A.id(entity);if id then S[name][id]=nil end
    end
    if S.net_pending and (S.net_pending.unit==entity or S.net_pending.target==entity) then S.net_pending=nil end
end

function HUD.text(x,y,text,color,size)
    if not HUD.font then return end
    A.call(Render.Text,HUD.font,size or 15,tostring(text),Vec2(x,y),color or Color(225,232,240,255))
end
function HUD.draw()
    if not UI.get("hud") or not S.session then return end
    if not HUD.font then HUD.font=A.call(Render.LoadFont,"Arial",0,500) end
    local x,y,w=28,250,510
    local lines={
        {"МИПО • RU 8.1",Color(118,223,199,255)},
        {S.combo_status or "Ожидание",Color(235,238,244,255)},
        {"Сетки: "..tostring(S.net_status or "готовность по цели")},
        {"Пуф: "..tostring(S.poof_status or "готовность по цели")},
        {S.farm_status or "Ожидание фарма"},
        {S.tower_status or (UI.push_active() and "Башни: ждём подтверждённую цель-крипа" or "Сплитпуш выключен")},
        {S.hunt_status or (UI.get("hunt_enabled") and "Автонападение: поиск" or "Автонападение выключено")},
        {S.heal_status or "Лечение: по выбранному режиму"},
        {"Предметов применено: "..tostring(S.metrics.items or 0)},
        {UI.get("econ_enabled") and "Экономика: оценка награды и времени; не фактический GPM" or "Экономический планировщик выключен"},
        {"Мипо: "..#S.units.." | сеток: "..S.metrics.nets.." | пуфов: "..S.metrics.poofs},
    }
    if S.target then
        local name=A.name(S.target):gsub("npc_dota_hero_","")
        lines[#lines+1]={string.format("Цель: %s | контроль: %.2f с",name,A.control_remaining(S.target,A.now()))}
    end
    if S.safety_status then lines[#lines+1]={S.safety_status,Color(255,190,100,255)} end
    if S.last_error then lines[#lines+1]={"Ошибка API: см. консоль",Color(255,120,120,255)} end
    if not S.net_pending and S.combo_active then
        for _,u in ipairs(S.units) do
            local ready,why=A.ready(u,A.spell(u,"meepo_earthbind"),false)
            if not ready then lines[#lines+1]={"Мипо "..tostring(A.id(u))..": сетка — "..why};break end
        end
    end
    A.call(Render.FilledRect,Vec2(x,y),Vec2(x+w,y+20+#lines*21),Color(18,24,34,225),8)
    A.call(Render.FilledRect,Vec2(x,y),Vec2(x+4,y+20+#lines*21),Color(90,204,174,255),2)
    for i,line in ipairs(lines) do HUD.text(x+15,y+10+(i-1)*21,line[1],line[2],i==1 and 17 or 15) end
    if UI.get("world_labels") then
        for i,u in ipairs(S.units) do
            local p=A.pos(u)
            if p then
                local screen,visible=A.call(Render.WorldToScreen,A.vec(p.x,p.y,p.z+145))
                if screen and visible then
                    local id=A.id(u)
                    local mode=u==S.hero and "Главный" or "Клон"
                    local status=S.healing[id] and "Лечение" or S.locks[id] and "Применение"
                        or S.combo_active and "Комбо" or S.stack_units[id] and ("Стак: "..S.stack_units[id].phase)
                        or S.assignment[id] and (S.assignment[id].phase or "Фарм") or "Ожидание"
                    HUD.text(screen.x-65,screen.y,string.format("%s %d • %s • HP %.0f%%",mode,i,status,A.hp(u)),nil,13)
                    local info=S.econ_info[id]
                    if UI.get("econ_details") and UI.get("econ_enabled") and info then
                        HUD.text(screen.x-100,screen.y+17,string.format("≈%.0f зол/мин | %.1f с | %s",info.gold_rate or 0,info.total or 0,info.reason or "оценка"),nil,12)
                    end
                end
            end
        end
    end
end
function M.OnDraw()
    local ok,err=pcall(HUD.draw)
    if not ok then A.log("Ошибка панели: "..tostring(err),true) end
    local finance_ok,finance_error=pcall(Finance.draw)
    if not finance_ok then A.log("Ошибка статистики: "..tostring(finance_error),true) end
end
-- RU4: последовательный урон, автонападение, адаптивные задания, предметы и лечение.
function A.flag(value, group, name)
    local flag=A.enum(group,name)
    local n,f=math.tointeger(value or 0),math.tointeger(flag or 0)
    return n~=nil and f~=nil and f~=0 and (n & f)~=0
end
function Combat.poof_in_progress()
    local busy=false
    for _,u in ipairs(S.units) do
        local ab=A.spell(u,"meepo_poof")
        local phase=ab and (A.call(Ability.IsChannelling,ab)==true or A.call(Ability.IsInAbilityPhase,ab)==true)
        local lock=S.locks[A.id(u)]
        if phase then
            busy=true;if lock and lock.ability==ab then lock.observed=true end
        elseif lock and lock.ability==ab and S.now<lock.until_time and not lock.observed then busy=true end
    end
    return busy
end
-- Обычное комбо: только ОДИН канал Poof. Остальные свободные Мипо атакуют.
function Combat.poof(units,target)
    if not UI.get("combo_poof") then return false end
    if Combat.poof_in_progress() then S.poof_status="Один пуф применяется; остальные бьют";return false end
    local anchor,dist=Combat.poof_anchor(units,target)
    if not anchor then return false end
    local root=A.control_remaining(target,S.now)
    local reserved
    if UI.get("combo_net") and #units>1 and (root>0 or Combat.pending_net(target)) then
        local candidate=Combat.net_candidate(units,target,S.last_net and S.last_net.unit)
        if candidate then reserved=candidate.unit end
    end
    local start=1
    for i,u in ipairs(units) do if A.id(u)==S.poof_last_caster then start=i%#units+1;break end end
    for offset=0,#units-1 do
        local u=units[(start+offset-1)%#units+1]
        if u~=reserved and not Orders.busy(u,60,S.now) then
            local ab=A.spell(u,"meepo_poof")
            local ready,why=A.ready(u,ab,false)
            if ready then
                local duration,radius=A.poof_time(ab),A.poof_radius(ab)-70
                local point=root>=duration and A.pos(target) or Combat.predict(target,duration)
                if dist<=radius and A.distance(A.pos(anchor),point)<=radius then
                    if not UI.get("poof_require_root") or root>=duration+0.08 then
                        if Orders.cast(u,ab,anchor,nil,60,"пуф-комбо-очередь",duration+0.12,false) then
                            S.poof_last_caster=A.id(u);S.metrics.poofs=S.metrics.poofs+1
                            S.poof_status="Пуфует Мипо №"..tostring(A.id(u)).."; остальные атакуют"
                            return true
                        end
                    else S.poof_status="Ждём достаточный контроль" end
                else S.poof_status="Нужен Мипо в зоне урона пуфа" end
            else S.poof_status=why end
        end
    end
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
    return out
end
function Items.usable(u,item,name)
    if Items.blocked[name] or name:find("item_recipe_",1,true)==1 then return false,"Утилитарный предмет" end
    if name:find("blink",1,true) then return false,"Blink управляется сближением" end
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
function Items.tick(units,target)
    if not UI.get("items_enabled") then return end
    for _,u in ipairs(units) do
        if not Orders.busy(u,60,S.now) then
            local inventory=Items.inventory(u)
            -- Сначала ситуативный сейв/ресурсы; затем активки урона, без вечного ожидания предмета.
            table.sort(inventory,function(a,b)
                local ra,rb=Items.rules[a.name],Items.rules[b.name]
                local pa=ra and ra.category=="items_defensive" and 0 or ra and ra.category=="items_resources" and 1 or 2
                local pb=rb and rb.category=="items_defensive" and 0 or rb and rb.category=="items_resources" and 1 or 2
                return pa==pb and a.index<b.index or pa<pb
            end)
            for _,rec in ipairs(inventory) do if Items.apply(u,rec,target) then break end end
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
    S.npcs_next=S.now+0.25;S.metrics.npc_scans=S.metrics.npc_scans+1
    local list=A.call(NPCs and NPCs.GetAll)
    S.neutrals_valid=type(list)=="table";S.snapshot_valid=S.neutrals_valid
    S.neutral_bins,S.lane_creeps,S.towers,S.ally_creeps,S.buildings={},{},{},{},{}
    for _,u in ipairs(list or {}) do
        if A.alive(u) then
            local pos=A.pos(u)
            if pos and A.team(u)==S.team and A.name(u):find("fountain",1,true) then S.fountain=A.copy(pos) end
            if pos and A.team(u)~=S.team and A.call(NPC.IsTower,u)==true then S.towers[#S.towers+1]=u end
            if pos and A.team(u)~=S.team and (A.call(NPC.IsTower,u)==true or A.name(u):find("barracks",1,true)) then S.buildings[#S.buildings+1]=u end
            if pos and A.visible(u) and A.team(u)==S.team and A.call(NPC.IsLaneCreep,u)==true then S.ally_creeps[#S.ally_creeps+1]=u end
            if pos and A.visible(u) and A.call(NPC.IsWaitingToSpawn,u)~=true then
                if A.call(NPC.IsNeutral,u)==true then
                    local key=math.floor(pos.x/760)..":"..math.floor(pos.y/760)
                    local bin=S.neutral_bins[key] or {};S.neutral_bins[key]=bin;bin[#bin+1]={unit=u,pos=pos}
                elseif A.call(NPC.IsLaneCreep,u)==true and A.team(u)~=S.team then S.lane_creeps[#S.lane_creeps+1]=u end
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
    return list
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
function Farm.damage_creeps(u,creeps,tag)
    local id=A.id(u);local record=S.assignment[id] or {}
    local target,score=nil,math.huge
    for _,c in ipairs(creeps) do
        if A.visible(c) then
            if c==record.target then target=c;break end
            local value=A.distance(A.pos(u),A.pos(c))+A.number(A.call(Entity.GetHealth,c),1000)*0.1
            if value<score then target,score=c,value end
        end
    end
    if UI.get("econ_enabled") then target=Econ.target(u,creeps,record,target) end
    if not target then return false end
    record.target=target;record.members=record.members or creeps
    if S.now<(S.attack_commit[id] or 0) then return false end
    if Econ.midas(u,creeps) then return true end
    local poof=A.spell(u,"meepo_poof")
    if UI.get("farm_poof") and poof and A.ready(u,poof,false) then
        local count,radius=0,A.poof_radius(poof)-35
        for _,c in ipairs(creeps) do if A.visible(c) and A.distance(A.pos(u),A.pos(c))<=radius then count=count+1 end end
        local cost=A.number(A.call(Ability.GetManaCost,poof),0)
        local maxmana=A.number(A.call(NPC.GetMaxMana,u),0)
        if count>=UI.get("farm_min_creeps") and maxmana>0 and (A.mana(u)-cost)/maxmana*100>=UI.get("farm_mana_pct")
            and Econ.poof_worth(u,creeps,poof) then
            if Orders.cast(u,poof,u,nil,20,"пуф-фарм",A.poof_time(poof)+0.12,false) then S.metrics.poofs=S.metrics.poofs+1;return true end
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
    if S.snapshot_valid and rec.engaged and #creeps==0 and rec.deaths_confirmed and not S.stack_units[A.id(u)] then
        -- Keep the confirmation grace, but never walk back towards an already dead pack.
        rec.phase="confirm_empty";rec.empty_since=rec.empty_since or S.now
        if S.now-rec.empty_since>=1.3 then
            rec.phase="done";S.camp_empty[camp.id]=Farm.spawn_deadline()
            S.assignment[A.id(u)],S.econ_watch[A.id(u)]=nil,nil
        end
        return
    end
    local visible={}
    for _,c in ipairs(creeps) do if A.visible(c) then visible[#visible+1]=c end end
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
        if contact then rec.engaged=true end
        rec.phase=contact and "combat" or "approach"
        if Stack.tick(u,task,rec) then return end
        -- The same ATTACK command owns approach and combat. No MOVE-to-centre is inserted between them.
        Farm.damage_creeps(u,visible,"атака-нейтрала")
        return
    end
    if S.stack_units[A.id(u)] then Stack.tick(u,task,rec);return end
    if not S.snapshot_valid then return end
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
    if S.now-rec.empty_since>=1.3 then
        rec.phase="done";S.camp_empty[camp.id]=Farm.spawn_deadline()
        S.assignment[A.id(u)],S.econ_watch[A.id(u)]=nil,nil
        Farm.unblock(u)
    end
end
function Farm.tick()
    if not UI.get("farm_enabled") then Stack.cancel_all("Фарм выключен");S.farm_status="Автофарм выключен; F6 — включить";return end
    if S.combo_active or S.hunt then Stack.cancel_all("Бой");S.farm_status="Пауза фарма: идёт бой";return end
    if S.now<(S.farm_next or -math.huge) then return end
    S.farm_next=S.now+.2
    Farm.refresh_camps();Farm.snapshot();Stable.ownership();Econ.observe()
    local waves,taken,active=Farm.waves(),{},0
    for id,rec in pairs(S.assignment) do
        if S.unit_ids[id] then local key=Econ.key(rec);if key then taken[key]=id end
        else S.assignment[id]=nil;Stack.cancel(id,"Мипо недоступен") end
    end
    Econ.plan(waves,taken)
    for _,u in ipairs(S.units) do
        local id=A.id(u)
        if Farm.eligible(u,true) then
            if S.stack_units[id] and (A.hp(u)<UI.get("stack_min_hp") or not UI.get("stack_enabled")) then Stack.cancel(id,"Низкий HP / выключено") end
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
        S.safety_status="MegaMeepo: сбор группы для спасения";return true
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
                    if Echo.protect(u,left) then rec.handled[uid]=true;S.safety_status="Попытка доджа Echo: Мипо №"..tostring(uid) end
                end
            end
        end
    end
end

-- RU6: bounded economic allocation. All income/rates below are estimates, never measured GPM.
function Econ.stat(u)
    local id=A.id(u);local cached=S.econ_cache[id]
    if cached and cached.unit==u and S.now<cached.until_time then return cached end
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
    local result={unit=u,until_time=S.now+.35,pos=A.copy(A.pos(u)),
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
    forecast.reason=forecast.confidence<.7 and "разведка / оценка" or forecast.poof and "выгоден Poof" or "атаки выгоднее"
    forecast.expiry=expiry
    return forecast
end
function Econ.next_distance(task)
    local best=math.huge
    for _,other in ipairs(S.econ_catalogue or {}) do
        if other.key~=task.key then best=math.min(best,A.distance(task.pos,other.pos)) end
    end
    return best<math.huge and best or nil
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
    S.econ_info[A.id(u)].reason=forecast.poof and "выгоден Poof" or "берегу ману / атаки быстрее"
    return forecast.poof
end
function Econ.target(u,creeps,record,fallback)
    if fallback and (record.kind~="lane" or A.call(NPC.IsAttacking,u)==true or S.now<(S.attack_commit[A.id(u)] or 0)) then return fallback end
    local us=Econ.stat(u);local best,score=nil,-math.huge
    for _,c in ipairs(creeps) do
        if A.visible(c) and not A.state(c,"MODIFIER_STATE_ATTACK_IMMUNE") then
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
    local us=Econ.stat(u);local walking=A.distance(A.pos(u),task.pos)/us.speed
    local best,saving=nil,UI.get("econ_travel_save")
    local info=S.econ_info[A.id(u)] or {};local lost_clear=info.poof_gain or 0
    local mana_time=A.number(A.call(Ability.GetManaCost,ab),0)/math.max(1.5,us.mana_regen)*.03
    for _,ally in ipairs(S.units) do
        if ally~=u and A.hp(ally)>55 and not S.healing[A.id(ally)] and not S.push_escape[A.id(ally)]
            and not A.state(ally,"MODIFIER_STATE_OUT_OF_GAME") and A.call(NPC.IsRunning,ally)~=true
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
        S.econ_info[id]=info;info.reason=string.format("Poof экономит ≈%.1f с",saving);return true
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
    local pos=target and A.visible(target) and A.pos(target)
        or rec.kind=="neutral" and Farm.find_camp(rec.camp) and Farm.find_camp(rec.camp).pos
    if not pos then return false end
    local health=0
    if rec.kind=="push" then health=A.number(A.call(Entity.GetHealth,target),0)
    else for _,c in ipairs(rec.members or {}) do if A.visible(c) then health=health+A.number(A.call(Entity.GetHealth,c),0) end end end
    local distance=A.distance(A.pos(u),pos);local watch=S.econ_watch[id]
    if not watch or watch.key~=key then S.econ_watch[id]={key=key,health=health,distance=distance,progress=S.now};return false end
    local last_hit=A.number(A.call(NPC.GetLastAttackTime,u),-math.huge)
    if health<watch.health-2 or distance<watch.distance-70 or A.call(NPC.IsAttacking,u)==true or S.now-last_hit<1.8 then
        if health<watch.health-2 then S.econ_retries[tostring(id)..":"..key]=nil end
        watch.progress=S.now;watch.health=health;watch.distance=distance;return false
    end
    if S.now-watch.progress<UI.get("econ_stall_sec") then return false end
    local retry_key=tostring(id)..":"..key;local attempts=S.econ_retries[retry_key] or 0
    S.econ_retries[retry_key]=attempts+1;watch.progress=S.now;S.econ_metrics.stalls=S.econ_metrics.stalls+1
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
        A.log(string.format("%0.2f | Мипо %s | %s | %s | %s",S.now,tostring(line.unit),line.phase,tostring(line.key or "—"),tag),true)
    end
end
function Stable.ownership()
    if not S.snapshot_valid then return end
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
    if A.hp(u)<UI.get("stack_min_hp") then Stack.cancel(id,"Низкий HP");return false end
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
function Tower.arm(u,b,serial,reason)
    local id=A.id(u);local old=S.tower_evade[id]
    if old and old.tower==b then
        if serial and serial>old.serial then old.serial=serial;old.outside=nil;old.resume_after=nil end
        return old
    end
    local state={tower=b,serial=serial or 0,started=A.now(),point=Tower.exit_point(u,b),phase="exit",reason=reason}
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
            if not state and rec and rec.kind=="push" and A.call(NPC.IsTower,rec.building)==true
                and A.visible(rec.building) and not Tower.creep_target(rec.building)
                and A.distance(A.pos(u),A.pos(rec.building))<Tower.range(rec.building,u)+200 then
                local shot=S.tower_shots[A.id(rec.building)]
                state=Tower.arm(u,rec.building,shot and shot.serial or 0,"Нет подтверждённого прикрытия")
            end
            if state then
                if not A.alive(state.tower) then Tower.cancel(id);S.assignment[id]=nil
                elseif not Orders.busy(u,88,S.now) then
                    local distance=A.distance(A.pos(u),A.pos(state.tower))
                    local outside=distance>=Tower.range(state.tower,u)+UI.get("tower_exit_margin")-25
                    if not outside then
                        state.phase="exit";state.outside=nil;state.resume_after=nil
                        if state.point then Orders.walk(u,state.point,88,"сплитпуш-выход-из-агро") end
                        S.tower_status="Башня выбрала Мипо: выхожу из радиуса"
                    else
                        if not state.outside then state.outside=S.now;state.resume_after=S.now+.65 end
                        state.phase="wait"
                        local creep,shot=Tower.creep_target(state.tower)
                        if creep and shot.serial>state.serial and shot.time>=state.outside-.1 and S.now>=state.resume_after then
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
function Finance.draw()
    if not UI.get("finance_show") or not S.session then return end
    if not Finance.font then Finance.font=A.call(Render.LoadFont,"Arial",0,500) end
    if not Finance.font then return end
    local f=S.finance;local x,y=UI.get("finance_x"),UI.get("finance_y")
    local elapsed=f.measure_seconds or 0
    local rows={
        "ЗОЛОТО • МИПО RU 8",
        "GPM матча (средний): "..Finance.text(f.gpm),
        "Нетворс сейчас: "..Finance.text(f.networth),
        "Золото в кошельке: "..Finance.text(f.wallet),
        "Крипы / денай: "..Finance.text(f.lasthits).." / "..Finance.text(f.denies),
        string.format("Замер: %02d:%02d | крипов +%s",math.floor(elapsed/60),math.floor(elapsed%60),Finance.text(f.measure_hits)),
        "GPM замера (весь доход): "..Finance.text(f.measure_gpm),
        f.earned==nil and "Статистика игрока недоступна" or "Данные игрока; не оценка маршрута фарма",
    }
    A.call(Render.FilledRect,Vec2(x,y),Vec2(x+370,y+20+#rows*22),Color(18,24,34,230),8)
    for i,text in ipairs(rows) do
        A.call(Render.Text,Finance.font,i==1 and 17 or 15,text,Vec2(x+14,y+10+(i-1)*22),i==1 and Color(240,205,110,255) or Color(232,237,245,255))
    end
end

A.log("Загружен Meepo RU 8.1. Комбо: Пробел. Фарм: только клоны. F6 — пауза фарма.",true)
return M
