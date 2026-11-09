local script = {}
script._last_net_cast_pos = script._last_net_cast_pos or nil
script._last_net_cast_time = script._last_net_cast_time or 0
script._combo_net_pending_target_key = script._combo_net_pending_target_key or nil
script._combo_net_pending_end_time = script._combo_net_pending_end_time or 0
script._combo_net_pending_arrival_time = script._combo_net_pending_arrival_time or 0
script._combo_item_sets = script._combo_item_sets or {
    silence = { "item_bloodthorn", "item_orchid" },
    atos = { "item_rod_of_atos", "item_gleipnir" },
    abyssal = { "item_abyssal_blade" },
    purge = { "item_diffusal_blade", "item_disperser" },
    grenade = { "item_grenade" },
    phase = { "item_phase_boots" },
    shadow = { "item_silver_edge", "item_invis_sword" },
    mjollnir = { "item_mjollnir" },
    mom = { "item_mask_of_madness" },
    armlet = { "item_armlet" },
    manta = { "item_manta" },
    blademail = { "item_blade_mail" },
}
script._combo_modifier_sets = script._combo_modifier_sets or {
    hex = { "modifier_sheepstick_debuff" },
    silence = { "modifier_orchid_malevolence_debuff", "modifier_bloodthorn_debuff" },
    atos = { "modifier_rod_of_atos_debuff", "modifier_gleipnir_root" },
}
script._combo_silence_last_global = script._combo_silence_last_global or -9999
script._combo_silence_last_attempt_global = script._combo_silence_last_attempt_global or -9999
script._combo_silence_last_attempt_frame = script._combo_silence_last_attempt_frame or -1
script._combo_silence_last_by_meepo = script._combo_silence_last_by_meepo or {}
script._combo_silence_last_frame_by_meepo = script._combo_silence_last_frame_by_meepo or {}
script._combo_atos_last_global = script._combo_atos_last_global or -9999
script._combo_atos_last_attempt_global = script._combo_atos_last_attempt_global or -9999
script._combo_atos_last_attempt_frame = script._combo_atos_last_attempt_frame or -1
script._combo_atos_last_by_meepo = script._combo_atos_last_by_meepo or {}
script._combo_atos_pending_target_key = script._combo_atos_pending_target_key or nil
script._combo_atos_pending_end_time = script._combo_atos_pending_end_time or 0
script._combo_abyssal_last_global = script._combo_abyssal_last_global or -9999
script._combo_abyssal_last_attempt_global = script._combo_abyssal_last_attempt_global or -9999
script._combo_abyssal_last_attempt_frame = script._combo_abyssal_last_attempt_frame or -1
script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
script._combo_atos_last_frame_by_meepo = script._combo_atos_last_frame_by_meepo or {}
script._combo_abyssal_last_frame_by_meepo = script._combo_abyssal_last_frame_by_meepo or {}
script._combo_abyssal_pending_target_key = script._combo_abyssal_pending_target_key or nil
script._combo_abyssal_pending_end_time = script._combo_abyssal_pending_end_time or 0
script._combo_abyssal_recent_blink_until = script._combo_abyssal_recent_blink_until or 0
script._combo_abyssal_recent_blink_target_key = script._combo_abyssal_recent_blink_target_key or nil
script._combo_abyssal_recent_blink_caster_key = script._combo_abyssal_recent_blink_caster_key or nil
script._combo_hex_last_attempt_global = script._combo_hex_last_attempt_global or -9999
script._combo_hex_last_attempt_frame = script._combo_hex_last_attempt_frame or -1
script._combo_hex_last_frame_by_meepo = script._combo_hex_last_frame_by_meepo or {}
script._combo_purge_last_global = script._combo_purge_last_global or -9999
script._combo_purge_last_target_key = script._combo_purge_last_target_key or nil
script._combo_purge_last_attempt_global = script._combo_purge_last_attempt_global or -9999
script._combo_purge_last_attempt_frame = script._combo_purge_last_attempt_frame or -1
script._combo_purge_last_by_meepo = script._combo_purge_last_by_meepo or {}
script._item_next_allowed_time = script._item_next_allowed_time or {}
script._item_last_frame_by_meepo = script._item_last_frame_by_meepo or {}
script._item_frame_budget_consumed = script._item_frame_budget_consumed or 0
script._cast_next_allowed_time = script._cast_next_allowed_time or {}
script._cast_last_frame_by_meepo = script._cast_last_frame_by_meepo or {}
script.COMBO_PHASE_ABYSSAL = script.COMBO_PHASE_ABYSSAL or "ABYSSAL"
script.COMBO_PHASE_HEX = script.COMBO_PHASE_HEX or "HEX"
script.COMBO_PHASE_NET_CHAIN = script.COMBO_PHASE_NET_CHAIN or "NET_CHAIN"
script.COMBO_PHASE_POOF_ATTACK = script.COMBO_PHASE_POOF_ATTACK or "POOF_ATTACK"
script._combo_state_phase = script._combo_state_phase or script.COMBO_PHASE_ABYSSAL
script._combo_state_target_key = script._combo_state_target_key or nil
script._combo_debug_phase = script._combo_debug_phase or script.COMBO_PHASE_ABYSSAL
script._combo_debug_reason = script._combo_debug_reason or "idle"
script._combo_debug_next_disable = script._combo_debug_next_disable or ""
script._combo_debug_last_emit = script._combo_debug_last_emit or ""
script._combo_last_net_follow_poof_count = script._combo_last_net_follow_poof_count or 0
script._combo_last_net_follow_poof_time = script._combo_last_net_follow_poof_time or -9999
script._combo_last_net_follow_poof_reason = script._combo_last_net_follow_poof_reason or ""
script._combo_net_priority_until = script._combo_net_priority_until or 0
script._combo_net_priority_target_key = script._combo_net_priority_target_key or nil
script._combo_hold_next_order_time = script._combo_hold_next_order_time or 0
script._combo_action_next_order_time = script._combo_action_next_order_time or 0
script._combo_search_next_move_time = script._combo_search_next_move_time or 0
script._combo_search_last_position = script._combo_search_last_position or nil
script._combo_ground_next_net_time = script._combo_ground_next_net_time or 0
script._combo_ground_last_cast_pos = script._combo_ground_last_cast_pos or nil
script._combo_ground_last_cast_time = script._combo_ground_last_cast_time or -9999
script._combo_blink_scheduled_time = script._combo_blink_scheduled_time or 0
script._combo_blink_target = script._combo_blink_target or nil
script._combo_blink_anchor = script._combo_blink_anchor or nil
script._combo_blink_target_key = script._combo_blink_target_key or nil
script._combo_blink_last_schedule = script._combo_blink_last_schedule or -9999
script._combo_blink_poof_units = script._combo_blink_poof_units or {}
script._combo_blink_post_poof_delay = script._combo_blink_post_poof_delay or 0
script._combo_blink_poof_prescheduled = script._combo_blink_poof_prescheduled or false
script._combo_blink_retry_deadline = script._combo_blink_retry_deadline or 0
script._combo_blink_next_attempt = script._combo_blink_next_attempt or 0
script._combo_preblink_phase = script._combo_preblink_phase or "idle"
script._combo_preblink_target_key = script._combo_preblink_target_key or nil
script._combo_preblink_anchor_key = script._combo_preblink_anchor_key or nil
script._combo_preblink_poof_sent_time = script._combo_preblink_poof_sent_time or 0
script._combo_preblink_wait_until = script._combo_preblink_wait_until or 0
script._combo_preblink_sent_set = script._combo_preblink_sent_set or {}
script._combo_target_last_seen_time = script._combo_target_last_seen_time or -9999
script._combo_logic_next_tick = script._combo_logic_next_tick or 0
script._combo_armlet_forced_on = script._combo_armlet_forced_on or false
script._combo_engage_mode = script._combo_engage_mode or "MID"
script._combo_engage_distance = script._combo_engage_distance or 0
script._combo_engage_close_threshold = script._combo_engage_close_threshold or 0
script._combo_engage_mid_threshold = script._combo_engage_mid_threshold or 0
script._combo_predicted_hp_left = script._combo_predicted_hp_left or 0
script._combo_predicted_damage = script._combo_predicted_damage or 0
script._tp_interrupt_last_target_key = script._tp_interrupt_last_target_key or nil
script._tp_interrupt_last_time = script._tp_interrupt_last_time or -9999
script._tp_fog_particles = script._tp_fog_particles or {}
script._tp_fog_cache_by_target_key = script._tp_fog_cache_by_target_key or {}
script._tp_interrupt_lock_by_target_key = script._tp_interrupt_lock_by_target_key or {}
script._tp_interrupt_global_lock_until = script._tp_interrupt_global_lock_until or 0
script._auto_save_hp_sample_by_meepo = script._auto_save_hp_sample_by_meepo or {}
script._utility_bind_down_state = script._utility_bind_down_state or {}
script._tp_teleport_modifier_candidates = script._tp_teleport_modifier_candidates or {
    "modifier_teleporting",
    "modifier_teleporting_visual",
    "modifier_furion_teleport",
    "modifier_furion_teleporting",
}
script._auto_safe_last_cast_by_meepo = script._auto_safe_last_cast_by_meepo or {}
script._auto_safe_last_enemy_poof_by_meepo = script._auto_safe_last_enemy_poof_by_meepo or {}
script._float_panel_pos_x = script._float_panel_pos_x
script._float_panel_pos_y = script._float_panel_pos_y
script._float_panel_drag_active = script._float_panel_drag_active or false
script._float_panel_drag_offset_x = script._float_panel_drag_offset_x or 0
script._float_panel_drag_offset_y = script._float_panel_drag_offset_y or 0
if script._autofarm_runtime_enabled == nil then
    script._autofarm_runtime_enabled = false
end
script._autofarm_map_pos_x = script._autofarm_map_pos_x
script._autofarm_map_pos_y = script._autofarm_map_pos_y
script._autofarm_map_drag_active = script._autofarm_map_drag_active or false
script._autofarm_map_drag_offset_x = script._autofarm_map_drag_offset_x or 0
script._autofarm_map_drag_offset_y = script._autofarm_map_drag_offset_y or 0
script._autofarm_selected_points = script._autofarm_selected_points or {}
script._autofarm_last_toggle_time = script._autofarm_last_toggle_time or -9999
script._autofarm_image_cache = script._autofarm_image_cache or {}
script._autofarm_camp_cache = script._autofarm_camp_cache or nil
script._autofarm_camp_cache_time = script._autofarm_camp_cache_time or -9999
script._autofarm_assignment_by_meepo = script._autofarm_assignment_by_meepo or {}
script._autofarm_last_camp_by_meepo = script._autofarm_last_camp_by_meepo or {}
script._autofarm_last_poof_move_by_meepo = script._autofarm_last_poof_move_by_meepo or {}
script._autofarm_stack_state_by_meepo = script._autofarm_stack_state_by_meepo or {}
script._autofarm_last_order_by_meepo = script._autofarm_last_order_by_meepo or {}
script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
script._autofarm_wave_owner_key = script._autofarm_wave_owner_key or nil
script._autofarm_wave_owner_until = script._autofarm_wave_owner_until or 0
script._autofarm_camp_presence = script._autofarm_camp_presence or {}
script._autofarm_camp_status = script._autofarm_camp_status or {}
script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
script._autofarm_camp_queue_by_meepo = script._autofarm_camp_queue_by_meepo or {}
script._autofarm_last_order_sig_by_meepo = script._autofarm_last_order_sig_by_meepo or {}
script._autofarm_last_order_sig_time_by_meepo = script._autofarm_last_order_sig_time_by_meepo or {}
script._autofarm_last_order_meta_by_meepo = script._autofarm_last_order_meta_by_meepo or {}
script._autofarm_heal_mode_by_meepo = script._autofarm_heal_mode_by_meepo or {}
script._autofarm_heal_resume_by_meepo = script._autofarm_heal_resume_by_meepo or {}
script._autofarm_timeline_by_meepo = script._autofarm_timeline_by_meepo or {}
script._autofarm_fountain_cache = script._autofarm_fountain_cache or {}
script._autofarm_wave_markers_cache = script._autofarm_wave_markers_cache or { t = -9999, hero = nil, markers = {}, towers = {}, team = -1 }
script._autofarm_presence_cache = script._autofarm_presence_cache or { t = -9999, key = "", out = {} }
script._autofarm_metrics = script._autofarm_metrics or {}
script._autofarm_last_game_time = script._autofarm_last_game_time
script._autofarm_next_tick = script._autofarm_next_tick or 0
script._autofarm_master_last_enabled = script._autofarm_master_last_enabled or false
script._autofarm_point_anim = script._autofarm_point_anim or {}
script._autofarm_settings_side = script._autofarm_settings_side or "r"
script._autofarm_wave_marker_selected = script._autofarm_wave_marker_selected or {}
script._autofarm_map_hero_cache = script._autofarm_map_hero_cache or { t = -9999, team = -1, entries = {}, pos_by_key = {}, count = 0 }
script._autofarm_map_visible = script._autofarm_map_visible ~= false
script._autofarm_map_last_toggle_time = script._autofarm_map_last_toggle_time or -9999
script._frame_context = script._frame_context or {
    frame = -1,
    now = 0,
    local_hero = nil,
    local_player = nil,
    meepos = nil,
    heroes = nil,
    selected_player = nil,
    selected_units = nil,
    selected_key_set = nil,
    cursor_x = nil,
    cursor_y = nil,
    world_cursor = nil,
}
script._autofarm_path_cost_cache = script._autofarm_path_cost_cache or {}
script._autofarm_path_cost_cache_gc_next = script._autofarm_path_cost_cache_gc_next or 0
script._autofarm_path_cost_cache_size = script._autofarm_path_cost_cache_size or 0
script._autofarm_path_cost_cache_size_next = script._autofarm_path_cost_cache_size_next or 0
script._autofarm_tower_cache = script._autofarm_tower_cache or { t = -9999, hero = nil, team = -1, out = {} }
script._autofarm_neutral_spatial = script._autofarm_neutral_spatial or { t = -9999, cell = 760, bins = {}, entries = {} }
script._autofarm_text_size_cache = script._autofarm_text_size_cache or {}
script._autofarm_text_size_cache_gc_next = script._autofarm_text_size_cache_gc_next or 0
script._autofarm_perf = script._autofarm_perf or {}
local get_game_time
local safe_call
local get_entity_key
local is_combo_cast_in_progress
local C
safe_call = function(fn, ...)
    if not fn then
        return nil
    end
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end
    return nil
end
local combo_group = nil
local display_group = nil
local items_group = nil
local abilities_group = nil
local utilities_group = nil
local autofarm_group = nil
local function create_menu_group_safe(parent, name, side)
    if not parent or not parent.Create then
        return nil
    end
    local ok_with_side, created_with_side = pcall(function()
        return parent:Create(name, side)
    end)
    if ok_with_side and created_with_side then
        return created_with_side
    end
    local ok_default, created_default = pcall(function()
        return parent:Create(name)
    end)
    if ok_default then
        return created_default
    end
    return nil
end
if Menu.Create then
    local tab = Menu.Create("Heroes", "Hero List", "Meepo")
    if tab and tab.Create then
        local section = tab:Create("Meepo Panel")
        if section and section.Create then
            combo_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0433}\u{0435}\u{0440}\u{043e}\u{044f}", 1)
            utilities_group = create_menu_group_safe(section, "\u{0423}\u{0442}\u{0438}\u{043b}\u{0438}\u{0442}\u{044b}", 1)
            display_group = create_menu_group_safe(section, "Display", 1)
            items_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}", 2)
            abilities_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0410}\u{0432}\u{0442}\u{043e}-\u{0421}\u{0435}\u{0439}\u{0432}\u{0430}", 2)
            autofarm_group = create_menu_group_safe(section, "\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}\u{0430}", 2)
        end
    end
end
local ui = {}
local ICON_DIG = "panorama/images/spellicons/meepo_petrify_png.vtex_c"
local ICON_MEGA = "panorama/images/spellicons/meepo_megameepo_png.vtex_c"
local ICON_POOF = "panorama/images/spellicons/meepo_poof_png.vtex_c"
local ICON_NET = "panorama/images/spellicons/meepo_earthbind_png.vtex_c"
local COMBO_MODE_SELECTED = 0
local COMBO_MODE_ALL = 1
script._autofarm_mode = script._autofarm_mode or {
    UNSELECTED = 0,
    ALL = 1,
    CLONES = 2,
    ANY_UNSELECTED = 3,
}
local AUTOFARM_MAP_TEXTURES = {
    "panorama/images/textures/minimap_game_png.vtex_c",
    "panorama/images/textures/minimap_game_psd.vtex_c",
    "panorama/images/minimap/minimap_game_png.vtex_c",
    "panorama/images/minimap/dotamap_png.vtex_c",
    "panorama/images/minimap/dotamap_psd.vtex_c",
    "panorama/images/minimap/dotamap_psd_png.vtex_c",
}
local AUTOFARM_MAP_UV_MIN = Vec2(0.02, 0.02)
local AUTOFARM_MAP_UV_MAX = Vec2(0.98, 0.98)
local AUTOFARM_WORLD_MIN = -8800
local AUTOFARM_WORLD_MAX = 8800
local AUTOFARM_MAX_CUSTOM_POINTS = 24
local AUTOFARM_CAMP_CACHE_TTL = 1.5
local AUTOFARM_LOGIC_TICK = 0.08
local AUTOFARM_MAP_HERO_CACHE_TTL = 0.24
local AUTOFARM_ORDER_INTERVAL = 0.14
local AUTOFARM_ASSIGN_LOCK_SEC = 2.25
local AUTOFARM_CAMP_DETECT_RADIUS = 760
local AUTOFARM_CAMP_REACH_RADIUS = 680
local AUTOFARM_POINT_REACH_RADIUS = 280
local AUTOFARM_CAMP_STATUS_TEXT_OFFSET = 64
local AUTOFARM_QUEUE_MAX_TRAVEL = 3600
local AUTOFARM_QUEUE_NEAR_BAND = 1400
local AUTOFARM_RESPAWN_WAIT_WINDOW = 8
local AUTOFARM_RESPAWN_WAIT_BUFFER = 2
local AUTOFARM_TRAVEL_SPEED_ESTIMATE = 360
local AUTOFARM_SPAWN_CLEAR_SECOND = 55
local AUTOFARM_SPAWN_CLEAR_WINDOW = 5.2
local AUTOFARM_SPAWN_CLEAR_DISTANCE = 760
local AUTOFARM_STACK_PREP_SECOND = 54
local AUTOFARM_POOF_MOVE_MIN_DIST = 1850
local AUTOFARM_POOF_MOVE_ADVANTAGE = 1500
local AUTOFARM_POOF_MOVE_RECAST = 3.8
local AUTOFARM_POOF_DAMAGE_RECAST = 3.3
local AUTOFARM_POOF_DAMAGE_MIN_CREEPS = 2
local AUTOFARM_POOF_DAMAGE_RANGE = 340
script._autofarm_cfg = script._autofarm_cfg or {
    ASSIGN_STICKY_RADIUS = 760,
    WAVE_CLUSTER_LINK_DIST = 980,
    WAVE_DEFENSE_TOWER_RADIUS = 1450,
    WAVE_DEFENSE_MIN_CREEPS = 2,
    WAVE_DEFENSE_REACH_RADIUS = 760,
    WAVE_DEFENSE_POOF_MIN_CREEPS = 3,
    WAVE_KEEP_SAME_TARGET_BONUS = 360,
    WAVE_INTEREST_RADIUS = 2600,
    LAST_CAMP_SCORE_BONUS = 520,
    NEAR_PICK_RADIUS = 1500,
    NEAR_PICK_DELTA = 320,
    ORDER_DEDUPE_WINDOW = 0.32,
    ORDER_COALESCE_WINDOW = 0.26,
    ORDER_COALESCE_DIST = 160,
    PATH_SAMPLE_STEP = 560,
    PATH_BLOCK_PENALTY = 780,
    PATH_CACHE_TTL = 2.40,
    QUEUE_TTL = 22,
    QUEUE_PLAN_MAX_WAIT = 21,
    RESPAWN_PLAN_FUZZ = 1.35,
    WAVE_MARKER_CACHE_TTL = 0.24,
    PRESENCE_CACHE_TTL = 0.22,
    UI_WAVE_MARKER_CACHE_TTL = 0.30,
    TOWER_CACHE_TTL = 0.35,
    FOUNTAIN_CACHE_TTL = 2.20,
    NEUTRAL_SPATIAL_CELL = 760,
    TEXT_SIZE_CACHE_TTL = 0.75,
}
local AUTOFARM_MANA_MIN_RESERVE = 0
local function autofarm_use_poof_flags()
    local damage = true
    local move = true
    if ui.autofarm_poof_use_move and ui.autofarm_poof_use_move.Get then
        local ok_move, mv = pcall(function()
            return ui.autofarm_poof_use_move:Get()
        end)
        if ok_move and mv ~= nil then
            move = mv == true
        end
    end
    if ui.autofarm_poof_use_damage and ui.autofarm_poof_use_damage.Get then
        local ok_dmg, dm = pcall(function()
            return ui.autofarm_poof_use_damage:Get()
        end)
        if ok_dmg and dm ~= nil then
            damage = dm == true
        end
    end
    if ui.autofarm_poof_use and ui.autofarm_poof_use.Get then
        local ok_move, mv = pcall(function()
            return ui.autofarm_poof_use:Get("move")
        end)
        if ok_move and mv ~= nil then
            move = mv == true
        end
        local ok_dmg, dm = pcall(function()
            return ui.autofarm_poof_use:Get("damage")
        end)
        if ok_dmg and dm ~= nil then
            damage = dm == true
        end
    end
    if ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled then
        local ok_list, enabled = pcall(function()
            return ui.autofarm_poof_use:ListEnabled()
        end)
        if ok_list and type(enabled) == "table" then
            local move_found = false
            local damage_found = false
            local recognized_any = false
            for i = 1, #enabled do
                local raw = tostring(enabled[i] or "")
                if raw ~= "" then
                    if raw:find("move", 1, true)
                        or raw:find("Move", 1, true)
                        or raw:find("\u{041f}\u{0435}\u{0440}\u{0435}\u{043c}", 1, true)
                        or raw:find("\u{043f}\u{0435}\u{0440}\u{0435}\u{043c}", 1, true)
                    then
                        move_found = true
                        recognized_any = true
                    end
                    if raw:find("damage", 1, true)
                        or raw:find("Damage", 1, true)
                        or raw:find("\u{0423}\u{0440}\u{043e}\u{043d}", 1, true)
                        or raw:find("\u{0443}\u{0440}\u{043e}\u{043d}", 1, true)
                    then
                        damage_found = true
                        recognized_any = true
                    end
                end
            end
            if recognized_any then
                move = move_found
                damage = damage_found
            end
        end
    end
    return damage, move
end
local AUTOFARM_STACK_TRIGGER_RADIUS = 900
local AUTOFARM_STACK_RETREAT_DELAY = 0.65
local AUTOFARM_STACK_RETREAT_DISTANCE = 1750
local AUTOFARM_STACK_WAIT_OFFSET = 2
local AUTOFARM_LOW_HP_RETREAT_PCT = 6
local AUTOFARM_HEAL_EXIT_PCT = 100
local AUTOFARM_FOUNTAIN_RADIUS = 950
local AUTOFARM_THOUGHT_MAX_AGE = 1.8
local AUTOFARM_FALLBACK_CAMPS = {
    { id = "r_easy_1", label = "R-E1", nx = 0.17, ny = 0.27, side = "r" },
    { id = "r_med_1", label = "R-M1", nx = 0.24, ny = 0.34, side = "r" },
    { id = "r_hard_1", label = "R-H1", nx = 0.30, ny = 0.41, side = "r" },
    { id = "r_med_2", label = "R-M2", nx = 0.18, ny = 0.44, side = "r" },
    { id = "r_hard_2", label = "R-H2", nx = 0.13, ny = 0.55, side = "r" },
    { id = "r_ancient", label = "R-A", nx = 0.22, ny = 0.66, side = "r" },
    { id = "r_top_1", label = "R-T1", nx = 0.07, ny = 0.66, side = "r" },
    { id = "r_top_2", label = "R-T2", nx = 0.28, ny = 0.58, side = "r" },
    { id = "d_easy_1", label = "D-E1", nx = 0.83, ny = 0.73, side = "d" },
    { id = "d_med_1", label = "D-M1", nx = 0.76, ny = 0.66, side = "d" },
    { id = "d_hard_1", label = "D-H1", nx = 0.70, ny = 0.59, side = "d" },
    { id = "d_med_2", label = "D-M2", nx = 0.82, ny = 0.56, side = "d" },
    { id = "d_hard_2", label = "D-H2", nx = 0.87, ny = 0.45, side = "d" },
    { id = "d_ancient", label = "D-A", nx = 0.78, ny = 0.34, side = "d" },
    { id = "d_top_1", label = "D-T1", nx = 0.93, ny = 0.34, side = "d" },
    { id = "d_top_2", label = "D-T2", nx = 0.72, ny = 0.42, side = "d" },
}
local CFG = {
    burger_icon = "\u{f0c9}",
    item_icon_prefix = "panorama/images/items/",
    item_icon_suffix = "_png.vtex_c",
    blink_lead = 0.10,
    blink_recast_delay = 0.30,
    blink_item_candidates = {
        "item_blink",
        "item_swift_blink",
        "item_overwhelming_blink",
        "item_arcane_blink",
    },
    important_items = {
        "item_blink",
        "item_swift_blink",
        "item_overwhelming_blink",
        "item_arcane_blink",
        "item_sheepstick",
        "item_orchid",
        "item_bloodthorn",
        "item_cyclone",
        "item_rod_of_atos",
        "item_gleipnir",
        "item_abyssal_blade",
        "item_diffusal_blade",
        "item_disperser",
        "item_mjollnir",
        "item_mask_of_madness",
        "item_armlet",
        "item_manta",
        "item_blade_mail",
        "item_silver_edge",
        "item_invis_sword",
        "item_phase_boots",
        "item_grenade",
    },
    linken_break_items = {
        "item_orchid",
        "item_bloodthorn",
        "item_sheepstick",
        "item_abyssal_blade",
        "item_rod_of_atos",
        "item_diffusal_blade",
        "item_disperser",
        "item_nullifier",
        "item_heavens_halberd",
        "item_force_staff",
        "item_hurricane_pike",
        "item_cyclone",
        "item_wind_waker",
        "item_ethereal_blade",
        "item_urn_of_shadows",
        "item_spirit_vessel",
        "item_medallion_of_courage",
        "item_solar_crest",
        "item_dagon",
        "item_dagon_2",
        "item_dagon_3",
        "item_dagon_4",
        "item_dagon_5",
    },
}
local item_utils = {}
function item_utils.build_item_icon(item_name)
    if not item_name or item_name == "" then
        return ""
    end
    local icon_name = item_name:gsub("^item_", "")
    return CFG.item_icon_prefix .. icon_name .. CFG.item_icon_suffix
end
function item_utils.build_item_multiselect(items, default_enabled)
    local result = {}
    if not items then
        return result
    end
    for i = 1, #items do
        local name = items[i]
        if name and name ~= "" then
            result[#result + 1] = { name, item_utils.build_item_icon(name), default_enabled == true }
        end
    end
    return result
end
local function try_set_widget_image(widget, image_path)
    if not widget or not widget.Image or not image_path or image_path == "" then
        return
    end
    pcall(function()
        widget:Image(image_path)
    end)
end
local function begin_item_frame_budget()
    script._item_frame_budget_consumed = 0
end
local function get_cast_lock_key(ability, fallback_prefix)
    local name = safe_call(Ability.GetName, ability) or ""
    if name ~= "" then
        return name
    end
    return (fallback_prefix or "cast") .. ":" .. tostring(ability)
end
local function set_combo_action_lock(now, duration)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local lock_for = tonumber(duration or (C and C.COMBO_ACTION_MIN_INTERVAL) or 0.12) or 0.12
    if lock_for < 0 then
        lock_for = 0
    end
    local next_time = now_time + lock_for
    if next_time > (tonumber(script._combo_action_next_order_time or 0) or 0) then
        script._combo_action_next_order_time = next_time
    end
end
local function is_combo_action_locked(now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    return now_time < (tonumber(script._combo_action_next_order_time or 0) or 0)
end
function script.is_direct_cast_mode()
    if ui and ui.combo_direct_cast and ui.combo_direct_cast.Get then
        local ok, enabled = pcall(function()
            return ui.combo_direct_cast:Get()
        end)
        if ok then
            return enabled == true
        end
    end
    return true
end
local function cast_target_item_budgeted(meepo, item, target, tag, cast_pos_override)
    if not meepo or not item then
        return false
    end
    if not script.can_cast_target_item_now(meepo, item) then
        return false
    end
    local now = tonumber(get_game_time() or 0) or 0
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local name = safe_call(Ability.GetName, item) or ""
    local cast_lock_key = get_cast_lock_key(item, "target")
    local is_position_cast = (name == "item_gleipnir")
    local cast_pos = cast_pos_override
    if is_position_cast and not cast_pos and target then
        cast_pos = safe_call(Entity.GetAbsOrigin, target)
    end
    if (not is_position_cast and not target) or (is_position_cast and not cast_pos) then
        return false
    end
    if (not is_position_cast) and target and script.is_target_linkens_protected(target) then
        local caster_team = tonumber(safe_call(Entity.GetTeamNum, meepo) or -1) or -1
        local target_team = tonumber(safe_call(Entity.GetTeamNum, target) or -2) or -2
        local enemy_target = (caster_team < 0 or target_team < 0 or caster_team ~= target_team)
        if enemy_target and not script.is_linken_breaker_item_enabled(name) then
            return false
        end
    end
    if cast_lock_key ~= "" then
        local next_ok = script._cast_next_allowed_time[cast_lock_key] or -9999
        if now < next_ok then
            return false
        end
    end
    if script.is_direct_cast_mode() then
        local action_interval = math.max(
            tonumber(C.ITEM_MIN_INTERVAL_SEC or 0.15) or 0.15,
            tonumber(C.GENERIC_CAST_INTERVAL or 0.18) or 0.18
        )
        local ok = false
        if is_position_cast then
            ok = pcall(function()
                Ability.CastPosition(
                    item,
                    cast_pos,
                    false,
                    true,
                    true,
                    tag or name,
                    false
                )
            end)
        else
            ok = pcall(function()
                Ability.CastTarget(
                    item,
                    target,
                    false,
                    true,
                    true,
                    tag or name,
                    false
                )
            end)
        end
        if ok and cast_lock_key ~= "" then
            script._cast_next_allowed_time[cast_lock_key] = now + action_interval
            set_combo_action_lock(now, action_interval)
        end
        return ok == true
    end
    if frame >= 0 then
        local meepo_key = get_entity_key(meepo)
        local last_frame = script._cast_last_frame_by_meepo[meepo_key] or -1
        if frame == last_frame then
            return false
        end
        script._cast_last_frame_by_meepo[meepo_key] = frame
    end
    local ok = false
    if is_position_cast then
        ok = pcall(function()
            Ability.CastPosition(
                item,
                cast_pos,
                false,
                true,
                true,
                tag or name,
                false
            )
        end)
    else
        ok = pcall(function()
            Ability.CastTarget(
                item,
                target,
                false,
                true,
                true,
                tag or name,
                false
            )
        end)
    end
    if ok and cast_lock_key ~= "" then
        local interval = C.GENERIC_CAST_INTERVAL or 0.18
        script._cast_next_allowed_time[cast_lock_key] = now + interval
        set_combo_action_lock(now, interval)
    end
    return ok == true
end
function script.cast_no_target_item_budgeted(meepo, item, tag)
    if not meepo or not item then
        return false
    end
    local name = safe_call(Ability.GetName, item) or ""
    if name ~= "" and not is_item_enabled(name) then
        return false
    end
    if not can_cast_ability_for_npc(meepo, item) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, item) == true then
        return false
    end
    local now = tonumber(get_game_time() or 0) or 0
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local cast_lock_key = get_cast_lock_key(item, "notarget")
    if cast_lock_key ~= "" then
        local next_ok = script._cast_next_allowed_time[cast_lock_key] or -9999
        if now < next_ok then
            return false
        end
    end
    if script.is_direct_cast_mode() then
        local action_interval = math.max(
            tonumber(C.ITEM_MIN_INTERVAL_SEC or 0.15) or 0.15,
            tonumber(C.GENERIC_CAST_INTERVAL or 0.18) or 0.18
        )
        local ok = pcall(function()
            Ability.CastNoTarget(
                item,
                false,
                true,
                true,
                tag or name
            )
        end)
        if not ok then
            ok = pcall(function()
                Ability.CastNoTarget(item)
            end)
        end
        if ok and cast_lock_key ~= "" then
            script._cast_next_allowed_time[cast_lock_key] = now + action_interval
            set_combo_action_lock(now, action_interval)
        end
        return ok == true
    end
    if frame >= 0 then
        local meepo_key = get_entity_key(meepo)
        local last_frame = script._cast_last_frame_by_meepo[meepo_key] or -1
        if frame == last_frame then
            return false
        end
        script._cast_last_frame_by_meepo[meepo_key] = frame
    end
    local ok = pcall(function()
        Ability.CastNoTarget(
            item,
            false,
            true,
            true,
            tag or name
        )
    end)
    if not ok then
        ok = pcall(function()
            Ability.CastNoTarget(item)
        end)
    end
    if ok and cast_lock_key ~= "" then
        local interval = C.GENERIC_CAST_INTERVAL or 0.18
        script._cast_next_allowed_time[cast_lock_key] = now + interval
        set_combo_action_lock(now, interval)
    end
    return ok == true
end
local function get_default_bind_code()
    if Enum and Enum.ButtonCode then
        if Enum.ButtonCode.BUTTON_CODE_INVALID ~= nil then
            return Enum.ButtonCode.BUTTON_CODE_INVALID
        end
        if Enum.ButtonCode.BUTTON_CODE_NONE ~= nil then
            return Enum.ButtonCode.BUTTON_CODE_NONE
        end
    end
    return nil
end
local function create_bind_safe(group, bind_name, icon)
    if not group or not group.Bind then
        return nil
    end
    local default_code = get_default_bind_code()
    if default_code ~= nil then
        local ok_with_code, bind_with_code = pcall(function()
            if icon ~= nil then
                return group:Bind(bind_name, default_code, icon)
            end
            return group:Bind(bind_name, default_code)
        end)
        if ok_with_code and bind_with_code then
            return bind_with_code
        end
    end
    local ok_default, bind_default = pcall(function()
        if icon ~= nil then
            return group:Bind(bind_name, nil, icon)
        end
        return group:Bind(bind_name)
    end)
    if ok_default and bind_default then
        return bind_default
    end
    return nil
end
local has_combo_group = combo_group and combo_group.Switch and combo_group.Bind and combo_group.Combo and combo_group.Slider
local has_display_group = display_group and display_group.Switch and display_group.Slider
local has_abilities_group = abilities_group and abilities_group.Switch and abilities_group.Slider
local has_utilities_group = utilities_group and utilities_group.Bind
local has_items_group = items_group and items_group.Label
local has_autofarm_group = autofarm_group and autofarm_group.Switch and autofarm_group.Bind and autofarm_group.Slider
if has_combo_group and has_display_group and has_abilities_group then
    ui.combo_enabled = { Get = function() return true end }
    ui.combo_key = create_bind_safe(combo_group, "\u{041a}\u{043b}\u{0430}\u{0432}\u{0438}\u{0448}\u{0430} \u{043a}\u{043e}\u{043c}\u{0431}\u{043e}") or { IsDown = function() return false end }
    ui.combo_ground_key = create_bind_safe(combo_group, "\u{0417}\u{0435}\u{043c}\u{043d}\u{043e}\u{0435} \u{041a}\u{043e}\u{043c}\u{0431}\u{043e}") or { IsDown = function() return false end }
    try_set_widget_image(ui.combo_key, "panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
    try_set_widget_image(ui.combo_ground_key, ICON_NET)
    if combo_group.MultiSelect then
        ui.combo_spells = combo_group:MultiSelect("\u{0421}\u{043f}\u{043e}\u{0441}\u{043e}\u{0431}\u{043d}\u{043e}\u{0441}\u{0442}\u{0438}", {
            { "net", ICON_NET, true },
            { "poof", ICON_POOF, true },
        }, true)
        if ui.combo_spells.DragAllowed then
            ui.combo_spells:DragAllowed(false)
        end
    else
        ui.combo_use_net = combo_group:Switch("Net", true, ICON_NET)
        ui.combo_use_poof = combo_group:Switch("Poof", true, ICON_POOF)
    end
    ui.combo_type = combo_group:Combo("\u{0422}\u{0438}\u{043f} \u{041a}\u{043e}\u{043c}\u{0431}\u{043e}", {
        "\u{0412}\u{044b}\u{0431}\u{0440}\u{0430}\u{043d}\u{043d}\u{044b}\u{0439} \u{041c}\u{0438}\u{043f}\u{043e}",
        "\u{0412}\u{0441}\u{0435} \u{043c}\u{0438}\u{043f}\u{043e}",
    }, 1)
    try_set_widget_image(ui.combo_type, "panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
    ui.combo_target_fov = combo_group:Slider("Target FOV (px)", 40, 500, 140, "%d")
    ui.combo_state_machine = combo_group:Switch("State Machine", true)
    ui.combo_strict_control = combo_group:Switch("Strict Control", true)
    ui.combo_control_break_checks = combo_group:Switch("Control Break Checks", true)
    ui.combo_main_first = combo_group:Switch("Main Meepo First", true)
    ui.combo_hold_disable_ms = combo_group:Slider("Hold Disable Window (ms)", 100, 1400, 450, "%d")
    ui.combo_poof_before_blink = combo_group:Switch("Poof before Blink", true, ICON_POOF)
    ui.combo_blink_pre_poof_delay_ms = { Get = function() return 100 end }
    try_set_widget_image(ui.combo_use_net, ICON_NET)
    try_set_widget_image(ui.combo_use_poof, ICON_POOF)
    try_set_widget_image(ui.combo_target_fov, ICON_NET)
    try_set_widget_image(ui.combo_state_machine, "panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
    try_set_widget_image(ui.combo_strict_control, ICON_NET)
    try_set_widget_image(ui.combo_control_break_checks, item_utils.build_item_icon("item_lotus_orb"))
    try_set_widget_image(ui.combo_main_first, "panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
    try_set_widget_image(ui.combo_hold_disable_ms, ICON_NET)
    if ui.combo_poof_before_blink and ui.combo_poof_before_blink.Gear then
        local ok_child, child = pcall(function()
            return ui.combo_poof_before_blink:Gear("Settings")
        end)
        if ok_child and child and child.Slider then
            ok_child, child = pcall(function()
                return child:Slider("Timing (%)", 1, 100, 100, "%d%%")
            end)
            if ok_child and child then
                ui.combo_blink_pre_poof_delay_ms = child
                try_set_widget_image(ui.combo_blink_pre_poof_delay_ms, ICON_POOF)
            end
        end
    end
    ui.combo_direct_cast = combo_group:Switch("Direct Cast Mode", true)
    ui.net_on_tp = combo_group:Switch("\u{0421}\u{0435}\u{0442}\u{043a}\u{0430} \u{0412} \u{0422}\u{0435}\u{043b}\u{0435}\u{043f}\u{043e}\u{0440}\u{0442}", false, ICON_NET)
    ui.net_on_tp_combo_only = { Get = function() return true end }
    ui.net_on_tp_fog = { Get = function() return true end }
    ui.net_on_tp_fog_combo_only = { Get = function() return true end }
    if ui.net_on_tp and ui.net_on_tp.Gear then
        local ok_gear, tp_gear = pcall(function()
            return ui.net_on_tp:Gear("\u{041d}\u{0430}\u{0441}\u{0442}\u{0440}\u{043e}\u{0439}\u{043a}\u{0438}")
        end)
        try_set_widget_image(tp_gear, ICON_NET)
        if ok_gear and tp_gear and tp_gear.Switch then
            local ok_combo_only, combo_only = pcall(function()
                return tp_gear:Switch("\u{0422}\u{043e}\u{043b}\u{044c}\u{043a}\u{043e} \u{0412}\u{043e} \u{0412}\u{0440}\u{0435}\u{043c}\u{044f} \u{043a}\u{043e}\u{043c}\u{0431}\u{043e}", true)
            end)
            if ok_combo_only and combo_only then
                ui.net_on_tp_combo_only = combo_only
                try_set_widget_image(ui.net_on_tp_combo_only, ICON_NET)
            end
            local ok_fog, fog_switch = pcall(function()
                return tp_gear:Switch("\u{0421}\u{0435}\u{0442}\u{043a}\u{0430} \u{0432} \u{0442}\u{0435}\u{043b}\u{0435}\u{043f}\u{043e}\u{0440}\u{0442} \u{0432} \u{0442}\u{0443}\u{043c}\u{0430}\u{043d}", true, ICON_NET)
            end)
            if ok_fog and fog_switch then
                ui.net_on_tp_fog = fog_switch
                try_set_widget_image(ui.net_on_tp_fog, ICON_NET)
            end
            local ok_fog_combo_only, fog_combo_only = pcall(function()
                return tp_gear:Switch("\u{0422}\u{0443}\u{043c}\u{0430}\u{043d}: \u{0422}\u{043e}\u{043b}\u{044c}\u{043a}\u{043e} \u{0412}\u{043e} \u{0412}\u{0440}\u{0435}\u{043c}\u{044f} \u{043a}\u{043e}\u{043c}\u{0431}\u{043e}", true)
            end)
            if ok_fog_combo_only and fog_combo_only then
                ui.net_on_tp_fog_combo_only = fog_combo_only
                try_set_widget_image(ui.net_on_tp_fog_combo_only, ICON_NET)
            end
        end
    end
    ui.combo_debug = combo_group:Switch("Combo Debug HUD", false)
    ui.combo_fight_estimator = combo_group:Switch("Fight Estimator HUD", true)
    ui.enabled = display_group:Switch("Enable Meepo Panel", true)
    ui.show_main = display_group:Switch("Show main Meepo", true)
    ui.show_clones = display_group:Switch("Show clones", true)
    ui.draw_world = display_group:Switch("Draw above units", true)
    ui.draw_portraits = display_group:Switch("Draw near portraits", true)
    ui.show_tactical = display_group:Switch("Show tactical line", true)
    ui.float_panel_enable = display_group:Switch("Floating Control Box", true)
    ui.float_panel_click_select = display_group:Switch("Panel Click Select", true)
    ui.float_panel_x = display_group:Slider("Control Box X", 0, 3840, 28, "%d")
    ui.float_panel_y = display_group:Slider("Control Box Y", 0, 2160, 420, "%d")
    ui.float_panel_scale = display_group:Slider("Control Box Scale", 60, 180, 100, "%d%%")
    if has_autofarm_group then
        ui.autofarm_enable = autofarm_group:Switch("\u{0412}\u{043a}\u{043b}\u{044e}\u{0447}\u{0438}\u{0442}\u{044c} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}", false)
        ui.autofarm_toggle_key = create_bind_safe(autofarm_group, "\u{041a}\u{043b}\u{0430}\u{0432}\u{0438}\u{0448}\u{0430} \u{0410}\u{0432}\u{0442}\u{043e}\u{0424}\u{0430}\u{0440}\u{043c}")
            or { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_map_toggle_key = create_bind_safe(autofarm_group, "AutoFarm Map: Open/Close")
            or { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_map_x = { Get = function() return 28 end }
        ui.autofarm_map_y = { Get = function() return 820 end }
        ui.autofarm_map_scale = autofarm_group:Slider("Minimap Scale (%)", 60, 220, 100, "%d%%")
        ui.autofarm_perf_panel = autofarm_group:Switch("Performance Panel", false)
        ui.autofarm_perf_x = { Get = function() return 420 end }
        ui.autofarm_perf_y = { Get = function() return 840 end }
        ui.autofarm_perf_scale = { Get = function() return 100 end }
        ui.autofarm_mana_reserve = autofarm_group:Slider("\u{0421}\u{043e}\u{0445}\u{0440}\u{0430}\u{043d}\u{044f}\u{0442}\u{044c} \u{041c}\u{0430}\u{043d}\u{0443} (%)", 0, 80, 30, "%d%%")
        ui.autofarm_auto_stack = autofarm_group:Switch("Auto Stack", false)
        ui.autofarm_wave_split = autofarm_group:Switch("Wave Split", true)
        ui.autofarm_farm_only = autofarm_group:Combo("\u{0424}\u{0430}\u{0440}\u{043c}\u{0438}\u{0442}\u{044c} \u{0422}\u{043e}\u{043b}\u{044c}\u{043a}\u{043e}", {
            "\u{041d}\u{0435}\u{0432}\u{044b}\u{0431}\u{0440}\u{0430}\u{043d}\u{043d}\u{044b}\u{0435} \u{043c}\u{0438}\u{043f}\u{043e}",
            "\u{0412}\u{0441}\u{0435} \u{043c}\u{0438}\u{043f}\u{043e}",
            "\u{041a}\u{043b}\u{043e}\u{043d}\u{044b}",
            "\u{041b}\u{044e}\u{0431}\u{043e}\u{0439} \u{043d}\u{0435}\u{0432}\u{044b}\u{0434}\u{0435}\u{043b}\u{0435}\u{043d}\u{043d}\u{044b}\u{0439} \u{043c}\u{0438}\u{043f}\u{043e}",
        }, script._autofarm_mode.ALL)
        if autofarm_group.MultiCombo then
            ui.autofarm_poof_use = autofarm_group:MultiCombo("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{041f}\u{0443}\u{0444}\u{0430}", {
                "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}",
                "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}",
            }, {
                "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}",
                "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}",
            })
            ui.autofarm_poof_use_move = {
                Get = function()
                    local enabled = (ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled and ui.autofarm_poof_use:ListEnabled()) or {}
                    return list_has_string(enabled, "\u{0414}\u{043b}\u{044f} \u{043f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}")
                end
            }
            ui.autofarm_poof_use_damage = {
                Get = function()
                    local enabled = (ui.autofarm_poof_use and ui.autofarm_poof_use.ListEnabled and ui.autofarm_poof_use:ListEnabled()) or {}
                    return list_has_string(enabled, "\u{0414}\u{043b}\u{044f} \u{0443}\u{0440}\u{043e}\u{043d}\u{0430}")
                end
            }
        elseif autofarm_group.MultiSelect then
            ui.autofarm_poof_use = autofarm_group:MultiSelect("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{041f}\u{0443}\u{0444}\u{0430}", {
                { "move", nil, true },
                { "damage", nil, true },
            }, true)
            if ui.autofarm_poof_use and ui.autofarm_poof_use.DragAllowed then
                ui.autofarm_poof_use:DragAllowed(false)
            end
            ui.autofarm_poof_use_move = {
                Get = function()
                    return ui.autofarm_poof_use and ui.autofarm_poof_use.Get and ui.autofarm_poof_use:Get("move") == true
                end
            }
            ui.autofarm_poof_use_damage = {
                Get = function()
                    return ui.autofarm_poof_use and ui.autofarm_poof_use.Get and ui.autofarm_poof_use:Get("damage") == true
                end
            }
        else
            ui.autofarm_poof_use_move = autofarm_group:Switch("\u{041f}\u{0443}\u{0444} \u{0434}\u{043b}\u{044f} \u{041f}\u{0435}\u{0440}\u{0435}\u{043c}\u{0435}\u{0449}\u{0435}\u{043d}\u{0438}\u{044f}", true)
            ui.autofarm_poof_use_damage = autofarm_group:Switch("\u{041f}\u{0443}\u{0444} \u{0434}\u{043b}\u{044f} \u{0423}\u{0440}\u{043e}\u{043d}\u{0430}", true)
        end
    else
        ui.autofarm_enable = { Get = function() return false end }
        ui.autofarm_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_map_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
        ui.autofarm_map_x = { Get = function() return 28 end }
        ui.autofarm_map_y = { Get = function() return 820 end }
        ui.autofarm_map_scale = { Get = function() return 100 end }
        ui.autofarm_perf_panel = { Get = function() return true end }
        ui.autofarm_perf_x = { Get = function() return 420 end }
        ui.autofarm_perf_y = { Get = function() return 840 end }
        ui.autofarm_perf_scale = { Get = function() return 100 end }
        ui.autofarm_mana_reserve = { Get = function() return 0 end }
        ui.autofarm_auto_stack = { Get = function() return false end }
        ui.autofarm_wave_split = { Get = function() return true end }
        ui.autofarm_farm_only = { Get = function() return script._autofarm_mode.ALL end }
        ui.autofarm_poof_use_move = { Get = function() return true end }
        ui.autofarm_poof_use_damage = { Get = function() return true end }
    end
    if abilities_group.MultiSelect then
        ui.auto_save_spells = abilities_group:MultiSelect("\u{0421}\u{043f}\u{043e}\u{0441}\u{043e}\u{0431}\u{043d}\u{043e}\u{0441}\u{0442}\u{0438}", {
            { "dig", ICON_DIG, false },
            { "mega", ICON_MEGA, false },
        }, true)
        if ui.auto_save_spells.DragAllowed then
            ui.auto_save_spells:DragAllowed(false)
        end
        ui.auto_dig = { Get = function() return ui.auto_save_spells:Get("dig") end }
        ui.auto_mega = { Get = function() return ui.auto_save_spells:Get("mega") end }
    else
        ui.auto_dig = abilities_group:Switch("Dig", false, ICON_DIG)
        ui.auto_mega = abilities_group:Switch("MegaMeepo", false, ICON_MEGA)
    end
    ui.auto_dig_hp = abilities_group:Slider("Auto Dig HP (%)", 5, 80, 28, "%d%%")
    ui.auto_mega_hp = abilities_group:Slider("Auto MegaMeepo HP (%)", 5, 80, 35, "%d%%")
    ui.auto_safe_enable = abilities_group:Switch("Enable Auto Safe", true, ICON_POOF)
    ui.auto_safe_which_meepos = abilities_group:Combo("Which Meepos to Save", {
        "All Meepos",
        "Only Clones",
        "Only Main",
    }, 1)
    ui.auto_safe_poof_hp_enable = abilities_group:Switch("Poof to Safety (HP)", true, ICON_POOF)
    ui.auto_safe_poof_hp = abilities_group:Slider("Poof Threshold (%)", 5, 60, 25, "%d%%")
    ui.auto_safe_poof_dest = abilities_group:Combo("Poof Destination", {
        "Farthest Clone",
        "Main Meepo",
        "Healthiest Clone",
    }, 0)
    ui.auto_safe_cd_ms = abilities_group:Slider("Auto Safe Cooldown (ms)", 500, 6000, 2000, "%dms")
    ui.auto_safe_enemy_poof = abilities_group:Switch("Poof Away from Enemies", true, ICON_POOF)
    ui.auto_safe_enemy_radius = abilities_group:Slider("Enemy Detection Radius", 400, 1500, 900, "%d")
    try_set_widget_image(ui.auto_safe_enable, ICON_POOF)
    try_set_widget_image(ui.auto_safe_enemy_poof, ICON_POOF)
    try_set_widget_image(ui.auto_safe_enemy_radius, ICON_NET)
    try_set_widget_image(ui.auto_safe_which_meepos, "panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c")
    try_set_widget_image(ui.auto_safe_poof_dest, ICON_POOF)
    try_set_widget_image(ui.auto_dig_hp, ICON_DIG)
    try_set_widget_image(ui.auto_mega_hp, ICON_MEGA)
    try_set_widget_image(ui.auto_safe_poof_hp, ICON_POOF)
    if has_utilities_group then
        ui.poof_to_cursor = create_bind_safe(utilities_group, "\u{041f}\u{0443}\u{0444} \u{043a} \u{043a}\u{0443}\u{0440}\u{0441}\u{043e}\u{0440}\u{0443}", ICON_POOF) or { IsPressed = function() return false end }
        ui.poof_on_self = create_bind_safe(utilities_group, "\u{041f}\u{0443}\u{0444} \u{043d}\u{0430} \u{0441}\u{0435}\u{0431}\u{044f}", ICON_POOF) or { IsPressed = function() return false end }
    else
        ui.poof_to_cursor = { IsPressed = function() return false end }
        ui.poof_on_self = { IsPressed = function() return false end }
    end
    if has_items_group then
        ui.items_menu = items_group:Label("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}")
        ui.items_linken_menu = items_group:Label("\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}")
        try_set_widget_image(ui.items_linken_menu, item_utils.build_item_icon("item_sphere"))
        if ui.items_menu and ui.items_menu.Gear then
            local items_gear = ui.items_menu:Gear("\u{0418}\u{0441}\u{043f}\u{043e}\u{043b}\u{044c}\u{0437}\u{043e}\u{0432}\u{0430}\u{043d}\u{0438}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{043e}\u{0432}", CFG.burger_icon, true)
            if items_gear and items_gear.MultiSelect then
                ui.items_important = items_gear:MultiSelect(
                    "\u{0412}\u{0430}\u{0436}\u{043d}\u{044b}\u{0435} \u{043f}\u{0440}\u{0435}\u{0434}\u{043c}\u{0435}\u{0442}\u{044b}",
                    item_utils.build_item_multiselect(CFG.important_items, true),
                    true
                )
                if ui.items_important and ui.items_important.DragAllowed then
                    ui.items_important:DragAllowed(false)
                end
            else
                ui.items_important = { Get = function() return false end }
            end
        else
            ui.items_important = { Get = function() return false end }
        end
        if ui.items_linken_menu and ui.items_linken_menu.Gear then
            local linken_gear = ui.items_linken_menu:Gear("\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}", CFG.burger_icon, true)
            try_set_widget_image(linken_gear, item_utils.build_item_icon("item_sphere"))
            if linken_gear and linken_gear.MultiSelect then
                ui.items_linken_breakers = linken_gear:MultiSelect(
                    "\u{0421}\u{0431}\u{0438}\u{0442}\u{0438}\u{0435} \u{041b}\u{0438}\u{043d}\u{043a}\u{0438}",
                    item_utils.build_item_multiselect(CFG.linken_break_items, true),
                    true
                )
                if ui.items_linken_breakers and ui.items_linken_breakers.DragAllowed then
                    ui.items_linken_breakers:DragAllowed(false)
                end
            else
                ui.items_linken_breakers = { Get = function() return false end }
            end
        else
            ui.items_linken_breakers = { Get = function() return false end }
        end
        ui.items_enabled = { Get = function() return true end }
    else
        ui.items_enabled = { Get = function() return false end }
        ui.items_important = { Get = function() return false end }
        ui.items_linken_breakers = { Get = function() return false end }
    end
else
    ui.combo_enabled = { Get = function() return true end }
    ui.combo_key = { IsDown = function() return false end }
    ui.combo_ground_key = { IsDown = function() return false end }
    ui.combo_type = { Get = function() return COMBO_MODE_SELECTED end }
    ui.combo_target_fov = { Get = function() return 140 end }
    ui.combo_state_machine = { Get = function() return true end }
    ui.combo_strict_control = { Get = function() return true end }
    ui.combo_control_break_checks = { Get = function() return true end }
    ui.combo_main_first = { Get = function() return true end }
    ui.combo_hold_disable_ms = { Get = function() return 450 end }
    ui.combo_poof_before_blink = { Get = function() return true end }
    ui.combo_blink_pre_poof_delay_ms = { Get = function() return 100 end }
    ui.combo_direct_cast = { Get = function() return true end }
    ui.net_on_tp = { Get = function() return false end }
    ui.net_on_tp_combo_only = { Get = function() return true end }
    ui.net_on_tp_fog = { Get = function() return true end }
    ui.net_on_tp_fog_combo_only = { Get = function() return true end }
    ui.combo_debug = { Get = function() return false end }
    ui.combo_fight_estimator = { Get = function() return true end }
    ui.enabled = { Get = function() return true end }
    ui.show_main = { Get = function() return true end }
    ui.show_clones = { Get = function() return true end }
    ui.draw_world = { Get = function() return true end }
    ui.draw_portraits = { Get = function() return false end }
    ui.show_tactical = { Get = function() return true end }
    ui.float_panel_enable = { Get = function() return true end }
    ui.float_panel_click_select = { Get = function() return true end }
    ui.float_panel_x = { Get = function() return 28 end }
    ui.float_panel_y = { Get = function() return 420 end }
    ui.float_panel_scale = { Get = function() return 100 end }
    ui.auto_dig = { Get = function() return false end }
    ui.auto_mega = { Get = function() return false end }
    ui.auto_dig_hp = { Get = function() return 28 end }
    ui.auto_mega_hp = { Get = function() return 35 end }
    ui.auto_safe_enable = { Get = function() return false end }
    ui.auto_safe_which_meepos = { Get = function() return 1 end }
    ui.auto_safe_poof_hp_enable = { Get = function() return true end }
    ui.auto_safe_poof_hp = { Get = function() return 25 end }
    ui.auto_safe_poof_dest = { Get = function() return 0 end }
    ui.auto_safe_cd_ms = { Get = function() return 2000 end }
    ui.auto_safe_enemy_poof = { Get = function() return true end }
    ui.auto_safe_enemy_radius = { Get = function() return 900 end }
    ui.autofarm_enable = { Get = function() return false end }
    ui.autofarm_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
    ui.autofarm_map_toggle_key = { IsPressed = function() return false end, IsDown = function() return false end }
    ui.autofarm_map_x = { Get = function() return 28 end }
    ui.autofarm_map_y = { Get = function() return 820 end }
    ui.autofarm_map_scale = { Get = function() return 100 end }
    ui.autofarm_perf_panel = { Get = function() return true end }
    ui.autofarm_perf_x = { Get = function() return 420 end }
    ui.autofarm_perf_y = { Get = function() return 840 end }
    ui.autofarm_perf_scale = { Get = function() return 100 end }
    ui.autofarm_auto_stack = { Get = function() return false end }
    ui.autofarm_wave_split = { Get = function() return true end }
    ui.autofarm_farm_only = { Get = function() return script._autofarm_mode.ALL end }
    ui.poof_to_cursor = { IsPressed = function() return false end }
    ui.poof_on_self = { IsPressed = function() return false end }
    ui.items_enabled = { Get = function() return false end }
    ui.items_important = { Get = function() return false end }
    ui.items_linken_breakers = { Get = function() return false end }
end
local combo_bind = nil
local farm_bind = nil
local binds_initialized = false
local function init_binds_once()
    if binds_initialized then
        return
    end
    local success1, bind1 = pcall(function()
        return Menu.Find("Heroes", "Hero List", "Meepo", "Main Settings", "Hero Settings", "Combo Key")
    end)
    if success1 and bind1 then
        combo_bind = bind1
    end
    local success2, bind2 = pcall(function()
        return Menu.Find("Heroes", "Hero List", "Meepo", "Main Settings", "Jungle Settings", "Farm Key")
    end)
    if success2 and bind2 then
        farm_bind = bind2
    end
    binds_initialized = true
end
local font = Render.LoadFont("Arial", Enum.FontCreate.FONTFLAG_OUTLINE, Enum.FontWeight.BOLD)
local font_size = 16
local tactical_font_size = 12
local COLORS = {
    combo = Color(255, 80, 80, 255),
    farm = Color(120, 220, 120, 255),
    move = Color(255, 220, 120, 255),
    idle = Color(200, 200, 200, 255),
    dead = Color(150, 150, 255, 255),
    retreat = Color(255, 150, 90, 255),
    engage_ready = Color(120, 235, 255, 255),
    bg = Color(0, 0, 0, 150),
    tactical = Color(220, 235, 255, 230),
}
C = {
    BAR_OFFSET_Z = 135,
    BAR_LABEL_GAP_PX = 14,
    PORTRAIT_X_PCT = 4,
    PORTRAIT_Y_PCT = 18,
    PORTRAIT_STEP_Y_PCT = 6,
    ENEMY_RADIUS = 800,
    READY_RADIUS = 900,
    RETREAT_HP_PCT = 32,
    SAFE_ENGAGE_HP_PCT = 35,
    AUTO_SAVE_ENEMY_RADIUS = 1000,
    AUTO_SAVE_RECENT_DROP_WINDOW = 1.20,
    AUTO_SAVE_RECENT_DROP_PCT = 6,
    AUTO_SAVE_EMERGENCY_HP_PCT = 12,
    ABILITY_POOF = "meepo_poof",
    ABILITY_NET = "meepo_earthbind",
    ABILITY_DIG = "meepo_petrify",
    ITEM_HEX = "item_sheepstick",
    MODIFIER_DIG = "modifier_meepo_petrify",
    ABILITY_MEGA_CANDIDATES = { "meepo_megameepo", "meepo_mega_meepo" },
    MODIFIER_MEGA_CANDIDATES = { "modifier_meepo_megameepo", "modifier_meepo_mega_meepo" },
    MODIFIER_NET_CANDIDATES = {
        "modifier_meepo_earthbind",
        "modifier_meepo_earthbind_debuff",
        "modifier_meepo_earthbind_root",
    },
    AUTO_DIG_RECAST_DELAY = 0.35,
    AUTO_MEGA_RECAST_DELAY = 0.45,
    AUTO_DIG_TICK_INTERVAL = 0.04,
    COMBO_MOVE_ORDER_INTERVAL = 0.07,
    COMBO_MOVE_MIN_DELTA = 4,
    COMBO_NET_CHAIN_BUFFER = 0.16,
    COMBO_NET_HANDOFF_EXTRA = 0.18,
    COMBO_NET_CASTER_RECAST_DELAY = 0.14,
    COMBO_NET_GLOBAL_RECAST_DELAY = 0.06,
    COMBO_NET_CAST_LOCK = 0.03,
    COMBO_NET_PENDING_CONFIRM_GRACE = 0.12,
    COMBO_NET_PROJECTILE_SPEED_FALLBACK = 900,
    COMBO_NET_RANGE_PADDING = 80,
    COMBO_NET_FACE_TIME_CAP = 0.35,
    COMBO_GROUND_NET_INTERVAL = 1.00,
    COMBO_GROUND_NET_MIN_CURSOR_DELTA = 120,
    TP_FOG_TRACK_DURATION = 3.35,
    TP_FOG_DESTROY_GRACE = 0.40,
    COMBO_HEX_RANGE_PADDING = 50,
    COMBO_HEX_RANGE_FALLBACK = 800,
    COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW = 0.30,
    COMBO_HEX_TO_CONTROL_CHAIN_WINDOW = 0.35,
    COMBO_HOLD_ORDER_INTERVAL = 0.12,
    COMBO_POOF_CASTER_RECAST_DELAY = 0.20,
    COMBO_POOF_ROOT_MIN_REMAINING = 0.30,
    COMBO_POOF_SAFE_ROOT_BUFFER = 0.06,
    COMBO_POOF_STAGGER = 0.04,
    COMBO_BLINK_RECAST_DELAY = 0.24,
    COMBO_BLINK_CMD_GUARD = 0.32,
    COMBO_POOF_CHANNEL_FALLBACK = 1.5,
    COMBO_POOF_DAMAGE_RADIUS_FALLBACK = 375,
    COMBO_POOF_DAMAGE_RADIUS_PAD = -50,
    COMBO_POOF_SELF_HIT_PAD = -10,
    COMBO_POOF_ANCHOR_DISTANCE_RATIO = 0.50,
    COMBO_POOF_ANCHOR_DISTANCE_CAP = 190,
    COMBO_POOF_ANCHOR_DISTANCE_MIN = 120,
    COMBO_ENGAGE_CLOSE_PAD = 210,
    COMBO_ENGAGE_MID_PAD = 120,
    COMBO_ENGAGE_MID_EXTRA = 420,
    COMBO_PRED_ATTACK_HITS_CLOSE = 3,
    COMBO_PRED_ATTACK_HITS_MID = 2,
    COMBO_PRED_ATTACK_HITS_FAR = 1,
    COMBO_PRED_ATTACK_INTERVAL_FALLBACK = 1.55,
    COMBO_PRED_FIRST_HIT_WINDUP = 0.20,
    COMBO_PRED_MAX_ATTACK_HITS_PER_MEEPO = 4,
    COMBO_PRED_MAX_OPEN_DELAY = 1.45,
    COMBO_PRED_MAX_CHAIN_NETS = 4,
    COMBO_PRED_MAX_CONTROL_WINDOW = 7.0,
    COMBO_PRED_POOF_SETUP_TIME = 0.40,
    COMBO_FIGHT_EST_KILL_CTRL_MIN = 0.30,
    COMBO_FIGHT_EST_WIN_HP_RATIO = 0.20,
    COMBO_FIGHT_EST_RISK_HP_RATIO = 0.45,
    COMBO_FIGHT_EST_MIN_CTRL_FOR_WIN = 0.40,
    COMBO_ATTACK_ORDER_INTERVAL = 0.28,
    COMBO_ATTACK_ACTION_LOCK = 0.06,
    COMBO_ACTION_MIN_INTERVAL = 0.12,
    COMBO_CONTROL_HOLD_MIN_REMAINING = 0.08,
    COMBO_DEBUG_LOG_MIN_GAP = 0.18,
    COMBO_LOGIC_TICK_INTERVAL = 0.03,
    COMBO_PURGE_GLOBAL_RECAST_DELAY = 0.65,
    COMBO_PURGE_SAME_TARGET_RECAST_DELAY = 1.25,
    COMBO_ITEM_FRAME_GAP = 3,
    ITEM_CAST_BUDGET_PER_FRAME = 2,
    ITEM_MIN_INTERVAL_SEC = 0.15,
    GENERIC_CAST_INTERVAL = 0.18,
    HUD_COMBO_Y_OFFSET = 245,
    HUD_COMBO_W = 126,
    HUD_COMBO_H = 24,
    HUD_COMBO_TEXT_ON = "\u{0412}\u{043a}\u{043b}",
    HUD_COMBO_TEXT_OFF = "\u{0412}\u{044b}\u{043a}\u{043b}",
    HUD_COMBO_TITLE = "\u{041a}\u{043e}\u{043c}\u{0431}\u{043e}",
}
local auto_dig_last_cast = {}
local auto_mega_last_cast = {}
local auto_dig_next_tick = 0
local combo_runtime_enabled = true
local combo_focus_target = nil
local combo_focus_source = nil
local combo_focus_target_key = nil
local combo_move_next_order_time = 0
local combo_move_last_position = nil
local combo_move_last_frame = -1
local combo_last_selection_key = nil
local combo_net_last_global_cast = -9999
local combo_net_last_cast_by_meepo = {}
local combo_hex_last_cast = -9999
local combo_hex_last_cast_by_meepo = {}
local combo_poof_last_cast_by_meepo = {}
local combo_attack_next_order_time = 0
local combo_was_active = false
local poof_cast_queue = {}
local poof_queue_by_meepo = {}
local can_schedule_poof
local schedule_poof_burst
script._poof_next_order_time = script._poof_next_order_time or 0
local function is_sync_poof_reason(reason)
    if not reason or reason == "" then
        return false
    end
    local r = tostring(reason)
    if string.find(r, "meepo_combo_", 1, true) == 1 then
        return true
    end
    return r == "meepo_combo_poof_sync"
        or r == "meepo_poof_cursor"
        or r == "meepo_poof_self"
end
function script.is_autofarm_poof_reason(reason)
    if not reason or reason == "" then
        return false
    end
    local r = tostring(reason)
    return string.find(r, "meepo_autofarm_", 1, true) ~= nil
end
local clear_poof_queue
local has_pending_poof_queue
script._debug_combo_log = true
script._debug_use_engine_echo = false
script._debug_emit_min_gap = script._debug_emit_min_gap or 0.15
script._debug_last_emit_time = script._debug_last_emit_time or -9999
function script._fmt_vec(v)
    if not v then
        return "nil"
    end
    return string.format("(%.1f,%.1f,%.1f)", v.x or 0, v.y or 0, v.z or 0)
end
function script._dbg(tag, msg)
    if not script._debug_combo_log then
        return
    end
    local debug_ui_enabled = false
    if ui and ui.combo_debug and ui.combo_debug.Get then
        local ok, enabled = pcall(function()
            return ui.combo_debug:Get()
        end)
        debug_ui_enabled = ok and enabled == true
    end
    if not debug_ui_enabled then
        return
    end
    pcall(function()
        local t = 0
        if GameRules and GameRules.GetGameTime then
            t = tonumber(GameRules.GetGameTime()) or 0
        end
        if tag ~= "combo_state" and (t - (script._debug_last_emit_time or -9999)) < (script._debug_emit_min_gap or 0) then
            return
        end
        local line = string.format("[meepo:%s][%.3f] %s", tag or "-", t, msg or "")
        print(line)
        script._debug_last_emit_time = t
        if script._debug_use_engine_echo and Engine and Engine.ExecuteCommand then
            pcall(function()
                Engine.ExecuteCommand("echo " .. line)
            end)
        end
    end)
end
script._combo_blink_last_cast_cmd = script._combo_blink_last_cast_cmd or -9999
local function is_meepo_hero(npc)
    if not npc or not Entity.IsHero(npc) then
        return false
    end
    local name = NPC.GetUnitName(npc)
    return name == "npc_dota_hero_meepo"
end
local function is_meepo_instance(npc)
    if not npc or not Entity.IsHero(npc) then
        return false
    end
    if safe_call(NPC.IsIllusion, npc) == true then
        return false
    end
    if NPC.IsMeepoClone and NPC.IsMeepoClone(npc) then
        return true
    end
    return is_meepo_hero(npc)
end
local function round_int(v)
    return math.floor((tonumber(v) or 0) + 0.5)
end
get_game_time = function()
    if not GameRules or not GameRules.GetGameTime then
        return 0
    end
    return tonumber(safe_call(GameRules.GetGameTime) or 0) or 0
end
function script.af_num(v, d)
    local n = tonumber(v)
    if n ~= nil then
        return n
    end
    local fallback = tonumber(d)
    if fallback ~= nil then
        return fallback
    end
    return 0
end
function script.af_time(now)
    return script.af_num(now or get_game_time() or 0, 0)
end
function script.af_alive_pos(unit)
    if not unit or not Entity.IsAlive(unit) then
        return nil
    end
    return safe_call(Entity.GetAbsOrigin, unit)
end
function script.af_camp_is_active(camp, now_time)
    if not camp then
        return false, 0, ""
    end
    local ready_at = script.af_num(camp.ready_at or (camp.id and get_autofarm_camp_ready_at(camp.id) or 0), 0)
    local status = tostring(camp.status or "")
    local is_active = (now_time >= ready_at) and (camp.has_creeps == true or status == "unseen" or status == "ready")
    return is_active, ready_at, status
end
function script.af_camp_tier(camp, now_time)
    local is_active, ready_at, status = script.af_camp_is_active(camp, now_time)
    local tier = 4
    if is_active then
        if camp and camp.has_creeps == true then
            tier = 1
        elseif status == "unseen" then
            tier = 2
        else
            tier = 3
        end
    end
    return tier, ready_at, status, is_active
end
function script._frame_count_safe(now_time)
    if GlobalVars and GlobalVars.GetFrameCount then
        local frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
        if frame >= 0 then
            return frame
        end
    end
    local t = tonumber(now_time or get_game_time() or 0) or 0
    return math.floor(t * 60 + 0.5)
end
function script._frame_context_get(now_time)
    local now = tonumber(now_time or get_game_time() or 0) or 0
    script._frame_context = script._frame_context or {}
    local ctx = script._frame_context
    local frame = script._frame_count_safe(now)
    if (tonumber(ctx.frame or -1) or -1) ~= frame then
        ctx.frame = frame
        ctx.now = now
        ctx.local_hero = nil
        ctx.local_player = nil
        ctx.meepos = nil
        ctx.heroes = nil
        ctx.selected_player = nil
        ctx.selected_units = nil
        ctx.selected_key_set = nil
        ctx.cursor_x = nil
        ctx.cursor_y = nil
        ctx.world_cursor = nil
    else
        ctx.now = now
    end
    script._frame_context = ctx
    return ctx
end
function script._heroes_all_frame_cached(now_time)
    local ctx = script._frame_context_get(now_time)
    if ctx.heroes ~= nil then
        return ctx.heroes
    end
    local heroes = Heroes and Heroes.GetAll and safe_call(Heroes.GetAll) or nil
    ctx.heroes = heroes or {}
    return ctx.heroes
end
function script._selected_units_frame_cached(local_player, now_time)
    if not local_player or not Player or not Player.GetSelectedUnits then
        return {}
    end
    local ctx = script._frame_context_get(now_time)
    if ctx.selected_player == local_player and ctx.selected_units ~= nil then
        return ctx.selected_units
    end
    local selected = safe_call(Player.GetSelectedUnits, local_player) or {}
    ctx.selected_player = local_player
    ctx.selected_units = selected
    ctx.selected_key_set = nil
    return selected
end
function script.profiler_begin(_tag)
    if os and os.clock then
        return os.clock()
    end
    return tonumber(get_game_time and get_game_time() or 0) or 0
end
function script.profiler_end(tag, start_time)
    if not tag or not start_time then
        return 0
    end
    local now
    if os and os.clock then
        now = os.clock()
    else
        now = tonumber(get_game_time and get_game_time() or 0) or 0
    end
    local dt = now - (tonumber(start_time) or now)
    if dt < 0 then
        dt = 0
    end
    script._autofarm_perf = script._autofarm_perf or {}
    local perf = script._autofarm_perf
    local stat = perf[tag] or { ring = {}, idx = 1, count = 0, sum = 0, avg = 0, p95 = 0, max = 0 }
    local ring = stat.ring or {}
    local cap = 72
    local idx = tonumber(stat.idx or 1) or 1
    if idx < 1 or idx > cap then
        idx = 1
    end
    local old = tonumber(ring[idx] or 0) or 0
    ring[idx] = dt
    stat.sum = (tonumber(stat.sum or 0) or 0) - old + dt
    if (tonumber(stat.count or 0) or 0) < cap then
        stat.count = (tonumber(stat.count or 0) or 0) + 1
    end
    idx = idx + 1
    if idx > cap then
        idx = 1
    end
    stat.idx = idx
    stat.ring = ring
    local count = tonumber(stat.count or 0) or 0
    if count > 0 then
        stat.avg = (tonumber(stat.sum or 0) or 0) / count
        local snapshot = {}
        for i = 1, count do
            snapshot[i] = tonumber(ring[i] or 0) or 0
        end
        table.sort(snapshot)
        local p95_idx = math.floor(count * 0.95 + 0.5)
        if p95_idx < 1 then
            p95_idx = 1
        elseif p95_idx > count then
            p95_idx = count
        end
        stat.p95 = tonumber(snapshot[p95_idx] or 0) or 0
        if dt > (tonumber(stat.max or 0) or 0) then
            stat.max = dt
        end
    end
    perf[tag] = stat
    script._autofarm_perf = perf
    script._autofarm_metrics = script._autofarm_metrics or {}
    local metrics = script._autofarm_metrics
    local prefix = "perf_" .. tostring(tag)
    metrics[prefix .. "_last_ms"] = dt * 1000
    metrics[prefix .. "_avg_ms"] = (tonumber(stat.avg or 0) or 0) * 1000
    metrics[prefix .. "_p95_ms"] = (tonumber(stat.p95 or 0) or 0) * 1000
    metrics[prefix .. "_max_ms"] = (tonumber(stat.max or 0) or 0) * 1000
    script._autofarm_metrics = metrics
    return dt
end
local function get_health_pct(npc)
    local hp = tonumber(safe_call(Entity.GetHealth, npc) or 0) or 0
    local max_hp = tonumber(safe_call(Entity.GetMaxHealth, npc) or 0) or 0
    if max_hp <= 0 then
        return 0
    end
    local pct = (hp / max_hp) * 100
    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end
    return pct
end
local function get_mana_pct(npc)
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local max_mana = tonumber(safe_call(NPC.GetMaxMana, npc) or 0) or 0
    if max_mana <= 0 then
        return 0
    end
    local pct = (mana / max_mana) * 100
    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end
    return pct
end
local function vec_dist_2d(a, b)
    if not a or not b then
        return nil
    end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    return math.sqrt(dx * dx + dy * dy)
end
local function get_enemy_info(npc, radius)
    local enemies = Entity.GetHeroesInRadius(npc, radius, Enum.TeamType.TEAM_ENEMY, false, true)
    local count = (enemies and #enemies) or 0
    if count <= 0 then
        return 0, nil
    end
    local meepo_pos = safe_call(Entity.GetAbsOrigin, npc)
    if not meepo_pos then
        return count, nil
    end
    local nearest = nil
    for i = 1, count do
        local enemy = enemies[i]
        local epos = safe_call(Entity.GetAbsOrigin, enemy)
        local d = vec_dist_2d(meepo_pos, epos)
        if d and (not nearest or d < nearest) then
            nearest = d
        end
    end
    return count, nearest
end
local function get_ability_cd(npc, ability_name)
    local ability = safe_call(NPC.GetAbility, npc, ability_name)
    if not ability then
        return nil
    end
    return tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
end
local function is_ability_ready(npc, ability_name)
    local ability = safe_call(NPC.GetAbility, npc, ability_name)
    if not ability then
        return false
    end
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local castable = safe_call(Ability.IsCastable, ability, mana)
    if castable ~= nil then
        return castable == true
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    local mc = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    return cd <= 0.05 and mana >= mc
end
local function fmt_cd(cd)
    if cd == nil then
        return "--"
    end
    local v = tonumber(cd) or 0
    if v <= 0.05 then
        return "0.0"
    end
    return string.format("%.1f", v)
end
local function fmt_dist(d)
    if d == nil then
        return "--"
    end
    return tostring(round_int(d))
end
local function build_tactical_line(hp_pct, mana_pct, poof_cd, net_cd, nearest_dist)
    return string.format(
        "HP %d%% | MP %d%% | P %s | N %s | E %s",
        round_int(hp_pct),
        round_int(mana_pct),
        fmt_cd(poof_cd),
        fmt_cd(net_cd),
        fmt_dist(nearest_dist)
    )
end
local function collect_meepos(local_hero, now_time)
    if local_hero == nil then
        local ctx = script._frame_context_get(now_time)
        local_hero = ctx.local_hero
        if local_hero == nil then
            local_hero = Heroes.GetLocal()
            ctx.local_hero = local_hero
        end
    end
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    now_time = tonumber(now_time or get_game_time and get_game_time() or 0) or 0
    script._meepo_collect_cache = script._meepo_collect_cache or { t = -9999, hero = nil, team = -1, units = {}, clone_count = 0 }
    local cache = script._meepo_collect_cache
    if cache.hero == local_hero and cache.team == local_team and (now_time - (tonumber(cache.t or -9999) or -9999)) <= 0.03 then
        return cache.units or {}
    end
    local result = {}
    local clone_count = 0
    local heroes = script._heroes_all_frame_cached(now_time)
    if not heroes then
        cache.t = now_time
        cache.hero = local_hero
        cache.team = local_team
        cache.units = result
        cache.clone_count = 0
        script._meepo_collect_cache = cache
        return result
    end
    for _, h in ipairs(heroes) do
        if is_meepo_instance(h) then
            local meepo_team = tonumber(safe_call(Entity.GetTeamNum, h) or -2) or -2
            if local_team < 0 or meepo_team == local_team then
                result[#result + 1] = h
                if NPC.IsMeepoClone and NPC.IsMeepoClone(h) then
                    clone_count = clone_count + 1
                end
            end
        end
    end
    cache.t = now_time
    cache.hero = local_hero
    cache.team = local_team
    cache.units = result
    cache.clone_count = clone_count
    script._meepo_collect_cache = cache
    return result
end
get_entity_key = function(entity)
    local idx = tonumber(safe_call(Entity.GetIndex, entity) or 0) or 0
    if idx > 0 then
        return idx
    end
    return entity
end
local get_earthbind_projectile_speed
function script.update_auto_save_hp_samples(meepos, now)
    if not meepos or #meepos == 0 then
        return
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local samples = script._auto_save_hp_sample_by_meepo or {}
    local seen = {}
    local drop_window = tonumber(C.AUTO_SAVE_RECENT_DROP_WINDOW or 1.20) or 1.20
    local drop_pct = tonumber(C.AUTO_SAVE_RECENT_DROP_PCT or 6) or 6
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local key = get_entity_key(meepo)
            if key then
                seen[key] = true
                local hp_pct = get_health_pct(meepo)
                local rec = samples[key]
                if not rec then
                    samples[key] = { hp = hp_pct, t = sample_now, drop_until = 0 }
                else
                    local prev_hp = tonumber(rec.hp or hp_pct) or hp_pct
                    local prev_t = tonumber(rec.t or sample_now) or sample_now
                    if sample_now >= prev_t then
                        local drop = prev_hp - hp_pct
                        if drop >= drop_pct then
                            rec.drop_until = sample_now + drop_window
                        end
                        rec.hp = hp_pct
                        rec.t = sample_now
                    end
                end
            end
        end
    end
    for key, rec in pairs(samples) do
        if (not seen[key]) then
            local rec_t = tonumber(rec and rec.t or -9999) or -9999
            if sample_now - rec_t > 4.0 then
                samples[key] = nil
            end
        end
    end
    script._auto_save_hp_sample_by_meepo = samples
end
local function should_trigger_save_by_enemy(npc, now)
    if not npc or not Entity.IsAlive(npc) then
        return false
    end
    local enemy_count = select(1, get_enemy_info(npc, C.AUTO_SAVE_ENEMY_RADIUS))
    if (enemy_count or 0) > 0 then
        return true
    end
    local hp_pct = get_health_pct(npc)
    if hp_pct <= (tonumber(C.AUTO_SAVE_EMERGENCY_HP_PCT or 12) or 12) then
        return true
    end
    local key = get_entity_key(npc)
    local samples = script._auto_save_hp_sample_by_meepo or {}
    local rec = key and samples[key] or nil
    if rec then
        local sample_now = tonumber(now or get_game_time() or 0) or 0
        local drop_until = tonumber(rec.drop_until or 0) or 0
        if drop_until > sample_now then
            return true
        end
    end
    return false
end
local function has_any_modifier(npc, modifier_names)
    if not npc or not modifier_names then
        return false
    end
    for i = 1, #modifier_names do
        if safe_call(NPC.HasModifier, npc, modifier_names[i]) then
            return true
        end
    end
    return false
end
can_cast_ability_for_npc = function(npc, ability)
    if not npc or not ability then
        return false
    end
    local mana = tonumber(safe_call(NPC.GetMana, npc) or 0) or 0
    local castable = safe_call(Ability.IsCastable, ability, mana)
    if castable ~= nil then
        return castable == true
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    local mc = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    return cd <= 0.05 and mana >= mc
end
local function find_ability_by_names(npc, ability_names)
    if not npc or not ability_names then
        return nil
    end
    for i = 1, #ability_names do
        local ability = safe_call(NPC.GetAbility, npc, ability_names[i])
        if ability then
            return ability
        end
    end
    return nil
end
is_item_enabled = function(item_name)
    if ui.items_important and ui.items_important.Get and item_name then
        local ok, enabled = pcall(function()
            return ui.items_important:Get(item_name)
        end)
        if ok then
            return enabled == true
        end
    end
    return true
end
local function get_blink_item(npc)
    if not npc then
        return nil
    end
    local blink = find_ability_by_names(npc, CFG.blink_item_candidates)
    if not blink and NPC.GetItem then
        for i = 1, #CFG.blink_item_candidates do
            blink = safe_call(NPC.GetItem, npc, CFG.blink_item_candidates[i], true)
            if blink then
                break
            end
        end
    end
    if not blink then
        return nil
    end
    local name = safe_call(Ability.GetName, blink)
    if name and name ~= "" and not is_item_enabled(name) then
        return nil
    end
    return blink
end
local function can_cast_dig(meepo)
    local dig = safe_call(NPC.GetAbility, meepo, C.ABILITY_DIG)
    if not dig then
        return false, nil
    end
    return can_cast_ability_for_npc(meepo, dig), dig
end
local function can_cast_mega(meepo)
    local mega = find_ability_by_names(meepo, C.ABILITY_MEGA_CANDIDATES)
    if not mega then
        return false, nil
    end
    return can_cast_ability_for_npc(meepo, mega), mega
end
function script.get_mega_save_range(mega, caster)
    if not mega then
        return 0
    end
    local best = 0
    local names = {
        "radius",
        "merge_radius",
        "pickup_radius",
        "search_radius",
        "ability_radius",
        "distance",
    }
    for i = 1, #names do
        local key = names[i]
        local value = 0
        if Ability.GetSpecialValueFor then
            value = tonumber(safe_call(Ability.GetSpecialValueFor, mega, key) or 0) or 0
        end
        if value <= 0 and Ability.GetLevelSpecialValueFor then
            value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, mega, key, -1) or 0) or 0
        end
        if value > best then
            best = value
        end
    end
    if best <= 0 then
        best = tonumber(safe_call(Ability.GetCastRange, mega) or 0) or 0
    end
    if best <= 0 then
        return 0
    end
    local bonus = tonumber(caster and safe_call(NPC.GetCastRangeBonus, caster) or 0) or 0
    if bonus > 0 and best > 0 then
        best = best + bonus
    end
    return best
end
function script.can_mega_save_target(caster, target, mega)
    if not caster or not target or not mega then
        return false, nil
    end
    if not Entity.IsAlive(caster) or not Entity.IsAlive(target) then
        return false, nil
    end
    if caster == target then
        return true, 0
    end
    local cast_range = script.get_mega_save_range(mega, caster)
    if cast_range <= 0 then
        return false, nil
    end
    local caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not caster_pos or not target_pos then
        return false, nil
    end
    local dist = vec_dist_2d(caster_pos, target_pos) or 99999
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    local allow = cast_range + target_hull + 20
    return dist <= allow, dist
end
local function get_lowest_hp_meepo(meepos)
    local lowest_meepo = nil
    local lowest_hp_pct = nil
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local hp_pct = get_health_pct(meepo)
            if not lowest_hp_pct or hp_pct < lowest_hp_pct then
                lowest_hp_pct = hp_pct
                lowest_meepo = meepo
            end
        end
    end
    return lowest_meepo, lowest_hp_pct
end
function script.get_combo_input_mode()
    if ui.combo_ground_key and ui.combo_ground_key.IsDown then
        local ok_ground, down_ground = pcall(function()
            return ui.combo_ground_key:IsDown()
        end)
        if ok_ground and down_ground then
            return true, "GROUND"
        end
    end
    if ui.combo_key and ui.combo_key.IsDown then
        local ok_combo, down_combo = pcall(function()
            return ui.combo_key:IsDown()
        end)
        if ok_combo and down_combo then
            return true, "NORMAL"
        end
    end
    if combo_bind and combo_bind.IsDown then
        local ok_bind, down_bind = pcall(function()
            return combo_bind:IsDown()
        end)
        if ok_bind and down_bind then
            return true, "NORMAL"
        end
    end
    return false, "NONE"
end
local function is_combo_key_down()
    local down = select(1, script.get_combo_input_mode())
    return down == true
end
local function is_combo_active()
    if not combo_runtime_enabled then
        return false
    end
    if not ui.combo_enabled or not ui.combo_enabled.Get or not ui.combo_enabled:Get() then
        return false
    end
    return is_combo_key_down()
end
local function get_combo_type_index()
    if ui.combo_type and ui.combo_type.Get then
        local ok, idx = pcall(function()
            return ui.combo_type:Get()
        end)
        if ok and idx ~= nil then
            return tonumber(idx) or COMBO_MODE_SELECTED
        end
    end
    return COMBO_MODE_SELECTED
end
function script.get_autofarm_farm_only_index()
    if ui.autofarm_farm_only and ui.autofarm_farm_only.Get then
        local ok, idx = pcall(function()
            return ui.autofarm_farm_only:Get()
        end)
        if ok and idx ~= nil then
            local value = tonumber(idx)
            if value then
                return value
            end
        end
    end
    return script._autofarm_mode.ALL
end
function script.is_autofarm_wave_split_enabled()
    if ui.autofarm_wave_split and ui.autofarm_wave_split.Get then
        local ok, enabled = pcall(function()
            return ui.autofarm_wave_split:Get()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end
    return true
end
local function is_combo_spell_enabled(spell_key, fallback_switch)
    if ui.combo_spells and ui.combo_spells.Get and spell_key then
        local ok, enabled = pcall(function()
            return ui.combo_spells:Get(spell_key)
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end
    if fallback_switch and fallback_switch.Get then
        local ok, enabled = pcall(function()
            return fallback_switch:Get()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end
    return false
end
local function get_selected_meepo(local_player)
    if not local_player then
        return nil
    end
    local selected_units = script._selected_units_frame_cached(local_player)
    if not selected_units then
        return nil
    end
    for i = 1, #selected_units do
        local unit = selected_units[i]
        if unit and is_meepo_instance(unit) and Entity.IsAlive(unit) then
            return unit
        end
    end
    return nil
end
function script.get_selected_meepo_key_set(local_player)
    local out = {}
    if not local_player then
        return out
    end
    local ctx = script._frame_context_get()
    if ctx.selected_player == local_player and ctx.selected_key_set ~= nil then
        return ctx.selected_key_set
    end
    local selected_units = script._selected_units_frame_cached(local_player, ctx.now)
    if not selected_units then
        return out
    end
    for i = 1, #selected_units do
        local unit = selected_units[i]
        if unit and is_meepo_instance(unit) and Entity.IsAlive(unit) then
            out[get_entity_key(unit)] = true
        end
    end
    ctx.selected_player = local_player
    ctx.selected_key_set = out
    return out
end
local function get_main_meepo(local_hero)
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(local_hero) or false
        if not is_clone then
            return local_hero
        end
    end
    local meepos = collect_meepos(local_hero)
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(meepo) or false
            if not is_clone then
                return meepo
            end
        end
    end
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        return local_hero
    end
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            return meepo
        end
    end
    return nil
end
local function get_combo_anchor_meepo(local_player, local_hero)
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_SELECTED then
        local selected_meepo = get_selected_meepo(local_player)
        if selected_meepo then
            return selected_meepo
        end
        if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
            return local_hero
        end
        return get_main_meepo(local_hero)
    end
    if mode == COMBO_MODE_ALL then
        return get_main_meepo(local_hero)
    end
    return get_main_meepo(local_hero)
end
function script.get_combo_main_priority_key(local_hero)
    if not script.is_combo_option_enabled(ui.combo_main_first) then
        return nil
    end
    local main_meepo = nil
    if get_combo_type_index() == COMBO_MODE_SELECTED then
        local local_player = safe_call(Players.GetLocal)
        local selected_meepo = get_selected_meepo(local_player)
        if selected_meepo and Entity.IsAlive(selected_meepo) then
            main_meepo = selected_meepo
        end
    end
    if not main_meepo then
        main_meepo = get_main_meepo(local_hero)
    end
    if not main_meepo or not Entity.IsAlive(main_meepo) then
        return nil
    end
    return get_entity_key(main_meepo)
end
function script.should_take_combo_candidate(candidate, dist, best, best_dist, preferred_key)
    if not candidate then
        return false
    end
    if not best then
        return true
    end
    if preferred_key then
        local candidate_is_preferred = get_entity_key(candidate) == preferred_key
        local best_is_preferred = get_entity_key(best) == preferred_key
        if candidate_is_preferred ~= best_is_preferred then
            return candidate_is_preferred
        end
    end
    if best_dist == nil then
        return true
    end
    if dist == nil then
        return false
    end
    return dist < best_dist
end
local function reset_combo_move_state()
    combo_move_next_order_time = 0
    combo_move_last_position = nil
    combo_move_last_frame = -1
    combo_last_selection_key = nil
    combo_net_last_global_cast = -9999
    combo_net_last_cast_by_meepo = {}
    script._combo_net_pending_target_key = nil
    script._combo_net_pending_end_time = 0
    script._combo_net_pending_arrival_time = 0
    script._combo_silence_last_global = -9999
    script._combo_silence_last_attempt_global = -9999
    script._combo_silence_last_attempt_frame = -1
    script._combo_silence_last_by_meepo = {}
    script._combo_silence_last_frame_by_meepo = {}
    script._combo_atos_last_global = -9999
    script._combo_atos_last_attempt_global = -9999
    script._combo_atos_last_attempt_frame = -1
    script._combo_atos_last_by_meepo = {}
    script._combo_atos_last_frame_by_meepo = {}
    script._combo_atos_pending_target_key = nil
    script._combo_atos_pending_end_time = 0
    script._combo_abyssal_last_global = -9999
    script._combo_abyssal_last_attempt_global = -9999
    script._combo_abyssal_last_attempt_frame = -1
    script._combo_abyssal_last_by_meepo = {}
    script._combo_abyssal_last_frame_by_meepo = {}
    script._combo_abyssal_pending_target_key = nil
    script._combo_abyssal_pending_end_time = 0
    script._combo_abyssal_recent_blink_until = 0
    script._combo_abyssal_recent_blink_target_key = nil
    script._combo_abyssal_recent_blink_caster_key = nil
    script._item_next_allowed_time = {}
    script._item_last_frame_by_meepo = {}
    script._item_frame_budget_consumed = 0
    combo_hex_last_cast = -9999
    script._combo_hex_last_attempt_global = -9999
    script._combo_hex_last_attempt_frame = -1
    script._combo_hex_last_frame_by_meepo = {}
    script._combo_purge_last_global = -9999
    script._combo_purge_last_target_key = nil
    script._combo_purge_last_attempt_global = -9999
    script._combo_purge_last_attempt_frame = -1
    script._combo_purge_last_by_meepo = {}
    combo_hex_last_cast_by_meepo = {}
    combo_poof_last_cast_by_meepo = {}
    combo_attack_next_order_time = 0
    script._combo_logic_next_tick = 0
    script._combo_hold_next_order_time = 0
    script._combo_action_next_order_time = 0
    combo_focus_target_key = nil
    script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    script._combo_state_target_key = nil
    script._combo_debug_phase = script.COMBO_PHASE_ABYSSAL
    script._combo_debug_reason = "idle"
    script._combo_debug_next_disable = ""
    script._combo_debug_last_non_active_emit = -9999
    script._combo_debug_last_emit = ""
    script._combo_last_net_follow_poof_count = 0
    script._combo_last_net_follow_poof_time = -9999
    script._combo_last_net_follow_poof_reason = ""
    script._combo_net_priority_until = 0
    script._combo_net_priority_target_key = nil
    script._combo_search_next_move_time = 0
    script._combo_search_last_position = nil
    script._combo_ground_next_net_time = 0
    script._combo_ground_last_cast_pos = nil
    script._combo_ground_last_cast_time = -9999
    if clear_poof_queue then
        clear_poof_queue()
    else
        poof_cast_queue = {}
        poof_queue_by_meepo = {}
    end
    script._combo_blink_scheduled_time = 0
    script._combo_blink_target = nil
    script._combo_blink_anchor = nil
    script._combo_blink_target_key = nil
    script._combo_blink_last_schedule = -9999
    script._combo_blink_poof_units = {}
    script._combo_blink_post_poof_delay = 0
    script._combo_blink_next_attempt = 0
    script._combo_blink_retry_deadline = 0
    script._combo_blink_last_cast_cmd = -9999
    script.clear_preblink_poof_state()
    script._combo_target_last_seen_time = -9999
    script._combo_engage_mode = "MID"
    script._combo_engage_distance = 0
    script._combo_engage_close_threshold = 0
    script._combo_engage_mid_threshold = 0
    script._combo_predicted_hp_left = 0
    script._combo_predicted_damage = 0
    -- TP-interrupt state is intentionally not reset here.
    -- reset_combo_move_state runs frequently when combo idles; clearing TP locks there
    -- causes repeated interrupt nets on the same teleport window.
    script._auto_save_hp_sample_by_meepo = {}
end
local function collect_combo_move_units(local_player, local_hero, meepos)
    local units = {}
    local seen = {}
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local function add_unit(unit)
        if not unit or not is_meepo_instance(unit) or not Entity.IsAlive(unit) then
            return
        end
        local unit_team = tonumber(safe_call(Entity.GetTeamNum, unit) or -2) or -2
        if local_team >= 0 and unit_team ~= local_team then
            return
        end
        local key = get_entity_key(unit)
        if seen[key] then
            return
        end
        seen[key] = true
        units[#units + 1] = unit
    end
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_SELECTED then
        local selected_units = nil
        if local_player and Player and Player.GetSelectedUnits then
            selected_units = safe_call(Player.GetSelectedUnits, local_player)
        end
        if selected_units then
            for i = 1, #selected_units do
                add_unit(selected_units[i])
            end
        end
    else
        for i = 1, #meepos do
            add_unit(meepos[i])
        end
    end
    if #units == 0 and mode ~= COMBO_MODE_SELECTED then
        add_unit(get_combo_anchor_meepo(local_player, local_hero))
    end
    return units
end
local function collect_owned_meepo_units(local_hero, meepos)
    local units = {}
    if not meepos then
        return units
    end
    local seen = {}
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and is_meepo_instance(meepo) and Entity.IsAlive(meepo) then
            local team = tonumber(safe_call(Entity.GetTeamNum, meepo) or -2) or -2
            if local_team < 0 or team == local_team then
                local key = get_entity_key(meepo)
                if not seen[key] then
                    seen[key] = true
                    units[#units + 1] = meepo
                end
            end
        end
    end
    return units
end
function script.is_unit_in_units_list(unit, units)
    if not unit or not units then
        return false
    end
    for i = 1, #units do
        if units[i] == unit then
            return true
        end
    end
    return false
end
function script.pick_first_alive_unit(units)
    if not units then
        return nil
    end
    for i = 1, #units do
        local unit = units[i]
        if unit and Entity.IsAlive(unit) then
            return unit
        end
    end
    return nil
end
local function build_units_key(units)
    if not units or #units == 0 then
        return ""
    end
    local ids = {}
    for i = 1, #units do
        local unit = units[i]
        local idx = tonumber(safe_call(Entity.GetIndex, unit) or 0) or 0
        if idx > 0 then
            ids[#ids + 1] = idx
        end
    end
    table.sort(ids)
    return table.concat(ids, ",")
end
local function ensure_combo_units_selected(player, units)
    if not player or not units or #units == 0 or not Player then
        return false
    end
    if not Player.GetSelectedUnits or not Player.ClearSelectedUnits or not Player.AddSelectedUnit then
        return false
    end
    local key = build_units_key(units)
    if key == "" then
        return false
    end
    local current = safe_call(Player.GetSelectedUnits, player)
    if current and build_units_key(current) == key then
        combo_last_selection_key = key
        return true
    end
    local cleared = pcall(function()
        Player.ClearSelectedUnits(player)
    end)
    if not cleared then
        return false
    end
    local added_any = false
    for i = 1, #units do
        local unit = units[i]
        if unit and Entity.IsAlive(unit) then
            local ok = pcall(function()
                Player.AddSelectedUnit(player, unit)
            end)
            if ok then
                added_any = true
            end
        end
    end
    if added_any then
        combo_last_selection_key = key
    end
    return added_any
end
local function issue_combo_move_order(player, units, position, now)
    if not player or not units or #units == 0 or not position then
        return false
    end
    local frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if frame >= 0 and frame == combo_move_last_frame then
        return false
    end
    if now < combo_move_next_order_time then
        return false
    end
    if combo_move_last_position then
        local delta = vec_dist_2d(combo_move_last_position, position) or 0
        if delta < C.COMBO_MOVE_MIN_DELTA then
            return false
        end
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not order_type or not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local issued_any = false
    for i = 1, #units do
        local unit = units[i]
        if unit and Entity.IsAlive(unit) and not is_combo_cast_in_progress(unit) then
            local ok = pcall(function()
                Player.PrepareUnitOrders(
                    player,
                    order_type,
                    nil,
                    position,
                    nil,
                    issuer_type,
                    unit,
                    false,
                    true,
                    true,
                    false,
                    "meepo_combo_group_click",
                    false
                )
            end)
            if ok then
                issued_any = true
            end
        end
    end
    if issued_any then
        combo_move_next_order_time = now + C.COMBO_MOVE_ORDER_INTERVAL
        combo_move_last_position = Vector(position.x or 0, position.y or 0, position.z or 0)
        combo_move_last_frame = frame
    end
    return issued_any
end
local function get_modifier_remaining_time(modifier, now)
    if not modifier then
        return 0
    end
    local die_time = tonumber(safe_call(Modifier.GetDieTime, modifier) or 0) or 0
    if die_time > 0 then
        local remaining = die_time - now
        if remaining > 0 then
            return remaining
        end
    end
    local last_applied = tonumber(safe_call(Modifier.GetLastAppliedTime, modifier) or 0) or 0
    local duration = tonumber(safe_call(Modifier.GetDuration, modifier) or 0) or 0
    if last_applied > 0 and duration > 0 then
        local remaining = (last_applied + duration) - now
        if remaining > 0 then
            return remaining
        end
    end
    return 0
end
local function get_target_earthbind_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    for i = 1, #C.MODIFIER_NET_CANDIDATES do
        local mod = safe_call(NPC.GetModifier, target, C.MODIFIER_NET_CANDIDATES[i])
        local remaining = get_modifier_remaining_time(mod, now)
        if remaining > best_remaining then
            best_remaining = remaining
        end
    end
    if best_remaining > 0 then
        return best_remaining
    end
    if NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, "earthbind", 1, true) then
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    return best_remaining
end
function script.get_target_modifier_remaining(target, names, now, keyword)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    if names then
        for i = 1, #names do
            local mod = safe_call(NPC.GetModifier, target, names[i])
            local remaining = get_modifier_remaining_time(mod, now)
            if remaining > best_remaining then
                best_remaining = remaining
            end
        end
    end
    if best_remaining > 0 then
        return best_remaining
    end
    if keyword and NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, keyword, 1, true) then
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    return best_remaining
end
function script.get_item_special_value(item, key_primary, key_alt, fallback)
    local value = 0
    if item and Ability.GetSpecialValueFor then
        if key_primary and key_primary ~= "" then
            value = tonumber(safe_call(Ability.GetSpecialValueFor, item, key_primary) or 0) or 0
        end
        if value <= 0 and key_alt and key_alt ~= "" then
            value = tonumber(safe_call(Ability.GetSpecialValueFor, item, key_alt) or 0) or 0
        end
    end
    if value <= 0 and item and Ability.GetLevelSpecialValueFor then
        if key_primary and key_primary ~= "" then
            value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, item, key_primary, -1) or 0) or 0
        end
        if value <= 0 and key_alt and key_alt ~= "" then
            value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, item, key_alt, -1) or 0) or 0
        end
    end
    if value <= 0 then
        return tonumber(fallback or 0) or 0
    end
    return value
end
function script.get_enabled_item_by_names(npc, names)
    if not npc or not names or not NPC.GetItem then
        return nil
    end
    for i = 1, #names do
        local name = names[i]
        if name and is_item_enabled(name) then
            local item = safe_call(NPC.GetItem, npc, name, true)
            if item then
                return item
            end
        end
    end
    return nil
end
function script.can_cast_target_item_now(npc, item)
    if not npc or not item then
        return false
    end
    local name = safe_call(Ability.GetName, item) or ""
    if name ~= "" and not is_item_enabled(name) then
        return false
    end
    if not can_cast_ability_for_npc(npc, item) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, item)
    if in_phase == true then
        return false
    end
    return true
end
function script.get_item_cast_range(item, fallback)
    local cast_range = tonumber(safe_call(Ability.GetCastRange, item) or 0) or 0
    if cast_range <= 0 then
        cast_range = tonumber(fallback or 0) or 0
    end
    return cast_range
end
function script.get_item_cast_range_for_npc(npc, item, fallback)
    local cast_range = script.get_item_cast_range(item, fallback)
    if cast_range <= 0 then
        cast_range = tonumber(fallback or 0) or 0
    end
    local bonus = tonumber(safe_call(NPC.GetCastRangeBonus, npc) or 0) or 0
    if bonus > 0 then
        cast_range = cast_range + bonus
    end
    return cast_range
end
function script.get_target_hex_remaining(target, now)
    return script.get_target_modifier_remaining(target, script._combo_modifier_sets.hex, now, "sheep")
end
function script.get_target_silence_remaining(target, now)
    return script.get_target_modifier_remaining(target, script._combo_modifier_sets.silence, now, "orchid")
end
function script.get_target_atos_remaining(target, now)
    local remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.atos, now, "atos")
    if not target then
        return remaining
    end
    local target_key = get_entity_key(target)
    if target_key and script._combo_atos_pending_target_key == target_key then
        local pending = script._combo_atos_pending_end_time - now
        if pending > remaining then
            remaining = pending
        end
        if pending <= 0 then
            script._combo_atos_pending_target_key = nil
            script._combo_atos_pending_end_time = 0
        end
    end
    return remaining
end
function script.get_target_abyssal_remaining(target, now)
    local remaining = 0
    if target then
        local modifier_remaining = script.get_target_modifier_remaining(target, nil, now, "abyssal")
        if modifier_remaining > remaining then
            remaining = modifier_remaining
        end
        local bash_remaining = script.get_target_modifier_remaining(target, nil, now, "bash")
        if bash_remaining > remaining then
            remaining = bash_remaining
        end
        local target_key = get_entity_key(target)
        if target_key and script._combo_abyssal_pending_target_key == target_key then
            local pending = script._combo_abyssal_pending_end_time - now
            if pending > remaining then
                remaining = pending
            end
            if pending <= 0 then
                script._combo_abyssal_pending_target_key = nil
                script._combo_abyssal_pending_end_time = 0
            end
        end
    end
    return remaining
end
get_earthbind_projectile_speed = function(ability)
    if not ability then
        return C.COMBO_NET_PROJECTILE_SPEED_FALLBACK
    end
    local speed = 0
    if Ability.GetSpecialValueFor then
        speed = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "speed") or 0) or 0
        if speed <= 0 then
            speed = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "projectile_speed") or 0) or 0
        end
    end
    if speed <= 0 and Ability.GetLevelSpecialValueFor then
        speed = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "speed", -1) or 0) or 0
        if speed <= 0 then
            speed = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "projectile_speed", -1) or 0) or 0
        end
    end
    if speed <= 0 then
        speed = C.COMBO_NET_PROJECTILE_SPEED_FALLBACK
    end
    return speed
end
function script.get_earthbind_root_duration(ability)
    if not ability then
        return 2.0
    end
    local duration = 0
    if Ability.GetSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "duration") or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetSpecialValueFor, ability, "ensnare_duration") or 0) or 0
        end
    end
    if duration <= 0 and Ability.GetLevelSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "duration", -1) or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, "ensnare_duration", -1) or 0) or 0
        end
    end
    if duration <= 0 then
        duration = 2.0
    end
    return duration
end
local function get_net_cast_range(caster, ability)
    local cast_range = tonumber(safe_call(Ability.GetCastRange, ability) or 0) or 0
    if cast_range <= 0 then
        cast_range = 700
    end
    local bonus = tonumber(safe_call(NPC.GetCastRangeBonus, caster) or 0) or 0
    if bonus > 0 then
        cast_range = cast_range + bonus
    end
    return cast_range
end
function script.get_simple_net_position(caster, target, net, now)
    if not caster or not target or not net then
        return nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return nil
    end
    if not Entity.IsAlive(target) then
        return target_pos
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    if get_target_earthbind_remaining(target, sample_now) > 0 then
        return target_pos
    end
    if NPC.IsStunned and safe_call(NPC.IsStunned, target) == true then
        return target_pos
    end
    if NPC.IsRunning and safe_call(NPC.IsRunning, target) ~= true then
        return target_pos
    end
    if NPC.IsTurning and safe_call(NPC.IsTurning, target) == true then
        return target_pos
    end
    local rot = safe_call(Entity.GetRotation, target)
    if not rot or not rot.GetForward then
        return target_pos
    end
    local forward = rot:GetForward()
    if not forward then
        return target_pos
    end
    forward = forward:Normalized()
    local move_speed = tonumber(safe_call(NPC.GetMoveSpeed, target) or 0) or 0
    if move_speed <= 0 then
        return target_pos
    end
    local caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    if not caster_pos then
        return target_pos
    end
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local speed = get_earthbind_projectile_speed(net)
    local function build_predicted(base_pos)
        local dist = vec_dist_2d(caster_pos, base_pos) or 0
        local face_time = tonumber(safe_call(NPC.GetTimeToFacePosition, caster, base_pos) or 0) or 0
        face_time = math.max(0, math.min(C.COMBO_NET_FACE_TIME_CAP, face_time))
        local travel_time = face_time + cast_point + (dist / math.max(1, speed))
        travel_time = math.max(0, math.min(0.80, travel_time))
        local lead_x = (forward.x or 0) * move_speed * travel_time
        local lead_y = (forward.y or 0) * move_speed * travel_time
        local lead_len = math.sqrt((lead_x * lead_x) + (lead_y * lead_y))
        if lead_len > 340 and lead_len > 0 then
            local scale = 340 / lead_len
            lead_x = lead_x * scale
            lead_y = lead_y * scale
        end
        return Vector(
            (target_pos.x or 0) + lead_x,
            (target_pos.y or 0) + lead_y,
            target_pos.z or 0
        )
    end
    local pass1 = build_predicted(target_pos)
    if not pass1 then
        return target_pos
    end
    return build_predicted(pass1) or pass1
end
local function get_effective_earthbind_remaining(target, now)
    local remaining = get_target_earthbind_remaining(target, now)
    if not target then
        return remaining
    end
    local target_key = get_entity_key(target)
    if target_key and script._combo_net_pending_target_key == target_key then
        local pending = script._combo_net_pending_end_time - now
        local pending_arrival = tonumber(script._combo_net_pending_arrival_time or 0) or 0
        local pending_still_valid = true
        if pending_arrival > 0 and now > (pending_arrival + C.COMBO_NET_PENDING_CONFIRM_GRACE) then
            if remaining <= 0.01 then
                pending_still_valid = false
            end
        end
        if pending_still_valid and pending > remaining then
            remaining = pending
        end
        if (not pending_still_valid) or pending <= 0 then
            script._combo_net_pending_target_key = nil
            script._combo_net_pending_end_time = 0
            script._combo_net_pending_arrival_time = 0
        end
    end
    local atos_remaining = script.get_target_atos_remaining(target, now)
    if atos_remaining > remaining then
        remaining = atos_remaining
    end
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > remaining then
        remaining = abyssal_remaining
    end
    return remaining
end
local function get_confirmed_control_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local remaining = get_target_earthbind_remaining(target, now)
    local hex_remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.hex, now, "hex")
    if hex_remaining > remaining then
        remaining = hex_remaining
    end
    local atos_remaining = script.get_target_modifier_remaining(target, script._combo_modifier_sets.atos, now, "atos")
    if atos_remaining > remaining then
        remaining = atos_remaining
    end
    local abyssal_remaining = script.get_target_modifier_remaining(target, nil, now, "abyssal")
    if abyssal_remaining > remaining then
        remaining = abyssal_remaining
    end
    local bash_remaining = script.get_target_modifier_remaining(target, nil, now, "bash")
    if bash_remaining > remaining then
        remaining = bash_remaining
    end
    return remaining
end
local function is_net_projectile_in_flight(target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local target_key = get_entity_key(target)
    if not target_key or script._combo_net_pending_target_key ~= target_key then
        return false
    end
    local pending_end = tonumber(script._combo_net_pending_end_time or 0) or 0
    if pending_end <= now then
        script._combo_net_pending_target_key = nil
        script._combo_net_pending_end_time = 0
        script._combo_net_pending_arrival_time = 0
        return false
    end
    local arrival = tonumber(script._combo_net_pending_arrival_time or 0) or 0
    return arrival > now
end
function script.get_modifier_state_enum(state_name)
    if not Enum or not Enum.ModifierState then
        return nil
    end
    return Enum.ModifierState[state_name]
end
function script.has_modifier_state(npc, state_name)
    local state = script.get_modifier_state_enum(state_name)
    if not npc or not state or not NPC.HasState then
        return false
    end
    return safe_call(NPC.HasState, npc, state) == true
end
function script.get_control_break_reason(target, single_target)
    if not script.is_combo_option_enabled(ui.combo_control_break_checks) then
        return nil
    end
    if not target or not Entity.IsAlive(target) then
        return "invalid_target"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_INVULNERABLE") then
        return "invulnerable"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_UNTARGETABLE")
        or script.has_modifier_state(target, "MODIFIER_STATE_UNTARGETABLE_ENEMY") then
        return "untargetable"
    end
    if script.has_modifier_state(target, "MODIFIER_STATE_MAGIC_IMMUNE")
        or script.has_modifier_state(target, "MODIFIER_STATE_DEBUFF_IMMUNE") then
        return "debuff_immune"
    end
    if single_target then
        if script.is_target_linkens_protected(target) then
            return "linkens"
        end
        if safe_call(NPC.HasModifier, target, "modifier_item_lotus_orb_active") == true then
            return "lotus"
        end
    end
    return nil
end
function script.set_combo_debug_state(phase, reason, next_disable)
    local now = 0
    if GameRules and GameRules.GetGameTime then
        now = tonumber(safe_call(GameRules.GetGameTime)) or 0
    end
    script._combo_debug_last_phase = script._combo_debug_last_phase or ""
    script._combo_debug_last_reason = script._combo_debug_last_reason or ""
    script._combo_debug_last_change = script._combo_debug_last_change or -9999
    script._combo_debug_last_non_active_emit = script._combo_debug_last_non_active_emit or -9999
    script._combo_debug_last_emit_time = script._combo_debug_last_emit_time or -9999
    local incoming_phase = script._combo_debug_phase
    local incoming_reason = script._combo_debug_reason
    local incoming_next_disable = script._combo_debug_next_disable
    if phase and phase ~= "" then
        incoming_phase = phase
    end
    if reason and reason ~= "" then
        incoming_reason = reason
    end
    if next_disable ~= nil then
        incoming_next_disable = next_disable
    end
    if incoming_reason == "active" then
        local phase_changed = incoming_phase ~= script._combo_debug_last_phase
        local since_non_active = now - (tonumber(script._combo_debug_last_non_active_emit or -9999) or -9999)
        if (not phase_changed) and since_non_active < 0.30 then
            return
        end
    end
    local changed = (incoming_phase ~= script._combo_debug_last_phase)
        or (incoming_reason ~= script._combo_debug_last_reason)
        or (incoming_next_disable ~= script._combo_debug_next_disable)
    if changed then
        script._combo_debug_phase = incoming_phase
        script._combo_debug_reason = incoming_reason
        script._combo_debug_next_disable = incoming_next_disable
        script._combo_debug_last_phase = incoming_phase
        script._combo_debug_last_reason = incoming_reason
        script._combo_debug_last_change = now
        if incoming_reason ~= "active" then
            script._combo_debug_last_non_active_emit = now
        end
    end
    if not changed then
        return
    end
    if not script.is_combo_option_enabled(ui.combo_debug) then
        return
    end
    local emit_gap = tonumber(C and C.COMBO_DEBUG_LOG_MIN_GAP or 0.12) or 0.12
    if (now - (tonumber(script._combo_debug_last_emit_time or -9999) or -9999)) < emit_gap then
        return
    end
    local line = tostring(script._combo_debug_phase) .. " | " .. tostring(script._combo_debug_reason) .. " | " .. tostring(script._combo_debug_next_disable or "")
    if line ~= script._combo_debug_last_emit then
        script._combo_debug_last_emit = line
        script._combo_debug_last_emit_time = now
        script._dbg("combo_state", line)
    end
end
function script.resolve_combo_state_phase(target_key, has_abyssal_item, abyssal_ready, abyssal_remaining, hex_ready_anywhere, hex_remaining, net_enabled, net_actionable, now)
    if not target_key or target_key ~= script._combo_state_target_key then
        script._combo_state_target_key = target_key
        script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    end
    local net_ok = net_enabled and net_actionable == true
    local hex_active = hex_remaining and hex_remaining > 0
    local prefer_hex_open = hex_ready_anywhere and not has_abyssal_item
    local lock_now = tonumber(now or 0) or 0
    local net_priority_lock =
        net_enabled
        and target_key ~= nil
        and script._combo_net_priority_target_key == target_key
        and (tonumber(script._combo_net_priority_until or 0) or 0) > lock_now
    if not script.is_combo_option_enabled(ui.combo_state_machine) then
        if has_abyssal_item and (abyssal_ready or abyssal_remaining > 0.08) then
            script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
        elseif net_priority_lock then
            script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
        elseif prefer_hex_open or (hex_active and not net_ok) then
            script._combo_state_phase = script.COMBO_PHASE_HEX
        elseif net_ok then
            script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
        else
            script._combo_state_phase = script.COMBO_PHASE_POOF_ATTACK
        end
        return script._combo_state_phase
    end
    if has_abyssal_item and (abyssal_ready or abyssal_remaining > 0.08) then
        script._combo_state_phase = script.COMBO_PHASE_ABYSSAL
    elseif net_priority_lock then
        script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
    elseif prefer_hex_open or (hex_active and not net_ok) then
        script._combo_state_phase = script.COMBO_PHASE_HEX
    elseif net_ok then
        script._combo_state_phase = script.COMBO_PHASE_NET_CHAIN
    else
        script._combo_state_phase = script.COMBO_PHASE_POOF_ATTACK
    end
    return script._combo_state_phase
end
local function get_poof_channel_duration(poof)
    if not poof then
        return C.COMBO_POOF_CHANNEL_FALLBACK
    end
    local duration = 0
    if Ability.GetLevelSpecialValueFor then
        duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "teleport_duration", -1) or 0) or 0
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "poof_duration", -1) or 0) or 0
        end
        if duration <= 0 then
            duration = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "channel_time", -1) or 0) or 0
        end
    end
    if duration <= 0 then
        duration = C.COMBO_POOF_CHANNEL_FALLBACK
    end
    return duration
end
local function get_poof_damage_radius(poof)
    if not poof then
        return C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    local radius = 0
    if Ability.GetLevelSpecialValueFor then
        radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "radius", -1) or 0) or 0
        if radius <= 0 then
            radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "poof_radius", -1) or 0) or 0
        end
        if radius <= 0 then
            radius = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "damage_radius", -1) or 0) or 0
        end
    end
    if radius <= 0 then
        radius = C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    return radius
end
local function get_allowed_poof_anchor_distance(max_radius)
    local radius = max_radius
    if not radius or radius <= 0 then
        radius = C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK
    end
    local pad = tonumber(C.COMBO_POOF_DAMAGE_RADIUS_PAD or 0) or 0
    local base_allowed = radius + pad
    if base_allowed < 80 then
        base_allowed = 80
    end
    local ratio = tonumber(C.COMBO_POOF_ANCHOR_DISTANCE_RATIO or 0.50) or 0.50
    if ratio < 0.10 then
        ratio = 0.10
    elseif ratio > 1.00 then
        ratio = 1.00
    end
    local tight_allowed = radius * ratio
    local cap = tonumber(C.COMBO_POOF_ANCHOR_DISTANCE_CAP or 0) or 0
    if cap > 0 and tight_allowed > cap then
        tight_allowed = cap
    end
    local min_allowed = tonumber(C.COMBO_POOF_ANCHOR_DISTANCE_MIN or 0) or 0
    if min_allowed > 0 and tight_allowed < min_allowed then
        tight_allowed = min_allowed
    end
    local allowed = math.min(base_allowed, tight_allowed)
    if allowed < 80 then
        allowed = 80
    end
    return allowed
end
function script.get_poof_anchor_damage_distance(max_radius, target)
    local radius = max_radius
    if not radius or radius <= 0 then
        radius = tonumber(C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK or 375) or 375
    end
    local pad = tonumber(C.COMBO_POOF_DAMAGE_RADIUS_PAD or 0) or 0
    local allowed = radius + pad
    local hull = tonumber(target and safe_call(NPC.GetHullRadius, target) or 0) or 0
    if hull > 0 then
        allowed = allowed + hull
    end
    if allowed < 120 then
        allowed = 120
    end
    return allowed
end
function script.resolve_combo_engage_mode(local_hero, target)
    local mode = "MID"
    local close_threshold = get_allowed_poof_anchor_distance(C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK) + (tonumber(C.COMBO_ENGAGE_CLOSE_PAD or 70) or 70)
    local mid_threshold = close_threshold + (tonumber(C.COMBO_ENGAGE_MID_EXTRA or 420) or 420)
    local distance = nil
    if target and Entity.IsAlive(target) then
        local anchor = nil
        if get_combo_type_index() == COMBO_MODE_SELECTED then
            if combo_focus_source and Entity.IsAlive(combo_focus_source) then
                anchor = combo_focus_source
            else
                local local_player = safe_call(Players.GetLocal)
                local selected_anchor = get_selected_meepo(local_player)
                if selected_anchor and Entity.IsAlive(selected_anchor) then
                    anchor = selected_anchor
                end
            end
        end
        if (not anchor) or (not Entity.IsAlive(anchor)) then
            anchor = get_main_meepo(local_hero)
        end
        if (not anchor) or (not Entity.IsAlive(anchor)) then
            anchor = combo_focus_source
        end
        if anchor and Entity.IsAlive(anchor) then
            local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
            local target_pos = safe_call(Entity.GetAbsOrigin, target)
            distance = vec_dist_2d(anchor_pos, target_pos)
            local blink = get_blink_item(anchor)
            if blink then
                local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
                if blink_range > 0 then
                    local blink_threshold = blink_range + (tonumber(C.COMBO_ENGAGE_MID_PAD or 120) or 120)
                    if blink_threshold > mid_threshold then
                        mid_threshold = blink_threshold
                    end
                end
            end
        end
    end
    if distance ~= nil then
        if distance <= close_threshold then
            mode = "CLOSE"
        elseif distance > mid_threshold then
            mode = "FAR"
        else
            mode = "MID"
        end
    end
    return mode, tonumber(distance or 0) or 0, close_threshold, mid_threshold
end
function script.get_poof_damage_amount(poof)
    if not poof then
        return 0
    end
    local damage = 0
    if Ability.GetLevelSpecialValueFor then
        damage = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "poof_damage", -1) or 0) or 0
        if damage <= 0 then
            damage = tonumber(safe_call(Ability.GetLevelSpecialValueFor, poof, "damage", -1) or 0) or 0
        end
    end
    if damage <= 0 then
        local level = tonumber(safe_call(Ability.GetLevel, poof) or 0) or 0
        if level > 0 then
            damage = 70 + (40 * (level - 1))
        end
    end
    if damage < 0 then
        damage = 0
    end
    return damage
end
function script.get_magic_damage_multiplier(target)
    if not target or not Entity.IsAlive(target) then
        return 1.0
    end
    local mult = tonumber(safe_call(NPC.GetMagicalArmorDamageMultiplier, target) or 0) or 0
    if mult > 0 and mult <= 2.5 then
        return mult
    end
    local resist = tonumber(
        safe_call(NPC.GetMagicalArmorValue, target)
            or safe_call(NPC.GetMagicalResist, target)
            or 25
    ) or 25
    if resist > 1.5 then
        resist = resist / 100.0
    end
    if resist < -0.95 then
        resist = -0.95
    elseif resist > 0.95 then
        resist = 0.95
    end
    return 1.0 - resist
end
function script.get_physical_damage_multiplier(target)
    if not target or not Entity.IsAlive(target) then
        return 1.0
    end
    local armor = tonumber(
        safe_call(NPC.GetArmor, target)
            or safe_call(NPC.GetPhysicalArmorValue, target)
            or 0
    ) or 0
    local reduction = (0.06 * armor) / (1 + 0.06 * math.abs(armor))
    local mult = 1.0 - reduction
    if mult < 0.05 then
        mult = 0.05
    elseif mult > 3.0 then
        mult = 3.0
    end
    return mult
end
function script.get_meepo_attack_damage_estimate(meepo)
    if not meepo or not Entity.IsAlive(meepo) then
        return 0
    end
    local min_dmg = tonumber(safe_call(NPC.GetDamageMin, meepo) or 0) or 0
    local max_dmg = tonumber(safe_call(NPC.GetDamageMax, meepo) or 0) or 0
    local value = 0
    if min_dmg > 0 and max_dmg > 0 then
        value = (min_dmg + max_dmg) * 0.5
    end
    if value <= 0 then
        value = tonumber(safe_call(NPC.GetTrueDamage, meepo) or safe_call(NPC.GetDamage, meepo) or 0) or 0
    end
    if value < 0 then
        value = 0
    end
    return value
end
function script.estimate_combo_hp_after_full(local_hero, target, units, now, engage_mode)
    if not target or not Entity.IsAlive(target) then
        return nil
    end
    local target_hp = tonumber(safe_call(Entity.GetHealth, target) or 0) or 0
    local target_max_hp = tonumber(safe_call(Entity.GetMaxHealth, target) or 0) or 0
    if target_hp <= 0 then
        return nil
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local mode = tostring(engage_mode or script._combo_engage_mode or "MID")
    local magic_mult = script.get_magic_damage_multiplier(target)
    local phys_mult = script.get_physical_damage_multiplier(target)
    if not units or #units == 0 then
        units = collect_owned_meepo_units(local_hero, collect_meepos())
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    local control_now = math.max(
        get_effective_earthbind_remaining(target, sample_now),
        get_confirmed_control_remaining(target, sample_now)
    )
    local control_start_delay = 0
    local control_window = math.max(0, control_now)
    local chain_nets_used = 0
    local net_windows = {}
    if target_pos and units and #units > 0 then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
                if net and can_cast_ability_for_npc(meepo, net) and safe_call(Ability.IsInAbilityPhase, net) ~= true then
                    local meepo_key = get_entity_key(meepo)
                    local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                    if sample_now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY then
                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                        local cast_pos = script.get_simple_net_position(meepo, target, net, sample_now) or target_pos
                        local dist = vec_dist_2d(meepo_pos, cast_pos)
                        local cast_range = get_net_cast_range(meepo, net) + C.COMBO_NET_RANGE_PADDING
                        if dist and dist <= cast_range then
                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                            if cast_point < 0 then
                                cast_point = 0
                            end
                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                            if turn_time < 0 then
                                turn_time = 0
                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                            end
                            local speed = get_earthbind_projectile_speed(net)
                            local arrival_delay = turn_time + cast_point + (dist / math.max(1, speed))
                            local root_duration = script.get_earthbind_root_duration(net)
                            if arrival_delay >= 0 and root_duration > 0 then
                                net_windows[#net_windows + 1] = { arrival = arrival_delay, duration = root_duration }
                            end
                        end
                    end
                end
            end
        end
    end
    if #net_windows > 0 then
        table.sort(net_windows, function(a, b)
            return (a.arrival or 0) < (b.arrival or 0)
        end)
        local open_delay_limit = tonumber(C.COMBO_PRED_MAX_OPEN_DELAY or 1.45) or 1.45
        local max_chain_nets = tonumber(C.COMBO_PRED_MAX_CHAIN_NETS or 4) or 4
        if max_chain_nets < 1 then
            max_chain_nets = 1
        end
        local chain_buffer = tonumber(C.COMBO_NET_CHAIN_BUFFER or 0.16) or 0.16
        local handoff_extra = tonumber(C.COMBO_NET_HANDOFF_EXTRA or 0.18) or 0.18
        local start_index = 1
        local chain_end = control_window
        if chain_end <= 0 then
            local first = net_windows[1]
            if first and (first.arrival or 99) <= open_delay_limit then
                control_start_delay = math.max(0, first.arrival or 0)
                chain_end = control_start_delay + math.max(0, first.duration or 0)
                chain_nets_used = 1
                start_index = 2
            end
        end
        if chain_end > control_start_delay then
            for i = start_index, #net_windows do
                if chain_nets_used >= max_chain_nets then
                    break
                end
                local slot = net_windows[i]
                local land = tonumber(slot and slot.arrival or 0) or 0
                local duration = tonumber(slot and slot.duration or 0) or 0
                if duration > 0 and land <= (chain_end + chain_buffer + handoff_extra) then
                    local extended_end = land + duration
                    if extended_end > chain_end then
                        chain_end = extended_end
                    end
                    chain_nets_used = chain_nets_used + 1
                end
            end
            control_window = math.max(0, chain_end - control_start_delay)
        end
    end
    local max_control_window = tonumber(C.COMBO_PRED_MAX_CONTROL_WINDOW or 7.0) or 7.0
    if control_window > max_control_window then
        control_window = max_control_window
    end
    local poof_raw = 0
    local poof_count = 0
    local max_poof_radius = 0
    local max_poof_channel = 0
    if control_window > 0 then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                if poof and tonumber(safe_call(Ability.GetLevel, poof) or 0) > 0 then
                    local poof_ready = can_cast_ability_for_npc(meepo, poof)
                        and safe_call(Ability.IsInAbilityPhase, poof) ~= true
                        and safe_call(Ability.IsChannelling, poof) ~= true
                    if poof_ready then
                        local poof_damage = script.get_poof_damage_amount(poof)
                        if poof_damage > 0 then
                            poof_raw = poof_raw + poof_damage
                            poof_count = poof_count + 1
                            local radius = get_poof_damage_radius(poof)
                            if radius > max_poof_radius then
                                max_poof_radius = radius
                            end
                            local channel = get_poof_channel_duration(poof)
                            if channel > max_poof_channel then
                                max_poof_channel = channel
                            end
                        end
                    end
                end
            end
        end
    end
    if poof_count > 0 and target_pos then
        local required_root = max_poof_channel
            + (tonumber(C.COMBO_POOF_STAGGER or 0.04) or 0.04) * math.max(0, poof_count - 1)
            + (tonumber(C.COMBO_POOF_SAFE_ROOT_BUFFER or 0.06) or 0.06)
        local root_min = tonumber(C.COMBO_POOF_ROOT_MIN_REMAINING or 0.30) or 0.30
        if required_root < root_min then
            required_root = root_min
        end
        local anchor_ok = false
        if control_window >= required_root then
            local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_poof_radius, target)
            local poof_setup = control_start_delay + math.min(
                control_window,
                tonumber(C.COMBO_PRED_POOF_SETUP_TIME or 0.40) or 0.40
            )
            for i = 1, #units do
                local meepo = units[i]
                if meepo and Entity.IsAlive(meepo) then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local move_speed = tonumber(safe_call(NPC.GetMoveSpeed, meepo) or 0) or 0
                        if move_speed < 250 then
                            move_speed = 250
                        end
                        local reachable = allowed_anchor_dist + (move_speed * poof_setup)
                        if dist <= reachable then
                            anchor_ok = true
                            break
                        end
                    end
                end
            end
        end
        if not anchor_ok then
            poof_raw = 0
            poof_count = 0
        end
    else
        poof_raw = 0
        poof_count = 0
    end
    local attack_raw = 0
    local attack_hits = 0
    if control_window > 0 and target_pos then
        local interval_fallback = tonumber(C.COMBO_PRED_ATTACK_INTERVAL_FALLBACK or 1.55) or 1.55
        local first_hit_windup = tonumber(C.COMBO_PRED_FIRST_HIT_WINDUP or 0.20) or 0.20
        local max_hits_per_meepo = tonumber(C.COMBO_PRED_MAX_ATTACK_HITS_PER_MEEPO or 4) or 4
        if mode == "FAR" and max_hits_per_meepo > 2 then
            max_hits_per_meepo = 2
        end
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local attack_dmg = script.get_meepo_attack_damage_estimate(meepo)
                if attack_dmg > 0 then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    local attack_range = tonumber(safe_call(NPC.GetAttackRange, meepo) or 0) or 0
                    local attack_bonus = tonumber(safe_call(NPC.GetAttackRangeBonus, meepo) or 0) or 0
                    local meepo_hull = tonumber(safe_call(NPC.GetHullRadius, meepo) or 0) or 0
                    local reach = attack_range + attack_bonus + meepo_hull + target_hull + 30
                    local approach_time = 0
                    if dist and dist > reach then
                        local move_speed = tonumber(safe_call(NPC.GetMoveSpeed, meepo) or 0) or 0
                        if move_speed < 250 then
                            move_speed = 250
                        end
                        approach_time = (dist - reach) / move_speed
                    end
                    local interval = tonumber(safe_call(NPC.GetSecondsPerAttack, meepo) or 0) or 0
                    if interval <= 0 then
                        local aps = tonumber(safe_call(NPC.GetAttacksPerSecond, meepo) or 0) or 0
                        if aps > 0 then
                            interval = 1 / aps
                        end
                    end
                    if interval <= 0 then
                        interval = interval_fallback
                    end
                    if interval < 0.25 then
                        interval = 0.25
                    elseif interval > 2.20 then
                        interval = 2.20
                    end
                    local first_hit_delay = first_hit_windup + math.max(0, approach_time - control_start_delay)
                    local hits = 0
                    if control_window > first_hit_delay then
                        hits = 1 + math.floor((control_window - first_hit_delay) / interval)
                    end
                    if hits > max_hits_per_meepo then
                        hits = max_hits_per_meepo
                    end
                    if hits > 0 then
                        attack_raw = attack_raw + (attack_dmg * hits)
                        attack_hits = attack_hits + hits
                    end
                end
            end
        end
    end
    local magic_damage = poof_raw * magic_mult
    local physical_damage = attack_raw * phys_mult
    local total_damage = magic_damage + physical_damage
    local hp_left = target_hp - total_damage
    if hp_left < 0 then
        hp_left = 0
    elseif target_max_hp > 0 and hp_left > target_max_hp then
        hp_left = target_max_hp
    end
    return {
        hp_left = hp_left,
        hp_now = target_hp,
        total_damage = total_damage,
        poof_count = poof_count,
        magic_damage = magic_damage,
        physical_damage = physical_damage,
        attack_hits = attack_hits,
        control_start_delay = control_start_delay,
        control_window = control_window,
        chained_nets = chain_nets_used,
    }
end
function script.get_combo_fight_estimate(prediction)
    if not prediction then
        return "FIGHT EST: UNKNOWN", Color(220, 220, 220, 230)
    end
    local hp_now = tonumber(prediction.hp_now or 0) or 0
    local hp_left = tonumber(prediction.hp_left or 0) or 0
    local control_window = tonumber(prediction.control_window or 0) or 0
    local poof_count = tonumber(prediction.poof_count or 0) or 0
    local attack_hits = tonumber(prediction.attack_hits or 0) or 0
    local chained_nets = tonumber(prediction.chained_nets or 0) or 0
    poof_count = math.max(0, math.floor(poof_count + 0.5))
    attack_hits = math.max(0, math.floor(attack_hits + 0.5))
    chained_nets = math.max(0, math.floor(chained_nets + 0.5))
    if hp_now <= 0 then
        return "FIGHT EST: UNKNOWN", Color(220, 220, 220, 230)
    end
    local hp_ratio = hp_left / hp_now
    local kill_ctrl_min = tonumber(C.COMBO_FIGHT_EST_KILL_CTRL_MIN or 0.30) or 0.30
    local win_ratio = tonumber(C.COMBO_FIGHT_EST_WIN_HP_RATIO or 0.20) or 0.20
    local risk_ratio = tonumber(C.COMBO_FIGHT_EST_RISK_HP_RATIO or 0.45) or 0.45
    local win_ctrl_min = tonumber(C.COMBO_FIGHT_EST_MIN_CTRL_FOR_WIN or 0.40) or 0.40
    local verdict = "BAD"
    local verdict_color = Color(255, 145, 145, 245)
    if hp_left <= 0 then
        if control_window >= kill_ctrl_min then
            verdict = "KILL"
            verdict_color = Color(140, 255, 165, 245)
        else
            verdict = "KILL/RISK"
            verdict_color = Color(255, 215, 145, 245)
        end
    elseif hp_ratio <= win_ratio and (control_window >= win_ctrl_min or poof_count >= 2) then
        verdict = "WIN"
        verdict_color = Color(170, 245, 170, 245)
    elseif hp_ratio <= risk_ratio or (control_window >= kill_ctrl_min and (poof_count >= 1 or attack_hits >= 2)) then
        verdict = "RISK"
        verdict_color = Color(255, 230, 150, 245)
    end
    local line = string.format(
        "FIGHT EST: %s  ctrl %.1fs  net %d  poof %d  hits %d",
        verdict,
        control_window,
        chained_nets,
        poof_count,
        attack_hits
    )
    return line, verdict_color
end
can_schedule_poof = function(meepo, now, cast_time)
    if not meepo or not Entity.IsAlive(meepo) then
        return false, nil
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local desired_cast_time = tonumber(cast_time or sample_now) or sample_now
    if desired_cast_time < sample_now then
        desired_cast_time = sample_now
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    if not poof then
        return false, poof
    end
    local can_cast_now = can_cast_ability_for_npc(meepo, poof)
    if not can_cast_now then
        local lead_time = math.max(0, desired_cast_time - sample_now)
        if lead_time > 0 then
            local cd = tonumber(safe_call(Ability.GetCooldown, poof) or 0) or 0
            local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
            local mana_cost = tonumber(safe_call(Ability.GetManaCost, poof) or 0) or 0
            if cd > 0 and cd <= (lead_time + 0.03) and mana >= mana_cost then
                can_cast_now = true
            end
        end
    end
    if not can_cast_now then
        return false, poof
    end
    local meepo_key = get_entity_key(meepo)
    local last_cast = combo_poof_last_cast_by_meepo[meepo_key] or -9999
    if sample_now - last_cast < C.COMBO_POOF_CASTER_RECAST_DELAY then
        return false, poof
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
    local channelling = safe_call(Ability.IsChannelling, poof)
    if in_phase == true or channelling == true then
        return false, poof
    end
    return true, poof
end
script.can_schedule_poof = can_schedule_poof
function script.cast_target_single_unit(local_player, caster, ability, target, reason, queue)
    if not caster or not ability or not target then
        return false
    end
    if not Entity.IsAlive(caster) or not Entity.IsAlive(target) then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        local ordered = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                target,
                Vector(0, 0, 0),
                ability,
                issuer_type,
                caster,
                queue == true,
                true,
                false,
                true,
                reason or "meepo_single_cast_target",
                false
            )
        end)
        if ordered then
            return true
        end
        -- Avoid Ability.CastTarget fallback in Umbrella API because it can fan-out
        -- to selected units and cause multi-meepo accidental poofs.
        return false
    end
    return false
end
function script.cast_position_single_unit(local_player, caster, ability, position, reason, queue)
    if not caster or not ability or not position then
        return false
    end
    if not Entity.IsAlive(caster) then
        return false
    end
    if not can_cast_ability_for_npc(caster, ability) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, ability) == true then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        local ordered = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                nil,
                position,
                ability,
                issuer_type,
                caster,
                queue == true,
                true,
                false,
                true,
                reason or "meepo_single_cast_position",
                false
            )
        end)
        if ordered then
            return true
        end
    end
    return false
end
function script.cast_no_target_single_unit(local_player, caster, ability, reason, queue)
    if not caster or not ability then
        return false
    end
    if not Entity.IsAlive(caster) then
        return false
    end
    if not can_cast_ability_for_npc(caster, ability) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, ability) == true then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        local ordered = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                nil,
                safe_call(Entity.GetAbsOrigin, caster) or Vector(0, 0, 0),
                ability,
                issuer_type,
                caster,
                queue == true,
                true,
                false,
                true,
                reason or "meepo_single_cast_notarget",
                false
            )
        end)
        if ordered then
            return true
        end
    end
    return false
end
local function get_required_root_for_poof(ready_count, max_channel)
    if ready_count <= 0 then
        return C.COMBO_POOF_ROOT_MIN_REMAINING
    end
    local stagger = C.COMBO_POOF_STAGGER * math.max(0, ready_count - 1)
    local required = max_channel + stagger + C.COMBO_POOF_SAFE_ROOT_BUFFER
    if required < C.COMBO_POOF_ROOT_MIN_REMAINING then
        required = C.COMBO_POOF_ROOT_MIN_REMAINING
    end
    return required
end
local function get_ready_poof_burst_info(units, now)
    local ready_count = 0
    local max_radius = 0
    local max_channel = 0
    for i = 1, #units do
        local meepo = units[i]
        local ready, poof = can_schedule_poof(meepo, now)
        if ready and poof then
            ready_count = ready_count + 1
            local radius = get_poof_damage_radius(poof)
            if radius > max_radius then
                max_radius = radius
            end
            local channel = get_poof_channel_duration(poof)
            if channel > max_channel then
                max_channel = channel
            end
        end
    end
    return ready_count, max_radius, max_channel
end
local function should_refresh_root_for_poof(units, target, now, remaining_root)
    if not target or remaining_root <= 0 then
        return false
    end
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    local ready_count, _, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    return remaining_root < required_root
end
local function get_ordered_units(units)
    if not units then
        return {}
    end
    local ordered = {}
    for i = 1, #units do
        ordered[#ordered + 1] = units[i]
    end
    table.sort(ordered, function(a, b)
        local a_idx = tonumber(safe_call(Entity.GetIndex, a) or 0) or 0
        local b_idx = tonumber(safe_call(Entity.GetIndex, b) or 0) or 0
        return a_idx < b_idx
    end)
    return ordered
end
local function queue_poof_cast(meepo, target, cast_time, reason)
    if not meepo or not target then
        return false
    end
    if not Entity.IsAlive(meepo) or not Entity.IsAlive(target) then
        return false
    end
    local key = get_entity_key(meepo)
    if not key or poof_queue_by_meepo[key] then
        return false
    end
    poof_queue_by_meepo[key] = true
    poof_cast_queue[#poof_cast_queue + 1] = {
        time = cast_time or 0,
        meepo = meepo,
        target = target,
        key = key,
        reason = reason or "meepo_poof_queue",
    }
    return true
end
clear_poof_queue = function()
    poof_cast_queue = {}
    poof_queue_by_meepo = {}
end
has_pending_poof_queue = function()
    return poof_cast_queue and #poof_cast_queue > 0
end
local function resolve_poof_target_for_meepo(meepo, fallback_target, enemy_target_pos)
    if not meepo or not fallback_target then
        return fallback_target
    end
    if not enemy_target_pos or not Entity.IsAlive(meepo) then
        return fallback_target
    end
    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
    local dist = vec_dist_2d(meepo_pos, enemy_target_pos)
    if not dist then
        return fallback_target
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    local radius = get_poof_damage_radius(poof)
    local self_hit_pad = tonumber(C.COMBO_POOF_SELF_HIT_PAD or 0) or 0
    local self_hit_dist = radius + self_hit_pad
    if self_hit_dist < 120 then
        self_hit_dist = 120
    end
    if dist <= self_hit_dist then
        return meepo
    end
    return fallback_target
end
schedule_poof_burst = function(units, target, now, reason, stagger, enemy_target_pos)
    if not units or #units == 0 or not target then
        return 0
    end
    local ordered = get_ordered_units(units)
    local cast_stagger = stagger
    if cast_stagger == nil then
        cast_stagger = C.COMBO_POOF_STAGGER
    end
    if cast_stagger < 0 then
        cast_stagger = 0
    end
    local sample_now = tonumber(get_game_time() or now or 0) or 0
    local scheduled = 0
    for i = 1, #ordered do
        local meepo = ordered[i]
        local cast_time = now + (scheduled * cast_stagger)
        local ready = can_schedule_poof(meepo, sample_now, cast_time)
        if ready then
            local poof_target = resolve_poof_target_for_meepo(meepo, target, enemy_target_pos)
            if queue_poof_cast(meepo, poof_target, cast_time, reason) then
                scheduled = scheduled + 1
            end
        end
    end
    return scheduled
end
script.schedule_poof_burst = schedule_poof_burst
function script.process_poof_queue(now)
    if not poof_cast_queue or #poof_cast_queue == 0 then
        return
    end
    local local_player = safe_call(Players.GetLocal)
    local has_due_sync = false
    for i = 1, #poof_cast_queue do
        local q = poof_cast_queue[i]
        if q and now >= (q.time or 0) and is_sync_poof_reason(q.reason) then
            has_due_sync = true
            break
        end
    end
    if (not has_due_sync) and now < (script._poof_next_order_time or 0) then
        return
    end
    local remaining = {}
    local cast_issued = false
    for i = 1, #poof_cast_queue do
        local item = poof_cast_queue[i]
        local keep = true
        if not item or not item.meepo or not item.target then
            keep = false
        elseif not Entity.IsAlive(item.meepo) or not Entity.IsAlive(item.target) then
            keep = false
        elseif now >= (item.time or 0) then
            local poof = safe_call(NPC.GetAbility, item.meepo, C.ABILITY_POOF)
            local cast_ok = false
            if poof and can_cast_ability_for_npc(item.meepo, poof) then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    cast_ok = script.cast_target_single_unit(local_player, item.meepo, poof, item.target, item.reason, false)
                    if cast_ok then
                        combo_poof_last_cast_by_meepo[item.key] = now
                        if is_sync_poof_reason(item.reason) then
                        else
                            cast_issued = true
                            script._poof_next_order_time = now + 0.08
                        end
                    end
                end
            end
            if cast_ok then
                keep = false
            else
                if script.is_autofarm_poof_reason(item.reason) then
                    keep = false
                else
                    item.time = now + 0.03
                    keep = true
                end
            end
        end
        if keep then
            remaining[#remaining + 1] = item
        elseif item and item.key then
            poof_queue_by_meepo[item.key] = nil
        end
        if cast_issued then
            for j = i + 1, #poof_cast_queue do
                local rest = poof_cast_queue[j]
                if rest and rest.key then
                    remaining[#remaining + 1] = rest
                end
            end
            break
        end
    end
    poof_cast_queue = remaining
end
local function choose_poof_anchor(units, target_pos, max_anchor_distance, allow_relaxed_fallback)
    local best = nil
    local best_dist = nil
    local best_non_main = nil
    local best_non_main_dist = nil
    local best_any = nil
    local best_any_dist = nil
    local best_any_non_main = nil
    local best_any_non_main_dist = nil
    local local_hero = safe_call(Heroes.GetLocal)
    local main_meepo = get_main_meepo(local_hero)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local pos = safe_call(Entity.GetAbsOrigin, meepo)
            local d = vec_dist_2d(pos, target_pos)
            if d then
                if (not best_any_dist) or d < best_any_dist then
                    best_any = meepo
                    best_any_dist = d
                end
                if meepo ~= main_meepo and ((not best_any_non_main_dist) or d < best_any_non_main_dist) then
                    best_any_non_main = meepo
                    best_any_non_main_dist = d
                end
                if (not max_anchor_distance) or d <= max_anchor_distance then
                    if (not best_dist) or d < best_dist then
                        best = meepo
                        best_dist = d
                    end
                    if meepo ~= main_meepo then
                        if (not best_non_main_dist) or d < best_non_main_dist then
                            best_non_main = meepo
                            best_non_main_dist = d
                        end
                    end
                end
            end
        end
    end
    if best_non_main then
        return best_non_main, best_non_main_dist
    end
    if best then
        return best, best_dist
    end
    if allow_relaxed_fallback then
        if best_any_non_main then
            return best_any_non_main, best_any_non_main_dist
        end
        return best_any, best_any_dist
    end
    return nil, nil
end
function script.select_combo_poof_anchor(units, target_pos, max_anchor_distance, allow_relaxed_fallback)
    if not units or #units == 0 or not target_pos then
        return nil, nil
    end
    local preferred_anchor = nil
    if combo_focus_source and Entity.IsAlive(combo_focus_source) then
        preferred_anchor = combo_focus_source
    else
        local local_player = safe_call(Players.GetLocal)
        local local_hero = safe_call(Heroes.GetLocal)
        preferred_anchor = get_combo_anchor_meepo(local_player, local_hero) or get_main_meepo(local_hero)
    end
    if preferred_anchor and Entity.IsAlive(preferred_anchor) then
        local exists_in_units = false
        for i = 1, #units do
            if units[i] == preferred_anchor then
                exists_in_units = true
                break
            end
        end
        if exists_in_units then
            local anchor_pos = safe_call(Entity.GetAbsOrigin, preferred_anchor)
            local dist = vec_dist_2d(anchor_pos, target_pos)
            if dist then
                if (not max_anchor_distance) or dist <= max_anchor_distance then
                    return preferred_anchor, dist
                end
                if allow_relaxed_fallback then
                    return preferred_anchor, dist
                end
            end
        end
    end
    return choose_poof_anchor(units, target_pos, max_anchor_distance, allow_relaxed_fallback)
end
function script.get_world_cursor_position()
    if not Input or not Input.GetWorldCursorPos then
        return nil
    end
    local ctx = script._frame_context_get()
    if ctx.world_cursor ~= nil then
        return ctx.world_cursor
    end
    local ok, pos = pcall(function()
        return Input.GetWorldCursorPos()
    end)
    if ok then
        ctx.world_cursor = pos
    else
        ctx.world_cursor = false
    end
    if ctx.world_cursor == false then
        return nil
    end
    return ctx.world_cursor
end
function script.is_bind_pressed(bind)
    if not bind then
        return false
    end
    if bind.IsPressed then
        local ok, pressed = pcall(function()
            return bind:IsPressed()
        end)
        if ok and pressed == true then
            return true
        end
    end
    if bind.IsDown then
        local ok, down = pcall(function()
            return bind:IsDown()
        end)
        if ok and down == true then
            return true
        end
    end
    return false
end
function script.is_bind_just_pressed(bind, state_key)
    local down = false
    local pressed = false
    if bind then
        if bind.IsPressed then
            local ok, value = pcall(function()
                return bind:IsPressed()
            end)
            if ok and value == true then
                pressed = true
            end
        end
        if bind.IsDown then
            local ok, value = pcall(function()
                return bind:IsDown()
            end)
            if ok and value == true then
                down = true
            end
        end
    end
    local states = script._utility_bind_down_state or {}
    script._utility_bind_down_state = states
    if state_key then
        local was_down = states[state_key] == true
        states[state_key] = down
        if pressed then
            return true
        end
        return down and not was_down
    end
    if pressed then
        return true
    end
    return down
end
function script.schedule_poof_self(units, now, reason)
    if not units or #units == 0 then
        return 0
    end
    local ordered = get_ordered_units(units)
    local scheduled = 0
    for i = 1, #ordered do
        local meepo = ordered[i]
        local ready = can_schedule_poof(meepo, now)
        if ready then
            local cast_time = now
            if queue_poof_cast(meepo, meepo, cast_time, reason) then
                scheduled = scheduled + 1
            end
        end
    end
    return scheduled
end
function script.clear_blink_schedule()
    script._combo_blink_scheduled_time = 0
    script._combo_blink_target = nil
    script._combo_blink_anchor = nil
    script._combo_blink_target_key = nil
    script._combo_blink_last_schedule = -9999
    script._combo_blink_poof_units = {}
    script._combo_blink_post_poof_delay = 0
    script._combo_blink_poof_prescheduled = false
    script._combo_blink_next_attempt = 0
    script._combo_blink_retry_deadline = 0
    script.clear_preblink_poof_state()
    local now = get_game_time()
    if combo_move_next_order_time > (now + C.COMBO_MOVE_ORDER_INTERVAL) then
        combo_move_next_order_time = now + C.COMBO_MOVE_ORDER_INTERVAL
    end
end
function script.clear_preblink_poof_state()
    script._combo_preblink_phase = "idle"
    script._combo_preblink_target_key = nil
    script._combo_preblink_anchor_key = nil
    script._combo_preblink_poof_sent_time = 0
    script._combo_preblink_wait_until = 0
    script._combo_preblink_sent_set = {}
end
local function get_preblink_delay_sec(poof_units)
    local pct = 100
    if ui.combo_blink_pre_poof_delay_ms and ui.combo_blink_pre_poof_delay_ms.Get then
        local ok, v = pcall(function()
            return ui.combo_blink_pre_poof_delay_ms:Get()
        end)
        if ok and v ~= nil then
            local raw = tonumber(v) or 100
            -- Backward compatibility for old saved values (milliseconds).
            if raw > 100 then
                raw = (raw / 1500.0) * 100.0
            end
            if raw < 1 then
                raw = 1
            elseif raw > 100 then
                raw = 100
            end
            pct = raw
        end
    end
    local channel = tonumber(C and C.COMBO_POOF_CHANNEL_FALLBACK or 1.5) or 1.5
    if poof_units and #poof_units > 0 then
        for i = 1, #poof_units do
            local meepo = poof_units[i]
            if meepo and Entity.IsAlive(meepo) then
                local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                local duration = get_poof_channel_duration(poof)
                if duration > channel then
                    channel = duration
                end
            end
        end
    end
    if channel <= 0 then
        channel = 1.5
    end
    local effective_pct = pct
    if effective_pct >= 80 then
        -- Compress top-end harder: 100% should still blink before Poof completion.
        effective_pct = 80 + ((effective_pct - 80) * 0.45)
    end
    local delay = channel * (effective_pct / 100.0)
    local lead_time = 0.18
    if channel < 1.2 then
        local scaled = channel * 0.12
        if scaled > lead_time then
            lead_time = scaled
        end
    end
    local latest_safe = channel - lead_time
    if latest_safe > 0.04 and delay > latest_safe then
        delay = latest_safe
    end
    if delay < 0.01 then
        delay = 0.01
    end
    return delay
end
function script.can_cast_blink_now(npc, blink)
    if not npc or not blink then
        return false
    end
    if Ability and Ability.IsReady then
        local ready = safe_call(Ability.IsReady, blink)
        if ready ~= nil and ready ~= true then
            return false
        end
    end
    if not can_cast_ability_for_npc(npc, blink) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, blink)
    if in_phase == true then
        return false
    end
    return true
end
function script.is_linken_breaker_item_enabled(item_name)
    if not item_name or item_name == "" then
        return false
    end
    if ui.items_linken_breakers and ui.items_linken_breakers.Get then
        local ok, enabled = pcall(function()
            return ui.items_linken_breakers:Get(item_name)
        end)
        if ok then
            return enabled == true
        end
    end
    return false
end
function script.is_linkens_item_ready(item)
    if not item then
        return false
    end
    if Ability and Ability.IsReady then
        local ready = safe_call(Ability.IsReady, item)
        if ready ~= nil then
            return ready == true
        end
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, item) or 0) or 0
    return cd <= 0.05
end
function script.is_target_linkens_protected(target)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if NPC.IsLinkensProtected then
        local protected = safe_call(NPC.IsLinkensProtected, target)
        if protected ~= nil and protected == true then
            return true
        end
    end
    local sphere = safe_call(NPC.GetItem, target, "item_sphere", true)
    if sphere and script.is_linkens_item_ready(sphere) then
        return true
    end
    local mirror = safe_call(NPC.GetItem, target, "item_mirror_shield", true)
    if mirror and script.is_linkens_item_ready(mirror) then
        return true
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_sphere_target") == true then
        return true
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_sphere") == true then
        if not sphere then
            return true
        end
    end
    if safe_call(NPC.HasModifier, target, "modifier_item_mirror_shield") == true then
        if not mirror then
            return true
        end
    end
    return false
end
function script.should_combo_surprise_hold(local_hero, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if (script._combo_blink_scheduled_time or 0) > now then
        return true
    end
    if (script._combo_hold_next_order_time or 0) > now then
        return true
    end
    if has_pending_poof_queue and has_pending_poof_queue() then
        return true
    end
    local anchor = nil
    if get_combo_type_index() == COMBO_MODE_SELECTED then
        if combo_focus_source and Entity.IsAlive(combo_focus_source) then
            anchor = combo_focus_source
        else
            local local_player = safe_call(Players.GetLocal)
            local selected_anchor = get_selected_meepo(local_player)
            if selected_anchor and Entity.IsAlive(selected_anchor) then
                anchor = selected_anchor
            end
        end
    end
    if (not anchor) or (not Entity.IsAlive(anchor)) then
        anchor = get_main_meepo(local_hero)
    end
    if not anchor or not Entity.IsAlive(anchor) then
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        return false
    end
    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not anchor_pos or not target_pos then
        return false
    end
    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
    return dist > 0 and dist <= (blink_range + 80)
end
function script.cast_combo_blink(anchor, target, now, reason_tag)
    if not anchor or not target then
        return false
    end
    if now < (tonumber(script._combo_blink_last_cast_cmd or -9999) or -9999) + (tonumber(C.COMBO_BLINK_CMD_GUARD or 0.32) or 0.32) then
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
    if not target_pos or not anchor_pos then
        return false
    end
    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
    if blink_range <= 0 then
        blink_range = 1200
    end
    if dist <= 40 then
        return false
    end
    local cast_pos = target_pos
    if dist > blink_range then
        local dx = (target_pos.x or 0) - (anchor_pos.x or 0)
        local dy = (target_pos.y or 0) - (anchor_pos.y or 0)
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            local scale = blink_range / len
            cast_pos = Vector(
                (anchor_pos.x or 0) + dx * scale,
                (anchor_pos.y or 0) + dy * scale,
                target_pos.z or anchor_pos.z or 0
            )
        end
    end
    local name = "blink_" .. tostring(anchor)
    local next_ok = script._cast_next_allowed_time[name] or -9999
    if now < next_ok then
        return false
    end
    local ok = false
    local issued_by = "none"
    local local_player = safe_call(Players.GetLocal)
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if script.is_direct_cast_mode() then
        ok = pcall(function()
            Ability.CastPosition(
                blink,
                cast_pos,
                false,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "ability_cast"
        end
    end
    if not ok and local_player and order_type and issuer_type and Player and Player.PrepareUnitOrders then
        ok = pcall(function()
            Player.PrepareUnitOrders(
                local_player,
                order_type,
                nil,
                cast_pos,
                blink,
                issuer_type,
                anchor,
                false,
                true,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "prepare_order"
        end
    end
    if (not ok) and (not script.is_direct_cast_mode()) then
        ok = pcall(function()
            Ability.CastPosition(
                blink,
                cast_pos,
                false,
                true,
                true,
                reason_tag or "meepo_combo_blink_simple",
                true
            )
        end)
        if ok then
            issued_by = "ability_cast"
        end
    end
    if ok then
        script._combo_blink_last_cast_cmd = now
        local cmd_guard = tonumber(C.COMBO_BLINK_CMD_GUARD or 0.32) or 0.32
        local lock_for = tonumber(C.GENERIC_CAST_INTERVAL or 0.18) or 0.18
        if cmd_guard > lock_for then
            lock_for = cmd_guard
        end
        script._cast_next_allowed_time[name] = now + lock_for
        set_combo_action_lock(now, lock_for)
        script._dbg("blink", string.format("issued via %s dist %.0f range %.0f", issued_by, dist, blink_range))
    else
        script._dbg("blink", string.format("failed dist %.0f range %.0f", dist, blink_range))
    end
    return ok == true
end
function script.has_ready_hex_item_for_blink(units)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and NPC.GetItem then
            local hex = safe_call(NPC.GetItem, meepo, C.ITEM_HEX, true)
            if hex then
                local name = safe_call(Ability.GetName, hex)
                local enabled = true
                if name and name ~= "" then
                    enabled = is_item_enabled(name)
                end
                if enabled and can_cast_ability_for_npc(meepo, hex) and safe_call(Ability.IsInAbilityPhase, hex) ~= true then
                    return true
                end
            end
        end
    end
    return false
end
function script.try_combo_blink_sync(local_hero, units, target, now, net_units)
    if not target or not Entity.IsAlive(target) then
        script.clear_preblink_poof_state()
        return false
    end
    local engage_mode = tostring(script._combo_engage_mode or "MID")
    if engage_mode == "CLOSE" then
        script.clear_preblink_poof_state()
        return false
    end
    local local_player = safe_call(Players.GetLocal)
    local anchor_pool = (net_units and #net_units > 0) and net_units or units
    local anchor = nil
    if get_combo_type_index() == COMBO_MODE_SELECTED then
        if combo_focus_source and Entity.IsAlive(combo_focus_source) and script.is_unit_in_units_list(combo_focus_source, anchor_pool) then
            anchor = combo_focus_source
        end
        if not anchor then
            local selected_anchor = get_selected_meepo(local_player)
            if selected_anchor and Entity.IsAlive(selected_anchor) and script.is_unit_in_units_list(selected_anchor, anchor_pool) then
                anchor = selected_anchor
            end
        end
    end
    if not anchor then
        local main_anchor = get_main_meepo(local_hero)
        if main_anchor and Entity.IsAlive(main_anchor) and script.is_unit_in_units_list(main_anchor, anchor_pool) then
            anchor = main_anchor
        end
    end
    if not anchor then
        anchor = script.pick_first_alive_unit(anchor_pool)
    end
    if not anchor or not Entity.IsAlive(anchor) then
        script.clear_preblink_poof_state()
        return false
    end
    local blink = get_blink_item(anchor)
    if not script.can_cast_blink_now(anchor, blink) then
        script.clear_preblink_poof_state()
        return false
    end
    if script._combo_blink_scheduled_time > 0 then
        script.clear_blink_schedule()
    end
    if now < (script._combo_blink_last_schedule or -9999) + C.COMBO_BLINK_RECAST_DELAY then
        script.clear_preblink_poof_state()
        return false
    end
    local target_key = get_entity_key(target)
    local anchor_key = get_entity_key(anchor)
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local poof_units = (net_units and #net_units > 0) and net_units or units
    local ready_casters = {}
    local poof_enabled = script.is_combo_option_enabled(ui.combo_poof_before_blink) and is_combo_spell_enabled("poof", ui.combo_use_poof)
    if poof_enabled and poof_units and #poof_units > 0 then
        for i = 1, #poof_units do
            local meepo = poof_units[i]
            if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                local ready = can_schedule_poof(meepo, now)
                if ready then
                    ready_casters[#ready_casters + 1] = meepo
                end
            end
        end
    end
    local preblink_active_for_pair =
        script._combo_preblink_phase ~= "idle"
        and script._combo_preblink_target_key == target_key
        and script._combo_preblink_anchor_key == anchor_key
    local allow_preblink = poof_enabled and (#ready_casters > 0 or preblink_active_for_pair)
    if allow_preblink then
        local state_changed = false
        if script._combo_preblink_target_key ~= target_key then
            state_changed = true
        end
        if script._combo_preblink_anchor_key ~= anchor_key then
            state_changed = true
        end
        if state_changed then
            script.clear_preblink_poof_state()
        end
        if script._combo_preblink_phase == "idle" then
            script._combo_preblink_phase = "poof"
            script._combo_preblink_target_key = target_key
            script._combo_preblink_anchor_key = anchor_key
            script._combo_preblink_poof_sent_time = 0
            script._combo_preblink_wait_until = 0
            script._combo_preblink_sent_set = script._combo_preblink_sent_set or {}
        end
        if script._combo_preblink_phase == "poof" then
            local sent_any = false
            for i = 1, #poof_units do
                local meepo = poof_units[i]
                if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                    local meepo_key = get_entity_key(meepo)
                    if not script._combo_preblink_sent_set[meepo_key] then
                        local ready, poof = can_schedule_poof(meepo, now)
                        if ready and poof then
                            local poof_target = resolve_poof_target_for_meepo(meepo, anchor, target_pos)
                            local cast_ok = script.cast_target_single_unit(local_player, meepo, poof, poof_target, "meepo_poof_before_blink", false)
                            script._combo_preblink_sent_set[meepo_key] = true
                            if cast_ok then
                                combo_poof_last_cast_by_meepo[meepo_key] = now
                                sent_any = true
                                if (script._combo_preblink_poof_sent_time or 0) <= 0 then
                                    script._combo_preblink_poof_sent_time = now
                                end
                                script._poof_next_order_time = now + 0.05
                            end
                        else
                            script._combo_preblink_sent_set[meepo_key] = true
                        end
                    end
                end
            end
            if sent_any then
                script._dbg("blink", "pre-poof cast")
            end
            if (script._combo_preblink_poof_sent_time or 0) <= 0 then
                script._combo_preblink_poof_sent_time = now
            end
            script._combo_preblink_wait_until = script._combo_preblink_poof_sent_time + get_preblink_delay_sec(poof_units)
            script._combo_preblink_phase = "wait"
            return true
        end
        if script._combo_preblink_phase == "wait" then
            if now < (script._combo_preblink_wait_until or 0) then
                return true
            end
            script._combo_preblink_phase = "blink"
        end
    else
        script.clear_preblink_poof_state()
    end
    local preblink_sequence_used =
        poof_enabled
        and ((script._combo_preblink_phase == "blink") or ((script._combo_preblink_poof_sent_time or 0) > 0))
    local blinked = script.cast_combo_blink(anchor, target, now, "meepo_combo_blink_simple")
    if not blinked then
        if script._combo_preblink_phase == "blink" then
            local retry_deadline = tonumber(script._combo_blink_retry_deadline or 0) or 0
            if retry_deadline <= now then
                script._combo_blink_retry_deadline = now + 0.25
                return true
            end
            if now <= retry_deadline then
                return true
            end
            script.clear_preblink_poof_state()
        end
        return false
    end
    script._combo_blink_last_schedule = now
    script._combo_blink_retry_deadline = 0
    local hex_units = (net_units and #net_units > 0) and net_units or units
    local hex_ready_for_blink = script.has_ready_hex_item_for_blink(hex_units)
    if (not hex_ready_for_blink) and (not preblink_sequence_used) then
        script.try_main_earthbind_after_blink(anchor, target, now)
    elseif clear_poof_queue then
        clear_poof_queue()
    end
    if (not hex_ready_for_blink) and (not poof_enabled) and #ready_casters > 0 then
        schedule_poof_burst(ready_casters, anchor, now + 0.02, "meepo_combo_poof_sync", 0)
    end
    script.clear_preblink_poof_state()
    return true
end
function script.try_main_earthbind_after_blink(anchor, target, now)
    if not anchor or not target or not Entity.IsAlive(anchor) or not Entity.IsAlive(target) then
        return false
    end
    if script.is_tp_interrupt_net_globally_locked and script.is_tp_interrupt_net_globally_locked(now) then
        return false
    end
    if not is_combo_spell_enabled("net", ui.combo_use_net) then
        return false
    end
    if script.get_control_break_reason(target, false) then
        return false
    end
    local net = safe_call(NPC.GetAbility, anchor, C.ABILITY_NET)
    if not net or not can_cast_ability_for_npc(anchor, net) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, net) == true then
        return false
    end
    local caster_key = get_entity_key(anchor)
    local last_cast = combo_net_last_cast_by_meepo[caster_key] or -9999
    if now - last_cast < C.COMBO_NET_CASTER_RECAST_DELAY then
        return false
    end
    if now - combo_net_last_global_cast < C.COMBO_NET_GLOBAL_RECAST_DELAY then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local caster_pos = safe_call(Entity.GetAbsOrigin, anchor)
    if not target_pos or not caster_pos then
        return false
    end
    local cast_pos = script.get_simple_net_position(anchor, target, net, now) or target_pos
    local max_cast_dist = get_net_cast_range(anchor, net) + C.COMBO_NET_RANGE_PADDING
    local dist = vec_dist_2d(caster_pos, cast_pos)
    if dist and dist > max_cast_dist then
        cast_pos = target_pos
        dist = vec_dist_2d(caster_pos, cast_pos)
        if not dist or dist > max_cast_dist then
            return false
        end
    end
    local ok = pcall(function()
        Ability.CastPosition(
            net,
            cast_pos,
            false,
            true,
            true,
            "meepo_combo_blink_main_net",
            false
        )
    end)
    if not ok then
        return false
    end
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, anchor, cast_pos) or 0) or 0
    if turn_time < 0 then
        turn_time = 0
    elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
        turn_time = C.COMBO_NET_FACE_TIME_CAP
    end
    local speed = get_earthbind_projectile_speed(net)
    local travel_dist = vec_dist_2d(caster_pos, cast_pos) or 0
    local arrival_time = now + turn_time + cast_point + (travel_dist / math.max(1, speed))
    script._combo_net_pending_target_key = get_entity_key(target)
    script._combo_net_pending_arrival_time = arrival_time
    script._combo_net_pending_end_time = arrival_time + script.get_earthbind_root_duration(net)
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    return true
end
function script.is_combo_option_enabled(option)
    if option and option.Get then
        local ok, value = pcall(function()
            return option:Get()
        end)
        if ok then
            return value == true
        end
    end
    return false
end
function script.get_combo_hold_window_sec()
    if ui.combo_hold_disable_ms and ui.combo_hold_disable_ms.Get then
        local ok, value = pcall(function()
            return ui.combo_hold_disable_ms:Get()
        end)
        if ok and value ~= nil then
            local ms = tonumber(value) or 450
            if ms < 100 then
                ms = 100
            end
            return ms / 1000.0
        end
    end
    return 0.45
end
function script.process_blink_queue(now)
    if (script._combo_blink_scheduled_time or 0) > 0 then
        script.clear_blink_schedule()
    end
end
function script.collect_utility_poof_units(local_player, local_hero, meepos)
    local mode = get_combo_type_index()
    if mode == COMBO_MODE_ALL then
        return collect_owned_meepo_units(local_hero, meepos)
    end
    local selected_units = collect_combo_move_units(local_player, local_hero, meepos)
    if selected_units and #selected_units > 1 then
        return selected_units
    end
    -- Utility poof binds should still work in selected mode even if only one Meepo is selected.
    local all_units = collect_owned_meepo_units(local_hero, meepos)
    if all_units and #all_units > 0 then
        return all_units
    end
    return selected_units
end
function script.collect_ready_poof_casters(units, now)
    local ready = {}
    local ability = nil
    if not units or #units == 0 then
        return ready, ability
    end
    for i = 1, #units do
        local meepo = units[i]
        local can_cast, poof = can_schedule_poof(meepo, now)
        if can_cast and poof then
            ready[#ready + 1] = meepo
            if not ability then
                ability = poof
            end
        end
    end
    return ready, ability
end
function script.issue_group_poof_target_order(local_player, casters, anchor, now, reason)
    if not casters or #casters == 0 or not anchor or not Entity.IsAlive(anchor) then
        return false
    end
    local ready_casters = script.collect_ready_poof_casters(casters, now)
    if #ready_casters == 0 then
        return false
    end
    local casted = 0
    local failed = {}
    for i = 1, #ready_casters do
        local meepo = ready_casters[i]
        if meepo and Entity.IsAlive(meepo) then
            local can_cast, poof = can_schedule_poof(meepo, now)
            if can_cast and poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    local ok = script.cast_target_single_unit(local_player, meepo, poof, anchor, reason or "meepo_poof_group_target", false)
                    if ok then
                        local key = get_entity_key(meepo)
                        combo_poof_last_cast_by_meepo[key] = now
                        casted = casted + 1
                    else
                        failed[#failed + 1] = meepo
                    end
                else
                    failed[#failed + 1] = meepo
                end
            else
                failed[#failed + 1] = meepo
            end
        else
            failed[#failed + 1] = meepo
        end
    end
    local queued = 0
    if #failed > 0 and not script.is_autofarm_poof_reason(reason) then
        queued = schedule_poof_burst(failed, anchor, now + 0.02, reason or "meepo_poof_group_target", 0)
    end
    if casted <= 0 and queued <= 0 then
        script._dbg("poof_util", "cursor direct cast failed (queued 0)")
        return false
    end
    script._dbg("poof_util", string.format("cursor direct casted %d queued %d", casted, queued))
    script._poof_next_order_time = now + 0.05
    return true
end
function script.issue_group_poof_self_order(local_player, casters, now, reason)
    if not casters or #casters == 0 then
        return false
    end
    local ready_casters = script.collect_ready_poof_casters(casters, now)
    if #ready_casters == 0 then
        return false
    end
    local casted = 0
    local failed = {}
    for i = 1, #ready_casters do
        local meepo = ready_casters[i]
        if meepo and Entity.IsAlive(meepo) then
            local can_cast, poof = can_schedule_poof(meepo, now)
            if can_cast and poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase ~= true and channelling ~= true then
                    local ok = script.cast_target_single_unit(local_player, meepo, poof, meepo, reason or "meepo_poof_group_self", false)
                    if ok then
                        local key = get_entity_key(meepo)
                        combo_poof_last_cast_by_meepo[key] = now
                        casted = casted + 1
                    else
                        failed[#failed + 1] = meepo
                    end
                else
                    failed[#failed + 1] = meepo
                end
            else
                failed[#failed + 1] = meepo
            end
        else
            failed[#failed + 1] = meepo
        end
    end
    local queued = 0
    if #failed > 0 and not script.is_autofarm_poof_reason(reason) then
        queued = script.schedule_poof_self(failed, now + 0.02, reason or "meepo_poof_group_self")
    end
    if casted <= 0 and queued <= 0 then
        script._dbg("poof_util", "self direct cast failed (queued 0)")
        return false
    end
    script._dbg("poof_util", string.format("self direct casted %d queued %d", casted, queued))
    script._poof_next_order_time = now + 0.05
    return true
end
function script.try_poof_to_cursor(local_player, local_hero, meepos, now)
    local units = script.collect_utility_poof_units(local_player, local_hero, meepos)
    if #units == 0 then
        return false
    end
    local function is_unit_in_list(unit, list)
        if not unit or not list then
            return false
        end
        for i = 1, #list do
            if list[i] == unit then
                return true
            end
        end
        return false
    end
    local anchor = nil
    local selected_anchor = get_selected_meepo(local_player)
    if selected_anchor and Entity.IsAlive(selected_anchor) and is_unit_in_list(selected_anchor, units) then
        anchor = selected_anchor
    end
    if not anchor then
        local combo_anchor = get_combo_anchor_meepo(local_player, local_hero)
        if combo_anchor and Entity.IsAlive(combo_anchor) and is_unit_in_list(combo_anchor, units) then
            anchor = combo_anchor
        end
    end
    if not anchor then
        local main_anchor = get_main_meepo(local_hero)
        if main_anchor and Entity.IsAlive(main_anchor) and is_unit_in_list(main_anchor, units) then
            anchor = main_anchor
        end
    end
    if not anchor then
        local cursor_pos = script.get_world_cursor_position()
        if cursor_pos then
            anchor = select(1, choose_poof_anchor(units, cursor_pos, nil, true))
        end
    end
    if not anchor then
        return false
    end
    local filtered = {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and meepo ~= anchor then
            filtered[#filtered + 1] = meepo
        end
    end
    if #filtered == 0 then
        return false
    end
    if script.issue_group_poof_target_order(local_player, filtered, anchor, now, "meepo_poof_cursor_group") then
        return true
    end
    script._dbg("poof_util", "cursor fallback queue")
    return schedule_poof_burst(filtered, anchor, now, "meepo_poof_cursor", 0) > 0
end
function script.try_poof_on_self(local_player, local_hero, meepos, now)
    local units = script.collect_utility_poof_units(local_player, local_hero, meepos)
    if #units == 0 then
        return false
    end
    if script.issue_group_poof_self_order(local_player, units, now, "meepo_poof_self_group") then
        return true
    end
    script._dbg("poof_util", "self fallback queue")
    return script.schedule_poof_self(units, now, "meepo_poof_self") > 0
end
local function is_poof_in_progress(units)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
            if poof then
                local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
                local channelling = safe_call(Ability.IsChannelling, poof)
                if in_phase == true or channelling == true then
                    return true
                end
            end
        end
    end
    return false
end
is_combo_cast_in_progress = function(meepo)
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
    if poof then
        local in_phase = safe_call(Ability.IsInAbilityPhase, poof)
        local channelling = safe_call(Ability.IsChannelling, poof)
        if in_phase == true or channelling == true then
            return true
        end
    end
    local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
    if net and safe_call(Ability.IsInAbilityPhase, net) == true then
        return true
    end
    return false
end
local function interrupt_combo_casts(player, units)
    if not player or not units or #units == 0 then
        return false
    end
    local stop_order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_STOP or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    local interrupted = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and is_combo_cast_in_progress(meepo) then
            local issued = false
            if stop_order and issuer_type and Player and Player.PrepareUnitOrders then
                issued = pcall(function()
                    Player.PrepareUnitOrders(
                        player,
                        stop_order,
                        nil,
                        safe_call(Entity.GetAbsOrigin, meepo),
                        nil,
                        issuer_type,
                        meepo,
                        false,
                        true,
                        true,
                        true,
                        "meepo_combo_cancel_cast",
                        false
                    )
                end)
            end
            if (not issued) and Player and Player.HoldPosition then
                issued = pcall(function()
                    Player.HoldPosition(player, meepo, false, true, true, "meepo_combo_cancel_cast_hold")
                end)
            end
            if issued then
                interrupted = true
            end
        end
    end
    return interrupted
end
local function choose_earthbind_caster(units, target, now, preferred_caster)
    local best_meepo = nil
    local best_ability = nil
    local best_arrival = nil
    local best_cast_pos = nil
    local preferred_meepo = nil
    local preferred_ability = nil
    local preferred_arrival = nil
    local preferred_cast_pos = nil
    local preferred_key = nil
    if preferred_caster and Entity.IsAlive(preferred_caster) then
        preferred_key = get_entity_key(preferred_caster)
    end
    if not target or not Entity.IsAlive(target) then
        return nil, nil, nil, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return nil, nil, nil, nil
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net and can_cast_ability_for_npc(meepo, net) then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                    if now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local cast_pos = script.get_simple_net_position(meepo, target, net, now) or target_pos
                    local dist = vec_dist_2d(meepo_pos, cast_pos)
                    if dist then
                        local cast_range = get_net_cast_range(meepo, net)
                        if dist > cast_range + C.COMBO_NET_RANGE_PADDING then
                            cast_pos = target_pos
                            dist = vec_dist_2d(meepo_pos, cast_pos)
                        end
                        if dist and dist <= cast_range + C.COMBO_NET_RANGE_PADDING then
                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                            if cast_point < 0 then
                                cast_point = 0
                            end
                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                            if turn_time < 0 then
                                turn_time = 0
                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                            end
                            local speed = get_earthbind_projectile_speed(net)
                            local time_to_land = turn_time + cast_point + (dist / math.max(1, speed))
                            local arrival = now + time_to_land
                            local meepo_key_now = get_entity_key(meepo)
                            if preferred_key and meepo_key_now == preferred_key then
                                if not preferred_arrival or arrival < preferred_arrival then
                                    preferred_arrival = arrival
                                    preferred_meepo = meepo
                                    preferred_ability = net
                                    preferred_cast_pos = cast_pos
                                end
                            elseif not best_arrival or arrival < best_arrival then
                                best_arrival = arrival
                                best_meepo = meepo
                                best_ability = net
                                best_cast_pos = cast_pos
                            end
                        end
                    end
                end
            end
        end
    end
    if preferred_meepo and preferred_ability and preferred_arrival then
        return preferred_meepo, preferred_ability, preferred_arrival, preferred_cast_pos
    end
    return best_meepo, best_ability, best_arrival, best_cast_pos
end
local function get_hex_item(npc)
    if not npc or not NPC.GetItem then
        return nil
    end
    local hex = safe_call(NPC.GetItem, npc, C.ITEM_HEX, true)
    if not hex then
        return nil
    end
    local name = safe_call(Ability.GetName, hex)
    if name and name ~= "" and not is_item_enabled(name) then
        return nil
    end
    return hex
end
local function can_cast_hex_now(npc, hex)
    if not npc or not hex then
        return false
    end
    if not can_cast_ability_for_npc(npc, hex) then
        return false
    end
    local in_phase = safe_call(Ability.IsInAbilityPhase, hex)
    if in_phase == true then
        return false
    end
    return true
end
local function get_hex_cast_range(caster, hex)
    return script.get_item_cast_range_for_npc(caster, hex, C.COMBO_HEX_RANGE_FALLBACK)
end
script.can_cast_combo_hex_now = function(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if script.get_control_break_reason(target, true) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local has_enabled_abyssal = false
    local has_enabled_atos = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if (not has_enabled_abyssal) and script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal) then
                has_enabled_abyssal = true
            end
            if (not has_enabled_atos) and script.get_enabled_item_by_names(meepo, script._combo_item_sets.atos) then
                has_enabled_atos = true
            end
            if has_enabled_abyssal and has_enabled_atos then
                break
            end
        end
    end
    local abyssal_remaining = has_enabled_abyssal and script.get_target_abyssal_remaining(target, now) or 0
    local atos_remaining = has_enabled_atos and script.get_target_atos_remaining(target, now) or 0
    if has_enabled_atos and atos_remaining > 0.10 then
        return false
    end
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > 0.20 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_hex_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local cast_point = tonumber(safe_call(Ability.GetCastPoint, hex, true) or 0) or 0
                    if cast_point < 0 then
                        cast_point = 0
                    end
                    local abyssal_gate = cast_point + C.COMBO_POOF_SAFE_ROOT_BUFFER
                    if abyssal_gate < C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW then
                        abyssal_gate = C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW
                    end
                    if (not has_enabled_abyssal) or abyssal_remaining <= abyssal_gate then
                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                        local dist = vec_dist_2d(meepo_pos, target_pos)
                        if dist then
                            local cast_range = get_hex_cast_range(meepo, hex)
                            if dist <= cast_range + C.COMBO_HEX_RANGE_PADDING then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end
local function try_combo_hex(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not script.can_cast_combo_hex_now(units, target, now) then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_hex_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_hex = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_hex_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local cast_range = get_hex_cast_range(meepo, hex)
                        if dist <= cast_range + C.COMBO_HEX_RANGE_PADDING then
                            if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                best_dist = dist
                                best_meepo = meepo
                                best_hex = hex
                            end
                        end
                    end
                end
            end
        end
    end
    if best_meepo and best_hex then
        local caster_key = get_entity_key(best_meepo)
        if attempt_frame >= 0 then
            script._combo_hex_last_frame_by_meepo[caster_key] = attempt_frame
        end
        script._combo_hex_last_attempt_global = now
        script._combo_hex_last_attempt_frame = attempt_frame
        local cast_ok = cast_target_item_budgeted(best_meepo, best_hex, target, "meepo_combo_hex")
        if cast_ok then
            combo_hex_last_cast = now
            combo_hex_last_cast_by_meepo[caster_key] = now
            return true
        end
    end
    return false
end
function script.try_combo_linken_break(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, "invalid_target"
    end
    if not script.is_target_linkens_protected(target) then
        return false, nil
    end
    if not units or #units == 0 then
        return false, "no_units"
    end
    if script.is_combo_option_enabled(ui.combo_control_break_checks)
        and safe_call(NPC.HasModifier, target, "modifier_item_lotus_orb_active") == true then
        return false, "lotus"
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, "no_position"
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local best_priority = 9999
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
            local dist = vec_dist_2d(meepo_pos, target_pos)
            if dist then
                for j = 1, #CFG.linken_break_items do
                    local item_name = CFG.linken_break_items[j]
                    if script.is_linken_breaker_item_enabled(item_name) then
                        local item = safe_call(NPC.GetItem, meepo, item_name, true)
                        if item and script.can_cast_target_item_now(meepo, item) then
                            local cast_range = script.get_item_cast_range_for_npc(meepo, item, 900)
                            if dist <= cast_range + 50 then
                                local should_take = false
                                if not best_item or j < best_priority then
                                    should_take = true
                                elseif j == best_priority and script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                    should_take = true
                                end
                                if should_take then
                                    best_priority = j
                                    best_dist = dist
                                    best_meepo = meepo
                                    best_item = item
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, "no_enabled_breaker"
    end
    local best_name = safe_call(Ability.GetName, best_item) or ""
    if best_name ~= "" and not script.is_linken_breaker_item_enabled(best_name) then
        return false, "disabled_breaker"
    end
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_break_linken", target_pos)
    if not cast_ok then
        return false, "cast_failed"
    end
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
    set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    return true, safe_call(Ability.GetName, best_item) or "item"
end
function script.try_combo_silence(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_silence_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_silence_remaining(target, now) > 0.25 then
        return false
    end
    if script.get_target_atos_remaining(target, now) > 0.10 then
        return false
    end
    if script.get_target_hex_remaining(target, now) > 0.20 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    script._combo_silence_last_by_meepo = script._combo_silence_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_key = get_entity_key(meepo)
            local last_frame = script._combo_silence_last_frame_by_meepo[meepo_key] or -1
            if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                local dist = vec_dist_2d(meepo_pos, target_pos)
                if dist then
                    for j = 1, #script._combo_item_sets.silence do
                        local item_name = script._combo_item_sets.silence[j]
                        if item_name and is_item_enabled(item_name) then
                            local silence_item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if silence_item and script.can_cast_target_item_now(meepo, silence_item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, silence_item, 900)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_dist = dist
                                        best_meepo = meepo
                                        best_item = silence_item
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local caster_key = get_entity_key(best_meepo)
    if attempt_frame >= 0 then
        script._combo_silence_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_silence_last_attempt_global = now
    script._combo_silence_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_silence")
    if cast_ok then
        script._combo_silence_last_global = now
        script._combo_silence_last_by_meepo[caster_key] = now
        return true
    end
    return false
end
function script.try_combo_atos(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_atos_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_abyssal_remaining(target, now) > 0.35 then
        return false
    end
    if script.get_target_hex_remaining(target, now) > 0.35 then
        return false
    end
    if script.get_target_atos_remaining(target, now) > 0.25 then
        return false
    end
    if get_effective_earthbind_remaining(target, now) > 0.65 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    script._combo_atos_last_by_meepo = script._combo_atos_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_key = get_entity_key(meepo)
            local last_frame = script._combo_atos_last_frame_by_meepo[meepo_key] or -1
            if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                local dist = vec_dist_2d(meepo_pos, target_pos)
                if dist then
                    for j = 1, #script._combo_item_sets.atos do
                        local item_name = script._combo_item_sets.atos[j]
                        if item_name and is_item_enabled(item_name) then
                            local root_item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if root_item and script.can_cast_target_item_now(meepo, root_item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, root_item, 1100)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_dist = dist
                                        best_meepo = meepo
                                        best_item = root_item
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local caster_key = get_entity_key(best_meepo)
    if attempt_frame >= 0 then
        script._combo_atos_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_atos_last_attempt_global = now
    script._combo_atos_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_atos", target_pos)
    if cast_ok then
        script._combo_atos_last_global = now
        script._combo_atos_last_by_meepo[caster_key] = now
        local cast_point = tonumber(safe_call(Ability.GetCastPoint, best_item, true) or 0) or 0
        if cast_point < 0 then
            cast_point = 0
        end
        local item_name = safe_call(Ability.GetName, best_item) or ""
        local projectile_speed = script.get_item_special_value(best_item, "projectile_speed", "speed", 0)
        local duration = script.get_item_special_value(best_item, "duration", "ensnare_duration", 2.0)
        local travel = 0
        if item_name == "item_gleipnir" then
            travel = script.get_item_special_value(best_item, "activation_delay", "delay", 0.30)
            if travel < 0 then
                travel = 0
            end
        elseif projectile_speed > 0 then
            travel = (best_dist or 0) / math.max(1, projectile_speed)
        end
        local arrival = now + cast_point + travel
        script._combo_atos_pending_target_key = get_entity_key(target)
        script._combo_atos_pending_end_time = arrival + duration
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.try_combo_item_on_target(units, target, item_names, tag, fallback_range, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if not units or #units == 0 or not item_names then
        return false, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, nil
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local target_linkens = script.is_target_linkens_protected(target)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
            local dist = vec_dist_2d(meepo_pos, target_pos)
            if dist then
                for j = 1, #item_names do
                    local item_name = item_names[j]
                    if item_name and item_name ~= "" and is_item_enabled(item_name) then
                        local can_use_item = true
                        if target_linkens and not script.is_linken_breaker_item_enabled(item_name) then
                            can_use_item = false
                        end
                        if can_use_item then
                            local item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if item and script.can_cast_target_item_now(meepo, item) then
                                local cast_range = script.get_item_cast_range_for_npc(meepo, item, fallback_range or 800)
                                if dist <= cast_range + 50 then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_meepo = meepo
                                        best_item = item
                                        best_dist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, tag, target_pos)
    if cast_ok then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, safe_call(Ability.GetName, best_item) or ""
    end
    return false, nil
end
function script.is_meepo_windwalked(meepo)
    if not meepo then
        return false
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_silver_edge_windwalk") == true then
        return true
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_invisibility_edge_windwalk") == true then
        return true
    end
    if safe_call(NPC.HasModifier, meepo, "modifier_item_shadow_amulet_fade") == true then
        return true
    end
    return script.has_modifier_state(meepo, "MODIFIER_STATE_INVISIBLE")
end
function script.try_combo_item_no_target(units, item_names, tag, now, target, max_distance, require_not_windwalked)
    if not units or #units == 0 or not item_names then
        return false, nil
    end
    local target_pos = nil
    if target and Entity.IsAlive(target) then
        target_pos = safe_call(Entity.GetAbsOrigin, target)
    end
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if not require_not_windwalked or not script.is_meepo_windwalked(meepo) then
                local dist = 0
                if target_pos then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    dist = vec_dist_2d(meepo_pos, target_pos) or 99999
                    if max_distance and max_distance > 0 and dist > max_distance then
                        dist = nil
                    end
                end
                if dist ~= nil then
                    for j = 1, #item_names do
                        local item_name = item_names[j]
                        if item_name and item_name ~= "" and is_item_enabled(item_name) then
                            local item = safe_call(NPC.GetItem, meepo, item_name, true)
                            if item and script.cast_no_target_item_budgeted and script.can_cast_target_item_now then
                                if script.can_cast_target_item_now(meepo, item) then
                                    if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                                        best_meepo = meepo
                                        best_item = item
                                        best_dist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    if script.cast_no_target_item_budgeted(best_meepo, best_item, tag) then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, safe_call(Ability.GetName, best_item) or ""
    end
    return false, nil
end
function script.try_combo_armlet_control(units, should_enable, now)
    if not units or #units == 0 then
        return false
    end
    if should_enable and not is_item_enabled("item_armlet") then
        return false
    end
    if (not should_enable) and not script._combo_armlet_forced_on then
        return false
    end
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local best_meepo = nil
    local best_item = nil
    local best_pref = false
    local armlet_active_found = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local armlet = safe_call(NPC.GetItem, meepo, "item_armlet", true)
            local armlet_cast_ok = false
            if armlet then
                if should_enable then
                    armlet_cast_ok = script.can_cast_target_item_now(meepo, armlet)
                else
                    armlet_cast_ok = can_cast_ability_for_npc(meepo, armlet) and safe_call(Ability.IsInAbilityPhase, armlet) ~= true
                end
            end
            if armlet and armlet_cast_ok then
                local active = safe_call(NPC.HasModifier, meepo, "modifier_item_armlet_unholy_strength") == true
                if active then
                    armlet_active_found = true
                end
                if (should_enable and not active) or ((not should_enable) and active) then
                    local is_pref = preferred_key and get_entity_key(meepo) == preferred_key or false
                    if not best_meepo or (is_pref and not best_pref) then
                        best_meepo = meepo
                        best_item = armlet
                        best_pref = is_pref
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        if not should_enable and not armlet_active_found then
            script._combo_armlet_forced_on = false
        end
        return false
    end
    if script.cast_no_target_item_budgeted(best_meepo, best_item, should_enable and "meepo_combo_armlet_on" or "meepo_combo_armlet_off") then
        script._combo_armlet_forced_on = should_enable and true or false
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.try_combo_phase_shadow_engage(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.12 then
        return false, nil
    end
    local casted, cast_name = script.try_combo_item_no_target(
        units,
        script._combo_item_sets.phase,
        "meepo_combo_phase",
        now,
        target,
        1400,
        false
    )
    if casted then
        return true, cast_name
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.shadow,
        "meepo_combo_shadow",
        now,
        target,
        1400,
        true
    )
end
function script.try_combo_diffusal_disperser(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if script.get_control_break_reason(target, false) then
        return false, nil
    end
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local target_key = get_entity_key(target)
    local since_global = now_time - (tonumber(script._combo_purge_last_global or -9999) or -9999)
    if since_global < (tonumber(C.COMBO_PURGE_GLOBAL_RECAST_DELAY or 0.65) or 0.65) then
        return false, nil
    end
    if target_key and script._combo_purge_last_target_key == target_key then
        if since_global < (tonumber(C.COMBO_PURGE_SAME_TARGET_RECAST_DELAY or 1.25) or 1.25) then
            return false, nil
        end
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - (tonumber(script._combo_purge_last_attempt_frame or -1) or -1)
        if gap <= (tonumber(C.COMBO_ITEM_FRAME_GAP or 3) or 3) then
            return false, nil
        end
    end
    script._combo_purge_last_attempt_global = now_time
    script._combo_purge_last_attempt_frame = attempt_frame
    local casted, cast_name = script.try_combo_item_on_target(
        units,
        target,
        script._combo_item_sets.purge,
        "meepo_combo_purge",
        700,
        now_time
    )
    if casted then
        script._combo_purge_last_global = now_time
        script._combo_purge_last_target_key = target_key
    end
    return casted, cast_name
end
function script.try_combo_grenade(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.20 then
        return false, nil
    end
    return script.try_combo_item_on_target(
        units,
        target,
        script._combo_item_sets.grenade,
        "meepo_combo_grenade",
        900,
        now
    )
end
function script.try_combo_manta_after_net(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) <= 0.05 then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.manta,
        "meepo_combo_manta_after_net",
        now,
        target,
        650,
        false
    )
end
function script.try_combo_mjollnir_self(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if not units or #units == 0 then
        return false, nil
    end
    if not is_item_enabled("item_mjollnir") then
        return false, nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false, nil
    end
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if safe_call(NPC.HasModifier, meepo, "modifier_item_mjollnir_shield") ~= true then
                local mjollnir = safe_call(NPC.GetItem, meepo, "item_mjollnir", true)
                if mjollnir and script.can_cast_target_item_now(meepo, mjollnir) then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist and dist <= 900 then
                        if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                            best_meepo = meepo
                            best_item = mjollnir
                            best_dist = dist
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false, nil
    end
    if cast_target_item_budgeted(best_meepo, best_item, best_meepo, "meepo_combo_mjollnir_self") then
        combo_move_next_order_time = math.max(combo_move_next_order_time, (now or get_game_time()) + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true, "item_mjollnir"
    end
    return false, nil
end
function script.try_combo_blademail_close(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.blademail,
        "meepo_combo_blademail",
        now,
        target,
        420,
        false
    )
end
function script.try_combo_mom_finish(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false, nil
    end
    if get_effective_earthbind_remaining(target, now) > 0.05 then
        return false, nil
    end
    return script.try_combo_item_no_target(
        units,
        script._combo_item_sets.mom,
        "meepo_combo_mom_finish",
        now,
        target,
        650,
        false
    )
end
function script.try_combo_abyssal(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    local attempt_frame = -1
    if GlobalVars and GlobalVars.GetFrameCount then
        attempt_frame = tonumber(safe_call(GlobalVars.GetFrameCount) or -1) or -1
    end
    if attempt_frame >= 0 then
        local gap = attempt_frame - script._combo_abyssal_last_attempt_frame
        if gap <= C.COMBO_ITEM_FRAME_GAP then
            return false
        end
    end
    if script.get_target_abyssal_remaining(target, now) > 0.25 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local target_key = get_entity_key(target)
    local recent_blink_until = script._combo_abyssal_recent_blink_until or 0
    if recent_blink_until > 0 and now > recent_blink_until then
        script._combo_abyssal_recent_blink_until = 0
        script._combo_abyssal_recent_blink_target_key = nil
        script._combo_abyssal_recent_blink_caster_key = nil
    end
    script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
    local best_meepo = nil
    local best_item = nil
    local best_dist = nil
    local best_range = 0
    local preferred_key = script.get_combo_main_priority_key(safe_call(Heroes.GetLocal))
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            if abyssal and script.can_cast_target_item_now(meepo, abyssal) then
                local meepo_key = get_entity_key(meepo)
                local last_frame = script._combo_abyssal_last_frame_by_meepo[meepo_key] or -1
                if attempt_frame < 0 or (attempt_frame - last_frame) > C.COMBO_ITEM_FRAME_GAP then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local cast_range = script.get_item_cast_range(abyssal, 600)
                        local cast_bonus = tonumber(safe_call(NPC.GetCastRangeBonus, meepo) or 0) or 0
                        if cast_bonus > 0 then
                            cast_range = cast_range + cast_bonus
                        end
                        if script.should_take_combo_candidate(meepo, dist, best_meepo, best_dist, preferred_key) then
                            best_dist = dist
                            best_meepo = meepo
                            best_item = abyssal
                            best_range = cast_range
                        end
                    end
                end
            end
        end
    end
    if not best_meepo or not best_item then
        return false
    end
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, best_item, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > (cast_point + C.COMBO_POOF_SAFE_ROOT_BUFFER) then
        return false
    end
    local anchor = nil
    if combo_focus_source and Entity.IsAlive(combo_focus_source) and script.is_unit_in_units_list(combo_focus_source, units) then
        anchor = combo_focus_source
    end
    if (not anchor or not Entity.IsAlive(anchor)) and best_meepo and Entity.IsAlive(best_meepo) and script.is_unit_in_units_list(best_meepo, units) then
        anchor = best_meepo
    end
    if not anchor then
        local main_anchor = get_main_meepo(safe_call(Heroes.GetLocal))
        if main_anchor and Entity.IsAlive(main_anchor) and script.is_unit_in_units_list(main_anchor, units) then
            anchor = main_anchor
        end
    end
    if not anchor then
        anchor = script.pick_first_alive_unit(units)
    end
    local poof_clones = {}
    if anchor then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                poof_clones[#poof_clones + 1] = meepo
            end
        end
    end
    local function prepare_abyssal_poof()
        if not anchor or not Entity.IsAlive(anchor) then
            return 0
        end
        if not poof_clones or #poof_clones == 0 then
            return 0
        end
        local poof_time = now + math.max(0, cast_point)
        return schedule_poof_burst(poof_clones, anchor, poof_time, "meepo_combo_abyssal_poof", 0, target_pos)
    end
    local caster_key = get_entity_key(best_meepo)
    if (best_dist or 99999) > (best_range + 40) then
        local local_hero = safe_call(Heroes.GetLocal)
        local blinked = false
        if local_hero then
            blinked = script.try_combo_blink_sync(local_hero, units, target, now, units) == true
        end
        if blinked then
            script._combo_abyssal_recent_blink_until = now + 0.75
            script._combo_abyssal_recent_blink_target_key = target_key
            script._combo_abyssal_recent_blink_caster_key = caster_key
            return true
        end
        if (script._combo_abyssal_recent_blink_until or 0) > now
            and script._combo_abyssal_recent_blink_target_key == target_key
            and script._combo_abyssal_recent_blink_caster_key == caster_key then
            return true
        end
        return false
    end
    if attempt_frame >= 0 then
        script._combo_abyssal_last_frame_by_meepo[caster_key] = attempt_frame
    end
    script._combo_abyssal_last_attempt_global = now
    script._combo_abyssal_last_attempt_frame = attempt_frame
    local cast_ok = cast_target_item_budgeted(best_meepo, best_item, target, "meepo_combo_abyssal")
    if cast_ok then
        prepare_abyssal_poof()
        script._combo_abyssal_recent_blink_until = 0
        script._combo_abyssal_recent_blink_target_key = nil
        script._combo_abyssal_recent_blink_caster_key = nil
        script._combo_abyssal_last_global = now
        script._combo_abyssal_last_by_meepo[caster_key] = now
        local duration = script.get_item_special_value(best_item, "stun_duration", "duration", 0)
        local alt_duration = script.get_item_special_value(best_item, "bash_duration", "active_duration", 0)
        if alt_duration > duration then
            duration = alt_duration
        end
        if duration <= 0 then
            duration = 1.6
        end
        script._combo_abyssal_pending_target_key = target_key
        script._combo_abyssal_pending_end_time = now + cast_point + duration
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_ACTION_MIN_INTERVAL)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
        return true
    end
    return false
end
function script.has_ready_abyssal_for_combo(units, target, now)
    local break_reason = script.get_control_break_reason(target, true)
    if break_reason then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if not units or #units == 0 then
        return false
    end
    if script.get_target_abyssal_remaining(target, now) > 0.25 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    script._combo_abyssal_last_by_meepo = script._combo_abyssal_last_by_meepo or {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            if abyssal and script.can_cast_target_item_now(meepo, abyssal) then
                local meepo_key = get_entity_key(meepo)
                local last_cast = script._combo_abyssal_last_by_meepo[meepo_key] or -9999
                if now - last_cast >= 0.22 then
                    local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local dist = vec_dist_2d(meepo_pos, target_pos)
                    if dist then
                        local cast_range = script.get_item_cast_range_for_npc(meepo, abyssal, 600)
                        if dist <= (cast_range + 40) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end
local function has_combo_item_equipped(units, item_names)
    if not units or #units == 0 or not item_names then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local item = script.get_enabled_item_by_names(meepo, item_names)
            if item then
                return true
            end
        end
    end
    return false
end
local function has_any_combo_items_equipped(local_hero, units)
    if has_combo_item_equipped(units, script._combo_item_sets.purge) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.silence) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.atos) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.abyssal) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.grenade) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.phase) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.shadow) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.mjollnir) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.mom) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.armlet) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.manta) then
        return true
    end
    if has_combo_item_equipped(units, script._combo_item_sets.blademail) then
        return true
    end
    if units and #units > 0 then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local hex = get_hex_item(meepo)
                if hex then
                    return true
                end
            end
        end
    end
    if units and #units > 0 then
        for i = 1, #units do
            local meepo = units[i]
            if meepo and Entity.IsAlive(meepo) then
                local blink = get_blink_item(meepo)
                if blink then
                    return true
                end
            end
        end
    end
    return false
end
local function has_ready_hex_for_combo(units)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local hex = get_hex_item(meepo)
            if hex and can_cast_hex_now(meepo, hex) then
                return true
            end
        end
    end
    return false
end
local function is_meepo_net_ready_for_combo(meepo, now)
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
    if not net or not can_cast_ability_for_npc(meepo, net) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, net) == true then
        return false
    end
    local meepo_key = get_entity_key(meepo)
    local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
    if now - last_cast < C.COMBO_NET_CASTER_RECAST_DELAY then
        return false
    end
    return true
end
local function has_any_meepo_net_ready_for_combo(units, now)
    if not units or #units == 0 then
        return false
    end
    for i = 1, #units do
        local meepo = units[i]
        if is_meepo_net_ready_for_combo(meepo, now) then
            return true
        end
    end
    return false
end
function script.is_tp_particle_name(name, full_name)
    local short = string.lower(tostring(name or ""))
    local full = string.lower(tostring(full_name or ""))
    if short == "" and full == "" then
        return false
    end
    if string.find(short, "teleport", 1, true) or string.find(full, "teleport", 1, true) then
        return true
    end
    if string.find(short, "furion_teleport", 1, true) or string.find(full, "furion_teleport", 1, true) then
        return true
    end
    return false
end
function script.cleanup_tp_fog_cache(now)
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local particles = script._tp_fog_particles or {}
    for idx, rec in pairs(particles) do
        local expires = tonumber(rec and rec.expires or 0) or 0
        if expires <= sample_now then
            particles[idx] = nil
        end
    end
    script._tp_fog_particles = particles
    local cache = script._tp_fog_cache_by_target_key or {}
    for target_key, rec in pairs(cache) do
        local expires = tonumber(rec and rec.expires or 0) or 0
        if expires <= sample_now then
            cache[target_key] = nil
        end
    end
    script._tp_fog_cache_by_target_key = cache
end
function script.cleanup_tp_interrupt_locks(now)
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local locks = script._tp_interrupt_lock_by_target_key or {}
    for key, rec in pairs(locks) do
        local until_t = tonumber(rec and rec["until"] or 0) or 0
        if until_t <= sample_now then
            locks[key] = nil
        end
    end
    script._tp_interrupt_lock_by_target_key = locks
end
function script.get_tp_fog_cache_for_target(target, now)
    if not target then
        return nil
    end
    local target_key = get_entity_key(target)
    if not target_key then
        return nil
    end
    script.cleanup_tp_fog_cache(now)
    local cache = script._tp_fog_cache_by_target_key or {}
    local entry = cache[target_key]
    if not entry then
        return nil
    end
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local expires = tonumber(entry.expires or 0) or 0
    if expires <= sample_now then
        cache[target_key] = nil
        return nil
    end
    return entry
end
function script.is_tp_interrupt_net_globally_locked(now)
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    local until_t = tonumber(script._tp_interrupt_global_lock_until or 0) or 0
    return sample_now < until_t
end
function script.collect_tp_fog_cast_points(now)
    local sample_now = tonumber(now or get_game_time() or 0) or 0
    script.cleanup_tp_fog_cache(sample_now)
    local out = {}
    local particles = script._tp_fog_particles or {}
    for idx, rec in pairs(particles) do
        if rec and rec.pos then
            local expires = tonumber(rec.expires or 0) or 0
            if expires > sample_now and not rec.target_key then
                out[#out + 1] = {
                    id = idx,
                    pos = rec.pos,
                    remaining = expires - sample_now,
                }
            end
        end
    end
    return out
end
function script.track_tp_particle_data(data, event_name)
    if not data then
        return
    end
    local idx = tonumber(data.index or -1) or -1
    if idx < 0 then
        return
    end
    local now = tonumber(get_game_time() or 0) or 0
    local particles = script._tp_fog_particles or {}
    local cache = script._tp_fog_cache_by_target_key or {}
    if event_name == "destroy" then
        local rec = particles[idx]
        if rec then
            local keep_until = now + (tonumber(C.TP_FOG_DESTROY_GRACE or 0.40) or 0.40)
            local target_key = rec.target_key
            if target_key then
                local cached = cache[target_key]
                if not cached then
                    cached = {}
                    cache[target_key] = cached
                end
                if rec.pos then
                    cached.pos = rec.pos
                end
                local cached_expires = tonumber(cached.expires or 0) or 0
                if keep_until > cached_expires then
                    cached.expires = keep_until
                end
            end
            rec.expires = keep_until
            rec.destroyed = true
            particles[idx] = rec
        else
            particles[idx] = nil
        end
        script._tp_fog_particles = particles
        script._tp_fog_cache_by_target_key = cache
        script.cleanup_tp_fog_cache(now)
        return
    end
    local rec = particles[idx]
    if rec then
        if not script.is_combo_option_enabled(ui.net_on_tp_fog) then
            return
        end
        if data.position then
            rec.pos = data.position
        end
        rec.destroyed = false
        local target = data.entityForModifiers or data.entity
        local target_key = nil
        if target and Entity.IsAlive(target) and Entity.IsHero(target) and safe_call(NPC.IsIllusion, target) ~= true then
            local local_hero = safe_call(Heroes.GetLocal)
            local local_team = tonumber(local_hero and safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
            local target_team = tonumber(safe_call(Entity.GetTeamNum, target) or -2) or -2
            if local_team < 0 or target_team ~= local_team then
                target_key = get_entity_key(target)
            end
        end
        rec.target_key = target_key
        local refresh = now + (tonumber(C.TP_FOG_TRACK_DURATION or 3.35) or 3.35)
        local rec_expires = tonumber(rec.expires or 0) or 0
        if refresh > rec_expires then
            rec.expires = refresh
            rec_expires = refresh
        end
        local target_key = rec.target_key
        if target_key then
            local cached = cache[target_key] or {}
            if rec.pos then
                cached.pos = rec.pos
            end
            cached.expires = rec_expires
            cache[target_key] = cached
        end
        particles[idx] = rec
        script._tp_fog_particles = particles
        script._tp_fog_cache_by_target_key = cache
        return
    end
    if not script.is_combo_option_enabled(ui.net_on_tp_fog) then
        return
    end
    if not script.is_tp_particle_name(data.name, data.fullName) then
        return
    end
    local rec = particles[idx] or {}
    local target = data.entityForModifiers or data.entity
    rec.target_key = nil
    if target and Entity.IsAlive(target) and Entity.IsHero(target) and safe_call(NPC.IsIllusion, target) ~= true then
        local local_hero = safe_call(Heroes.GetLocal)
        local local_team = tonumber(local_hero and safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
        local target_team = tonumber(safe_call(Entity.GetTeamNum, target) or -2) or -2
        if local_team < 0 or target_team ~= local_team then
            rec.target_key = get_entity_key(target)
        end
    end
    if data.position then
        rec.pos = data.position
    elseif not rec.pos then
        rec.pos = target and safe_call(Entity.GetAbsOrigin, target) or nil
    end
    rec.destroyed = false
    rec.expires = now + (tonumber(C.TP_FOG_TRACK_DURATION or 3.35) or 3.35)
    particles[idx] = rec
    local target_key = rec.target_key
    if target_key then
        local cached = cache[target_key] or {}
        if rec.pos then
            cached.pos = rec.pos
        end
        cached.expires = rec.expires
        cache[target_key] = cached
    end
    script._tp_fog_particles = particles
    script._tp_fog_cache_by_target_key = cache
end
function script.get_target_teleport_remaining(target, now)
    if not target or not Entity.IsAlive(target) then
        return 0
    end
    local best_remaining = 0
    local had_teleport_modifier = false
    local candidates = script._tp_teleport_modifier_candidates or {}
    for i = 1, #candidates do
        local mod_name = candidates[i]
        local has_mod = safe_call(NPC.HasModifier, target, mod_name) == true
        local mod = safe_call(NPC.GetModifier, target, mod_name)
        if has_mod or mod then
            had_teleport_modifier = true
            if mod then
                local remaining = get_modifier_remaining_time(mod, now)
                if remaining > best_remaining then
                    best_remaining = remaining
                end
            elseif best_remaining <= 0 then
                best_remaining = 0.20
            end
        end
    end
    if NPC.GetModifiers and Modifier and Modifier.GetName then
        local mods = safe_call(NPC.GetModifiers, target)
        if mods then
            for i = 1, #mods do
                local mod = mods[i]
                local mod_name = safe_call(Modifier.GetName, mod)
                if mod_name then
                    local lower_name = string.lower(mod_name)
                    if string.find(lower_name, "teleport", 1, true) then
                        had_teleport_modifier = true
                        local remaining = get_modifier_remaining_time(mod, now)
                        if remaining > best_remaining then
                            best_remaining = remaining
                        end
                    end
                end
            end
        end
    end
    if had_teleport_modifier and best_remaining <= 0 then
        best_remaining = 0.01
    end
    local cached = script.get_tp_fog_cache_for_target(target, now)
    if cached then
        local sample_now = tonumber(now or get_game_time() or 0) or 0
        local cached_remaining = (tonumber(cached.expires or 0) or 0) - sample_now
        if cached_remaining > best_remaining then
            best_remaining = cached_remaining
        end
    end
    if best_remaining < 0 then
        best_remaining = 0
    end
    return best_remaining
end
function script.try_net_on_teleport(local_hero, meepos, now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local global_lock_until = tonumber(script._tp_interrupt_global_lock_until or 0) or 0
    if now_time < global_lock_until then
        return false
    end
    local net_on_tp_enabled = script.is_combo_option_enabled(ui.net_on_tp)
    if not net_on_tp_enabled then
        return false
    end
    local combo_active = is_combo_active()
    if combo_active and combo_focus_target and Entity.IsAlive(combo_focus_target) then
        return false
    end
    local allow_visible_tp_net = true
    if script.is_combo_option_enabled(ui.net_on_tp_combo_only) and not combo_active then
        allow_visible_tp_net = false
    end
    local allow_fog = script.is_combo_option_enabled(ui.net_on_tp_fog)
    if allow_fog and script.is_combo_option_enabled(ui.net_on_tp_fog_combo_only) and not combo_active then
        allow_fog = false
    end
    if not allow_visible_tp_net and not allow_fog then
        return false
    end
    if not local_hero or not Entity.IsAlive(local_hero) then
        return false
    end
    local units = collect_owned_meepo_units(local_hero, meepos)
    if not units or #units == 0 then
        return false
    end
    script.cleanup_tp_fog_cache(now)
    script.cleanup_tp_interrupt_locks(now)
    local tp_locks = script._tp_interrupt_lock_by_target_key or {}
    script._tp_interrupt_lock_by_target_key = tp_locks
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local best_target = nil
    local best_caster = nil
    local best_net = nil
    local best_cast_pos = nil
    local best_target_key = nil
    local best_source_is_fog_point = false
    local best_arrival = nil
    local best_margin = nil
    local best_can_catch = false
    local best_tp_remaining = 0
    -- Disabled anonymous fog particle cast-points: they can generate false positives
    -- and cause "random" net casts. We now rely on tracked enemy targets only.
    local fog_points = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net and can_cast_ability_for_npc(meepo, net) and safe_call(Ability.IsInAbilityPhase, net) ~= true then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                if now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY and now - combo_net_last_global_cast >= C.COMBO_NET_GLOBAL_RECAST_DELAY then
                    local cast_range = get_net_cast_range(meepo, net) + C.COMBO_NET_RANGE_PADDING
                    local enemies = nil
                    if allow_fog then
                        enemies = safe_call(Heroes.GetAll)
                    else
                        enemies = Entity.GetHeroesInRadius(
                            meepo,
                            cast_range + 80,
                            Enum.TeamType.TEAM_ENEMY,
                            true,
                            true
                        )
                    end
                    if enemies then
                        for j = 1, #enemies do
                            local enemy = enemies[j]
                            if enemy and Entity.IsAlive(enemy) and not safe_call(NPC.IsIllusion, enemy) then
                                local enemy_team = tonumber(safe_call(Entity.GetTeamNum, enemy) or -2) or -2
                                local enemy_visible = safe_call(NPC.IsVisible, enemy) == true
                                local visibility_ok = (enemy_visible and allow_visible_tp_net) or ((not enemy_visible) and allow_fog)
                                local enemy_valid = (local_team < 0 or enemy_team ~= local_team)
                                    and visibility_ok
                                if enemy_valid then
                                    local enemy_target_key = get_entity_key(enemy)
                                    local tp_remaining = script.get_target_teleport_remaining(enemy, now)
                                    if tp_remaining > 0 and enemy_target_key then
                                        local lock_rec = tp_locks[enemy_target_key]
                                        if lock_rec then
                                            local lock_until = tonumber(lock_rec["until"] or 0) or 0
                                            if tp_remaining <= 0.05 or now >= lock_until then
                                                tp_locks[enemy_target_key] = nil
                                            else
                                                tp_remaining = 0
                                            end
                                        end
                                    end
                                    if tp_remaining > 0 then
                                        local fog_cache = allow_fog and script.get_tp_fog_cache_for_target(enemy, now) or nil
                                        local enemy_pos = nil
                                        if fog_cache and fog_cache.pos then
                                            enemy_pos = fog_cache.pos
                                        end
                                        if not enemy_pos then
                                            enemy_pos = safe_call(Entity.GetAbsOrigin, enemy)
                                        end
                                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                                        local cast_pos = enemy_pos
                                        if safe_call(NPC.IsVisible, enemy) == true then
                                            cast_pos = script.get_simple_net_position(meepo, enemy, net, now) or enemy_pos
                                        end
                                        local dist = vec_dist_2d(meepo_pos, cast_pos)
                                        if enemy_pos and meepo_pos and dist and dist <= cast_range then
                                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                                            if cast_point < 0 then
                                                cast_point = 0
                                            end
                                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                                            if turn_time < 0 then
                                                turn_time = 0
                                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                                            end
                                            local speed = get_earthbind_projectile_speed(net)
                                            local travel = dist / math.max(1, speed)
                                            local time_to_land = turn_time + cast_point + travel
                                            local arrival = now + time_to_land
                                            local margin = tp_remaining - time_to_land
                                            local can_catch = margin >= -0.05
                                            local take = false
                                            if not best_caster then
                                                take = true
                                            elseif can_catch and not best_can_catch then
                                                take = true
                                            elseif can_catch == best_can_catch then
                                                if can_catch then
                                                    if not best_arrival or arrival < best_arrival then
                                                        take = true
                                                    end
                                                elseif not best_margin or margin > best_margin then
                                                    take = true
                                                end
                                            end
                                            if take then
                                                best_target = enemy
                                                best_caster = meepo
                                                best_net = net
                                                best_cast_pos = cast_pos
                                                best_target_key = enemy_target_key
                                                best_source_is_fog_point = false
                                                best_arrival = arrival
                                                best_margin = margin
                                                best_can_catch = can_catch
                                                best_tp_remaining = tp_remaining
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if allow_fog and fog_points and #fog_points > 0 then
                        for fp = 1, #fog_points do
                            local fog_point = fog_points[fp]
                            local cast_pos = fog_point and fog_point.pos or nil
                            local fog_target_key = "fog:" .. tostring((fog_point and fog_point.id) or 0)
                            local tp_remaining = tonumber(fog_point and fog_point.remaining or 0) or 0
                            local fog_lock = tp_locks[fog_target_key]
                            if fog_lock then
                                local lock_until = tonumber(fog_lock["until"] or 0) or 0
                                if tp_remaining <= 0.05 or now >= lock_until then
                                    tp_locks[fog_target_key] = nil
                                else
                                    tp_remaining = 0
                                end
                            end
                            local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                            local dist = cast_pos and meepo_pos and vec_dist_2d(meepo_pos, cast_pos) or nil
                            if cast_pos and meepo_pos and dist and dist <= cast_range and tp_remaining > 0 then
                                local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                                if cast_point < 0 then
                                    cast_point = 0
                                end
                                local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                                if turn_time < 0 then
                                    turn_time = 0
                                elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                    turn_time = C.COMBO_NET_FACE_TIME_CAP
                                end
                                local speed = get_earthbind_projectile_speed(net)
                                local travel = dist / math.max(1, speed)
                                local time_to_land = turn_time + cast_point + travel
                                local arrival = now + time_to_land
                                local margin = tp_remaining - time_to_land
                                local can_catch = margin >= -0.05
                                local take = false
                                if not best_caster then
                                    take = true
                                elseif can_catch and not best_can_catch then
                                    take = true
                                elseif can_catch == best_can_catch then
                                    if can_catch then
                                        if not best_arrival or arrival < best_arrival then
                                            take = true
                                        end
                                    elseif not best_margin or margin > best_margin then
                                        take = true
                                    end
                                end
                                if take then
                                    best_target = nil
                                    best_caster = meepo
                                    best_net = net
                                    best_cast_pos = cast_pos
                                    best_target_key = fog_target_key
                                    best_source_is_fog_point = true
                                    best_arrival = arrival
                                    best_margin = margin
                                    best_can_catch = can_catch
                                    best_tp_remaining = tp_remaining
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_caster or not best_net or not best_cast_pos then
        return false
    end
    if not best_can_catch then
        return false
    end
    if (tonumber(best_tp_remaining or 0) or 0) <= 0.10 then
        return false
    end
    if best_target_key then
        if (not best_source_is_fog_point)
            and script._combo_net_pending_target_key == best_target_key
            and (script._combo_net_pending_end_time or 0) > now
        then
            return false
        end
        local last_tp_key = script._tp_interrupt_last_target_key
        local last_tp_time = script._tp_interrupt_last_time or -9999
        if last_tp_key == best_target_key and (now - last_tp_time) < 1.20 then
            return false
        end
    end
    if best_source_is_fog_point and script._last_net_cast_pos then
        local last_cast_time = tonumber(script._last_net_cast_time or -9999) or -9999
        if (now - last_cast_time) < 0.65 then
            local same_spot_dist = vec_dist_2d(script._last_net_cast_pos, best_cast_pos)
            if same_spot_dist and same_spot_dist <= 120 then
                return false
            end
        end
    end
    local ok = pcall(function()
        Ability.CastPosition(
            best_net,
            best_cast_pos,
            false,
            true,
            true,
            "meepo_tp_interrupt_net",
            false
        )
    end)
    if not ok then
        return false
    end
    local caster_key = get_entity_key(best_caster)
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    script._tp_interrupt_last_target_key = best_target_key
    script._tp_interrupt_last_time = now
    if best_target_key then
        local lock_buffer = 0.45
        local target_tp_remaining = tonumber(best_tp_remaining or 0) or 0
        local lock_until = now + math.max(0.30, target_tp_remaining + lock_buffer)
        tp_locks[best_target_key] = {
            ["until"] = lock_until,
            cast = now,
        }
        script._tp_interrupt_lock_by_target_key = tp_locks
    end
    do
        local target_tp_remaining = tonumber(best_tp_remaining or 0) or 0
        local global_lock_sec = math.max(1.10, target_tp_remaining + 0.75)
        if global_lock_sec > 3.60 then
            global_lock_sec = 3.60
        end
        script._tp_interrupt_global_lock_until = now_time + global_lock_sec
    end
    script._last_net_cast_pos = best_cast_pos
    script._last_net_cast_time = now
    if best_arrival and best_target_key and not best_source_is_fog_point then
        script._combo_net_pending_target_key = best_target_key
        script._combo_net_pending_end_time = best_arrival + script.get_earthbind_root_duration(best_net)
    elseif best_source_is_fog_point then
        script._combo_net_pending_target_key = nil
        script._combo_net_pending_end_time = 0
    end
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    return true
end
function script.get_disable_ready_delay_for(meepo, ability)
    if not meepo or not ability then
        return nil
    end
    if can_cast_ability_for_npc(meepo, ability) and safe_call(Ability.IsInAbilityPhase, ability) ~= true then
        return 0
    end
    local cd = tonumber(safe_call(Ability.GetCooldown, ability) or 0) or 0
    if cd > 0 then
        return cd
    end
    local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
    local mana_cost = tonumber(safe_call(Ability.GetManaCost, ability) or 0) or 0
    if mana < mana_cost then
        return 1.20
    end
    return 0.20
end
function script.get_next_disable_ready_delay(local_hero, units, now)
    if not units or #units == 0 then
        return nil, nil
    end
    local preferred_key = script.get_combo_main_priority_key(local_hero)
    local best_delay = nil
    local best_source = nil
    local best_is_preferred = false
    local function consider_candidate(meepo, delay, source)
        if delay == nil then
            return
        end
        local is_preferred = preferred_key and get_entity_key(meepo) == preferred_key or false
        if best_delay == nil
            or delay < best_delay
            or (delay == best_delay and is_preferred and not best_is_preferred) then
            best_delay = delay
            best_source = source
            best_is_preferred = is_preferred
        end
    end
    local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            if net_enabled then
                local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
                consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, net), "net")
            end
            local hex = get_hex_item(meepo)
            consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, hex), "hex")
            local abyssal = script.get_enabled_item_by_names(meepo, script._combo_item_sets.abyssal)
            consider_candidate(meepo, script.get_disable_ready_delay_for(meepo, abyssal), "abyssal")
        end
    end
    return best_delay, best_source
end
function script.get_next_net_ready_delay(units, now)
    if not units or #units == 0 then
        return nil
    end
    local best_delay = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net then
                local meepo_key = get_entity_key(meepo)
                local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                local recast_left = C.COMBO_NET_CASTER_RECAST_DELAY - (now - last_cast)
                if recast_left < 0 then
                    recast_left = 0
                end
                local delay = nil
                if can_cast_ability_for_npc(meepo, net) and safe_call(Ability.IsInAbilityPhase, net) ~= true then
                    delay = recast_left
                else
                    local cd = tonumber(safe_call(Ability.GetCooldown, net) or 0) or 0
                    if cd > 0 then
                        delay = math.max(cd, recast_left)
                    else
                        local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
                        local mana_cost = tonumber(safe_call(Ability.GetManaCost, net) or 0) or 0
                        if mana < mana_cost then
                            delay = 1.20
                        else
                            delay = math.max(0.20, recast_left)
                        end
                    end
                end
                if delay ~= nil and (best_delay == nil or delay < best_delay) then
                    best_delay = delay
                end
            end
        end
    end
    return best_delay
end
script.can_cast_net_chain_now = function(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if script.get_control_break_reason(target, false) then
        return false
    end
    if is_net_projectile_in_flight(target, now) then
        return false
    end
    local confirmed_root = get_confirmed_control_remaining(target, now)
    if confirmed_root > C.COMBO_POOF_ROOT_MIN_REMAINING then
        local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
        if ready_count > 0 then
            local required_root = get_required_root_for_poof(ready_count, max_channel)
            if confirmed_root >= required_root then
                local target_pos = safe_call(Entity.GetAbsOrigin, target)
                if target_pos then
                    local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
                    local anchor = select(1, script.select_combo_poof_anchor(units, target_pos, allowed_anchor_dist))
                    if anchor then
                        return false
                    end
                end
            end
        end
    end
    local remaining_root = get_effective_earthbind_remaining(target, now)
    local _, _, arrival = choose_earthbind_caster(units, target, now)
    if not arrival then
        return false
    end
    local time_to_land = math.max(0, arrival - now)
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > (time_to_land + C.COMBO_NET_CHAIN_BUFFER) then
        return false
    end
    if remaining_root > 0 then
        local handoff_window = time_to_land + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
        if remaining_root > handoff_window then
            return false
        end
    end
    return true
end
local function can_cast_poof_burst_now(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    if root_remaining < required_root then
        if not (is_combo_spell_enabled("net", ui.combo_use_net) and script.can_cast_net_chain_now(units, target, now)) then
            return false
        end
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
    local anchor = select(1, script.select_combo_poof_anchor(units, target_pos, allowed_anchor_dist))
    return anchor ~= nil
end
local function can_cast_poof_burst_uncontrolled_now(units, target, now)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if tostring(script._combo_engage_mode or "") == "FAR" then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
    local anchor = select(1, script.select_combo_poof_anchor(units, target_pos, allowed_anchor_dist))
    return anchor ~= nil
end
local function schedule_follow_poof_after_net(units, net_caster, target, now, arrival_time)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return 0, 0
    end
    if not units or #units == 0 or not net_caster or not Entity.IsAlive(net_caster) then
        return 0, 0
    end
    local poof_units = {}
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            poof_units[#poof_units + 1] = meepo
        end
    end
    if #poof_units <= 0 then
        return 0, 0
    end
    local _, max_radius, max_channel = get_ready_poof_burst_info(poof_units, now)
    local poof_time = now + 0.01
    if arrival_time and arrival_time > 0 then
        local impact_buffer = tonumber(C.COMBO_POOF_SAFE_ROOT_BUFFER or 0.06) or 0.06
        if impact_buffer < 0 then
            impact_buffer = 0
        end
        local prechannel = math.max(0, max_channel - impact_buffer)
        local desired_time = arrival_time - prechannel
        if desired_time < (now + 0.01) then
            desired_time = now + 0.01
        end
        poof_time = desired_time
    end
    local anchor = nil
    local target_pos = target and safe_call(Entity.GetAbsOrigin, target) or nil
    if target_pos then
        local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
        local preferred_anchor = select(1, script.select_combo_poof_anchor(poof_units, target_pos, allowed_anchor_dist))
        if preferred_anchor and Entity.IsAlive(preferred_anchor) then
            anchor = preferred_anchor
        end
    end
    if (not anchor) and net_caster and Entity.IsAlive(net_caster) and target_pos then
        local net_caster_pos = safe_call(Entity.GetAbsOrigin, net_caster)
        local net_caster_dist = vec_dist_2d(net_caster_pos, target_pos)
        local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
        if net_caster_dist and net_caster_dist <= allowed_anchor_dist then
            anchor = net_caster
        end
    end
    if not anchor then
        return 0, 0
    end
    local scheduled = schedule_poof_burst(poof_units, anchor, poof_time, "meepo_combo_net_follow_poof", 0, target_pos)
    if scheduled <= 0 then
        return 0, 0
    end
    local lock = 0
    if max_channel > 0 then
        local delay = math.max(0, poof_time - now)
        lock = delay + max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
    end
    return scheduled, lock
end
function script.try_combo_ground_net(local_player, units, cursor_pos, now, preferred_caster)
    if not local_player or not units or #units == 0 or not cursor_pos then
        return false
    end
    if not is_combo_spell_enabled("net", ui.combo_use_net) then
        return false
    end
    if script.is_tp_interrupt_net_globally_locked and script.is_tp_interrupt_net_globally_locked(now) then
        return false
    end
    local next_allowed = tonumber(script._combo_ground_next_net_time or 0) or 0
    if now < next_allowed then
        return false
    end
    local last_cast_pos = script._combo_ground_last_cast_pos
    if last_cast_pos then
        local same_spot_delta = tonumber(C.COMBO_GROUND_NET_MIN_CURSOR_DELTA or 120) or 120
        if same_spot_delta < 40 then
            same_spot_delta = 40
        end
        local spot_dist = vec_dist_2d(last_cast_pos, cursor_pos) or 0
        if spot_dist <= same_spot_delta then
            return false
        end
    end
    if now - combo_net_last_global_cast < C.COMBO_NET_GLOBAL_RECAST_DELAY then
        return false
    end
    local preferred_key = nil
    if preferred_caster and Entity.IsAlive(preferred_caster) then
        preferred_key = get_entity_key(preferred_caster)
    end
    local best_caster = nil
    local best_net = nil
    local best_arrival = nil
    local best_cast_pos = nil
    local fallback_caster = nil
    local fallback_net = nil
    local fallback_arrival = nil
    local fallback_cast_pos = nil
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) then
            local net = safe_call(NPC.GetAbility, meepo, C.ABILITY_NET)
            if net and can_cast_ability_for_npc(meepo, net) then
                if safe_call(Ability.IsInAbilityPhase, net) ~= true and safe_call(Ability.IsChannelling, net) ~= true then
                    local meepo_key = get_entity_key(meepo)
                    local last_cast = combo_net_last_cast_by_meepo[meepo_key] or -9999
                    if now - last_cast >= C.COMBO_NET_CASTER_RECAST_DELAY then
                        local meepo_pos = safe_call(Entity.GetAbsOrigin, meepo)
                        if meepo_pos then
                            local cast_range = get_net_cast_range(meepo, net) + C.COMBO_NET_RANGE_PADDING
                            local cast_pos = cursor_pos
                            local dist = vec_dist_2d(meepo_pos, cast_pos) or 0
                            if dist > cast_range and dist > 0 then
                                local scale = cast_range / dist
                                cast_pos = Vector(
                                    (meepo_pos.x or 0) + ((cursor_pos.x or 0) - (meepo_pos.x or 0)) * scale,
                                    (meepo_pos.y or 0) + ((cursor_pos.y or 0) - (meepo_pos.y or 0)) * scale,
                                    cursor_pos.z or (meepo_pos.z or 0)
                                )
                                dist = cast_range
                            end
                            local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
                            if cast_point < 0 then
                                cast_point = 0
                            end
                            local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, meepo, cast_pos) or 0) or 0
                            if turn_time < 0 then
                                turn_time = 0
                            elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
                                turn_time = C.COMBO_NET_FACE_TIME_CAP
                            end
                            local speed = get_earthbind_projectile_speed(net)
                            local arrival = now + turn_time + cast_point + (dist / math.max(1, speed))
                            if preferred_key and meepo_key == preferred_key then
                                if not best_arrival or arrival < best_arrival then
                                    best_arrival = arrival
                                    best_caster = meepo
                                    best_net = net
                                    best_cast_pos = cast_pos
                                end
                            elseif not fallback_arrival or arrival < fallback_arrival then
                                fallback_arrival = arrival
                                fallback_caster = meepo
                                fallback_net = net
                                fallback_cast_pos = cast_pos
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_caster then
        best_caster = fallback_caster
        best_net = fallback_net
        best_arrival = fallback_arrival
        best_cast_pos = fallback_cast_pos
    end
    if not best_caster or not best_net or not best_cast_pos then
        return false
    end
    if not script.cast_position_single_unit(local_player, best_caster, best_net, best_cast_pos, "meepo_combo_ground_net", false) then
        return false
    end
    local caster_key = get_entity_key(best_caster)
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    script._last_net_cast_pos = best_cast_pos
    script._last_net_cast_time = now
    script._combo_ground_last_cast_pos = Vector(best_cast_pos.x or 0, best_cast_pos.y or 0, best_cast_pos.z or 0)
    script._combo_ground_last_cast_time = now
    script._combo_ground_next_net_time = now + (tonumber(C.COMBO_GROUND_NET_INTERVAL or 1.00) or 1.00)
    script._combo_net_pending_target_key = nil
    script._combo_net_pending_arrival_time = 0
    script._combo_net_pending_end_time = 0
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    return true
end
local function try_combo_earthbind_chain(units, target, now, preferred_caster)
    local break_reason = script.get_control_break_reason(target, false)
    if break_reason then
        return false
    end
    if script.is_tp_interrupt_net_globally_locked and script.is_tp_interrupt_net_globally_locked(now) then
        return false
    end
    if not is_combo_spell_enabled("net", ui.combo_use_net) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if is_net_projectile_in_flight(target, now) then
        return false
    end
    if now - combo_net_last_global_cast < C.COMBO_NET_GLOBAL_RECAST_DELAY then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local remaining_root = get_effective_earthbind_remaining(target, now)
    local caster, net, arrival, cast_pos = choose_earthbind_caster(units, target, now, preferred_caster)
    if not caster or not net or not arrival then
        return false
    end
    local time_to_land = math.max(0, arrival - now)
    local hex_remaining = script.get_target_hex_remaining(target, now)
    if hex_remaining > (time_to_land + C.COMBO_POOF_SAFE_ROOT_BUFFER) then
        return false
    end
    local abyssal_remaining = script.get_target_abyssal_remaining(target, now)
    if abyssal_remaining > (time_to_land + C.COMBO_NET_CHAIN_BUFFER) then
        return false
    end
    if remaining_root > 0 then
        local handoff_window = time_to_land + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
        if remaining_root > handoff_window then
            return false
        end
    end
    local confirmed_root = get_confirmed_control_remaining(target, now)
    if confirmed_root > C.COMBO_POOF_ROOT_MIN_REMAINING and can_cast_poof_burst_now(units, target, now) then
        return false
    end
    cast_pos = cast_pos or target_pos
    local caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    if caster_pos then
        local dist_to_cast = vec_dist_2d(caster_pos, cast_pos)
        local max_cast_dist = get_net_cast_range(caster, net) + C.COMBO_NET_RANGE_PADDING
        if dist_to_cast and dist_to_cast > max_cast_dist and dist_to_cast > 0 then
            local scale = max_cast_dist / dist_to_cast
            cast_pos = Vector(
                (caster_pos.x or 0) + ((cast_pos.x or 0) - (caster_pos.x or 0)) * scale,
                (caster_pos.y or 0) + ((cast_pos.y or 0) - (caster_pos.y or 0)) * scale,
                cast_pos.z or (caster_pos.z or 0)
            )
        end
    end
    script._last_net_cast_pos = cast_pos
    script._last_net_cast_time = now
    local ok = pcall(function()
        Ability.CastPosition(
            net,
            cast_pos,
            false,
            true,
            true,
            "meepo_combo_earthbind_chain",
            false
        )
    end)
    if not ok then
        return false
    end
    local caster_key = get_entity_key(caster)
    combo_net_last_cast_by_meepo[caster_key] = now
    combo_net_last_global_cast = now
    local cast_point = tonumber(safe_call(Ability.GetCastPoint, net, true) or 0) or 0
    if cast_point < 0 then
        cast_point = 0
    end
    caster_pos = safe_call(Entity.GetAbsOrigin, caster)
    local dist = (caster_pos and cast_pos) and (vec_dist_2d(caster_pos, cast_pos) or 0) or 0
    local turn_time = tonumber(safe_call(NPC.GetTimeToFacePosition, caster, cast_pos) or 0) or 0
    if turn_time < 0 then
        turn_time = 0
    elseif turn_time > C.COMBO_NET_FACE_TIME_CAP then
        turn_time = C.COMBO_NET_FACE_TIME_CAP
    end
    local speed = get_earthbind_projectile_speed(net)
    local arrival_time = now + turn_time + cast_point + (dist / math.max(1, speed))
    script._combo_net_pending_target_key = get_entity_key(target)
    script._combo_net_pending_arrival_time = arrival_time
    script._combo_net_pending_end_time = arrival_time + script.get_earthbind_root_duration(net)
    local follow_poof_count, follow_poof_lock = schedule_follow_poof_after_net(units, caster, target, now, arrival_time)
    script._combo_last_net_follow_poof_count = follow_poof_count or 0
    script._combo_last_net_follow_poof_time = now
    combo_move_next_order_time = math.max(combo_move_next_order_time, now + C.COMBO_NET_CAST_LOCK)
    set_combo_action_lock(now, C.COMBO_NET_CAST_LOCK)
    if follow_poof_lock and follow_poof_lock > 0 then
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + follow_poof_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return true
end
local function try_combo_poof_burst(units, target, now)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local required_root = get_required_root_for_poof(ready_count, max_channel)
    if root_remaining < required_root then
        if not (is_combo_spell_enabled("net", ui.combo_use_net) and script.can_cast_net_chain_now(units, target, now)) then
            return false
        end
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
    local anchor = select(1, script.select_combo_poof_anchor(units, target_pos, allowed_anchor_dist))
    if not anchor then
        return false
    end
    local scheduled = schedule_poof_burst(units, anchor, now, "meepo_combo_poof_burst", nil, target_pos)
    if scheduled > 0 and max_channel > 0 then
        local total_lock = max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + total_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return scheduled > 0
end
local function try_combo_poof_burst_uncontrolled(units, target, now, reason)
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return false
    end
    if not target or not Entity.IsAlive(target) then
        return false
    end
    if tostring(script._combo_engage_mode or "") == "FAR" then
        return false
    end
    local root_remaining = get_confirmed_control_remaining(target, now)
    if root_remaining < C.COMBO_POOF_ROOT_MIN_REMAINING then
        return false
    end
    local ready_count, max_radius, max_channel = get_ready_poof_burst_info(units, now)
    if ready_count <= 0 then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local allowed_anchor_dist = script.get_poof_anchor_damage_distance(max_radius, target)
    local anchor = select(1, script.select_combo_poof_anchor(units, target_pos, allowed_anchor_dist))
    if not anchor then
        return false
    end
    local scheduled = schedule_poof_burst(units, anchor, now, reason or "meepo_combo_poof_uncontrolled", nil, target_pos)
    if scheduled > 0 and max_channel > 0 then
        local total_lock = max_channel + (C.COMBO_POOF_STAGGER * math.max(0, scheduled - 1))
        combo_move_next_order_time = math.max(combo_move_next_order_time, now + total_lock)
        set_combo_action_lock(now, C.COMBO_ACTION_MIN_INTERVAL)
    end
    return scheduled > 0
end
local function try_combo_poof_burst_hex_fallback(units, target, now)
    return try_combo_poof_burst_uncontrolled(units, target, now, "meepo_combo_poof_hex_fallback")
end
local function can_meepo_attack_target_now(meepo, target, target_pos, target_hull)
    if not meepo or not target or not Entity.IsAlive(meepo) or not Entity.IsAlive(target) then
        return false
    end
    local unit_pos = safe_call(Entity.GetAbsOrigin, meepo)
    if not unit_pos or not target_pos then
        return false
    end
    local dist = vec_dist_2d(unit_pos, target_pos)
    if not dist then
        return false
    end
    local attack_range = tonumber(safe_call(NPC.GetAttackRange, meepo) or 0) or 0
    local attack_bonus = tonumber(safe_call(NPC.GetAttackRangeBonus, meepo) or 0) or 0
    local meepo_hull = tonumber(safe_call(NPC.GetHullRadius, meepo) or 0) or 0
    local reach = attack_range + attack_bonus + meepo_hull + (target_hull or 0) + 30
    return dist <= reach
end
local function can_any_meepo_attack_target_now(units, target)
    if not target or not Entity.IsAlive(target) then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return false
    end
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    for i = 1, #units do
        if can_meepo_attack_target_now(units[i], target, target_pos, target_hull) then
            return true
        end
    end
    return false
end
local function issue_combo_attack_order(player, units, target, now)
    if not player or not units or #units == 0 or not target or not Entity.IsAlive(target) then
        return false
    end
    if now < combo_attack_next_order_time then
        return false
    end
    local order_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not order_type or not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local issued_any = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local ok = pcall(function()
                Player.PrepareUnitOrders(
                    player,
                    order_type,
                    target,
                    target_pos,
                    nil,
                    issuer_type,
                    meepo,
                    false,
                    true,
                    true,
                    false,
                    "meepo_combo_attack_fallback",
                    false
                )
            end)
            if ok then
                issued_any = true
            end
        end
    end
    if issued_any then
        combo_attack_next_order_time = now + C.COMBO_ATTACK_ORDER_INTERVAL
        local action_lock = tonumber(C.COMBO_ATTACK_ACTION_LOCK or C.COMBO_ACTION_MIN_INTERVAL or 0.12) or 0.12
        if action_lock < 0 then
            action_lock = 0
        end
        local max_lock = tonumber(C.COMBO_ATTACK_ORDER_INTERVAL or 0.28) or 0.28
        if action_lock > max_lock then
            action_lock = max_lock
        end
        set_combo_action_lock(now, action_lock)
    end
    return issued_any
end
function script.issue_combo_hold_order(player, units, now, reason, hold_target)
    if not player or not units or #units == 0 then
        return false
    end
    if now < (script._combo_hold_next_order_time or 0) then
        return false
    end
    if not Player or not Player.HoldPosition then
        return false
    end
    local hold_target_pos = nil
    local hold_target_hull = 0
    if hold_target and Entity.IsAlive(hold_target) then
        hold_target_pos = safe_call(Entity.GetAbsOrigin, hold_target)
        hold_target_hull = tonumber(safe_call(NPC.GetHullRadius, hold_target) or 0) or 0
    end
    local issued = false
    for i = 1, #units do
        local meepo = units[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local can_attack_target = false
            if hold_target_pos then
                can_attack_target = can_meepo_attack_target_now(meepo, hold_target, hold_target_pos, hold_target_hull)
            end
            if not can_attack_target then
                local ok = pcall(function()
                    Player.HoldPosition(player, meepo, false, true, true, reason or "meepo_combo_hold_disable")
                end)
                if ok then
                    issued = true
                end
            end
        end
    end
    if issued then
        script._combo_hold_next_order_time = now + C.COMBO_HOLD_ORDER_INTERVAL
    end
    return issued
end
function script.issue_combo_hold_or_pressure(player, units, attack_units, target, now, reason, allow_hold_fallback)
    if not player or not units or #units == 0 then
        return false
    end
    local reason_text = tostring(reason or "")
    local net_hold_reason = string.find(reason_text, "net", 1, true) ~= nil
    local allow_hold = allow_hold_fallback ~= false
    local pressure_units = attack_units
    if not pressure_units or #pressure_units == 0 then
        pressure_units = units
    end
    if target and Entity.IsAlive(target) then
        if (not net_hold_reason) and can_any_meepo_attack_target_now(pressure_units, target) then
            if issue_combo_attack_order(player, pressure_units, target, now) then
                return true
            end
        end
        local target_pos = safe_call(Entity.GetAbsOrigin, target)
        if target_pos then
            if issue_combo_move_order(player, units, target_pos, now) then
                return true
            end
        end
    end
    if not allow_hold then
        return false
    end
    return script.issue_combo_hold_order(player, units, now, reason, target)
end
local function get_combo_target_fov_radius()
    if ui.combo_target_fov and ui.combo_target_fov.Get then
        local ok, value = pcall(function()
            return ui.combo_target_fov:Get()
        end)
        if ok and value ~= nil then
            local radius = tonumber(value) or 140
            if radius < 20 then
                radius = 20
            end
            return radius
        end
    end
    return 140
end
local function get_cursor_position()
    if not Input or not Input.GetCursorPos then
        return nil, nil
    end
    local ctx = script._frame_context_get()
    if ctx.cursor_x ~= nil and ctx.cursor_y ~= nil then
        return ctx.cursor_x, ctx.cursor_y
    end
    local ok, x, y = pcall(function()
        return Input.GetCursorPos()
    end)
    if not ok then
        return nil, nil
    end
    ctx.cursor_x = tonumber(x)
    ctx.cursor_y = tonumber(y)
    return ctx.cursor_x, ctx.cursor_y
end
local function get_mouse1_code()
    if Enum and Enum.ButtonCode and Enum.ButtonCode.KEY_MOUSE1 ~= nil then
        return Enum.ButtonCode.KEY_MOUSE1
    end
    return nil
end
function list_has_string(list, value)
    if not list or not value then
        return false
    end
    for i = 1, #list do
        if tostring(list[i]) == tostring(value) then
            return true
        end
    end
    return false
end
local function get_mouse2_code()
    if Enum and Enum.ButtonCode and Enum.ButtonCode.KEY_MOUSE2 ~= nil then
        return Enum.ButtonCode.KEY_MOUSE2
    end
    return nil
end
function script.draw_combo_runtime_switch()
    if not Render.ScreenSize then
        return
    end
    local screen = Render.ScreenSize()
    local w, h = C.HUD_COMBO_W, C.HUD_COMBO_H
    local x = screen.x * 0.5 - w * 0.5
    local y = screen.y - C.HUD_COMBO_Y_OFFSET
    local split_x = x + w * 0.5
    local hover_left = safe_call(Input.IsCursorInRect, x, y, w * 0.5, h) == true
    local hover_right = safe_call(Input.IsCursorInRect, split_x, y, w * 0.5, h) == true
    local mouse1 = get_mouse1_code()
    local click_once = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    if click_once and not input_captured then
        if hover_left then
            combo_runtime_enabled = false
        elseif hover_right then
            combo_runtime_enabled = true
        end
    end
    local bg = Color(0, 0, 0, 170)
    local on_color = combo_runtime_enabled and Color(90, 190, 120, 235) or Color(55, 65, 55, 220)
    local off_color = combo_runtime_enabled and Color(70, 55, 55, 220) or Color(200, 90, 90, 235)
    if Render.FilledRect then
        Render.FilledRect(Vec2(x, y), Vec2(x + w, y + h), bg, 4, Enum.DrawFlags.RoundCornersAll)
        Render.FilledRect(Vec2(x, y), Vec2(split_x, y + h), off_color, 4, Enum.DrawFlags.RoundCornersLeft)
        Render.FilledRect(Vec2(split_x, y), Vec2(x + w, y + h), on_color, 4, Enum.DrawFlags.RoundCornersRight)
    end
    if Render.Rect then
        Render.Rect(Vec2(x, y), Vec2(x + w, y + h), Color(20, 20, 20, 255), 4, Enum.DrawFlags.RoundCornersAll, 1.0)
    end
    local title = C.HUD_COMBO_TITLE
    local title_size = Render.TextSize(font, tactical_font_size, title)
    Render.Text(font, tactical_font_size, title, Vec2(x + w * 0.5 - title_size.x * 0.5, y - title_size.y - 2), Color(220, 220, 220, 235))
    local off_size = Render.TextSize(font, tactical_font_size, C.HUD_COMBO_TEXT_OFF)
    local on_size = Render.TextSize(font, tactical_font_size, C.HUD_COMBO_TEXT_ON)
    Render.Text(font, tactical_font_size, C.HUD_COMBO_TEXT_OFF, Vec2(x + w * 0.25 - off_size.x * 0.5, y + h * 0.5 - off_size.y * 0.5), Color(255, 245, 245, 240))
    Render.Text(font, tactical_font_size, C.HUD_COMBO_TEXT_ON, Vec2(split_x + w * 0.25 - on_size.x * 0.5, y + h * 0.5 - on_size.y * 0.5), Color(245, 255, 245, 240))
end
local function get_combo_target_under_cursor(anchor_meepo)
    local cursor_x, cursor_y = get_cursor_position()
    local fov_radius = get_combo_target_fov_radius()
    if not anchor_meepo then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local local_team = tonumber(safe_call(Entity.GetTeamNum, anchor_meepo) or -1) or -1
    if local_team < 0 or not cursor_x or not cursor_y then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local heroes = script._heroes_all_frame_cached()
    if not heroes then
        return nil, cursor_x, cursor_y, fov_radius
    end
    local best_target = nil
    local best_dist_sq = nil
    local fov_sq = fov_radius * fov_radius
    for i = 1, #heroes do
        local enemy = heroes[i]
        if enemy and enemy ~= anchor_meepo and Entity.IsHero(enemy) and Entity.IsAlive(enemy) then
            local enemy_team = tonumber(safe_call(Entity.GetTeamNum, enemy) or -1) or -1
            if enemy_team >= 0 and enemy_team ~= local_team and safe_call(Entity.IsDormant, enemy) ~= true then
                local pos = safe_call(Entity.GetAbsOrigin, enemy)
                if pos then
                    pos = pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, enemy) or 0) + 8)
                    local screen_pos, visible = Render.WorldToScreen(pos)
                    if visible and screen_pos then
                        local dx = (screen_pos.x or 0) - cursor_x
                        local dy = (screen_pos.y or 0) - cursor_y
                        local dist_sq = dx * dx + dy * dy
                        if dist_sq <= fov_sq and (not best_dist_sq or dist_sq < best_dist_sq) then
                            best_dist_sq = dist_sq
                            best_target = enemy
                        end
                    end
                end
            end
        end
    end
    return best_target, cursor_x, cursor_y, fov_radius
end
function script.try_combo_anchor_join_poof(local_player, anchor, clones, target, now, engage_mode, move_anchor_for_blink)
    if not local_player or not anchor or not target or not clones then
        return nil
    end
    if engage_mode == "FAR" or move_anchor_for_blink then
        return nil
    end
    if not Entity.IsAlive(anchor) or not Entity.IsAlive(target) then
        return nil
    end
    if not is_combo_spell_enabled("poof", ui.combo_use_poof) then
        return nil
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
    if not target_pos or not anchor_pos then
        return nil
    end
    local anchor_poof = safe_call(NPC.GetAbility, anchor, C.ABILITY_POOF)
    local poof_hit_radius = get_poof_damage_radius(anchor_poof)
    if poof_hit_radius < 220 then
        poof_hit_radius = tonumber(C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK or 375) or 375
    end
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    local hit_threshold = poof_hit_radius + target_hull + 26
    local anchor_dist = vec_dist_2d(anchor_pos, target_pos) or 99999
    if anchor_dist > hit_threshold then
        return nil
    end
    local confirmed_control = get_confirmed_control_remaining(target, now)
    local net_in_flight = is_net_projectile_in_flight(target, now)
    local anchor_can_open_net = false
    if confirmed_control <= 0.12 and is_combo_spell_enabled("net", ui.combo_use_net) then
        local net = safe_call(NPC.GetAbility, anchor, C.ABILITY_NET)
        if net and can_cast_ability_for_npc(anchor, net) then
            local in_phase = safe_call(Ability.IsInAbilityPhase, net)
            local channelling = safe_call(Ability.IsChannelling, net)
            anchor_can_open_net = (in_phase ~= true and channelling ~= true)
        end
    end
    if confirmed_control <= 0.12 and (not net_in_flight) and (not anchor_can_open_net) then
        return nil
    end
    local far_casters = {}
    local far_threshold = hit_threshold + 110
    for i = 1, #clones do
        local meepo = clones[i]
        if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
            local clone_pos = safe_call(Entity.GetAbsOrigin, meepo)
            local clone_dist = vec_dist_2d(clone_pos, target_pos)
            if clone_dist and clone_dist > far_threshold then
                local ready = can_schedule_poof(meepo, now)
                if ready then
                    far_casters[#far_casters + 1] = meepo
                end
            end
        end
    end
    if #far_casters <= 0 then
        return nil
    end
    if not script.issue_group_poof_target_order(local_player, far_casters, anchor, now, "meepo_combo_anchor_join") then
        return nil
    end
    local joined = {}
    for i = 1, #far_casters do
        local key = get_entity_key(far_casters[i])
        if key then
            joined[key] = true
        end
    end
    return joined
end
function script.handle_poof_utilities(local_player, local_hero, meepos, now)
    local cursor_pressed = script.is_bind_just_pressed(ui.poof_to_cursor, "poof_to_cursor")
    local self_pressed = script.is_bind_just_pressed(ui.poof_on_self, "poof_on_self")
    if safe_call(Input.IsInputCaptured) == true then
        return false
    end
    local issued = false
    if cursor_pressed then
        issued = script.try_poof_to_cursor(local_player, local_hero, meepos, now) or issued
    end
    if self_pressed then
        issued = script.try_poof_on_self(local_player, local_hero, meepos, now) or issued
    end
    return issued
end
function script.run_combo_logic(local_hero, meepos, now)
    local combo_active = is_combo_active()
    local combo_input_mode = "NONE"
    if combo_active then
        combo_active, combo_input_mode = script.get_combo_input_mode()
    end
    local ground_combo_mode = combo_input_mode == "GROUND"
    script._combo_input_mode = combo_input_mode
    local local_player = safe_call(Players.GetLocal)
    local combo_mode = get_combo_type_index()
    local selected_only_mode = combo_mode == COMBO_MODE_SELECTED
    local selected_key_set = selected_only_mode and script.get_selected_meepo_key_set(local_player) or nil
    local now = get_game_time()
    if not combo_active then
        script._combo_input_mode = "NONE"
        local units_for_armlet = nil
        if script._combo_armlet_forced_on then
            units_for_armlet = selected_only_mode
                and collect_combo_move_units(local_player, local_hero, meepos)
                or collect_owned_meepo_units(local_hero, meepos)
            if #units_for_armlet > 0 then
                script.try_combo_armlet_control(units_for_armlet, false, now)
            end
        end
        if combo_was_active then
            local units_to_interrupt = units_for_armlet
                or (selected_only_mode
                    and collect_combo_move_units(local_player, local_hero, meepos)
                    or collect_owned_meepo_units(local_hero, meepos))
            if #units_to_interrupt > 0 then
                interrupt_combo_casts(local_player, units_to_interrupt)
            end
        end
        combo_was_active = false
        combo_focus_target = nil
        combo_focus_source = nil
        script._combo_target_last_seen_time = -9999
        reset_combo_move_state()
        return
    end
    combo_was_active = true
    local source_meepo = get_combo_anchor_meepo(local_player, local_hero)
    combo_focus_source = source_meepo
    if not source_meepo then
        combo_focus_target = nil
        return
    end
    local units = collect_combo_move_units(local_player, local_hero, meepos)
    if selected_only_mode then
        if not selected_key_set or next(selected_key_set) == nil then
            combo_focus_target = nil
            script.set_combo_debug_state("SEARCHING", "no selected meepo", "")
            return
        end
        local filtered = {}
        for i = 1, #units do
            local unit = units[i]
            if unit and selected_key_set[get_entity_key(unit)] == true then
                filtered[#filtered + 1] = unit
            end
        end
        units = filtered
        if #units == 0 then
            combo_focus_target = nil
            script.set_combo_debug_state("SEARCHING", "no selected meepo", "")
            return
        end
        if not (source_meepo and selected_key_set[get_entity_key(source_meepo)] == true) then
            source_meepo = units[1]
            combo_focus_source = source_meepo
        end
    end
    local net_units = selected_only_mode and units or collect_owned_meepo_units(local_hero, meepos)
    local function ensure_unit(list, unit)
        if not list or not unit then
            return
        end
        if selected_only_mode and selected_key_set and selected_key_set[get_entity_key(unit)] ~= true then
            return
        end
        for i = 1, #list do
            if list[i] == unit then
                return
            end
        end
        list[#list + 1] = unit
    end
    if #units == 0 then
        return
    end
    if #net_units == 0 then
        net_units = units
    end
    if script.try_combo_armlet_control(net_units, true, now) then
        script.set_combo_debug_state("ARMLET", "armlet on", "")
        return
    end
    local acquired_target = select(1, get_combo_target_under_cursor(source_meepo))
    if acquired_target and Entity.IsAlive(acquired_target) then
        combo_focus_target = acquired_target
        script._combo_target_last_seen_time = now
    elseif combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local keep_current = false
        local preblink_active = script._combo_preblink_phase and script._combo_preblink_phase ~= "idle"
        if preblink_active then
            local preblink_target_key = script._combo_preblink_target_key
            local current_key = get_entity_key(combo_focus_target)
            if preblink_target_key and current_key and preblink_target_key == current_key then
                keep_current = true
            end
        end
        if (not keep_current) and (script._combo_blink_scheduled_time or 0) > now then
            keep_current = true
        elseif (not keep_current) and (now - (script._combo_target_last_seen_time or -9999)) <= 0.30 then
            keep_current = true
        end
        if not keep_current then
            combo_focus_target = nil
        end
    else
        combo_focus_target = nil
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local blink_anchor = selected_only_mode and source_meepo or get_main_meepo(local_hero)
        if (not blink_anchor or not Entity.IsAlive(blink_anchor)) and selected_only_mode then
            blink_anchor = script.pick_first_alive_unit(units)
        end
        if blink_anchor and Entity.IsAlive(blink_anchor) then
            local blink = get_blink_item(blink_anchor)
            if script.can_cast_blink_now(blink_anchor, blink) then
                ensure_unit(units, blink_anchor)
            end
        end
    end
    local current_target_key = combo_focus_target and get_entity_key(combo_focus_target) or nil
    if current_target_key ~= combo_focus_target_key then
        script.clear_blink_schedule()
        script.clear_preblink_poof_state()
        if clear_poof_queue then
            clear_poof_queue()
        end
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
        combo_focus_target_key = current_target_key
    end
    if not combo_focus_target or not Entity.IsAlive(combo_focus_target) then
        script._combo_engage_mode = "MID"
        script._combo_engage_distance = 0
        script._combo_engage_close_threshold = 0
        script._combo_engage_mid_threshold = 0
        local no_target_reason = ground_combo_mode and "no target (ground)" or "no target"
        script.set_combo_debug_state("SEARCHING", no_target_reason, "")
        local destination = safe_call(Input.GetWorldCursorPos)
        if ground_combo_mode and destination and script.try_combo_ground_net(local_player, net_units, destination, now, source_meepo) then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "ground net (cursor)", "")
            return
        end
        if now < (script._combo_search_next_move_time or 0) then
            return
        end
        if destination then
            local last_search_pos = script._combo_search_last_position
            if last_search_pos then
                local search_delta = vec_dist_2d(last_search_pos, destination) or 0
                if search_delta < 24 then
                    return
                end
            end
            if issue_combo_move_order(local_player, units, destination, now) then
                script._combo_search_next_move_time = now + 0.22
                script._combo_search_last_position = Vector(destination.x or 0, destination.y or 0, destination.z or 0)
            end
        end
        return
    end
    script._combo_search_next_move_time = 0
    script._combo_search_last_position = nil
    local engage_mode, engage_distance, engage_close_threshold, engage_mid_threshold =
        script.resolve_combo_engage_mode(local_hero, combo_focus_target)
    script._combo_engage_mode = engage_mode
    script._combo_engage_distance = engage_distance or 0
    script._combo_engage_close_threshold = engage_close_threshold or 0
    script._combo_engage_mid_threshold = engage_mid_threshold or 0
    if combo_focus_target and Entity.IsAlive(combo_focus_target)
        and not (has_pending_poof_queue and has_pending_poof_queue())
        and not script.should_combo_surprise_hold(local_hero, combo_focus_target, now) then
        local anchor = selected_only_mode and source_meepo or get_main_meepo(local_hero)
        if (not anchor or not Entity.IsAlive(anchor)) and selected_only_mode then
            anchor = script.pick_first_alive_unit(units)
        end
        if anchor and Entity.IsAlive(anchor) then
            local clones = selected_only_mode and units or collect_owned_meepo_units(local_hero, meepos)
            local moving = {}
            script._combo_joined_by_poof = nil
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            local move_anchor_for_blink = false
            local clone_frontliner_in_poof_range = false
            local anchor_should_walk_to_clone = false
            if target_pos then
                local blink = get_blink_item(anchor)
                if script.can_cast_blink_now(anchor, blink) then
                    local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
                    if anchor_pos then
                        local blink_range = script.get_item_cast_range(blink, 1200)
                        local blink_bonus = tonumber(safe_call(NPC.GetCastRangeBonus, anchor) or 0) or 0
                        if blink_bonus > 0 then
                            blink_range = blink_range + blink_bonus
                        end
                        if blink_range <= 0 then
                            blink_range = 1200
                        end
                        local dist = vec_dist_2d(anchor_pos, target_pos) or 0
                        if dist > (blink_range + 80) then
                            move_anchor_for_blink = true
                        end
                    end
                end
                if not move_anchor_for_blink then
                    local poof_frontline_radius = script.get_poof_anchor_damage_distance(C.COMBO_POOF_DAMAGE_RADIUS_FALLBACK, combo_focus_target)
                    local target_hull = tonumber(safe_call(NPC.GetHullRadius, combo_focus_target) or 0) or 0
                    local anchor_can_attack_now = can_meepo_attack_target_now(anchor, combo_focus_target, target_pos, target_hull)
                    local anchor_poof_ready = can_schedule_poof(anchor, now)
                    for i = 1, #clones do
                        local meepo = clones[i]
                        if meepo and meepo ~= anchor and Entity.IsAlive(meepo) then
                            local clone_pos = safe_call(Entity.GetAbsOrigin, meepo)
                            local clone_dist = vec_dist_2d(clone_pos, target_pos)
                            if clone_dist and clone_dist <= poof_frontline_radius then
                                clone_frontliner_in_poof_range = true
                                break
                            end
                        end
                    end
                    if clone_frontliner_in_poof_range
                        and not anchor_can_attack_now
                        and not anchor_poof_ready
                        and not is_combo_cast_in_progress(anchor) then
                        anchor_should_walk_to_clone = true
                    end
                end
                script._combo_joined_by_poof = script.try_combo_anchor_join_poof(local_player, anchor, clones, combo_focus_target, now, engage_mode, move_anchor_for_blink)
            end
            if engage_mode == "FAR" then
                for i = 1, #clones do
                    local meepo = clones[i]
                    if meepo and Entity.IsAlive(meepo) then
                        ensure_unit(moving, meepo)
                    end
                end
            elseif move_anchor_for_blink then
                ensure_unit(moving, anchor)
            else
                for i = 1, #clones do
                    local meepo = clones[i]
                    if meepo and meepo ~= anchor
                        and not (script._combo_joined_by_poof and script._combo_joined_by_poof[get_entity_key(meepo)] == true) then
                        moving[#moving + 1] = meepo
                    end
                end
                if anchor_should_walk_to_clone then
                    ensure_unit(moving, anchor)
                end
            end
            if #moving > 0 and not is_poof_in_progress(moving) then
                if target_pos then
                    issue_combo_move_order(local_player, moving, target_pos, now)
                end
            end
            script._combo_joined_by_poof = nil
        end
    end
    local main_preferred = nil
    if script.is_combo_option_enabled(ui.combo_main_first) then
        main_preferred = selected_only_mode and source_meepo or get_main_meepo(local_hero)
        if main_preferred and not script.is_unit_in_units_list(main_preferred, net_units) then
            main_preferred = nil
        end
    end
    local strict_control = script.is_combo_option_enabled(ui.combo_strict_control)
    local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
    local has_abyssal_item = has_combo_item_equipped(net_units, script._combo_item_sets.abyssal)
    local hex_ready_anywhere = has_ready_hex_for_combo(net_units) and not script.get_control_break_reason(combo_focus_target, true)
    local abyssal_remaining = script.get_target_abyssal_remaining(combo_focus_target, now)
    local hex_remaining = script.get_target_hex_remaining(combo_focus_target, now)
    local abyssal_ready = has_abyssal_item
        and script.has_ready_abyssal_for_combo
        and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now)
    local hex_ready = script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now)
    local net_chain_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
    local net_in_flight = net_enabled and is_net_projectile_in_flight(combo_focus_target, now) or false
    local combo_phase = script.resolve_combo_state_phase(
        current_target_key,
        has_abyssal_item,
        abyssal_ready,
        abyssal_remaining,
        hex_ready_anywhere,
        hex_remaining,
        net_enabled,
        net_chain_now or net_in_flight,
        now
    )
    local next_disable_delay, next_disable_source = script.get_next_disable_ready_delay(local_hero, net_units, now)
    local next_disable_text = ""
    if next_disable_delay then
        next_disable_text = string.format("%s %.2f", tostring(next_disable_source or "disable"), next_disable_delay)
    end
    script.set_combo_debug_state(combo_phase, "active", next_disable_text)
    if is_combo_action_locked(now) then
        return
    end
    local linken_break_reason = nil
    if script.is_target_linkens_protected(combo_focus_target) then
        local linken_broken, linken_reason = script.try_combo_linken_break(net_units, combo_focus_target, now)
        if linken_broken then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "break linken: " .. tostring(linken_reason or "item"), next_disable_text)
            return
        end
        linken_break_reason = linken_reason
        if linken_reason == "lotus" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken hold: lotus", next_disable_text)
        elseif linken_reason == "no_enabled_breaker" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken up: no breaker", next_disable_text)
        elseif linken_reason == "disabled_breaker" then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "linken hold: breaker disabled", next_disable_text)
        end
    end
    local single_target_break = script.get_control_break_reason(combo_focus_target, true)
    if single_target_break and (combo_phase == script.COMBO_PHASE_ABYSSAL or combo_phase == script.COMBO_PHASE_HEX) then
        script.set_combo_debug_state(combo_phase, "control break: " .. tostring(single_target_break), next_disable_text)
    end
    local allow_target_items = linken_break_reason ~= "no_enabled_breaker" and linken_break_reason ~= "disabled_breaker"
    local has_any_items_equipped = has_any_combo_items_equipped(local_hero, net_units)
    if has_any_items_equipped and (not single_target_break or single_target_break == "linkens") then
        local pre_item_casted, pre_item_name = false, nil
        if allow_target_items then
            pre_item_casted, pre_item_name = script.try_combo_diffusal_disperser(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "diffusal"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_silence(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "silence"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_atos(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "atos"), next_disable_text)
                return
            end
            pre_item_casted, pre_item_name = script.try_combo_grenade(net_units, combo_focus_target, now)
            if pre_item_casted then
                script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "grenade"), next_disable_text)
                return
            end
        end
    end
    if has_any_items_equipped and script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
        script.set_combo_debug_state(combo_phase, "blink sequence (items first)", next_disable_text)
        return
    end
    if has_any_items_equipped and (not single_target_break or single_target_break == "linkens") then
        local pre_item_casted, pre_item_name = false, nil
        pre_item_casted, pre_item_name = script.try_combo_phase_shadow_engage(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(combo_phase, "item-first: " .. tostring(pre_item_name or "phase/shadow"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_manta_after_net(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "manta"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_mjollnir_self(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "mjollnir"), next_disable_text)
            return
        end
        pre_item_casted, pre_item_name = script.try_combo_blademail_close(net_units, combo_focus_target, now)
        if pre_item_casted then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "item-first: " .. tostring(pre_item_name or "blademail"), next_disable_text)
            return
        end
    end
    if combo_phase == script.COMBO_PHASE_ABYSSAL and abyssal_ready then
        if script.try_combo_abyssal(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(combo_phase, "cast abyssal", next_disable_text)
            return
        end
        if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
            script.set_combo_debug_state(combo_phase, "blink for abyssal", next_disable_text)
            return
        end
        script.set_combo_debug_state(combo_phase, "waiting abyssal", next_disable_text)
        local attacked = false
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        if not attacked then
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            if target_pos then
                issue_combo_move_order(local_player, units, target_pos, now)
            end
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_ABYSSAL and has_abyssal_item and abyssal_remaining > 0.08 then
        local main_net_ready = is_meepo_net_ready_for_combo(main_preferred, now)
        local any_net_ready = has_any_meepo_net_ready_for_combo(net_units, now)
        if hex_ready_anywhere then
            if abyssal_remaining > C.COMBO_HEX_CHAIN_FROM_ABYSSAL_WINDOW then
                script.set_combo_debug_state(combo_phase, "wait abyssal->hex window", next_disable_text)
                return
            end
            if hex_ready then
                if try_combo_hex(net_units, combo_focus_target, now) then
                    script.set_combo_debug_state(combo_phase, "chain hex", next_disable_text)
                    return
                end
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(combo_phase, "blink for hex", next_disable_text)
                    return
                end
                script.set_combo_debug_state(combo_phase, "hex failed", next_disable_text)
                local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
                if not attacked then
                    local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
                    if target_pos then
                        issue_combo_move_order(local_player, units, target_pos, now)
                    end
                end
                return
            end
        end
        if net_enabled then
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net", next_disable_text)
                return
            end
            if main_net_ready or any_net_ready then
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for net", next_disable_text)
                    return
                end
            end
        end
        script.set_combo_debug_state(combo_phase, "wait control handoff", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_HEX and hex_ready then
        if try_combo_hex(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(combo_phase, "cast hex", next_disable_text)
            return
        end
        if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
            script.set_combo_debug_state(combo_phase, "blink for hex", next_disable_text)
            return
        end
        script.set_combo_debug_state(combo_phase, "hex pending", next_disable_text)
        local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        if not attacked then
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            if target_pos then
                issue_combo_move_order(local_player, units, target_pos, now)
            end
        end
        return
    end
    if combo_phase == script.COMBO_PHASE_HEX and hex_remaining > C.COMBO_HEX_TO_CONTROL_CHAIN_WINDOW then
        if try_combo_poof_burst_hex_fallback(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof during hex", next_disable_text)
            return
        end
        script.set_combo_debug_state(combo_phase, "wait hex chain window", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if hex_remaining > 0 and hex_remaining <= C.COMBO_HEX_TO_CONTROL_CHAIN_WINDOW then
        if try_combo_poof_burst_hex_fallback(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof during hex", next_disable_text)
            return
        end
        local main_net_ready = is_meepo_net_ready_for_combo(main_preferred, now)
        local any_net_ready = has_any_meepo_net_ready_for_combo(net_units, now)
        if net_enabled then
            local _, _, arrival = choose_earthbind_caster(net_units, combo_focus_target, now, main_preferred)
            if not arrival then
                local _, _, fallback_arrival = choose_earthbind_caster(net_units, combo_focus_target, now)
                arrival = fallback_arrival
            end
            if arrival then
                local time_to_land = math.max(0, arrival - now)
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net after hex (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "chain net after hex", next_disable_text)
                return
            end
            if main_net_ready then
                if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for main net", next_disable_text)
                    return
                end
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold main net", next_disable_text)
                return
            end
        end
        if net_enabled and any_net_ready then
            if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "blink for net", next_disable_text)
                return
            end
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "wait net ready", next_disable_text)
            return
        end
        if strict_control then
            local can_chain_now = false
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if can_chain_now and can_cast_poof_burst_now(net_units, combo_focus_target, now) then
                can_chain_now = false
            end
            if can_chain_now then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hex-end poof blocked (strict)", next_disable_text)
                return
            end
            local hold_window = script.get_combo_hold_window_sec()
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if next_disable_delay and next_disable_delay > 0 and next_disable_delay <= hold_window then
                if confirmed_control_now > C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hex-end hold for disable", next_disable_text)
                    if script.issue_combo_hold_or_pressure(local_player, units, net_units, combo_focus_target, now, "meepo_combo_hold_hex_end") then
                        return
                    end
                end
            end
        end
        if try_combo_poof_burst_hex_fallback(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof fallback after hex", next_disable_text)
            return
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "net skipped; no poof fallback", next_disable_text)
        return
    end
    if script.try_combo_blink_sync(local_hero, units, combo_focus_target, now, net_units) then
        script.set_combo_debug_state(combo_phase, "blink sequence", next_disable_text)
        return
    end
    if script.try_combo_silence(net_units, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "cast silence", next_disable_text)
        return
    end
    if script.try_combo_atos(net_units, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "cast atos", next_disable_text)
        return
    end
    if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net", next_disable_text)
        return
    end
    local items_still_ready = false
    if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
        items_still_ready = true
    end
    if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
        items_still_ready = true
    end
    if items_still_ready then
        script.set_combo_debug_state(combo_phase, "wait ready item disable", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
        end
        return
    end
    if strict_control then
        local break_reason = script.get_control_break_reason(combo_focus_target, false)
        if not break_reason then
            local can_chain_now = false
            if net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_chain_now = true
            end
            if can_chain_now and can_cast_poof_burst_now(net_units, combo_focus_target, now) then
                can_chain_now = false
            end
            if can_chain_now then
                script.set_combo_debug_state(combo_phase, "poof blocked (strict control)", next_disable_text)
                return
            end
            local hold_window = script.get_combo_hold_window_sec()
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if next_disable_delay and next_disable_delay > 0 and next_disable_delay <= hold_window then
                if confirmed_control_now > C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                    script.set_combo_debug_state(combo_phase, "holding for next disable", next_disable_text)
                    if script.issue_combo_hold_or_pressure(local_player, units, net_units, combo_focus_target, now, "meepo_combo_hold_next_disable") then
                        return
                    end
                end
            end
        else
            script.set_combo_debug_state(combo_phase, "control break: " .. tostring(break_reason), next_disable_text)
        end
    end
    local net_chain_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
    local any_net_ready_now = net_enabled and has_any_meepo_net_ready_for_combo(net_units, now) or false
    local next_net_delay = net_enabled and script.get_next_net_ready_delay(net_units, now) or nil
    local net_hold_window = script.get_combo_hold_window_sec()
    local control_break_for_net = script.get_control_break_reason(combo_focus_target, false)
    local hold_net_orders_allowed = true
    if linken_break_reason == "no_enabled_breaker" then
        hold_net_orders_allowed = false
    end
    if (script._combo_blink_scheduled_time or 0) > now then
        hold_net_orders_allowed = false
    end
    if is_poof_in_progress(net_units) then
        hold_net_orders_allowed = false
    end
    local prioritize_net_over_poof = false
    local net_priority_lock_active = false
    local net_priority_reason = nil
    if net_enabled and not control_break_for_net and current_target_key ~= nil then
        local lock_until = tonumber(script._combo_net_priority_until or 0) or 0
        if script._combo_net_priority_target_key == current_target_key and lock_until > now then
            if not (is_combo_spell_enabled("poof", ui.combo_use_poof) and can_cast_poof_burst_now(net_units, combo_focus_target, now)) then
                net_priority_lock_active = true
                prioritize_net_over_poof = true
                net_priority_reason = "lock"
            end
        end
    end
    if net_enabled and not control_break_for_net then
        if net_chain_now then
            if not (is_combo_spell_enabled("poof", ui.combo_use_poof) and can_cast_poof_burst_now(net_units, combo_focus_target, now)) then
                prioritize_net_over_poof = true
                net_priority_reason = net_priority_reason or "chain_now"
            end
        elseif any_net_ready_now then
            local remaining_control = get_effective_earthbind_remaining(combo_focus_target, now)
            local _, _, priority_arrival = choose_earthbind_caster(net_units, combo_focus_target, now, main_preferred)
            if not priority_arrival then
                local _, _, fallback_arrival = choose_earthbind_caster(net_units, combo_focus_target, now)
                priority_arrival = fallback_arrival
            end
            local handoff_window = (priority_arrival and math.max(0, priority_arrival - now) or 0) + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
            if priority_arrival
                and remaining_control > 0
                and remaining_control <= (handoff_window + C.COMBO_POOF_ROOT_MIN_REMAINING)
                and not (is_combo_spell_enabled("poof", ui.combo_use_poof) and can_cast_poof_burst_now(net_units, combo_focus_target, now)) then
                prioritize_net_over_poof = true
                net_priority_reason = net_priority_reason or "handoff"
                if hold_net_orders_allowed and remaining_control > 0 then
                    if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net handoff (main)", next_disable_text)
                        return
                    end
                    if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net handoff", next_disable_text)
                        return
                    end
                    script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold net handoff", next_disable_text)
                    if script.issue_combo_hold_or_pressure(local_player, units, net_units, combo_focus_target, now, "meepo_combo_hold_net_handoff", false) then
                        return
                    end
                end
            end
        elseif hold_net_orders_allowed and next_net_delay and next_net_delay > 0 and next_net_delay <= net_hold_window then
            local confirmed_control_now = get_confirmed_control_remaining(combo_focus_target, now)
            if confirmed_control_now <= C.COMBO_CONTROL_HOLD_MIN_REMAINING then
                hold_net_orders_allowed = false
            end
        end
        if hold_net_orders_allowed
            and next_net_delay and next_net_delay > 0 and next_net_delay <= net_hold_window
            and not (is_combo_spell_enabled("poof", ui.combo_use_poof) and can_cast_poof_burst_now(net_units, combo_focus_target, now)) then
            prioritize_net_over_poof = true
            net_priority_reason = net_priority_reason or "delay_window"
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net priority (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "cast net priority", next_disable_text)
                return
            end
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "hold net priority", next_disable_text)
            if script.issue_combo_hold_or_pressure(local_player, units, net_units, combo_focus_target, now, "meepo_combo_hold_net_priority", false) then
                return
            end
        end
    end
    if net_enabled and not control_break_for_net and prioritize_net_over_poof then
        script._combo_net_priority_target_key = current_target_key
        local lock_until = now + 0.35
        if lock_until > (tonumber(script._combo_net_priority_until or 0) or 0) then
            script._combo_net_priority_until = lock_until
        end
    elseif (not net_enabled) or control_break_for_net or (script._combo_net_priority_target_key ~= current_target_key) then
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
    elseif not net_priority_lock_active and (tonumber(script._combo_net_priority_until or 0) or 0) <= now then
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
    end
    if not prioritize_net_over_poof then
        local no_net_available_now = (not net_enabled) or (not any_net_ready_now)
        if no_net_available_now and is_combo_spell_enabled("poof", ui.combo_use_poof) then
            local can_control_now = false
            if net_enabled and net_chain_now then
                can_control_now = true
            end
            if script.can_cast_combo_hex_now and script.can_cast_combo_hex_now(net_units, combo_focus_target, now) then
                can_control_now = true
            end
            if script.has_ready_abyssal_for_combo and script.has_ready_abyssal_for_combo(net_units, combo_focus_target, now) then
                can_control_now = true
            end
            if not can_control_now and try_combo_poof_burst_uncontrolled(net_units, combo_focus_target, now, "meepo_combo_poof_no_net") then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof priority (no net)", next_disable_text)
                return
            end
        end
    else
        local priority_reason = "control priority net>poof"
        if net_priority_reason == "lock" or net_priority_lock_active then
            priority_reason = "control priority net>poof (lock)"
        elseif net_priority_reason == "chain_now" then
            priority_reason = "control priority net>poof (chain)"
        elseif net_priority_reason == "handoff" then
            priority_reason = "control priority net>poof (handoff)"
        elseif net_priority_reason == "delay_window" then
            priority_reason = "control priority net>poof (delay)"
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, priority_reason, next_disable_text)
    end
    local combat_item_casted, combat_item_name = script.try_combo_manta_after_net(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "manta"), next_disable_text)
        return
    end
    combat_item_casted, combat_item_name = script.try_combo_mjollnir_self(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "mjollnir"), next_disable_text)
        return
    end
    combat_item_casted, combat_item_name = script.try_combo_blademail_close(net_units, combo_focus_target, now)
    if combat_item_casted then
        script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "combat item: " .. tostring(combat_item_name or "blademail"), next_disable_text)
        return
    end
    if not prioritize_net_over_poof then
        if try_combo_poof_burst(net_units, combo_focus_target, now) then
            script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof allowed", next_disable_text)
            return
        end
    end
    if prioritize_net_over_poof then
        if net_chain_now then
            if try_combo_earthbind_chain(net_units, combo_focus_target, now, main_preferred) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "force chain net (main)", next_disable_text)
                return
            end
            if try_combo_earthbind_chain(net_units, combo_focus_target, now) then
                script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "force chain net", next_disable_text)
                return
            end
        end
        local remaining_control_now = get_effective_earthbind_remaining(combo_focus_target, now)
        if remaining_control_now > 0 and hold_net_orders_allowed then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "holding net priority", next_disable_text)
            if script.issue_combo_hold_or_pressure(local_player, units, net_units, combo_focus_target, now, "meepo_combo_hold_force_net", false) then
                return
            end
        end
        script._combo_net_priority_until = 0
        script._combo_net_priority_target_key = nil
        local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
        if target_pos then
            issue_combo_move_order(local_player, units, target_pos, now)
        end
        script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "reposition for net", next_disable_text)
        if can_any_meepo_attack_target_now(net_units, combo_focus_target) then
            issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
            return
        end
        return
    end
    if has_pending_poof_queue and has_pending_poof_queue() then
        if combo_focus_target and Entity.IsAlive(combo_focus_target) then
            script.issue_combo_hold_or_pressure(
                local_player,
                units,
                net_units,
                combo_focus_target,
                now,
                "meepo_combo_poof_queue_net",
                false
            )
        end
        return
    end
    if is_poof_in_progress(net_units) then
        return
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local net_enabled = is_combo_spell_enabled("net", ui.combo_use_net)
        local poof_enabled = is_combo_spell_enabled("poof", ui.combo_use_poof)
        local net_ready_now = net_enabled and script.can_cast_net_chain_now(net_units, combo_focus_target, now) or false
        local net_in_flight = net_enabled and is_net_projectile_in_flight(combo_focus_target, now) or false
        local no_net_available_now = (not net_enabled) or (not has_any_meepo_net_ready_for_combo(net_units, now))
        local poof_ready_now = false
        if poof_enabled then
            if no_net_available_now then
                poof_ready_now = can_cast_poof_burst_uncontrolled_now(net_units, combo_focus_target, now)
            else
                poof_ready_now = can_cast_poof_burst_now(net_units, combo_focus_target, now)
            end
        end
        local can_attack_now = can_any_meepo_attack_target_now(net_units, combo_focus_target)
        if (not prioritize_net_over_poof) and poof_ready_now then
            local poof_casted = false
            if no_net_available_now then
                poof_casted = try_combo_poof_burst_uncontrolled(net_units, combo_focus_target, now, "meepo_combo_poof_over_attack")
            else
                poof_casted = try_combo_poof_burst(net_units, combo_focus_target, now)
            end
            if poof_casted then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "poof over attack", next_disable_text)
                return
            end
        end
        if net_in_flight then
            script.set_combo_debug_state(script.COMBO_PHASE_NET_CHAIN, "wait net impact", next_disable_text)
            if has_pending_poof_queue and has_pending_poof_queue() then
                script.issue_combo_hold_or_pressure(
                    local_player,
                    units,
                    net_units,
                    combo_focus_target,
                    now,
                    "meepo_combo_wait_impact_net",
                    false
                )
                return
            end
            if can_attack_now then
                issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
                return
            end
            local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
            if target_pos then
                issue_combo_move_order(local_player, units, target_pos, now)
            end
            return
        end
        if (not prioritize_net_over_poof) and (not net_ready_now and not poof_ready_now) and can_attack_now then
            local mom_casted, mom_name = script.try_combo_mom_finish(net_units, combo_focus_target, now)
            if mom_casted then
                script.set_combo_debug_state(script.COMBO_PHASE_POOF_ATTACK, "finish item: " .. tostring(mom_name or "mom"), next_disable_text)
                return
            end
        end
        if can_attack_now or ((not prioritize_net_over_poof) and (not net_ready_now and not poof_ready_now)) then
            local fallback_reason = prioritize_net_over_poof and "attack pressure" or "attack fallback"
            local attacked = issue_combo_attack_order(local_player, net_units, combo_focus_target, now)
            if attacked then
                script.set_combo_debug_state(combo_phase, fallback_reason, next_disable_text)
            end
            return
        end
    end
    if combo_focus_target and Entity.IsAlive(combo_focus_target)
        and script.should_combo_surprise_hold(local_hero, combo_focus_target, now) then
        script.set_combo_debug_state(combo_phase, "hold surprise", next_disable_text)
        if script.issue_combo_hold_order(local_player, units, now, "meepo_combo_surprise_hold") then
            return
        end
        return
    end
    if now < combo_move_next_order_time then
        return
    end
    local destination = nil
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        destination = safe_call(Entity.GetAbsOrigin, combo_focus_target)
    end
    if not destination then
        destination = safe_call(Input.GetWorldCursorPos)
    end
    if not destination then
        return
    end
    local move_units = units
    if combo_focus_target and Entity.IsAlive(combo_focus_target) then
        local anchor = get_main_meepo(local_hero)
        if anchor and Entity.IsAlive(anchor) then
            local blink = get_blink_item(anchor)
            if engage_mode ~= "CLOSE" and script.can_cast_blink_now(anchor, blink) then
                local anchor_pos = safe_call(Entity.GetAbsOrigin, anchor)
                local target_pos = safe_call(Entity.GetAbsOrigin, combo_focus_target)
                if anchor_pos and target_pos then
                    local blink_range = script.get_item_cast_range_for_npc(anchor, blink, 1200)
                    local dist = vec_dist_2d(anchor_pos, target_pos) or 0
                    if dist > (blink_range + 80) then
                        move_units = { anchor }
                    end
                end
            end
        end
    end
    issue_combo_move_order(local_player, move_units, destination, now)
end
function script.draw_combo_target_focus(local_hero, meepos)
    if not is_combo_active() then
        return
    end
    local combo_input_mode = select(2, script.get_combo_input_mode())
    if combo_input_mode == "NONE" and script._combo_input_mode then
        combo_input_mode = tostring(script._combo_input_mode)
    end
    local ground_combo_mode = combo_input_mode == "GROUND"
    local local_player = safe_call(Players.GetLocal)
    local now = get_game_time()
    local source_meepo = combo_focus_source
    if not source_meepo or not Entity.IsAlive(source_meepo) or not is_meepo_instance(source_meepo) then
        source_meepo = get_combo_anchor_meepo(local_player, local_hero)
        combo_focus_source = source_meepo
    end
    local target = combo_focus_target
    local cursor_x, cursor_y = get_cursor_position()
    local fov_radius = get_combo_target_fov_radius()
    if source_meepo then
        local draw_target = select(1, get_combo_target_under_cursor(source_meepo))
        if draw_target and Entity.IsAlive(draw_target) then
            target = draw_target
            combo_focus_target = draw_target
        else
            target = nil
            combo_focus_target = nil
        end
    elseif target and not Entity.IsAlive(target) then
        target = nil
        combo_focus_target = nil
    end
    if cursor_x and cursor_y and Render.Circle then
        local circle_color = target and Color(255, 110, 110, 230) or Color(255, 205, 120, 220)
        Render.Circle(Vec2(cursor_x, cursor_y), fov_radius, circle_color, 1.8)
    end
    if not target then
        local search_text = ground_combo_mode and "SEARCHING GROUND" or "SEARCHING"
        if cursor_x and cursor_y then
            Render.Text(
                font,
                tactical_font_size,
                search_text,
                Vec2(cursor_x + fov_radius + 8, cursor_y - 8),
                Color(255, 220, 130, 245)
            )
        end
        return
    end
    local target_pos = safe_call(Entity.GetAbsOrigin, target)
    if not target_pos then
        return
    end
    local target_pos_render = target_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, target) or 0) + 8)
    local target_screen, visible = Render.WorldToScreen(target_pos_render)
    if not visible then
        return
    end
    if cursor_x and cursor_y and Render.Line then
        Render.Line(Vec2(cursor_x, cursor_y), target_screen, COLORS.combo, 2.0)
    end
    local source_pos = safe_call(Entity.GetAbsOrigin, source_meepo)
    if source_pos and Render.Line then
        source_pos = source_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, source_meepo) or 0) + 8)
        local source_screen, source_visible = Render.WorldToScreen(source_pos)
        if source_visible then
            Render.Line(source_screen, target_screen, Color(255, 180, 180, 200), 1.4)
        end
    end
    if Render.Circle then
        Render.Circle(target_screen, 18, COLORS.combo, 2.0)
    end
    local draw_meepos = meepos or collect_meepos()
    local net_units = collect_owned_meepo_units(local_hero, draw_meepos)
    if #net_units == 0 and source_meepo then
        net_units = { source_meepo }
    end
    if #net_units > 0 and Render.WorldToScreen then
        local preferred_draw = script.is_combo_option_enabled(ui.combo_main_first) and get_main_meepo(local_hero) or nil
        local _, _, _, predicted_pos = choose_earthbind_caster(net_units, target, now, preferred_draw)
        if predicted_pos then
            local predicted_world = predicted_pos + Vector(0, 0, (safe_call(NPC.GetHealthBarOffset, target) or 0) + 8)
            local pred_screen, pred_visible = Render.WorldToScreen(predicted_world)
            if pred_visible and pred_screen then
                if Render.Line then
                    Render.Line(target_screen, pred_screen, Color(120, 220, 255, 180), 1.2)
                end
                if Render.Circle then
                    Render.Circle(pred_screen, 10, Color(120, 220, 255, 220), 2.0)
                end
            end
        end
    end
    local target_name = safe_call(NPC.GetUnitName, target) or "target"
    Render.Text(
        font,
        tactical_font_size,
        "TARGET: " .. tostring(target_name),
        Vec2(target_screen.x + 14, target_screen.y - 10),
        Color(255, 210, 210, 245)
    )
    local engage_mode_draw = tostring(script._combo_engage_mode or "MID")
    local combo_prediction = script.estimate_combo_hp_after_full(local_hero, target, net_units, now, engage_mode_draw)
    if combo_prediction then
        script._combo_predicted_hp_left = tonumber(combo_prediction.hp_left or 0) or 0
        script._combo_predicted_damage = tonumber(combo_prediction.total_damage or 0) or 0
        local hp_after = math.max(0, script._combo_predicted_hp_left)
        local hp_now = tonumber(combo_prediction.hp_now or 0) or 0
        local dmg_now = tonumber(combo_prediction.total_damage or 0) or 0
        local hp_line = string.format("AFTER COMBO HP: %.0f (-%.0f)", hp_after, dmg_now)
        local mode_line = string.format(
            "ENGAGE: %s  dist %.0f  c%.0f/m%.0f",
            engage_mode_draw,
            tonumber(script._combo_engage_distance or 0) or 0,
            tonumber(script._combo_engage_close_threshold or 0) or 0,
            tonumber(script._combo_engage_mid_threshold or 0) or 0
        )
        local hp_color = Color(255, 190, 190, 240)
        if hp_after <= 0 then
            hp_color = Color(155, 255, 170, 245)
        elseif hp_now > 0 and hp_after <= (hp_now * 0.30) then
            hp_color = Color(255, 225, 150, 240)
        end
        local extra_y = script.is_combo_option_enabled(ui.combo_debug) and (target_screen.y + 102) or (target_screen.y + 4)
        Render.Text(font, tactical_font_size, hp_line, Vec2(target_screen.x + 14, extra_y), hp_color)
        Render.Text(font, tactical_font_size, mode_line, Vec2(target_screen.x + 14, extra_y + 14), Color(180, 225, 255, 235))
        if script.is_combo_option_enabled(ui.combo_fight_estimator) then
            local est_line, est_color = script.get_combo_fight_estimate(combo_prediction)
            Render.Text(font, tactical_font_size, est_line, Vec2(target_screen.x + 14, extra_y + 28), est_color or Color(220, 220, 220, 230))
        end
    else
        script._combo_predicted_hp_left = 0
        script._combo_predicted_damage = 0
    end
    if script.is_combo_option_enabled(ui.combo_debug) then
        local phase_line = "PHASE: " .. tostring(script._combo_debug_phase or "-")
        local reason_line = "WHY: " .. tostring(script._combo_debug_reason or "-")
        local next_line = "NEXT: " .. tostring(script._combo_debug_next_disable or "-")
        local preferred_debug = script.is_combo_option_enabled(ui.combo_main_first) and get_main_meepo(local_hero) or nil
        local remaining_root_debug = get_effective_earthbind_remaining(target, now)
        local confirmed_root_debug = get_confirmed_control_remaining(target, now)
        local in_flight_debug = is_net_projectile_in_flight(target, now)
        local _, _, arrival_debug = choose_earthbind_caster(net_units, target, now, preferred_debug)
        if not arrival_debug then
            local _, _, arrival_fallback_debug = choose_earthbind_caster(net_units, target, now)
            arrival_debug = arrival_fallback_debug
        end
        local net_line = "NET: no-caster rem " .. string.format("%.2f", remaining_root_debug)
        if arrival_debug then
            local time_to_land_debug = math.max(0, arrival_debug - now)
            local handoff_window_debug = time_to_land_debug + C.COMBO_NET_CHAIN_BUFFER + C.COMBO_NET_HANDOFF_EXTRA
            local net_state_debug = remaining_root_debug <= handoff_window_debug and "CAST" or "HOLD"
            net_line = string.format(
                "NET: %s rem %.2f land %.2f win %.2f",
                net_state_debug,
                remaining_root_debug,
                time_to_land_debug,
                handoff_window_debug
            )
        end
        local follow_poof_count = tonumber(script._combo_last_net_follow_poof_count or 0) or 0
        local follow_age = now - (tonumber(script._combo_last_net_follow_poof_time or -9999) or -9999)
        local follow_text = string.format("NET->POOF: %d", follow_poof_count)
        if follow_age >= 0 and follow_age < 2.5 then
            follow_text = string.format("NET->POOF: %d (%.2fs)", follow_poof_count, follow_age)
        end
        local queue_count = (poof_cast_queue and #poof_cast_queue) or 0
        local queue_line = string.format("POOF QUEUE: %d", queue_count)
        local control_line = string.format(
            "CTRL: confirmed %.2f inflight %s",
            confirmed_root_debug,
            in_flight_debug and "yes" or "no"
        )
        Render.Text(font, tactical_font_size, phase_line, Vec2(target_screen.x + 14, target_screen.y + 4), Color(190, 230, 255, 240))
        Render.Text(font, tactical_font_size, reason_line, Vec2(target_screen.x + 14, target_screen.y + 18), Color(255, 235, 180, 240))
        Render.Text(font, tactical_font_size, next_line, Vec2(target_screen.x + 14, target_screen.y + 32), Color(200, 255, 200, 240))
        Render.Text(font, tactical_font_size, net_line, Vec2(target_screen.x + 14, target_screen.y + 46), Color(150, 220, 255, 240))
        Render.Text(font, tactical_font_size, follow_text, Vec2(target_screen.x + 14, target_screen.y + 60), Color(255, 215, 150, 240))
        Render.Text(font, tactical_font_size, queue_line, Vec2(target_screen.x + 14, target_screen.y + 74), Color(190, 255, 190, 240))
        Render.Text(font, tactical_font_size, control_line, Vec2(target_screen.x + 14, target_screen.y + 88), Color(255, 200, 200, 240))
    end
end
function script.can_cast_auto_safe_poof(meepo, poof)
    if not meepo or not poof then
        return false
    end
    local level = tonumber(safe_call(Ability.GetLevel, poof) or 0) or 0
    if level < 1 then
        return false
    end
    if not can_cast_ability_for_npc(meepo, poof) then
        return false
    end
    if safe_call(Ability.IsInAbilityPhase, poof) == true or safe_call(Ability.IsChannelling, poof) == true then
        return false
    end
    if NPC.IsSilenced and safe_call(NPC.IsSilenced, meepo) == true then
        return false
    end
    if NPC.IsStunned and safe_call(NPC.IsStunned, meepo) == true then
        return false
    end
    local hexed_state = Enum and Enum.ModifierState and Enum.ModifierState.MODIFIER_STATE_HEXED or nil
    if hexed_state and NPC.HasState and safe_call(NPC.HasState, meepo, hexed_state) == true then
        return false
    end
    return true
end
function script.get_unit_distance_2d(a, b)
    if not a or not b then
        return nil
    end
    local a_pos = safe_call(Entity.GetAbsOrigin, a)
    local b_pos = safe_call(Entity.GetAbsOrigin, b)
    return vec_dist_2d(a_pos, b_pos)
end
function script.count_enemies_near_unit(unit, radius)
    if not unit or not Entity.IsAlive(unit) then
        return 0
    end
    local enemy_list = Entity.GetHeroesInRadius(unit, radius, Enum.TeamType.TEAM_ENEMY, false, true) or {}
    return #enemy_list
end
function script.issue_auto_safe_poof(local_player, meepo, destination, poof, reason)
    return script.cast_target_single_unit(local_player, meepo, poof, destination, reason or "meepo_auto_safe_poof", false)
end
function script.find_auto_safe_enemy_destination(meepo, meepos)
    if not meepo or not meepos then
        return nil
    end
    local best_clone = nil
    local best_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            if script.count_enemies_near_unit(other, 1200) <= 0 then
                local d = script.get_unit_distance_2d(meepo, other) or 0
                if d > best_dist then
                    best_dist = d
                    best_clone = other
                end
            end
        end
    end
    if best_clone then
        return best_clone
    end
    best_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            local d = script.get_unit_distance_2d(meepo, other) or 0
            if d > 1500 and d > best_dist then
                best_dist = d
                best_clone = other
            end
        end
    end
    return best_clone
end
function script.find_auto_safe_hp_destination(meepo, meepos, main_meepo, mode)
    if not meepo or not meepos then
        return nil
    end
    local choice = tonumber(mode or 0) or 0
    if choice == 1 then
        if main_meepo and main_meepo ~= meepo and Entity.IsAlive(main_meepo) then
            return main_meepo
        end
        return nil
    end
    if choice == 2 then
        local healthiest = nil
        local best_hp = -1
        for i = 1, #meepos do
            local other = meepos[i]
            if other and other ~= meepo and Entity.IsAlive(other) then
                local hp = get_health_pct(other)
                if hp > best_hp then
                    best_hp = hp
                    healthiest = other
                end
            end
        end
        return healthiest
    end
    local farthest = nil
    local farthest_dist = 0
    for i = 1, #meepos do
        local other = meepos[i]
        if other and other ~= meepo and Entity.IsAlive(other) then
            local d = script.get_unit_distance_2d(meepo, other) or 0
            if d > farthest_dist then
                farthest_dist = d
                farthest = other
            end
        end
    end
    return farthest
end
function script.run_auto_safe_poof(local_hero, meepos, local_player, now)
    if not ui.auto_safe_enable:Get() then
        return false
    end
    if not local_hero or not Entity.IsAlive(local_hero) then
        return false
    end
    if not meepos or #meepos <= 0 then
        return false
    end
    local enemy_poof_enabled = ui.auto_safe_enemy_poof:Get()
    local hp_poof_enabled = ui.auto_safe_poof_hp_enable:Get()
    if not enemy_poof_enabled and not hp_poof_enabled then
        return false
    end
    local which_meepos = tonumber(ui.auto_safe_which_meepos:Get() or 1) or 1
    local enemy_radius = tonumber(ui.auto_safe_enemy_radius:Get() or 900) or 900
    local hp_threshold = tonumber(ui.auto_safe_poof_hp:Get() or 25) or 25
    local destination_mode = tonumber(ui.auto_safe_poof_dest:Get() or 0) or 0
    local cooldown = (tonumber(ui.auto_safe_cd_ms:Get() or 2000) or 2000) / 1000.0
    local triggered = false
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local is_main = (meepo == local_hero)
            local allow_unit = true
            if which_meepos == 1 and is_main then
                allow_unit = false
            elseif which_meepos == 2 and not is_main then
                allow_unit = false
            end
            if allow_unit then
                local key = get_entity_key(meepo)
                local last_safe = script._auto_safe_last_cast_by_meepo[key] or -9999
                if now - last_safe >= cooldown then
                    local enemy_count = script.count_enemies_near_unit(meepo, enemy_radius)
                    local has_enemies = enemy_count > 0
                    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                    local can_poof = script.can_cast_auto_safe_poof(meepo, poof)
                    local casted_for_meepo = false
                    if can_poof and enemy_poof_enabled and has_enemies then
                        local last_enemy_poof = script._auto_safe_last_enemy_poof_by_meepo[key] or -9999
                        if now - last_enemy_poof >= cooldown then
                            local enemy_dest = script.find_auto_safe_enemy_destination(meepo, meepos)
                            if enemy_dest and script.issue_auto_safe_poof(local_player, meepo, enemy_dest, poof, "meepo_poof_safety") then
                                script._auto_safe_last_enemy_poof_by_meepo[key] = now
                                script._auto_safe_last_cast_by_meepo[key] = now
                                triggered = true
                                casted_for_meepo = true
                            end
                        end
                    end
                    if (not casted_for_meepo) and can_poof and hp_poof_enabled and has_enemies then
                        local hp_pct = get_health_pct(meepo)
                        if hp_pct <= hp_threshold then
                            local hp_dest = script.find_auto_safe_hp_destination(meepo, meepos, local_hero, destination_mode)
                            if hp_dest and script.issue_auto_safe_poof(local_player, meepo, hp_dest, poof, "meepo_safe_poof") then
                                script._auto_safe_last_cast_by_meepo[key] = now
                                triggered = true
                                casted_for_meepo = true
                            end
                        end
                    end
                end
            end
        end
    end
    return triggered
end
function script.try_auto_dig(meepo, now)
    if not ui.auto_dig:Get() then
        return false
    end
    if not meepo or not Entity.IsAlive(meepo) then
        return false
    end
    local hp_pct = get_health_pct(meepo)
    if hp_pct > (tonumber(ui.auto_dig_hp:Get()) or 28) then
        return false
    end
    if safe_call(NPC.HasModifier, meepo, C.MODIFIER_DIG) then
        return false
    end
    if not should_trigger_save_by_enemy(meepo, now) then
        return false
    end
    local ready, dig = can_cast_dig(meepo)
    if not ready or not dig then
        return false
    end
    local key = get_entity_key(meepo)
    local last_cast = auto_dig_last_cast[key] or -9999
    if now - last_cast < C.AUTO_DIG_RECAST_DELAY then
        return false
    end
    local local_player = safe_call(Players.GetLocal)
    local ok = script.cast_no_target_single_unit(local_player, meepo, dig, "meepo_auto_dig", false)
    if ok then
        auto_dig_last_cast[key] = now
        return true
    end
    return false
end
function script.try_auto_mega(meepos, now)
    if not ui.auto_mega:Get() then
        return false
    end
    if not meepos or #meepos <= 0 then
        return false
    end
    local target, hp_pct = get_lowest_hp_meepo(meepos)
    if not target then
        return false
    end
    if ui.auto_dig:Get() then
        if safe_call(NPC.HasModifier, target, C.MODIFIER_DIG) then
            return false
        end
        local dig_ready = select(1, can_cast_dig(target))
        if dig_ready then
            -- Dig has priority on the endangered Meepo; Mega is fallback when Dig is unavailable.
            return false
        end
    end
    if (hp_pct or 100) > (tonumber(ui.auto_mega_hp:Get()) or 35) then
        return false
    end
    if has_any_modifier(target, C.MODIFIER_MEGA_CANDIDATES) then
        return false
    end
    if not should_trigger_save_by_enemy(target, now) then
        return false
    end
    local caster = nil
    local mega = nil
    local caster_dist = nil
    local function consider_mega_caster(meepo)
        if not meepo or not Entity.IsAlive(meepo) then
            return
        end
        local ready, ability = can_cast_mega(meepo)
        if not ready or not ability then
            return
        end
        local can_save, dist = script.can_mega_save_target(meepo, target, ability)
        if not can_save then
            return
        end
        local score = tonumber(dist or 0) or 0
        if not caster or score < (tonumber(caster_dist or 999999) or 999999) then
            caster = meepo
            mega = ability
            caster_dist = score
        end
    end
    local local_hero = Heroes.GetLocal()
    if local_hero and is_meepo_instance(local_hero) and Entity.IsAlive(local_hero) then
        consider_mega_caster(local_hero)
    end
    consider_mega_caster(target)
    for i = 1, #meepos do
        consider_mega_caster(meepos[i])
    end
    if not mega or not caster then
        return false
    end
    local key = get_entity_key(caster)
    local last_cast = auto_mega_last_cast[key] or -9999
    if now - last_cast < C.AUTO_MEGA_RECAST_DELAY then
        return false
    end
    local local_player = safe_call(Players.GetLocal)
    local ok = false
    if caster ~= target then
        ok = script.cast_target_single_unit(local_player, caster, mega, target, "meepo_auto_mega_target", false)
    end
    if not ok then
        ok = script.cast_no_target_single_unit(local_player, caster, mega, "meepo_auto_mega", false)
    end
    if ok then
        auto_mega_last_cast[key] = now
        return true
    end
    return false
end
function script.get_meepo_status(meepo)
    if not Entity.IsAlive(meepo) then
        return "DEAD", COLORS.dead, "HP 0% | MP -- | P -- | N -- | E --"
    end
    local is_attacking = NPC.IsAttacking(meepo)
    local is_running = NPC.IsRunning(meepo)
    local enemy_count, nearest_dist = get_enemy_info(meepo, C.ENEMY_RADIUS)
    local enemy_near = enemy_count > 0
    local hp_pct = get_health_pct(meepo)
    local mana_pct = get_mana_pct(meepo)
    local poof_cd = get_ability_cd(meepo, C.ABILITY_POOF)
    local net_cd = get_ability_cd(meepo, C.ABILITY_NET)
    local poof_ready = is_ability_ready(meepo, C.ABILITY_POOF)
    local net_ready = is_ability_ready(meepo, C.ABILITY_NET)
    local tactical = build_tactical_line(hp_pct, mana_pct, poof_cd, net_cd, nearest_dist)
    local retreat = enemy_near and hp_pct <= C.RETREAT_HP_PCT and (is_running or not is_attacking)
    if retreat then
        return "RETREAT", COLORS.retreat, tactical
    end
    local engage_ready =
        enemy_near and
        nearest_dist and nearest_dist <= C.READY_RADIUS and
        hp_pct >= C.SAFE_ENGAGE_HP_PCT and
        poof_ready and net_ready
    if engage_ready then
        return "ENGAGE_READY", COLORS.engage_ready, tactical
    end
    if is_attacking and enemy_near then
        return "COMBO", COLORS.combo, tactical
    end
    if is_attacking then
        return "FARM", COLORS.farm, tactical
    end
    if is_running then
        return "MOVE", COLORS.move, tactical
    end
    return "IDLE", COLORS.idle, tactical
end
function script.draw_meepo_status_world(meepo, status, color, tactical, order_index)
    local pos = Entity.GetAbsOrigin(meepo)
    if not pos then
        return
    end
    local z = NPC.GetHealthBarOffset(meepo) or 0
    pos = pos + Vector(0, 0, z + C.BAR_OFFSET_Z)
    local screen_pos, is_visible = pos:ToScreen()
    if not is_visible then
        return
    end
    local status_text = status or ""
    local idx_num = tonumber(order_index or 0) or 0
    if idx_num > 0 then
        status_text = "#" .. tostring(idx_num) .. " " .. status_text
    end
    local tactical_text = (ui.show_tactical:Get() and tactical) and tactical or ""
    local status_size = Render.TextSize(font, font_size, status_text)
    local tactical_size = tactical_text ~= "" and Render.TextSize(font, tactical_font_size, tactical_text) or Vec2(0, 0)
    local text_w = math.max(status_size.x, tactical_size.x)
    local text_h = status_size.y + (tactical_text ~= "" and (tactical_size.y + 2) or 0)
    local label_center_y = screen_pos.y - (text_h * 0.5 + (tonumber(C.BAR_LABEL_GAP_PX or 14) or 14))
    local padding_x, padding_y = 6, 3
    local bg_pos = Vec2(
        screen_pos.x - text_w / 2 - padding_x,
        label_center_y - text_h / 2 - padding_y
    )
    local bg_size = Vec2(
        text_w + padding_x * 2,
        text_h + padding_y * 2
    )
    if Render.FilledRect then
        Render.FilledRect(bg_pos, bg_pos + bg_size, COLORS.bg, 4, Enum.DrawFlags.RoundCornersAll)
    end
    local status_pos = Vec2(
        screen_pos.x - status_size.x / 2,
        label_center_y - text_h / 2
    )
    Render.Text(font, font_size, status_text, status_pos, color)
    if tactical_text ~= "" then
        local tactical_pos = Vec2(
            screen_pos.x - tactical_size.x / 2,
            status_pos.y + status_size.y + 2
        )
        Render.Text(font, tactical_font_size, tactical_text, tactical_pos, COLORS.tactical)
    end
end
function script.get_global_override_status(meepos)
    init_binds_once()
    if is_combo_active() then
        return "COMBO", COLORS.combo
    end
    if farm_bind and farm_bind.IsToggled then
        local success, is_toggled = pcall(function() return farm_bind:IsToggled() end)
        if success and is_toggled then
            return "FARM", COLORS.farm
        end
    end
    local source_meepos = meepos
    if not source_meepos or #source_meepos == 0 then
        source_meepos = collect_meepos()
    end
    if not source_meepos or #source_meepos < 2 then
        return nil, nil
    end
    local alive_meepos = {}
    for i = 1, #source_meepos do
        local meepo = source_meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            alive_meepos[#alive_meepos + 1] = meepo
        end
    end
    if #alive_meepos < 2 then
        return nil, nil
    end
    local attacking_count = 0
    local enemy_near_count = 0
    for i = 1, #alive_meepos do
        local meepo = alive_meepos[i]
        if NPC.IsAttacking(meepo) then
            attacking_count = attacking_count + 1
        end
        local enemies = Entity.GetHeroesInRadius(meepo, C.ENEMY_RADIUS, Enum.TeamType.TEAM_ENEMY, false, true)
        if enemies and #enemies > 0 then
            enemy_near_count = enemy_near_count + 1
        end
    end
    if attacking_count >= math.ceil(#alive_meepos * 0.8) and enemy_near_count >= math.ceil(#alive_meepos * 0.6) then
        return "COMBO", COLORS.combo
    end
    if attacking_count >= math.ceil(#alive_meepos * 0.8) and enemy_near_count < math.ceil(#alive_meepos * 0.2) then
        return "FARM", COLORS.farm
    end
    return nil, nil
end
function script.draw_meepo_status_portrait(order_index, status, color, tactical)
    local screen_size = Render.ScreenSize()
    local base_x = screen_size.x * (C.PORTRAIT_X_PCT / 100.0)
    local base_y = screen_size.y * (C.PORTRAIT_Y_PCT / 100.0)
    local step_y = screen_size.y * (C.PORTRAIT_STEP_Y_PCT / 100.0)
    local center = Vec2(base_x, base_y + step_y * (order_index - 1))
    local status_text = status or ""
    local idx_num = tonumber(order_index or 0) or 0
    if idx_num > 0 then
        status_text = "#" .. tostring(idx_num) .. " " .. status_text
    end
    local tactical_text = (ui.show_tactical:Get() and tactical) and tactical or ""
    local status_size = Render.TextSize(font, font_size, status_text)
    local tactical_size = tactical_text ~= "" and Render.TextSize(font, tactical_font_size, tactical_text) or Vec2(0, 0)
    local text_w = math.max(status_size.x, tactical_size.x)
    local text_h = status_size.y + (tactical_text ~= "" and (tactical_size.y + 2) or 0)
    local padding_x, padding_y = 6, 3
    local bg_pos = Vec2(
        center.x - text_w / 2 - padding_x,
        center.y - text_h / 2 - padding_y
    )
    local bg_size = Vec2(
        text_w + padding_x * 2,
        text_h + padding_y * 2
    )
    if Render.FilledRect then
        Render.FilledRect(bg_pos, bg_pos + bg_size, COLORS.bg, 4, Enum.DrawFlags.RoundCornersAll)
    end
    local status_pos = Vec2(
        center.x - status_size.x / 2,
        center.y - text_h / 2
    )
    Render.Text(font, font_size, status_text, status_pos, color)
    if tactical_text ~= "" then
        local tactical_pos = Vec2(
            center.x - tactical_size.x / 2,
            status_pos.y + status_size.y + 2
        )
        Render.Text(font, tactical_font_size, tactical_text, tactical_pos, COLORS.tactical)
    end
end
local function build_floating_panel_units(local_hero, meepos)
    local out = {}
    local seen = {}
    local main = get_main_meepo(local_hero)
    if main and is_meepo_instance(main) then
        local key = get_entity_key(main)
        seen[key] = true
        out[#out + 1] = main
    end
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and is_meepo_instance(meepo) then
            local key = get_entity_key(meepo)
            if not seen[key] then
                seen[key] = true
                out[#out + 1] = meepo
            end
        end
    end
    table.sort(out, function(a, b)
        local a_main = (a == main)
        local b_main = (b == main)
        if a_main ~= b_main then
            return a_main
        end
        local ai = tonumber(get_entity_key(a) or 0) or 0
        local bi = tonumber(get_entity_key(b) or 0) or 0
        return ai < bi
    end)
    return out
end
function script.draw_floating_meepo_panel(local_hero, meepos, now)
    if not ui.float_panel_enable:Get() then
        return
    end
    if not meepos or #meepos == 0 then
        return
    end
    if not Render or not Render.Text or not Render.FilledRect or not Render.TextSize then
        return
    end
    local panel_units = build_floating_panel_units(local_hero, meepos)
    if #panel_units == 0 then
        return
    end
    local function get_ui_number(widget, fallback)
        if widget and widget.Get then
            local ok, value = pcall(function()
                return widget:Get()
            end)
            if ok and value ~= nil then
                return tonumber(value) or fallback
            end
        end
        return fallback
    end
    local scale = get_ui_number(ui.float_panel_scale, 100) / 100.0
    if scale < 0.6 then
        scale = 0.6
    elseif scale > 2.2 then
        scale = 2.2
    end
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local slider_x = get_ui_number(ui.float_panel_x, 28)
    local slider_y = get_ui_number(ui.float_panel_y, 420)
    if script._float_panel_pos_x == nil then
        script._float_panel_pos_x = slider_x
    end
    if script._float_panel_pos_y == nil then
        script._float_panel_pos_y = slider_y
    end
    local px = tonumber(script._float_panel_pos_x) or slider_x
    local py = tonumber(script._float_panel_pos_y) or slider_y
    local panel_w = math.floor(310 * scale)
    local header_h = math.floor(28 * scale)
    local row_h = math.floor(34 * scale)
    local pad = math.max(4, math.floor(6 * scale))
    local panel_h = header_h + pad + (#panel_units * row_h) + pad
    local all_w = math.floor(40 * scale)
    local screen = Render.ScreenSize and Render.ScreenSize() or nil
    if screen then
        local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
        local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
        if px < 0 then
            px = 0
        elseif px > max_x then
            px = max_x
        end
        if py < 0 then
            py = 0
        elseif py > max_y then
            py = max_y
        end
        script._float_panel_pos_x = px
        script._float_panel_pos_y = py
    end
    local mouse1 = get_mouse1_code()
    local click_once_raw = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local mouse_down = mouse1 and safe_call(Input.IsKeyDown, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    local cursor_x, cursor_y = get_cursor_position()
    local drag_header_w = math.max(20, panel_w - all_w - pad - math.floor(10 * scale))
    local hover_drag_header = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, px, py, drag_header_w, header_h) == true
    if input_captured then
        script._float_panel_drag_active = false
    end
    if (not input_captured) and click_once_raw and hover_drag_header and cursor_x and cursor_y then
        script._float_panel_drag_active = true
        script._float_panel_drag_offset_x = cursor_x - px
        script._float_panel_drag_offset_y = cursor_y - py
    end
    if script._float_panel_drag_active then
        if input_captured or (not mouse_down) or (not cursor_x) or (not cursor_y) then
            script._float_panel_drag_active = false
        else
            local nx = math.floor((cursor_x - (script._float_panel_drag_offset_x or 0)) + 0.5)
            local ny = math.floor((cursor_y - (script._float_panel_drag_offset_y or 0)) + 0.5)
            if screen then
                local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
                local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
                if nx < 0 then
                    nx = 0
                elseif nx > max_x then
                    nx = max_x
                end
                if ny < 0 then
                    ny = 0
                elseif ny > max_y then
                    ny = max_y
                end
            end
            px = nx
            py = ny
            script._float_panel_pos_x = nx
            script._float_panel_pos_y = ny
        end
    end
    local base_bg = Color(10, 14, 22, 210)
    local border = Color(70, 120, 210, 220)
    local header_bg = Color(20, 28, 42, 235)
    local row_bg = Color(20, 26, 38, 180)
    local row_hover_bg = Color(34, 47, 68, 215)
    local row_sel_bg = Color(44, 66, 96, 225)
    local dead_row = Color(42, 26, 26, 200)
    local hp_col = Color(90, 215, 120, 255)
    local mp_col = Color(90, 150, 255, 255)
    local bar_bg = Color(30, 34, 44, 220)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), base_bg, 6, Enum.DrawFlags.RoundCornersAll)
    if Render.Rect then
        Render.Rect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), border, 6, Enum.DrawFlags.RoundCornersAll, 1.0)
    end
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + header_h), header_bg, 6, Enum.DrawFlags.RoundCornersAll)
    local title = "MEEPO CONTROL"
    Render.Text(font, tactical_font_size, title, Vec2(px + pad, py + math.floor((header_h - tactical_font_size) * 0.5)), Color(220, 235, 255, 245))
    local local_player = safe_call(Players.GetLocal)
    local selected_set = {}
    local selected_count = 0
    if local_player and Player and Player.GetSelectedUnits then
        local selected_units = safe_call(Player.GetSelectedUnits, local_player) or {}
        for i = 1, #selected_units do
            local u = selected_units[i]
            if u and is_meepo_instance(u) and Entity.IsAlive(u) then
                selected_set[get_entity_key(u)] = true
                selected_count = selected_count + 1
            end
        end
    end
    local right_info = string.format("SEL %d/%d", selected_count, #panel_units)
    local right_size = Render.TextSize(font, tactical_font_size, right_info)
    Render.Text(font, tactical_font_size, right_info, Vec2(px + panel_w - right_size.x - pad - math.floor(44 * scale), py + math.floor((header_h - tactical_font_size) * 0.5)), Color(170, 200, 255, 230))
    local all_x1 = px + panel_w - all_w - pad
    local all_y1 = py + math.floor((header_h - math.floor(18 * scale)) * 0.5)
    local all_x2 = all_x1 + all_w
    local all_y2 = all_y1 + math.floor(18 * scale)
    local hover_all = safe_call(Input.IsCursorInRect, all_x1, all_y1, all_w, all_y2 - all_y1) == true
    local all_color = hover_all and Color(90, 160, 255, 240) or Color(64, 108, 176, 230)
    Render.FilledRect(Vec2(all_x1, all_y1), Vec2(all_x2, all_y2), all_color, 4, Enum.DrawFlags.RoundCornersAll)
    Render.Text(font, tactical_font_size, "ALL", Vec2(all_x1 + math.floor(8 * scale), all_y1 + math.floor(1 * scale)), Color(245, 252, 255, 245))
    local click_select_enabled = ui.float_panel_click_select:Get()
    local allow_click_actions = click_select_enabled and click_once_raw and (not input_captured) and (not script._float_panel_drag_active)
    if allow_click_actions and local_player and hover_all then
        local alive_units = {}
        for i = 1, #panel_units do
            if Entity.IsAlive(panel_units[i]) then
                alive_units[#alive_units + 1] = panel_units[i]
            end
        end
        if #alive_units > 0 then
            ensure_combo_units_selected(local_player, alive_units)
        end
    end
    local main_unit = get_main_meepo(local_hero)
    local clone_num = 0
    local start_y = py + header_h + pad
    local btn_w = math.floor(44 * scale)
    local btn_pad = math.floor(6 * scale)
    for i = 1, #panel_units do
        local meepo = panel_units[i]
        local is_alive = Entity.IsAlive(meepo)
        local is_main = (meepo == main_unit)
        local key = get_entity_key(meepo)
        local is_selected = selected_set[key] == true
        if not is_main then
            clone_num = clone_num + 1
        end
        local row_x1 = px + pad
        local row_y1 = start_y + ((i - 1) * row_h)
        local row_x2 = px + panel_w - pad
        local row_y2 = row_y1 + row_h - 1
        local hover_row = safe_call(Input.IsCursorInRect, row_x1, row_y1, row_x2 - row_x1, row_h - 1) == true
        local row_color = row_bg
        if not is_alive then
            row_color = dead_row
        elseif is_selected then
            row_color = row_sel_bg
        elseif hover_row then
            row_color = row_hover_bg
        end
        Render.FilledRect(Vec2(row_x1, row_y1), Vec2(row_x2, row_y2), row_color, 4, Enum.DrawFlags.RoundCornersAll)
        local badge = is_main and "M" or tostring(clone_num)
        local badge_color = is_main and Color(255, 210, 120, 245) or Color(150, 210, 255, 240)
        Render.Text(font, tactical_font_size, badge, Vec2(row_x1 + math.floor(8 * scale), row_y1 + math.floor(2 * scale)), badge_color)
        local hp_pct = get_health_pct(meepo)
        local mp_pct = get_mana_pct(meepo)
        local info = string.format("%s  HP %d%%  MP %d%%", is_main and "MAIN" or "CLONE", round_int(hp_pct), round_int(mp_pct))
        Render.Text(font, tactical_font_size, info, Vec2(row_x1 + math.floor(24 * scale), row_y1 + math.floor(2 * scale)), Color(230, 236, 245, is_alive and 240 or 170))
        local bar_x1 = row_x1 + math.floor(24 * scale)
        local bar_x2 = row_x2 - btn_w - btn_pad - math.floor(4 * scale)
        local bar_w = math.max(10, bar_x2 - bar_x1)
        local hp_w = math.floor(bar_w * math.max(0, math.min(100, hp_pct)) / 100.0)
        local mp_w = math.floor(bar_w * math.max(0, math.min(100, mp_pct)) / 100.0)
        local hp_y = row_y1 + math.floor(16 * scale)
        local mp_y = row_y1 + math.floor(23 * scale)
        local bar_h = math.max(2, math.floor(5 * scale))
        Render.FilledRect(Vec2(bar_x1, hp_y), Vec2(bar_x1 + bar_w, hp_y + bar_h), bar_bg, 2, Enum.DrawFlags.RoundCornersAll)
        if hp_w > 0 then
            Render.FilledRect(Vec2(bar_x1, hp_y), Vec2(bar_x1 + hp_w, hp_y + bar_h), hp_col, 2, Enum.DrawFlags.RoundCornersAll)
        end
        Render.FilledRect(Vec2(bar_x1, mp_y), Vec2(bar_x1 + bar_w, mp_y + bar_h), bar_bg, 2, Enum.DrawFlags.RoundCornersAll)
        if mp_w > 0 then
            Render.FilledRect(Vec2(bar_x1, mp_y), Vec2(bar_x1 + mp_w, mp_y + bar_h), mp_col, 2, Enum.DrawFlags.RoundCornersAll)
        end
        local btn_x1 = row_x2 - btn_w - btn_pad
        local btn_y1 = row_y1 + math.floor(6 * scale)
        local btn_h = math.floor(20 * scale)
        local btn_x2 = btn_x1 + btn_w
        local btn_y2 = btn_y1 + btn_h
        local hover_btn = safe_call(Input.IsCursorInRect, btn_x1, btn_y1, btn_w, btn_h) == true
        local btn_col = hover_btn and Color(86, 154, 255, 240) or Color(62, 110, 190, 230)
        Render.FilledRect(Vec2(btn_x1, btn_y1), Vec2(btn_x2, btn_y2), btn_col, 3, Enum.DrawFlags.RoundCornersAll)
        Render.Text(font, tactical_font_size, "SEL", Vec2(btn_x1 + math.floor(8 * scale), btn_y1 + math.floor(2 * scale)), Color(250, 252, 255, 245))
        if allow_click_actions and local_player and is_alive and (hover_row or hover_btn) then
            ensure_combo_units_selected(local_player, { meepo })
        end
    end
end
function clamp_value(v, min_v, max_v)
    if v < min_v then
        return min_v
    end
    if v > max_v then
        return max_v
    end
    return v
end
function clamp01(v)
    return clamp_value(v, 0, 1)
end
function autofarm_get_ui_number(widget, fallback)
    if widget and widget.Get then
        local ok, value = pcall(function()
            return widget:Get()
        end)
        if ok and value ~= nil then
            return tonumber(value) or fallback
        end
    end
    return fallback
end
function script._autofarm_get_text_size_cached(font_obj, font_size, text, now_time, ttl_override)
    if not Render or not Render.TextSize then
        return Vec2(0, 0)
    end
    local msg = tostring(text or "")
    local size_key = tostring(font_size or 0) .. "|" .. msg
    script._autofarm_text_size_cache = script._autofarm_text_size_cache or {}
    local cache = script._autofarm_text_size_cache
    local rec = cache[size_key]
    local now = tonumber(now_time or get_game_time() or 0) or 0
    local ttl = tonumber(ttl_override or (script._autofarm_cfg and script._autofarm_cfg.TEXT_SIZE_CACHE_TTL) or 0.75) or 0.75
    if ttl < 0.05 then
        ttl = 0.05
    end
    if now >= (tonumber(script._autofarm_text_size_cache_gc_next or 0) or 0) then
        local keep_window = math.max(1.00, ttl * 4.0)
        for k, v in pairs(cache) do
            local t = tonumber(v and v.t or -9999) or -9999
            if (now - t) > keep_window then
                cache[k] = nil
            end
        end
        script._autofarm_text_size_cache_gc_next = now + 1.15
    end
    if rec
        and rec.size == font_size
        and rec.text == msg
        and (now - (tonumber(rec.t or -9999) or -9999)) <= ttl
        and rec.v then
        return rec.v
    end
    local v = Render.TextSize(font_obj, font_size, msg)
    cache[size_key] = {
        t = now,
        size = font_size,
        text = msg,
        v = v,
    }
    script._autofarm_text_size_cache = cache
    return v
end
function autofarm_get_image_handle(path)
    if not path or path == "" then
        return nil
    end
    local cache = script._autofarm_image_cache or {}
    script._autofarm_image_cache = cache
    local cached = cache[path]
    if cached ~= nil then
        if cached == false then
            return nil
        end
        return cached
    end
    local handle = nil
    if Render and Render.LoadImage then
        handle = safe_call(Render.LoadImage, path)
    end
    if handle then
        cache[path] = handle
    else
        cache[path] = false
    end
    return handle
end
function autofarm_get_map_image()
    for i = 1, #AUTOFARM_MAP_TEXTURES do
        local handle = autofarm_get_image_handle(AUTOFARM_MAP_TEXTURES[i])
        if handle then
            return handle
        end
    end
    return nil
end
function autofarm_map_to_screen(nx, ny, map_x, map_y, map_size)
    local px = map_x + (clamp01(nx or 0) * map_size)
    local py = map_y + ((1 - clamp01(ny or 0)) * map_size)
    return px, py
end
function autofarm_screen_to_map(cursor_x, cursor_y, map_x, map_y, map_size)
    if map_size <= 0 then
        return nil, nil
    end
    local nx = (cursor_x - map_x) / map_size
    local ny = 1 - ((cursor_y - map_y) / map_size)
    if nx < 0 or nx > 1 or ny < 0 or ny > 1 then
        return nil, nil
    end
    return clamp01(nx), clamp01(ny)
end
function script.autofarm_world_to_norm(pos)
    if not pos then
        return nil, nil
    end
    local span = AUTOFARM_WORLD_MAX - AUTOFARM_WORLD_MIN
    if span <= 0 then
        return nil, nil
    end
    local nx = ((pos.x or 0) - AUTOFARM_WORLD_MIN) / span
    local ny = ((pos.y or 0) - AUTOFARM_WORLD_MIN) / span
    return clamp01(nx), clamp01(ny)
end
function script.autofarm_norm_to_world(nx, ny, z)
    local span = AUTOFARM_WORLD_MAX - AUTOFARM_WORLD_MIN
    local wx = AUTOFARM_WORLD_MIN + (clamp01(nx or 0) * span)
    local wy = AUTOFARM_WORLD_MIN + (clamp01(ny or 0) * span)
    return Vector(wx, wy, z or 0)
end
function script.get_autofarm_camp_points(now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local cached = script._autofarm_camp_cache
    local cached_time = tonumber(script._autofarm_camp_cache_time or -9999) or -9999
    if cached and #cached > 0 and (now_time - cached_time) <= AUTOFARM_CAMP_CACHE_TTL then
        return cached
    end
    local points = {}
    local camps = (Camps and Camps.GetAll) and safe_call(Camps.GetAll) or nil
    if camps then
        for i = 1, #camps do
            local camp = camps[i]
            local pos = camp and safe_call(Entity.GetAbsOrigin, camp) or nil
            if pos then
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local idx = tonumber(safe_call(Entity.GetIndex, camp) or i) or i
                    local side = (((pos.x or 0) + (pos.y or 0)) < 0) and "r" or "d"
                    local camp_type = (Camp and Camp.GetType) and (tonumber(safe_call(Camp.GetType, camp) or -1) or -1) or -1
                    local camp_box_raw = (Camp and Camp.GetCampBox) and safe_call(Camp.GetCampBox, camp) or nil
                    local camp_box = nil
                    if camp_box_raw and camp_box_raw.min and camp_box_raw.max then
                        camp_box = {
                            min = Vector(
                                camp_box_raw.min.x or 0,
                                camp_box_raw.min.y or 0,
                                camp_box_raw.min.z or 0
                            ),
                            max = Vector(
                                camp_box_raw.max.x or 0,
                                camp_box_raw.max.y or 0,
                                camp_box_raw.max.z or 0
                            ),
                        }
                    end
                    points[#points + 1] = {
                        id = "camp_" .. tostring(idx),
                        label = "",
                        nx = nx,
                        ny = ny,
                        side = side,
                        world = Vector(pos.x or 0, pos.y or 0, pos.z or 0),
                        camp_index = idx,
                        camp_type = camp_type,
                        camp_box = camp_box,
                        preset = true,
                    }
                end
            end
        end
    end
    if #points > 0 then
        table.sort(points, function(a, b)
            local a_side = tostring(a.side or "")
            local b_side = tostring(b.side or "")
            if a_side ~= b_side then
                return a_side < b_side
            end
            local ai = tonumber(a.camp_index or 0) or 0
            local bi = tonumber(b.camp_index or 0) or 0
            return ai < bi
        end)
        local r_count = 0
        local d_count = 0
        for i = 1, #points do
            local point = points[i]
            if point.side == "r" then
                r_count = r_count + 1
                point.label = "R" .. tostring(r_count)
            else
                d_count = d_count + 1
                point.label = "D" .. tostring(d_count)
            end
        end
    else
        for i = 1, #AUTOFARM_FALLBACK_CAMPS do
            local fallback = AUTOFARM_FALLBACK_CAMPS[i]
            points[#points + 1] = {
                id = fallback.id,
                label = fallback.label,
                nx = fallback.nx,
                ny = fallback.ny,
                side = fallback.side,
                world = fallback.world or script.autofarm_norm_to_world(fallback.nx, fallback.ny, 0),
                preset = true,
            }
        end
    end
    script._autofarm_camp_cache = points
    script._autofarm_camp_cache_time = now_time
    return points
end
function get_all_autofarm_points()
    return script.get_autofarm_camp_points and script.get_autofarm_camp_points() or {}
end
function script.get_autofarm_selected_locations()
    local selected = script._autofarm_selected_points or {}
    local out = {}
    local camps = script.get_autofarm_camp_points and script.get_autofarm_camp_points() or {}
    -- If nothing selected after a reload, auto-select stored side toggles (Radiant/Dire)
    if next(selected) == nil and #camps > 0 then
        local side_r = script._autofarm_settings_side_r
        local side_d = script._autofarm_settings_side_d
        if side_r == nil or side_d == nil then
            local side = script._autofarm_settings_side or "r"
            side_r = side ~= "d"
            side_d = side == "d"
        end
        if side_r ~= true and side_d ~= true then
            side_r = true
            side_d = false
        end
        script._autofarm_settings_side_r = side_r == true
        script._autofarm_settings_side_d = side_d == true
        if side_d == true and side_r ~= true then
            script._autofarm_settings_side = "d"
        else
            script._autofarm_settings_side = "r"
        end
        for i = 1, #camps do
            local point = camps[i]
            local pick = point and point.side and (
                (point.side == "r" and side_r == true)
                or (point.side == "d" and side_d == true)
            )
            if point and point.id and pick then
                selected[point.id] = true
            end
        end
        script._autofarm_selected_points = selected
    end
    for i = 1, #camps do
        local point = camps[i]
        if selected[point.id] == true then
            out[#out + 1] = {
                id = point.id,
                label = point.label,
                world = point.world or script.autofarm_norm_to_world(point.nx, point.ny, 0),
                nx = point.nx,
                ny = point.ny,
                side = point.side,
                camp_index = point.camp_index,
                camp_type = point.camp_type,
                camp_box = point.camp_box,
                preset = true,
            }
        end
    end
    return out
end
local function is_pos_in_box(pos, box)
    if not pos or not box or not box.min or not box.max then
        return false
    end
    return (pos.x or 0) >= (box.min.x or 0)
        and (pos.x or 0) <= (box.max.x or 0)
        and (pos.y or 0) >= (box.min.y or 0)
        and (pos.y or 0) <= (box.max.y or 0)
end
local function get_camp_center(camp)
    if not camp then
        return nil
    end
    if camp.camp_box and camp.camp_box.min and camp.camp_box.max then
        return Vector(
            ((camp.camp_box.min.x or 0) + (camp.camp_box.max.x or 0)) * 0.5,
            ((camp.camp_box.min.y or 0) + (camp.camp_box.max.y or 0)) * 0.5,
            ((camp.camp_box.min.z or 0) + (camp.camp_box.max.z or 0)) * 0.5
        )
    end
    return camp.world or script.autofarm_norm_to_world(camp.nx, camp.ny, 0)
end
local function get_camp_offset_point(camp, from_pos, distance)
    local center = get_camp_center(camp)
    if not center then
        return nil
    end
    local dir_x = 1
    local dir_y = 0
    if from_pos then
        local dx = (from_pos.x or 0) - (center.x or 0)
        local dy = (from_pos.y or 0) - (center.y or 0)
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0.001 then
            dir_x = dx / len
            dir_y = dy / len
        end
    end
    local dist = tonumber(distance or AUTOFARM_SPAWN_CLEAR_DISTANCE) or AUTOFARM_SPAWN_CLEAR_DISTANCE
    if camp and camp.camp_box and camp.camp_box.min and camp.camp_box.max then
        local half_x = math.abs((camp.camp_box.max.x or 0) - (camp.camp_box.min.x or 0)) * 0.5
        local half_y = math.abs((camp.camp_box.max.y or 0) - (camp.camp_box.min.y or 0)) * 0.5
        local min_clear = math.max(half_x, half_y) + 420
        if dist < min_clear then
            dist = min_clear
        end
    end
    local perp_x = -dir_y
    local perp_y = dir_x
    local function make_ground_pos(x, y, fallback_z)
        local px = clamp_value(tonumber(x or 0) or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX)
        local py = clamp_value(tonumber(y or 0) or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX)
        local pz = tonumber(fallback_z or 0) or 0
        if World and World.GetGroundZ then
            local gz = tonumber(safe_call(World.GetGroundZ, px, py))
            if gz then
                pz = gz
            end
        end
        return Vector(px, py, pz)
    end
    local function is_traversable_pos(pos)
        if not pos then
            return false
        end
        if GridNav and GridNav.IsTraversable then
            local traversable = safe_call(GridNav.IsTraversable, pos)
            if traversable ~= nil then
                return traversable == true
            end
        end
        return true
    end
    local function is_reachable_pos(from_pos_local, to_pos)
        if not to_pos then
            return false
        end
        if from_pos_local and GridNav and GridNav.IsTraversableFromTo then
            local reachable = safe_call(GridNav.IsTraversableFromTo, from_pos_local, to_pos, false)
            if reachable ~= nil then
                return reachable == true
            end
        end
        return is_traversable_pos(to_pos)
    end
    local lateral_scales = { 0, 0.25, -0.25, 0.45, -0.45, 0.70, -0.70, 1.0, -1.0 }
    local distance_scales = { 1.0, 1.15, 1.32 }
    local direction_scales = { 1.0, -1.0 }
    local origin = from_pos or center
    local fallback_traversable = nil
    for d_i = 1, #distance_scales do
        local base_dist = dist * distance_scales[d_i]
        for dir_i = 1, #direction_scales do
            local d_sign = direction_scales[dir_i]
            local base_x = dir_x * base_dist * d_sign
            local base_y = dir_y * base_dist * d_sign
            for l_i = 1, #lateral_scales do
                local lat = lateral_scales[l_i]
                local x = (center.x or 0) + base_x + (perp_x * base_dist * lat)
                local y = (center.y or 0) + base_y + (perp_y * base_dist * lat)
                local pos = make_ground_pos(x, y, center.z or 0)
                if pos and not (camp and camp.camp_box and is_pos_in_box(pos, camp.camp_box)) then
                    local traversable = is_traversable_pos(pos)
                    if traversable and not fallback_traversable then
                        fallback_traversable = pos
                    end
                    if traversable and is_reachable_pos(origin, pos) then
                        return pos
                    end
                end
            end
        end
    end
    if fallback_traversable then
        return fallback_traversable
    end
    return nil
end
local function format_time_short(seconds)
    if not seconds or seconds < 0 then
        return "0:00"
    end
    local s = math.floor(seconds + 0.5)
    local m = math.floor(s / 60)
    local r = s - (m * 60)
    return string.format("%d:%02d", m, r)
end
function script.autofarm_camp_has_creeps(camp, neutral_entries)
    local center = get_camp_center(camp)
    if not center then
        return false, {}, nil
    end
    local detect_radius = AUTOFARM_CAMP_DETECT_RADIUS or 760
    local radius_sq = detect_radius * detect_radius
    local candidates = neutral_entries
    if not candidates then
        candidates = script.get_autofarm_neutral_creep_snapshot()
    end
    local found = {}
    local spatial = script._autofarm_neutral_spatial
    local use_spatial = spatial
        and spatial.entries == candidates
        and spatial.bins
        and tonumber(spatial.cell or 0) > 0
    if use_spatial then
        local cell = tonumber(spatial.cell or detect_radius) or detect_radius
        local min_x, max_x, min_y, max_y
        if camp and camp.camp_box and camp.camp_box.min and camp.camp_box.max then
            min_x = tonumber(camp.camp_box.min.x or 0) or 0
            max_x = tonumber(camp.camp_box.max.x or 0) or 0
            min_y = tonumber(camp.camp_box.min.y or 0) or 0
            max_y = tonumber(camp.camp_box.max.y or 0) or 0
        else
            min_x = (tonumber(center.x or 0) or 0) - detect_radius
            max_x = (tonumber(center.x or 0) or 0) + detect_radius
            min_y = (tonumber(center.y or 0) or 0) - detect_radius
            max_y = (tonumber(center.y or 0) or 0) + detect_radius
        end
        local cmin_x = math.floor(min_x / cell)
        local cmax_x = math.floor(max_x / cell)
        local cmin_y = math.floor(min_y / cell)
        local cmax_y = math.floor(max_y / cell)
        for cx = cmin_x, cmax_x do
            for cy = cmin_y, cmax_y do
                local bucket = spatial.bins[tostring(cx) .. ":" .. tostring(cy)]
                if bucket then
                    for i = 1, #bucket do
                        local entry = bucket[i]
                        local npc = entry and (entry.npc or entry)
                        local pos = entry and entry.pos or nil
                        if npc and pos then
                            local inside = false
                            if camp and camp.camp_box then
                                inside = is_pos_in_box(pos, camp.camp_box)
                            else
                                local dx = (pos.x or 0) - (center.x or 0)
                                local dy = (pos.y or 0) - (center.y or 0)
                                inside = (dx * dx + dy * dy) <= radius_sq
                            end
                            if inside then
                                found[#found + 1] = npc
                            end
                        end
                    end
                end
            end
        end
    else
        for i = 1, #candidates do
            local entry = candidates[i]
            local npc = entry and (entry.npc or entry)
            local pos = entry and entry.pos or nil
            if npc then
                if not pos then
                    pos = safe_call(Entity.GetAbsOrigin, npc)
                end
                if pos then
                    local inside = false
                    if camp and camp.camp_box then
                        inside = is_pos_in_box(pos, camp.camp_box)
                    else
                        local dx = (pos.x or 0) - (center.x or 0)
                        local dy = (pos.y or 0) - (center.y or 0)
                        inside = (dx * dx + dy * dy) <= radius_sq
                    end
                    if inside then
                        found[#found + 1] = npc
                    end
                end
            end
        end
    end
    return #found > 0, found, center
end
function script.is_autofarm_tower_name(unit_name)
    local name = string.lower(tostring(unit_name or ""))
    if name == "" then
        return false
    end
    if string.find(name, "npc_dota_tower", 1, true) ~= nil then
        return true
    end
    if string.find(name, "npc_dota_goodguys_tower", 1, true) ~= nil then
        return true
    end
    if string.find(name, "npc_dota_badguys_tower", 1, true) ~= nil then
        return true
    end
    return false
end
function script.collect_autofarm_ally_towers(local_hero, now_time, ttl_override)
    local out = {}
    local local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local ttl = tonumber(ttl_override or (script._autofarm_cfg and script._autofarm_cfg.TOWER_CACHE_TTL) or 0.35) or 0.35
    if ttl < 0.05 then
        ttl = 0.05
    end
    script._autofarm_tower_cache = script._autofarm_tower_cache or { t = -9999, hero = nil, team = -1, out = {} }
    local cache = script._autofarm_tower_cache
    local cache_t = tonumber(cache.t or -9999) or -9999
    local cache_valid = cache.hero == local_hero and cache.team == local_team and (t - cache_t) <= ttl
    if cache_valid then
        local cached_out = cache.out or {}
        for i = 1, #cached_out do
            local entry = cached_out[i]
            if not (entry and entry.unit and Entity.IsAlive(entry.unit)) then
                cache_valid = false
                break
            end
        end
        if cache_valid then
            return cached_out, local_team
        end
    end
    local candidates = {}
    local function append_candidates(list)
        if not list then
            return
        end
        for i = 1, #list do
            candidates[#candidates + 1] = list[i]
        end
    end
    if NPCs and NPCs.GetAll then
        local building_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_BUILDING or nil
        if building_flag then
            script.autofarm_metric_inc("q_npcs_getall", 1)
            append_candidates(safe_call(NPCs.GetAll, building_flag) or {})
        end
        script.autofarm_metric_inc("q_npcs_getall", 1)
        append_candidates(safe_call(NPCs.GetAll) or {})
    end
    local seen = {}
    for i = 1, #candidates do
        local npc = candidates[i]
        if npc and Entity.IsAlive(npc) then
            local team = tonumber(safe_call(Entity.GetTeamNum, npc) or -2) or -2
            if local_team < 0 or team == local_team then
                local is_tower = false
                if NPC and NPC.IsTower then
                    is_tower = safe_call(NPC.IsTower, npc) == true
                end
                if not is_tower then
                    local unit_name = safe_call(NPC.GetUnitName, npc)
                    is_tower = script.is_autofarm_tower_name(unit_name)
                end
                if not is_tower then
                    local class_name = string.lower(tostring(safe_call(Entity.GetClassName, npc) or ""))
                    if class_name ~= "" and string.find(class_name, "tower", 1, true) ~= nil then
                        is_tower = true
                    end
                end
                if is_tower then
                    local pos = safe_call(Entity.GetAbsOrigin, npc)
                    if pos then
                        local key = get_entity_key(npc)
                        if not seen[key] then
                            seen[key] = true
                            local nx, ny = script.autofarm_world_to_norm(pos)
                            out[#out + 1] = {
                                id = key,
                                unit = npc,
                                pos = pos,
                                nx = nx,
                                ny = ny,
                                team = team,
                            }
                        end
                    end
                end
            end
        end
    end
    cache.t = t
    cache.hero = local_hero
    cache.team = local_team
    cache.out = out
    script._autofarm_tower_cache = cache
    return out, local_team
end
function script.is_autofarm_fountain_name(unit_name)
    local name = string.lower(tostring(unit_name or ""))
    if name == "" then
        return false
    end
    if string.find(name, "fountain", 1, true) ~= nil then
        return true
    end
    if string.find(name, "npc_dota_fountain", 1, true) ~= nil then
        return true
    end
    if string.find(name, "ent_dota_fountain", 1, true) ~= nil then
        return true
    end
    return false
end
function script.get_autofarm_team_fountain(local_hero, now_time)
    if not local_hero then
        return nil, nil
    end
    local team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    if team < 0 then
        return nil, nil
    end
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local cache_ttl = tonumber((script._autofarm_cfg and script._autofarm_cfg.FOUNTAIN_CACHE_TTL) or 2.2) or 2.2
    if cache_ttl < 0.30 then
        cache_ttl = 0.30
    end
    script._autofarm_fountain_cache = script._autofarm_fountain_cache or {}
    local cache = script._autofarm_fountain_cache
    local cached = cache[team]
    if cached and cached.unit and Entity.IsAlive(cached.unit) and ((t - (tonumber(cached.time or 0) or 0)) <= cache_ttl) then
        local live_pos = safe_call(Entity.GetAbsOrigin, cached.unit) or cached.pos
        if live_pos then
            cached.pos = live_pos
            cached.time = t
            return live_pos, cached.unit
        end
    end
    local local_pos = safe_call(Entity.GetAbsOrigin, local_hero)
    local best_unit = nil
    local best_pos = nil
    local best_dist = nil
    local candidates = {}
    local function append_candidates(list)
        if not list then
            return
        end
        for i = 1, #list do
            candidates[#candidates + 1] = list[i]
        end
    end
    if NPCs and NPCs.GetAll then
        local building_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_BUILDING or nil
        if building_flag then
            script.autofarm_metric_inc("q_npcs_getall", 1)
            append_candidates(safe_call(NPCs.GetAll, building_flag) or {})
        end
        script.autofarm_metric_inc("q_npcs_getall", 1)
        append_candidates(safe_call(NPCs.GetAll) or {})
    end
    local seen = {}
    for i = 1, #candidates do
        local npc = candidates[i]
        if npc and Entity.IsAlive(npc) then
            local npc_team = tonumber(safe_call(Entity.GetTeamNum, npc) or -2) or -2
            if npc_team == team then
                local key = get_entity_key(npc)
                if not seen[key] then
                    seen[key] = true
                    local is_fountain = false
                    if NPC and NPC.IsFountain then
                        is_fountain = safe_call(NPC.IsFountain, npc) == true
                    end
                    if not is_fountain then
                        local unit_name = safe_call(NPC.GetUnitName, npc)
                        is_fountain = script.is_autofarm_fountain_name(unit_name)
                    end
                    if not is_fountain then
                        local class_name = string.lower(tostring(safe_call(Entity.GetClassName, npc) or ""))
                        if class_name ~= "" and string.find(class_name, "fountain", 1, true) ~= nil then
                            is_fountain = true
                        end
                    end
                    if is_fountain then
                        local pos = safe_call(Entity.GetAbsOrigin, npc)
                        if pos then
                            local d = local_pos and vec_dist_2d(local_pos, pos) or 0
                            if (not best_dist) or d < best_dist then
                                best_unit = npc
                                best_pos = pos
                                best_dist = d
                            end
                        end
                    end
                end
            end
        end
    end
    cache[team] = { unit = best_unit, pos = best_pos, time = t }
    return best_pos, best_unit
end
function script.collect_autofarm_wave_markers(local_hero, now_time)
    local towers, local_team = script.collect_autofarm_ally_towers(local_hero, now_time)
    local markers = {}
    local lane_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_LANE_CREEP or nil
    local lane_units = {}
    if NPCs and NPCs.GetAll then
        script.autofarm_metric_inc("q_npcs_getall", 1)
        lane_units = lane_flag and (safe_call(NPCs.GetAll, lane_flag) or {}) or (safe_call(NPCs.GetAll) or {})
    end
    local clusters = {}
    local cluster_link_dist = script._autofarm_cfg.WAVE_CLUSTER_LINK_DIST
    local interest_points = {}
    for i = 1, #towers do
        local tower = towers[i]
        if tower and tower.pos then
            interest_points[#interest_points + 1] = tower.pos
        end
    end
    local meepos = collect_meepos(local_hero, now_time)
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local pos = safe_call(Entity.GetAbsOrigin, meepo)
            if pos then
                interest_points[#interest_points + 1] = pos
            end
        end
    end
    local interest_radius = tonumber(script._autofarm_cfg and script._autofarm_cfg.WAVE_INTEREST_RADIUS or 2600) or 2600
    if interest_radius < 900 then
        interest_radius = 900
    end
    local interest_radius_sq = interest_radius * interest_radius
    local function is_near_interest(pos)
        if not pos then
            return false
        end
        if #interest_points == 0 then
            return true
        end
        for ip = 1, #interest_points do
            local p = interest_points[ip]
            if p then
                local dx = (pos.x or 0) - (p.x or 0)
                local dy = (pos.y or 0) - (p.y or 0)
                if (dx * dx + dy * dy) <= interest_radius_sq then
                    return true
                end
            end
        end
        return false
    end
    for i = 1, #lane_units do
        local npc = lane_units[i]
        if npc and Entity.IsAlive(npc) and safe_call(NPC.IsWaitingToSpawn, npc) ~= true then
            local is_lane_creep = NPC.IsLaneCreep and safe_call(NPC.IsLaneCreep, npc) == true
            if lane_flag or is_lane_creep then
                local pos = safe_call(Entity.GetAbsOrigin, npc)
                local team = tonumber(safe_call(Entity.GetTeamNum, npc) or -1) or -1
                if pos and team >= 0 and is_near_interest(pos) then
                    local best_idx = nil
                    local best_dist = nil
                    for j = 1, #clusters do
                        local c = clusters[j]
                        if c and c.team == team and c.count and c.count > 0 then
                            local cx = c.sum_x / c.count
                            local cy = c.sum_y / c.count
                            local d = vec_dist_2d(pos, Vector(cx, cy, pos.z or 0))
                            if d <= cluster_link_dist and ((not best_dist) or d < best_dist) then
                                best_dist = d
                                best_idx = j
                            end
                        end
                    end
                    if best_idx then
                        local c = clusters[best_idx]
                        c.sum_x = c.sum_x + (pos.x or 0)
                        c.sum_y = c.sum_y + (pos.y or 0)
                        c.sum_z = c.sum_z + (pos.z or 0)
                        c.count = c.count + 1
                        c.units[#c.units + 1] = npc
                    else
                        clusters[#clusters + 1] = {
                            team = team,
                            sum_x = (pos.x or 0),
                            sum_y = (pos.y or 0),
                            sum_z = (pos.z or 0),
                            count = 1,
                            units = { npc },
                        }
                    end
                end
            end
        end
    end
    for i = 1, #clusters do
        local c = clusters[i]
        if c and c.count and c.count >= 2 then
            local center = Vector(c.sum_x / c.count, c.sum_y / c.count, c.sum_z / c.count)
            local nx, ny = script.autofarm_world_to_norm(center)
            if nx and ny then
                local qx = math.floor((((center.x or 0) + 9200) / 520) + 0.5)
                local qy = math.floor((((center.y or 0) + 9200) / 520) + 0.5)
                local id = tostring(c.team) .. ":" .. tostring(qx) .. ":" .. tostring(qy)
                local nearest_tower = nil
                local nearest_tower_dist = nil
                for ti = 1, #towers do
                    local tower = towers[ti]
                    local tower_pos = tower and tower.pos or nil
                    if tower_pos then
                        local d = vec_dist_2d(center, tower_pos)
                        if (not nearest_tower_dist) or d < nearest_tower_dist then
                            nearest_tower_dist = d
                            nearest_tower = tower
                        end
                    end
                end
                local is_enemy_wave = local_team >= 0 and c.team ~= local_team
                local threatens_ally_tower = is_enemy_wave and nearest_tower_dist and nearest_tower_dist <= script._autofarm_cfg.WAVE_DEFENSE_TOWER_RADIUS
                markers[#markers + 1] = {
                    id = id,
                    team = c.team,
                    count = c.count,
                    nx = nx,
                    ny = ny,
                    center = center,
                    creeps = c.units or {},
                    tower = nearest_tower,
                    dist_to_tower = nearest_tower_dist,
                    threatens_ally_tower = threatens_ally_tower == true,
                }
            end
        end
    end
    return markers, towers, local_team
end
function script.get_cached_autofarm_wave_markers(local_hero, now_time, ttl_override)
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local ttl = tonumber(ttl_override or (script._autofarm_cfg and script._autofarm_cfg.WAVE_MARKER_CACHE_TTL) or 0.12) or 0.12
    if ttl < 0.02 then
        ttl = 0.02
    end
    script._autofarm_wave_markers_cache = script._autofarm_wave_markers_cache or {
        t = -9999,
        hero = nil,
        markers = {},
        towers = {},
        team = -1,
    }
    local cache = script._autofarm_wave_markers_cache
    local cache_time = tonumber(cache.t or -9999) or -9999
    if cache.hero == local_hero and (t - cache_time) <= ttl then
        return cache.markers or {}, cache.towers or {}, tonumber(cache.team or -1) or -1
    end
    local perf_wave = script.profiler_begin("wave_markers")
    local markers, towers, local_team = script.collect_autofarm_wave_markers(local_hero, t)
    script.profiler_end("wave_markers", perf_wave)
    cache.t = t
    cache.hero = local_hero
    cache.markers = markers or {}
    cache.towers = towers or {}
    cache.team = tonumber(local_team or -1) or -1
    script._autofarm_wave_markers_cache = cache
    return cache.markers, cache.towers, cache.team
end

function script.get_cached_autofarm_map_heroes(local_hero, now_time, ttl_override)
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local ttl = tonumber(ttl_override or AUTOFARM_MAP_HERO_CACHE_TTL or 0.3) or 0.3
    if ttl < 0.05 then
        ttl = 0.05
    end
    script._autofarm_map_hero_cache = script._autofarm_map_hero_cache or { t = -9999, team = -1, entries = {}, pos_by_key = {}, count = 0 }
    local cache = script._autofarm_map_hero_cache
    cache.pos_by_key = cache.pos_by_key or {}
    cache.count = tonumber(cache.count or 0) or 0
    local cache_time = tonumber(cache.t or -9999) or -9999
    local local_team = tonumber(cache.team or -1) or -1
    local elapsed = t - cache_time
    if cache.hero == local_hero then
        local probe_window = ttl * 0.55
        if probe_window < 0.05 then
            probe_window = 0.05
        end
        local hard_refresh_window = ttl * 2.1
        if hard_refresh_window < 0.20 then
            hard_refresh_window = 0.20
        end
        if elapsed <= probe_window then
            return cache.entries or {}, local_team
        end
        if elapsed <= hard_refresh_window then
            local heroes_probe = script._heroes_all_frame_cached(t) or {}
            local prev_pos = cache.pos_by_key or {}
            local seen = {}
            local probe_count = 0
            local moved = false
            for i = 1, #heroes_probe do
                local hero = heroes_probe[i]
                if hero and Entity.IsAlive(hero) and not is_meepo_instance(hero) and safe_call(NPC.IsIllusion, hero) ~= true then
                    local pos = safe_call(Entity.GetAbsOrigin, hero)
                    if pos then
                        probe_count = probe_count + 1
                        local key = tostring(hero)
                        seen[key] = true
                        local prev = prev_pos[key]
                        if not prev then
                            moved = true
                            break
                        end
                        local dx = (tonumber(pos.x or 0) or 0) - (tonumber(prev.x or 0) or 0)
                        local dy = (tonumber(pos.y or 0) or 0) - (tonumber(prev.y or 0) or 0)
                        if (dx * dx + dy * dy) > 1444 then
                            moved = true
                            break
                        end
                    end
                end
            end
            if not moved then
                if probe_count ~= cache.count then
                    moved = true
                else
                    for key, _ in pairs(prev_pos) do
                        if not seen[key] then
                            moved = true
                            break
                        end
                    end
                end
            end
            if not moved then
                cache.t = t
                script._autofarm_map_hero_cache = cache
                return cache.entries or {}, local_team
            end
        end
    end

    local heroes = script._heroes_all_frame_cached(t) or {}
    local entries = {}
    local pos_by_key = {}
    local count = 0
    local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    for i = 1, #heroes do
        local hero = heroes[i]
        if hero and Entity.IsAlive(hero) and not is_meepo_instance(hero) and safe_call(NPC.IsIllusion, hero) ~= true then
            local pos = safe_call(Entity.GetAbsOrigin, hero)
            if pos then
                count = count + 1
                local key = tostring(hero)
                pos_by_key[key] = { x = tonumber(pos.x or 0) or 0, y = tonumber(pos.y or 0) or 0 }
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local team = tonumber(safe_call(Entity.GetTeamNum, hero) or -1) or -1
                    local is_ally = (local_team < 0) or (team == local_team)
                    local unit_name = safe_call(NPC.GetUnitName, hero)
                    local icon_path = unit_name and ("panorama/images/heroes/icons/" .. tostring(unit_name) .. "_png.vtex_c") or nil
                    local hero_icon = icon_path and autofarm_get_image_handle(icon_path) or nil
                    entries[#entries + 1] = {
                        nx = nx,
                        ny = ny,
                        tint = is_ally and Color(115, 220, 255, 245) or Color(255, 118, 118, 245),
                        icon = hero_icon,
                    }
                end
            end
        end
    end

    cache.t = t
    cache.hero = local_hero
    cache.team = local_team
    cache.entries = entries
    cache.pos_by_key = pos_by_key
    cache.count = count
    script._autofarm_map_hero_cache = cache
    return entries, local_team
end

function clear_autofarm_runtime_state()
    script._autofarm_assignment_by_meepo = {}
    script._autofarm_assignment_hold_until_by_meepo = {}
    script._autofarm_last_camp_by_meepo = {}
    script._autofarm_camp_queue_by_meepo = {}
    script._autofarm_heal_mode_by_meepo = {}
    script._autofarm_last_poof_move_by_meepo = {}
    script._autofarm_stack_state_by_meepo = {}
    script._autofarm_last_order_by_meepo = {}
    script._autofarm_last_order_sig_by_meepo = {}
    script._autofarm_last_order_sig_time_by_meepo = {}
    script._autofarm_last_order_meta_by_meepo = {}
    script._autofarm_wave_target_by_meepo = {}
    script._autofarm_move_commit_until_by_meepo = {}
    script._autofarm_heal_resume_by_meepo = {}
    script._autofarm_timeline_by_meepo = {}
    script._autofarm_wave_owner_key = nil
    script._autofarm_wave_owner_until = 0
    script._autofarm_camp_presence = {}
    script._autofarm_camp_status = {}
    script._autofarm_camp_cooldown_until = {}
    script._autofarm_vision_empty_since = {}
    script._autofarm_empty_since = {}
    script._autofarm_wave_markers_cache = { t = -9999, hero = nil, markers = {}, towers = {}, team = -1 }
    script._autofarm_map_hero_cache = { t = -9999, hero = nil, team = -1, entries = {}, pos_by_key = {}, count = 0 }
    script._autofarm_presence_cache = { t = -9999, key = "", out = {} }
    script._autofarm_tower_cache = { t = -9999, hero = nil, team = -1, out = {} }
    script._autofarm_neutral_cache = { t = -9999, entries = {} }
    script._autofarm_neutral_spatial = { t = -9999, cell = 760, bins = {}, entries = {} }
    script._autofarm_path_cost_cache = {}
    script._autofarm_path_cost_cache_gc_next = 0
    script._autofarm_path_cost_cache_size = 0
    script._autofarm_path_cost_cache_size_next = 0
    script._autofarm_last_game_time = nil
    script._autofarm_next_tick = 0
    script._autofarm_metrics = {
        started_at = tonumber(get_game_time and get_game_time() or 0) or 0,
        orders_sent = 0,
        orders_deduped = 0,
        orders_coalesced = 0,
        queue_hits = 0,
        queue_misses = 0,
        queue_plans = 0,
        repicks = 0,
        path_block_events = 0,
        path_wave_returns = 0,
        heal_orders = 0,
        heal_active = 0,
        heal_resumes = 0,
        q_npcs_getall = 0,
        q_gridnav_traversable = 0,
        q_gridnav_traversable_from_to = 0,
    }
end
local function get_next_neutral_spawn_time(now_time)
    local t = tonumber(now_time or 0) or 0
    return (math.floor(t / 60) + 1) * 60
end
function script.autofarm_metric_inc(metric_name, delta)
    if not metric_name or metric_name == "" then
        return
    end
    script._autofarm_metrics = script._autofarm_metrics or {}
    local metrics = script._autofarm_metrics
    local add = tonumber(delta or 1) or 1
    metrics[metric_name] = (tonumber(metrics[metric_name] or 0) or 0) + add
    metrics.last_update = tonumber(get_game_time and get_game_time() or 0) or 0
end
function script.autofarm_metric_set(metric_name, value)
    if not metric_name or metric_name == "" then
        return
    end
    script._autofarm_metrics = script._autofarm_metrics or {}
    local metrics = script._autofarm_metrics
    metrics[metric_name] = value
    metrics.last_update = tonumber(get_game_time and get_game_time() or 0) or 0
end
function script.autofarm_timeline_state_from_label(label)
    local txt = tostring(label or "")
    if txt == "" then
        return "order"
    end
    if string.find(txt, "heal", 1, true) then
        return "heal"
    end
    if string.find(txt, "wave", 1, true) then
        return "wave"
    end
    if string.find(txt, "stack", 1, true) then
        return "stack"
    end
    if string.find(txt, "poof", 1, true) then
        return "poof"
    end
    if string.find(txt, "move", 1, true) then
        return "move"
    end
    if string.find(txt, "attack", 1, true) then
        return "attack"
    end
    if string.find(txt, "verify", 1, true) then
        return "verify"
    end
    if string.find(txt, "spawn_clear", 1, true) then
        return "spawn"
    end
    return "order"
end
function script.autofarm_timeline_set(meepo_key, state, detail, now_time)
    if not meepo_key then
        return
    end
    script._autofarm_timeline_by_meepo = script._autofarm_timeline_by_meepo or {}
    local timeline = script._autofarm_timeline_by_meepo
    local t = tonumber(now_time or get_game_time() or 0) or 0
    timeline[meepo_key] = {
        state = tostring(state or "idle"),
        detail = tostring(detail or ""),
        time = t,
    }
end
function script.autofarm_collect_timeline_lines(meepos, now_time, max_lines)
    local lines = {}
    if not meepos or #meepos == 0 then
        return lines
    end
    script._autofarm_timeline_by_meepo = script._autofarm_timeline_by_meepo or {}
    local timeline = script._autofarm_timeline_by_meepo
    local limit = tonumber(max_lines or 4) or 4
    if limit < 1 then
        limit = 1
    end
    local t = tonumber(now_time or get_game_time() or 0) or 0
    for i = 1, #meepos do
        if #lines >= limit then
            break
        end
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) then
            local key = get_entity_key(meepo)
            local rec = timeline[key] or {}
            local state = tostring(rec.state or "idle")
            local detail = tostring(rec.detail or "")
            local stamp = tonumber(rec.time or t) or t
            local age = math.max(0, t - stamp)
            local hp_pct = get_health_pct(meepo)
            local mp_pct = get_mana_pct(meepo)
            local idx = tonumber(safe_call(Entity.GetIndex, meepo) or 0) or 0
            local short_id = idx > 0 and tostring(idx) or tostring(key or i)
            local line = string.format("#%s %s %.1fs | HP %.0f MP %.0f", short_id, state, age, hp_pct, mp_pct)
            if detail ~= "" then
                line = line .. " | " .. detail
            end
            lines[#lines + 1] = line
        end
    end
    return lines
end
function script.autofarm_order_target_key(target)
    if not target then
        return "-"
    end
    local idx = tonumber(safe_call(Entity.GetIndex, target) or 0) or 0
    if idx > 0 then
        return tostring(idx)
    end
    return tostring(target)
end
function script.autofarm_order_pos_key(position)
    if not position then
        return "-"
    end
    local qx = math.floor(((tonumber(position.x or 0) or 0) / 96) + 0.5)
    local qy = math.floor(((tonumber(position.y or 0) or 0) / 96) + 0.5)
    return tostring(qx) .. ":" .. tostring(qy)
end
function script.autofarm_build_order_signature(order_type, target, position, label)
    return table.concat({
        tostring(order_type or -1),
        script.autofarm_order_target_key(target),
        script.autofarm_order_pos_key(position),
        tostring(label or ""),
    }, "|")
end
function script.autofarm_is_critical_order_label(label)
    local txt = string.lower(tostring(label or ""))
    if txt == "" then
        return false
    end
    if string.find(txt, "heal", 1, true) then
        return true
    end
    if string.find(txt, "path_wave", 1, true) then
        return true
    end
    if string.find(txt, "wave_", 1, true) then
        return true
    end
    if string.find(txt, "stack_", 1, true) then
        return true
    end
    return false
end
function script.autofarm_estimate_path_cost(from_pos, to_pos, cache, now_time, ttl_override)
    if not from_pos or not to_pos then
        return 999999, 0, false
    end
    local direct = vec_dist_2d(from_pos, to_pos) or 999999
    if direct >= 999998 then
        return direct, 0, false
    end
    if direct <= 280 then
        return direct, 0, false
    end
    local fx = math.floor(((from_pos.x or 0) / 180) + 0.5)
    local fy = math.floor(((from_pos.y or 0) / 180) + 0.5)
    local tx = math.floor(((to_pos.x or 0) / 180) + 0.5)
    local ty = math.floor(((to_pos.y or 0) / 180) + 0.5)
    local a = tostring(fx) .. ":" .. tostring(fy)
    local b = tostring(tx) .. ":" .. tostring(ty)
    if a > b then
        a, b = b, a
    end
    local cache_key = a .. "|" .. b
    local now_t = tonumber(now_time or get_game_time() or 0) or 0
    local cache_ttl = tonumber(ttl_override or (script._autofarm_cfg and script._autofarm_cfg.PATH_CACHE_TTL) or 2.4) or 2.4
    if cache_ttl < 0.10 then
        cache_ttl = 0.10
    end
    if cache and cache[cache_key] then
        local cached = cache[cache_key]
        local cached_t = tonumber(cached.t or now_t) or now_t
        if (now_t - cached_t) <= cache_ttl then
            return tonumber(cached.cost or direct) or direct, tonumber(cached.blocked or 0) or 0, false
        end
        cache[cache_key] = nil
    end
    local blocked_count = 0
    local path_sample_step = tonumber(script._autofarm_cfg and script._autofarm_cfg.PATH_SAMPLE_STEP or 560) or 560
    local path_block_penalty = tonumber(script._autofarm_cfg and script._autofarm_cfg.PATH_BLOCK_PENALTY or 780) or 780
    local steps = math.max(1, math.min(8, math.floor(direct / path_sample_step)))
    local prev = from_pos
    for i = 1, steps do
        local t = i / steps
        local sx = (from_pos.x or 0) + (((to_pos.x or 0) - (from_pos.x or 0)) * t)
        local sy = (from_pos.y or 0) + (((to_pos.y or 0) - (from_pos.y or 0)) * t)
        local sz = (from_pos.z or 0) + (((to_pos.z or 0) - (from_pos.z or 0)) * t)
        local sample = Vector(sx, sy, sz)
        local traversable = true
        if GridNav and GridNav.IsTraversable then
            script.autofarm_metric_inc("q_gridnav_traversable", 1)
            local tr = safe_call(GridNav.IsTraversable, sample)
            if tr ~= nil then
                traversable = tr == true
            end
        end
        if not traversable then
            blocked_count = blocked_count + 1
        elseif GridNav and GridNav.IsTraversableFromTo and prev then
            script.autofarm_metric_inc("q_gridnav_traversable_from_to", 1)
            local link = safe_call(GridNav.IsTraversableFromTo, prev, sample, false)
            if link ~= nil and link ~= true then
                blocked_count = blocked_count + 1
            end
        end
        prev = sample
    end
    local cost = direct
    if blocked_count > 0 then
        cost = cost + (blocked_count * path_block_penalty) + math.min(1800, blocked_count * blocked_count * 110)
    end
    if cache then
        cache[cache_key] = { cost = cost, blocked = blocked_count, t = now_t }
    end
    return cost, blocked_count, true
end
local function get_neutral_clock_time(fallback_time)
    local t = tonumber(fallback_time or 0) or 0
    if GameRules then
        if GameRules.GetDOTATime then
            local dt = tonumber(safe_call(GameRules.GetDOTATime, false, false))
            if dt and dt > -600 and dt < 20000 then
                return dt
            end
            dt = tonumber(safe_call(GameRules.GetDOTATime, false, true))
            if dt and dt > -600 and dt < 20000 then
                return dt
            end
        end
        if GameRules.GetGameTime then
            local gt = tonumber(safe_call(GameRules.GetGameTime))
            if gt then
                return gt
            end
        end
    end
    return t
end
local function get_autofarm_camp_ready_at(camp_id)
    if not camp_id then
        return 0
    end
    local cooldown_until = tonumber((script._autofarm_camp_cooldown_until and script._autofarm_camp_cooldown_until[camp_id]) or 0) or 0
    local status = script._autofarm_camp_status and script._autofarm_camp_status[camp_id] or nil
    local status_ready_at = tonumber(status and status.ready_at or 0) or 0
    local now_time = get_neutral_clock_time(get_game_time and get_game_time() or 0)
    local next_spawn = get_next_neutral_spawn_time(now_time)
    if cooldown_until > next_spawn then
        cooldown_until = next_spawn
    end
    if status_ready_at > next_spawn then
        status_ready_at = next_spawn
    end
    return math.max(cooldown_until, status_ready_at)
end
local function mark_autofarm_camp_state(camp_id, now_time, has_creeps, state_name, reported_by)
    if not camp_id then
        return nil
    end
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    local cooldowns = script._autofarm_camp_cooldown_until
    local status_map = script._autofarm_camp_status
    local state = status_map[camp_id] or {}
    local next_spawn = get_next_neutral_spawn_time(now_time)
    local observed_once = state.observed_once == true
    local remembered_ready = state.remembered_ready == true
    if has_creeps then
        observed_once = true
        remembered_ready = true
    elseif reported_by and reported_by ~= "vision" then
        -- direct meepo report (assignment/clear/farm) is a confirmed observation
        observed_once = true
    end
    if has_creeps then
        state.state = "ready"
        state.ready_at = now_time
        state.next_spawn = next_spawn
        state.last_seen_creeps = now_time
        state.last_update = now_time
        if reported_by then
            state.reported_by = reported_by
        end
        state.remembered_ready = true
        cooldowns[camp_id] = 0
    else
        local desired = state_name or "empty"
        if desired == "unseen" and observed_once then
            -- once confirmed at least once, this camp should never go back to unseen
            if state.state == "farmed" then
                desired = "farmed"
            else
                desired = "empty"
            end
        end
        if desired == "ready" then
            state.state = "ready"
            local hold_ready = tonumber(state.ready_at or 0) or 0
            if hold_ready <= 0 then
                hold_ready = now_time
            end
            state.ready_at = hold_ready
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            state.remembered_ready = remembered_ready
            cooldowns[camp_id] = 0
        elseif desired == "unseen" then
            state.state = "unseen"
            state.ready_at = now_time
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            state.remembered_ready = remembered_ready
            cooldowns[camp_id] = 0
        else
            state.state = desired
            state.ready_at = next_spawn
            state.next_spawn = next_spawn
            state.last_update = now_time
            if reported_by then
                state.reported_by = reported_by
            end
            state.remembered_ready = false
            cooldowns[camp_id] = next_spawn
        end
    end
    state.observed_once = observed_once
    status_map[camp_id] = state
    return state
end
local function force_autofarm_camp_not_ready(camp_id, now_time, state_name, reported_by)
    if not camp_id then
        return nil
    end
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    local next_spawn = get_next_neutral_spawn_time(now_time)
    local ready_at = next_spawn
    local state = script._autofarm_camp_status[camp_id] or {}
    state.state = state_name or "empty"
    state.ready_at = ready_at
    state.next_spawn = next_spawn
    state.last_update = now_time
    state.remembered_ready = false
    if reported_by then
        state.reported_by = reported_by
    end
    script._autofarm_camp_status[camp_id] = state
    script._autofarm_camp_cooldown_until[camp_id] = ready_at
    return state
end
local function update_autofarm_camp_presence(selected, now_time)
    script._autofarm_camp_status = script._autofarm_camp_status or {}
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_vision_empty_since = script._autofarm_vision_empty_since or {}
    local presence = script._autofarm_camp_presence or {}
    local status_map = script._autofarm_camp_status
    local cooldowns = script._autofarm_camp_cooldown_until
    local vision_empty_since = script._autofarm_vision_empty_since
    local out = {}
    local active_ids = {}
    local next_spawn_base = get_next_neutral_spawn_time(now_time)
    local meepo_positions = {}
    local neutral_entries = script.get_autofarm_neutral_creep_snapshot(now_time)
    local tick_pos_t = tonumber(script._autofarm_tick_meepo_positions_time or -9999) or -9999
    local tick_positions = script._autofarm_tick_meepo_positions
    if tick_positions and (now_time - tick_pos_t) <= 0.20 then
        for i = 1, #tick_positions do
            meepo_positions[#meepo_positions + 1] = tick_positions[i]
        end
    else
        local meepos = collect_meepos(nil, now_time)
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local pos = safe_call(Entity.GetAbsOrigin, meepo)
                if pos then
                    meepo_positions[#meepo_positions + 1] = pos
                end
            end
        end
    end
    for i = 1, #selected do
        local camp = selected[i]
        if camp and camp.id then
            active_ids[camp.id] = true
            local state = presence[camp.id] or {}
            local had_creeps = state.has == true
            local has, creeps, center = script.autofarm_camp_has_creeps(camp, neutral_entries)
            local camp_center = center or get_camp_center(camp)
            local prev_status = status_map[camp.id]
            local prev_ready_at = tonumber(prev_status and prev_status.ready_at or 0) or 0
            local observed_once = prev_status and prev_status.observed_once == true
            local remembered_ready = prev_status and prev_status.remembered_ready == true
            local can_confirm_empty = false
            local camp_point_visible = false
            if camp_center and FogOfWar and FogOfWar.IsPointVisible then
                camp_point_visible = safe_call(FogOfWar.IsPointVisible, camp_center) == true
            end
            if not has and camp_center then
                for j = 1, #meepo_positions do
                    local m_pos = meepo_positions[j]
                    local in_box = camp.camp_box and is_pos_in_box(m_pos, camp.camp_box) or false
                    local center_dist = vec_dist_2d(m_pos, camp_center)
                    local close_no_box = (not camp.camp_box) and (center_dist <= (AUTOFARM_POINT_REACH_RADIUS * 0.55))
                    local close_with_box = camp.camp_box and (center_dist <= (AUTOFARM_POINT_REACH_RADIUS * 0.45))
                    if in_box or close_no_box or close_with_box or camp_point_visible then
                        can_confirm_empty = true
                        break
                    end
                end
                if (not can_confirm_empty) and camp_point_visible then
                    can_confirm_empty = true
                end
            end
            local can_commit_empty = false
            if has == true then
                vision_empty_since[camp.id] = nil
            elseif can_confirm_empty then
                local empty_since = tonumber(vision_empty_since[camp.id] or 0) or 0
                if empty_since <= 0 then
                    empty_since = now_time
                    vision_empty_since[camp.id] = empty_since
                end
                local empty_confirm_window = nil
                if camp_point_visible then
                    empty_confirm_window = remembered_ready and 0.45 or 0.25
                else
                    empty_confirm_window = remembered_ready and 1.10 or 0.55
                end
                can_commit_empty = (now_time - empty_since) >= empty_confirm_window
            else
                vision_empty_since[camp.id] = nil
            end
            local desired_state = has and "ready" or "empty"
            if not has then
                local prev_state_name = prev_status and tostring(prev_status.state or "") or ""
                local ready_elapsed = prev_ready_at > 0 and now_time >= prev_ready_at
                if remembered_ready and (not can_commit_empty) then
                    desired_state = "ready"
                elseif (not can_confirm_empty) and ready_elapsed then
                    desired_state = observed_once and "ready" or "unseen"
                elseif can_confirm_empty then
                    if can_commit_empty then
                        if prev_state_name == "farmed" or prev_state_name == "empty" then
                            desired_state = prev_state_name
                        else
                            desired_state = "empty"
                        end
                    else
                        if prev_state_name == "ready" then
                            desired_state = "ready"
                        elseif prev_state_name == "unseen" then
                            desired_state = "unseen"
                        elseif prev_state_name == "farmed" or prev_state_name == "empty" then
                            desired_state = prev_state_name
                        elseif (not observed_once) and prev_ready_at > 0 and now_time >= prev_ready_at then
                            desired_state = "unseen"
                        else
                            desired_state = observed_once and "ready" or "unseen"
                        end
                    end
                else
                    if prev_state_name == "ready" then
                        desired_state = "ready"
                    elseif prev_state_name == "unseen" then
                        desired_state = "unseen"
                    elseif prev_state_name == "farmed" or prev_state_name == "empty" then
                        desired_state = prev_state_name
                    elseif (not observed_once) and prev_ready_at > 0 and now_time >= prev_ready_at then
                        desired_state = "unseen"
                    else
                        desired_state = "unseen"
                    end
                end
            end
            local camp_state = mark_autofarm_camp_state(camp.id, now_time, has == true, desired_state, "vision")
            state.center = camp_center
            state.last_check = now_time
            if has == true then
                state.has = true
                state.last_seen_creeps = now_time
                state.last_cleared = nil
            else
                state.has = false
                if had_creeps and can_commit_empty then
                    state.last_cleared = now_time
                end
            end
            local ready_at = tonumber(camp_state and camp_state.ready_at or get_autofarm_camp_ready_at(camp.id)) or 0
            local status_next_spawn = tonumber(camp_state and camp_state.next_spawn or next_spawn_base) or next_spawn_base
            if ready_at <= 0 then
                ready_at = next_spawn_base
            end
            local status_name = camp_state and camp_state.state or (has and "ready" or "empty")
            state.next_spawn = status_next_spawn
            state.ready_at = ready_at
            state.status = status_name
            state.observed_once = camp_state and camp_state.observed_once == true
            presence[camp.id] = state
            out[#out + 1] = {
                camp = camp,
                center = camp_center,
                has = has == true,
                creeps = creeps or {},
                status = status_name,
                ready_at = ready_at,
                next_spawn = status_next_spawn,
                last_cleared = state.last_cleared,
            }
        end
    end
    for id in pairs(presence) do
        if not active_ids[id] then
            presence[id] = nil
        end
    end
    for id in pairs(status_map) do
        if not active_ids[id] then
            status_map[id] = nil
        end
    end
    for id in pairs(cooldowns) do
        if not active_ids[id] then
            cooldowns[id] = nil
        end
    end
    for id in pairs(vision_empty_since) do
        if not active_ids[id] then
            vision_empty_since[id] = nil
        end
    end
    script._autofarm_camp_presence = presence
    script._autofarm_camp_status = status_map
    script._autofarm_camp_cooldown_until = cooldowns
    script._autofarm_vision_empty_since = vision_empty_since
    return out
end
function script.get_cached_autofarm_camp_presence(selected, now_time)
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local ttl = tonumber((script._autofarm_cfg and script._autofarm_cfg.PRESENCE_CACHE_TTL) or 0.12) or 0.12
    if ttl < 0.03 then
        ttl = 0.03
    end
    script._autofarm_presence_cache = script._autofarm_presence_cache or { t = -9999, key = "", out = {} }
    local cache = script._autofarm_presence_cache
    local key_parts = {}
    if selected then
        for i = 1, #selected do
            local camp = selected[i]
            if camp and camp.id then
                key_parts[#key_parts + 1] = tostring(camp.id)
            end
        end
    end
    local selected_key = table.concat(key_parts, ",")
    local cache_time = tonumber(cache.t or -9999) or -9999
    if cache.key == selected_key and (t - cache_time) <= ttl then
        return cache.out or {}
    end
    local perf_presence = script.profiler_begin("camp_presence")
    local out = update_autofarm_camp_presence(selected, t)
    script.profiler_end("camp_presence", perf_presence)
    cache.t = t
    cache.key = selected_key
    cache.out = out or {}
    script._autofarm_presence_cache = cache
    return cache.out
end
function script.update_autofarm_map_toggle(now)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local toggle_pressed = false
    if script.is_bind_just_pressed then
        toggle_pressed = script.is_bind_just_pressed(ui.autofarm_map_toggle_key, "autofarm_map_toggle") == true
    elseif script.is_bind_pressed then
        toggle_pressed = script.is_bind_pressed(ui.autofarm_map_toggle_key) == true
    end
    if not toggle_pressed then
        return false
    end
    local last_toggle = tonumber(script._autofarm_map_last_toggle_time or -9999) or -9999
    if (now_time - last_toggle) < 0.10 then
        return false
    end
    script._autofarm_map_last_toggle_time = now_time
    script._autofarm_map_visible = not (script._autofarm_map_visible == true)
    return true
end

function script.update_autofarm_runtime_toggle(now)
    local master_enabled = ui.autofarm_enable and ui.autofarm_enable.Get and ui.autofarm_enable:Get() == true
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local last_master_enabled = script._autofarm_master_last_enabled == true
    local toggled = false
    if not master_enabled then
        if script._autofarm_runtime_enabled ~= false then
            clear_autofarm_runtime_state()
        end
        script._autofarm_runtime_enabled = false
        script._autofarm_master_last_enabled = false
        return false
    end
    if not last_master_enabled or script._autofarm_runtime_enabled == nil then
        script._autofarm_runtime_enabled = false
    end
    local toggle_pressed = false
    if script.is_bind_just_pressed then
        toggle_pressed = script.is_bind_just_pressed(ui.autofarm_toggle_key, "autofarm_toggle") == true
    elseif script.is_bind_pressed then
        toggle_pressed = script.is_bind_pressed(ui.autofarm_toggle_key) == true
    end
    -- Prevent accidental permanent autofarm toggle when combo keys are held.
    local combo_key_down = select(1, script.get_combo_input_mode())
    if combo_key_down == true then
        toggle_pressed = false
    end
    if toggle_pressed then
        local last_toggle = tonumber(script._autofarm_last_toggle_time or -9999) or -9999
        if (now_time - last_toggle) >= 0.10 then
            script._autofarm_runtime_enabled = not (script._autofarm_runtime_enabled == true)
            script._autofarm_last_toggle_time = now_time
            toggled = true
            if script._autofarm_runtime_enabled ~= true then
                clear_autofarm_runtime_state()
            end
        end
    end
    script._autofarm_master_last_enabled = true
    return toggled
end
local function autofarm_pick_nearest(targets, origin)
    if not targets or #targets == 0 or not origin then
        return nil, nil
    end
    local best = nil
    local best_dist = nil
    for i = 1, #targets do
        local npc = targets[i]
        local pos = npc and safe_call(Entity.GetAbsOrigin, npc) or nil
        local d = pos and vec_dist_2d(pos, origin) or nil
        if d and (not best_dist or d < best_dist) then
            best = npc
            best_dist = d
        end
    end
    return best, best_dist
end
function autofarm_issue_order(player, meepo, order_type, target, position, label, now_time)
    if not player or not meepo or not Entity.IsAlive(meepo) or not order_type then
        return false
    end
    local meepo_key = get_entity_key(meepo)
    local t = tonumber(now_time or get_game_time() or 0) or 0
    local move_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
    local attack_type = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
    script._autofarm_last_order_sig_by_meepo = script._autofarm_last_order_sig_by_meepo or {}
    script._autofarm_last_order_sig_time_by_meepo = script._autofarm_last_order_sig_time_by_meepo or {}
    script._autofarm_last_order_meta_by_meepo = script._autofarm_last_order_meta_by_meepo or {}
    local last_order_meta_by_meepo = script._autofarm_last_order_meta_by_meepo
    local function copy_pos(pos)
        if not pos then
            return nil
        end
        return Vector(pos.x or 0, pos.y or 0, pos.z or 0)
    end
    local function remember_last_order_meta()
        last_order_meta_by_meepo[meepo_key] = {
            order_type = order_type,
            target_key = script.autofarm_order_target_key(target),
            pos = copy_pos(position),
            label = tostring(label or ""),
            time = t,
        }
    end
    local order_sig = script.autofarm_build_order_signature(order_type, target, position, label)
    local last_sig = script._autofarm_last_order_sig_by_meepo[meepo_key]
    local last_sig_time = tonumber(script._autofarm_last_order_sig_time_by_meepo[meepo_key] or -9999) or -9999
    local dedupe_window = tonumber(script._autofarm_cfg and script._autofarm_cfg.ORDER_DEDUPE_WINDOW or 0.48) or 0.48
    if last_sig and last_sig == order_sig and t < (last_sig_time + dedupe_window) then
        script.autofarm_metric_inc("orders_deduped", 1)
        script.autofarm_timeline_set(meepo_key, "hold", "dedupe " .. tostring(label or ""), t)
        return false
    end
    local new_is_critical = script.autofarm_is_critical_order_label(label)
    local last_meta = last_order_meta_by_meepo[meepo_key]
    if last_meta and not new_is_critical then
        local last_meta_time = tonumber(last_meta.time or -9999) or -9999
        local coalesce_window = tonumber(script._autofarm_cfg and script._autofarm_cfg.ORDER_COALESCE_WINDOW or 0.26) or 0.26
        if t <= (last_meta_time + coalesce_window) then
            local prev_is_critical = script.autofarm_is_critical_order_label(last_meta.label)
            if not prev_is_critical then
                if move_type and order_type == move_type and last_meta.order_type == move_type and position and last_meta.pos then
                    local coalesce_dist = tonumber(script._autofarm_cfg and script._autofarm_cfg.ORDER_COALESCE_DIST or 160) or 160
                    local dist = vec_dist_2d(position, last_meta.pos)
                    if dist and dist <= coalesce_dist then
                        script.autofarm_metric_inc("orders_coalesced", 1)
                        script.autofarm_timeline_set(meepo_key, "hold", "coalesce move " .. tostring(label or ""), t)
                        return false
                    end
                elseif attack_type and order_type == attack_type and last_meta.order_type == attack_type then
                    local new_target_key = script.autofarm_order_target_key(target)
                    local prev_target_key = tostring(last_meta.target_key or "-")
                    if new_target_key ~= "-" and new_target_key == prev_target_key then
                        script.autofarm_metric_inc("orders_coalesced", 1)
                        script.autofarm_timeline_set(meepo_key, "hold", "coalesce attack " .. tostring(label or ""), t)
                        return false
                    end
                end
            end
        end
    end
    local last_order = tonumber(script._autofarm_last_order_by_meepo[meepo_key] or -9999) or -9999
    if t < last_order + AUTOFARM_ORDER_INTERVAL then
        script.autofarm_timeline_set(meepo_key, "hold", "order interval", t)
        return false
    end
    local issuer_type = Enum and Enum.PlayerOrderIssuer and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY or nil
    if not issuer_type or not Player or not Player.PrepareUnitOrders then
        return false
    end
    local issued = pcall(function()
        Player.PrepareUnitOrders(
            player,
            order_type,
            target,
            position,
            nil,
            issuer_type,
            meepo,
            false,
            true,
            true,
            false,
            label or "meepo_autofarm",
            false
        )
    end)
    if issued then
        script._autofarm_last_order_by_meepo[meepo_key] = t
        script._autofarm_last_order_sig_by_meepo[meepo_key] = order_sig
        script._autofarm_last_order_sig_time_by_meepo[meepo_key] = t
        remember_last_order_meta()
        script.autofarm_metric_inc("orders_sent", 1)
        script.autofarm_timeline_set(
            meepo_key,
            script.autofarm_timeline_state_from_label(label),
            tostring(label or ""),
            t
        )
        if move_type and order_type == move_type then
            script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
            local prev = tonumber(script._autofarm_move_commit_until_by_meepo[meepo_key] or 0) or 0
            local lock_until = t + 0.78
            if lock_until > prev then
                script._autofarm_move_commit_until_by_meepo[meepo_key] = lock_until
            end
        end
        return true
    end
    -- fallback direct issue if PrepareUnitOrders failed
    if order_type == attack_type and target then
        if NPC and NPC.AttackTarget then
            local ok = safe_call(NPC.AttackTarget, meepo, target, true)
            if ok then
                script._autofarm_last_order_by_meepo[meepo_key] = t
                script._autofarm_last_order_sig_by_meepo[meepo_key] = order_sig
                script._autofarm_last_order_sig_time_by_meepo[meepo_key] = t
                remember_last_order_meta()
                script.autofarm_metric_inc("orders_sent", 1)
                script.autofarm_timeline_set(
                    meepo_key,
                    script.autofarm_timeline_state_from_label(label),
                    tostring(label or ""),
                    t
                )
                return true
            end
        end
    elseif order_type == move_type and position then
        if NPC and NPC.MoveTo then
            local ok = safe_call(NPC.MoveTo, meepo, position)
            if ok then
                script._autofarm_last_order_by_meepo[meepo_key] = t
                script._autofarm_last_order_sig_by_meepo[meepo_key] = order_sig
                script._autofarm_last_order_sig_time_by_meepo[meepo_key] = t
                remember_last_order_meta()
                script.autofarm_metric_inc("orders_sent", 1)
                script.autofarm_timeline_set(
                    meepo_key,
                    script.autofarm_timeline_state_from_label(label),
                    tostring(label or ""),
                    t
                )
                script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
                local prev = tonumber(script._autofarm_move_commit_until_by_meepo[meepo_key] or 0) or 0
                local lock_until = t + 0.78
                if lock_until > prev then
                    script._autofarm_move_commit_until_by_meepo[meepo_key] = lock_until
                end
                return true
            end
        end
    end
    return false
end
function script.try_autofarm_path_wave_intercept(local_player, local_hero, meepo, meepo_key, meepo_pos, camp_world, wave_markers, wave_taken, now_time, use_poof_damage, mana_reserve_pct)
    if not local_player or not local_hero or not meepo or not meepo_key or not meepo_pos or not camp_world then
        return false, false
    end
    if not wave_markers or #wave_markers == 0 then
        return false, false
    end
    local team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
    local seg_dx = (camp_world.x or 0) - (meepo_pos.x or 0)
    local seg_dy = (camp_world.y or 0) - (meepo_pos.y or 0)
    local seg_len_sq = (seg_dx * seg_dx) + (seg_dy * seg_dy)
    if seg_len_sq <= (420 * 420) then
        return false, false
    end
    local seg_len = math.sqrt(seg_len_sq)
    local last_wave_id = script._autofarm_wave_target_by_meepo and script._autofarm_wave_target_by_meepo[meepo_key] or nil
    local best_marker = nil
    local best_creeps = nil
    local best_score = nil
    for i = 1, #wave_markers do
        local marker = wave_markers[i]
        if marker and marker.id and marker.center and (not wave_taken or not wave_taken[marker.id]) then
            if team < 0 or marker.team ~= team then
                local alive_creeps = {}
                local marker_creeps = marker.creeps or {}
                for ci = 1, #marker_creeps do
                    local creep = marker_creeps[ci]
                    if creep and Entity.IsAlive(creep) and safe_call(NPC.IsWaitingToSpawn, creep) ~= true then
                        alive_creeps[#alive_creeps + 1] = creep
                    end
                end
                local creep_count = #alive_creeps
                if creep_count >= script._autofarm_cfg.WAVE_DEFENSE_MIN_CREEPS then
                    local wx = (marker.center.x or 0) - (meepo_pos.x or 0)
                    local wy = (marker.center.y or 0) - (meepo_pos.y or 0)
                    local t = ((wx * seg_dx) + (wy * seg_dy)) / math.max(1, seg_len_sq)
                    if t >= 0.04 and t <= 0.96 then
                        local close_x = (meepo_pos.x or 0) + (seg_dx * t)
                        local close_y = (meepo_pos.y or 0) + (seg_dy * t)
                        local off_x = (marker.center.x or 0) - close_x
                        local off_y = (marker.center.y or 0) - close_y
                        local perp_dist = math.sqrt((off_x * off_x) + (off_y * off_y))
                        if perp_dist <= 560 then
                            local forward_dist = seg_len * t
                            local score = (forward_dist * 0.92) + (perp_dist * 1.35) - (creep_count * 76)
                            if marker.threatens_ally_tower == true then
                                score = score - 180
                            end
                            if last_wave_id and marker.id == last_wave_id then
                                score = score - 180
                            end
                            if (not best_score) or score < best_score then
                                best_marker = marker
                                best_creeps = alive_creeps
                                best_score = score
                            end
                        end
                    end
                end
            end
        end
    end
    if not best_marker or not best_creeps or #best_creeps <= 0 then
        return false, false
    end
    script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
    script._autofarm_wave_target_by_meepo[meepo_key] = best_marker.id
    if wave_taken then
        wave_taken[best_marker.id] = true
    end

    local wave_center = best_marker.center
    local dist_wave = vec_dist_2d(meepo_pos, wave_center)
    if dist_wave > script._autofarm_cfg.WAVE_DEFENSE_REACH_RADIUS then
        local move_order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
        if autofarm_issue_order(local_player, meepo, move_order, nil, wave_center, "meepo_autofarm_path_wave_move", now_time) then
            return true, true
        end
        return true, false
    end

    local target = autofarm_pick_nearest(best_creeps, meepo_pos or wave_center)
    if not target then
        return true, false
    end
    local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
    local max_mana = tonumber(safe_call(NPC.GetMaxMana, meepo) or 0) or 0
    local mana_pct = (max_mana > 0) and ((mana / max_mana) * 100) or 0
    if use_poof_damage and mana_pct > (tonumber(mana_reserve_pct or 0) or 0) and #best_creeps >= script._autofarm_cfg.WAVE_DEFENSE_POOF_MIN_CREEPS then
        local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
        if poof and safe_call(Ability.IsReady, poof) == true
            and safe_call(Ability.IsInAbilityPhase, poof) ~= true
            and safe_call(Ability.IsChannelling, poof) ~= true
        then
            local poof_radius = get_poof_damage_radius(poof)
            if poof_radius <= 0 then
                poof_radius = AUTOFARM_POOF_DAMAGE_RANGE
            end
            local effective_radius = math.max(190, poof_radius - 60)
            local packed = 0
            for ci = 1, #best_creeps do
                local creep_pos = safe_call(Entity.GetAbsOrigin, best_creeps[ci])
                if creep_pos and vec_dist_2d(meepo_pos, creep_pos) <= effective_radius then
                    packed = packed + 1
                end
            end
            if packed >= script._autofarm_cfg.WAVE_DEFENSE_POOF_MIN_CREEPS then
                if script.issue_group_poof_target_order(local_player, { meepo }, meepo, now_time, "meepo_autofarm_wave_poof") then
                    script._autofarm_last_order_by_meepo[meepo_key] = now_time
                    return true, true
                end
            end
        end
    end
    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
    if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_wave_attack", now_time) then
        return true, true
    end
    return true, false
end
function script.autofarm_reset_wave_owner()
    script._autofarm_wave_owner_key = nil
    script._autofarm_wave_owner_until = 0
end
function script.autofarm_can_assign_wave_to(meepo_key, now_time)
    if not meepo_key then
        return false
    end
    local owner_key = script._autofarm_wave_owner_key
    local owner_until = tonumber(script._autofarm_wave_owner_until or 0) or 0
    local t = tonumber(now_time or 0) or 0
    if owner_key and owner_key ~= meepo_key and owner_until > t then
        return false
    end
    return true
end
function script.autofarm_claim_wave_owner(meepo_key, now_time, hold_sec)
    if not meepo_key then
        return
    end
    local t = tonumber(now_time or 0) or 0
    local hold = tonumber(hold_sec or 1.05) or 1.05
    local until_time = t + hold
    local prev_until = tonumber(script._autofarm_wave_owner_until or 0) or 0
    script._autofarm_wave_owner_key = meepo_key
    script._autofarm_wave_owner_until = math.max(prev_until, until_time)
end
function script.autofarm_release_wave_owner_if(meepo_key)
    if meepo_key and script._autofarm_wave_owner_key == meepo_key then
        script._autofarm_wave_owner_key = nil
        script._autofarm_wave_owner_until = 0
    end
end
function script.run_autofarm_logic(local_player, local_hero, meepos, now)
    if script._autofarm_runtime_enabled ~= true then return false end
    if not local_player or not local_hero or not meepos or #meepos == 0 then return false end
    -- Pause only while combo bind is held (normal or ground); do not disable runtime.
    local combo_key_down = select(1, script.get_combo_input_mode())
    if combo_key_down == true then
        script._autofarm_combo_pause_active = true
        return false
    end
    script._autofarm_combo_pause_active = false
    if is_combo_active() then
        return false
    end

    local raw_now_time = script.af_time(now)
    local now_time = get_neutral_clock_time(raw_now_time)
    local minute_index = math.floor(now_time / 60)
    local second_in_minute = now_time - (minute_index * 60)
    local last_game_time = tonumber(script._autofarm_last_game_time or now_time) or now_time
    if now_time + 1 < last_game_time then
        clear_autofarm_runtime_state()
    end
    script._autofarm_last_game_time = now_time
    if now_time < (tonumber(script._autofarm_next_tick or 0) or 0) then return false end
    script._autofarm_next_tick = now_time + AUTOFARM_LOGIC_TICK
    script._autofarm_neutral_tick_entries = script.get_autofarm_neutral_creep_snapshot(now_time)
    script._autofarm_metrics = script._autofarm_metrics or {}
    if not script._autofarm_metrics.started_at then
        script._autofarm_metrics.started_at = now_time
    end
    script._autofarm_metrics.orders_sent = tonumber(script._autofarm_metrics.orders_sent or 0) or 0
    script._autofarm_metrics.orders_deduped = tonumber(script._autofarm_metrics.orders_deduped or 0) or 0
    script._autofarm_metrics.orders_coalesced = tonumber(script._autofarm_metrics.orders_coalesced or 0) or 0
    script._autofarm_metrics.queue_hits = tonumber(script._autofarm_metrics.queue_hits or 0) or 0
    script._autofarm_metrics.queue_misses = tonumber(script._autofarm_metrics.queue_misses or 0) or 0
    script._autofarm_metrics.queue_plans = tonumber(script._autofarm_metrics.queue_plans or 0) or 0
    script._autofarm_metrics.repicks = tonumber(script._autofarm_metrics.repicks or 0) or 0
    script._autofarm_metrics.path_block_events = tonumber(script._autofarm_metrics.path_block_events or 0) or 0
    script._autofarm_metrics.path_wave_returns = tonumber(script._autofarm_metrics.path_wave_returns or 0) or 0
    script._autofarm_metrics.heal_orders = tonumber(script._autofarm_metrics.heal_orders or 0) or 0
    script._autofarm_metrics.heal_active = tonumber(script._autofarm_metrics.heal_active or 0) or 0
    script._autofarm_metrics.heal_resumes = tonumber(script._autofarm_metrics.heal_resumes or 0) or 0
    script._autofarm_metrics.q_npcs_getall = tonumber(script._autofarm_metrics.q_npcs_getall or 0) or 0
    script._autofarm_metrics.q_gridnav_traversable = tonumber(script._autofarm_metrics.q_gridnav_traversable or 0) or 0
    script._autofarm_metrics.q_gridnav_traversable_from_to = tonumber(script._autofarm_metrics.q_gridnav_traversable_from_to or 0) or 0
    script.autofarm_metric_set("last_tick", now_time)
    script.autofarm_metric_set("active_meepos", #meepos)
    script.autofarm_metric_set("hp_retreat_pct", AUTOFARM_LOW_HP_RETREAT_PCT)
    script.autofarm_metric_set("hp_resume_pct", AUTOFARM_HEAL_EXIT_PCT)
    local meepo_pos_by_key = {}
    local meepo_positions_tick = {}
    for i = 1, #meepos do
        local meepo = meepos[i]
        local pos = script.af_alive_pos(meepo)
        if pos then
            local key = get_entity_key(meepo)
            meepo_pos_by_key[key] = pos
            meepo_positions_tick[#meepo_positions_tick + 1] = pos
        end
    end
    script._autofarm_tick_meepo_pos_by_key = meepo_pos_by_key
    script._autofarm_tick_meepo_positions = meepo_positions_tick
    script._autofarm_tick_meepo_positions_time = now_time

    -- build camp list with shared camp status for all meepos
    local selected = script.get_autofarm_selected_locations and script.get_autofarm_selected_locations() or {}
    script.autofarm_metric_set("selected_camps", #selected)
    local observed = script.get_cached_autofarm_camp_presence(selected, now_time)
    local observed_by_id = {}
    for i = 1, #observed do
        local entry = observed[i]
        if entry and entry.camp and entry.camp.id then
            observed_by_id[entry.camp.id] = entry
        end
    end
    local camps = {}
    local camp_by_id = {}
    local next_spawn_time = get_next_neutral_spawn_time(now_time)
    local next_spawn_eta = math.max(0, next_spawn_time - now_time)
    for i = 1, #selected do
        local c = selected[i]
        if c and c.id and c.world then
            local obs = observed_by_id[c.id]
            local pos = Vector(
                clamp_value(c.world.x or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX),
                clamp_value(c.world.y or 0, AUTOFARM_WORLD_MIN, AUTOFARM_WORLD_MAX),
                c.world.z or 0
            )
            local has_creeps = obs and (obs.has == true) or false
            local ready_at = script.af_num(obs and (obs.ready_at or obs.next_spawn) or get_autofarm_camp_ready_at(c.id), now_time)
            local status = tostring((obs and obs.status) or "ready")
            if not has_creeps then
                if status == "unseen" or status == "ready" then
                    ready_at = now_time
                else
                    ready_at = next_spawn_time
                end
            end
            camps[#camps + 1] = {
                id = c.id,
                world = pos,
                data = c,
                has_creeps = has_creeps,
                creeps = obs and (obs.creeps or {}) or {},
                status = status,
                ready_at = ready_at,
            }
            camp_by_id[c.id] = camps[#camps]
        end
    end
    if #camps == 0 then
        clear_autofarm_runtime_state()
        return false
    end

    -- shared status and cooldown state
    script._autofarm_camp_cooldown_until = script._autofarm_camp_cooldown_until or {}
    script._autofarm_camp_status = script._autofarm_camp_status or {}

    local mana_reserve_pct = tonumber(ui.autofarm_mana_reserve:Get() or AUTOFARM_MANA_MIN_RESERVE) or AUTOFARM_MANA_MIN_RESERVE
    local use_poof_damage, use_poof_move = autofarm_use_poof_flags()
    local auto_stack_enabled = ui.autofarm_auto_stack and ui.autofarm_auto_stack.Get and ui.autofarm_auto_stack:Get() == true
    local wave_split_enabled = script.is_autofarm_wave_split_enabled()
    local farm_only_mode = script.get_autofarm_farm_only_index()

    -- sticky assignment until camp empty for 0.6s
    script._autofarm_assignment_by_meepo = script._autofarm_assignment_by_meepo or {}
    script._autofarm_assignment_hold_until_by_meepo = script._autofarm_assignment_hold_until_by_meepo or {}
    script._autofarm_last_camp_by_meepo = script._autofarm_last_camp_by_meepo or {}
    script._autofarm_last_poof_move_by_meepo = script._autofarm_last_poof_move_by_meepo or {}
    script._autofarm_stack_state_by_meepo = script._autofarm_stack_state_by_meepo or {}
    script._autofarm_empty_since = script._autofarm_empty_since or {}
    script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
    script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
    script._autofarm_camp_queue_by_meepo = script._autofarm_camp_queue_by_meepo or {}
    script._autofarm_last_order_sig_by_meepo = script._autofarm_last_order_sig_by_meepo or {}
    script._autofarm_last_order_sig_time_by_meepo = script._autofarm_last_order_sig_time_by_meepo or {}
    script._autofarm_last_order_meta_by_meepo = script._autofarm_last_order_meta_by_meepo or {}
    script._autofarm_heal_mode_by_meepo = script._autofarm_heal_mode_by_meepo or {}
    script._autofarm_heal_resume_by_meepo = script._autofarm_heal_resume_by_meepo or {}
    script._autofarm_timeline_by_meepo = script._autofarm_timeline_by_meepo or {}
    local taken = {}
    local heal_mode_by_meepo = script._autofarm_heal_mode_by_meepo
    local heal_resume_by_meepo = script._autofarm_heal_resume_by_meepo
    local fountain_pos = select(1, script.get_autofarm_team_fountain(local_hero, now_time))
    local heal_active_count = 0

    local meepo_entries = {}
    local any_unselected_pool = {}
    local selected_key_set = script.get_selected_meepo_key_set(local_player)
    for i = 1, #meepos do
        local meepo = meepos[i]
        if meepo and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then
            local key = get_entity_key(meepo)
            local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(meepo) or false
            local is_selected = selected_key_set[key] == true
            local include = true
            if farm_only_mode == script._autofarm_mode.UNSELECTED then
                include = not is_selected
            elseif farm_only_mode == script._autofarm_mode.CLONES then
                include = is_clone
            elseif farm_only_mode == script._autofarm_mode.ANY_UNSELECTED then
                include = not is_selected
            end
            local entry = {
                unit = meepo,
                key = key,
                pos = meepo_pos_by_key[key] or script.af_alive_pos(meepo),
                priority_dist = 999999,
            }
            if include then
                if farm_only_mode == script._autofarm_mode.ANY_UNSELECTED then
                    any_unselected_pool[#any_unselected_pool + 1] = entry
                else
                    meepo_entries[#meepo_entries + 1] = entry
                end
            end
        end
    end
    if farm_only_mode == script._autofarm_mode.ANY_UNSELECTED and #any_unselected_pool > 0 then
        local best_entry = nil
        local best_score = nil
        for i = 1, #any_unselected_pool do
            local entry = any_unselected_pool[i]
            local nearest_active = nil
            local nearest_any = nil
            if entry and entry.pos then
                for j = 1, #camps do
                    local camp = camps[j]
                    if camp then
                        local d = vec_dist_2d(entry.pos, camp.world)
                        local is_active = select(1, script.af_camp_is_active(camp, now_time))
                        if is_active and ((not nearest_active) or d < nearest_active) then
                            nearest_active = d
                        end
                        if (not nearest_any) or d < nearest_any then
                            nearest_any = d
                        end
                    end
                end
            end
            local score = nearest_active or nearest_any or 999999
            if not nearest_active then
                score = score + 1200
            end
            if (not best_entry) or score < best_score then
                best_entry = entry
                best_score = score
            end
        end
        if best_entry then
            meepo_entries[1] = best_entry
        end
    end
    script.autofarm_metric_set("farm_meepos", #meepo_entries)
    if #meepo_entries == 0 then
        return false
    end

    local wave_markers = nil
    local wave_defense_targets = {}
    local wave_taken = {}
    if wave_split_enabled then
        local markers = select(1, script.get_cached_autofarm_wave_markers(local_hero, now_time))
        wave_markers = markers or {}
        for i = 1, #wave_markers do
            local marker = wave_markers[i]
            if marker and marker.threatens_ally_tower == true and (tonumber(marker.count or 0) or 0) >= script._autofarm_cfg.WAVE_DEFENSE_MIN_CREEPS then
                wave_defense_targets[#wave_defense_targets + 1] = marker
            end
        end
    else
        script.autofarm_reset_wave_owner()
        wave_markers = {}
    end

    local path_cost_cache = script._autofarm_path_cost_cache or {}
    script._autofarm_path_cost_cache = path_cost_cache
    local path_cache_ttl = tonumber(script._autofarm_cfg and script._autofarm_cfg.PATH_CACHE_TTL or 2.4) or 2.4
    if path_cache_ttl < 0.10 then
        path_cache_ttl = 0.10
    end
    if now_time >= (tonumber(script._autofarm_path_cost_cache_gc_next or 0) or 0) then
        local expire_before = now_time - (path_cache_ttl * 1.35)
        local kept = 0
        for cache_key, rec in pairs(path_cost_cache) do
            local rec_t = tonumber(rec and rec.t or -9999) or -9999
            if rec_t < expire_before then
                path_cost_cache[cache_key] = nil
            else
                kept = kept + 1
            end
        end
        script._autofarm_path_cost_cache_size = kept
        script._autofarm_path_cost_cache_gc_next = now_time + math.max(0.30, path_cache_ttl * 0.35)
    end
    local path_block_events_tick = 0
    function get_path_cost(from_pos, to_pos)
        local cost, blocked, is_new = script.autofarm_estimate_path_cost(from_pos, to_pos, path_cost_cache, now_time, path_cache_ttl)
        if is_new and blocked > 0 then
            path_block_events_tick = path_block_events_tick + 1
        end
        return tonumber(cost or 999999) or 999999
    end
    local camp_queue = script._autofarm_camp_queue_by_meepo or {}
    script._autofarm_camp_queue_by_meepo = camp_queue
    function get_queue_entry(meepo_key)
        if not meepo_key then
            return nil
        end
        local q = camp_queue[meepo_key]
        if type(q) ~= "table" then
            q = { primary_id = nil, secondary_id = nil, updated_at = now_time }
            camp_queue[meepo_key] = q
        end
        local queue_ttl = tonumber(script._autofarm_cfg and script._autofarm_cfg.QUEUE_TTL or 22) or 22
        if (tonumber(q.updated_at or 0) or 0) + queue_ttl < now_time then
            q.primary_id = nil
            q.secondary_id = nil
            q.updated_at = now_time
        end
        return q
    end
    function queue_clear_if_matches(meepo_key, camp_id)
        if not meepo_key or not camp_id then
            return
        end
        local q = get_queue_entry(meepo_key)
        if not q then
            return
        end
        if q.primary_id == camp_id then
            q.primary_id = q.secondary_id
            q.secondary_id = nil
            q.updated_at = now_time
        elseif q.secondary_id == camp_id then
            q.secondary_id = nil
            q.updated_at = now_time
        end
    end
    function queue_primary_candidate(meepo_key)
        local q = get_queue_entry(meepo_key)
        local camp_id = q and q.primary_id or nil
        local camp = camp_id and camp_by_id[camp_id] or nil
        if not camp or taken[camp_id] then
            if q then
                q.primary_id = q.secondary_id
                q.secondary_id = nil
                q.updated_at = now_time
            end
            camp_id = q and q.primary_id or nil
            camp = camp_id and camp_by_id[camp_id] or nil
        end
        if not camp or taken[camp_id] then
            return nil
        end
        return camp
    end
    function set_queue_plan(meepo_key, primary_id, secondary_id)
        if not meepo_key then
            return
        end
        local q = get_queue_entry(meepo_key)
        if not q then
            return
        end
        q.primary_id = primary_id
        q.secondary_id = secondary_id
        q.updated_at = now_time
    end

    local near_pick_radius_cfg = script.af_num(script._autofarm_cfg and script._autofarm_cfg.NEAR_PICK_RADIUS or 1500, 1500)
    local near_pick_delta_cfg = script.af_num(script._autofarm_cfg and script._autofarm_cfg.NEAR_PICK_DELTA or 320, 320)
    local respawn_fuzz_cfg = script.af_num(script._autofarm_cfg and script._autofarm_cfg.RESPAWN_PLAN_FUZZ or 1.35, 1.35)
    local queue_plan_max_wait_cfg = script.af_num(script._autofarm_cfg and script._autofarm_cfg.QUEUE_PLAN_MAX_WAIT or 21, 21)
    local camp_eval_by_meepo = {}
    local nearest_active_dist_by_meepo = {}
    local nearest_creep_dist_by_meepo = {}
    local camp_nearest_key = {}
    local camp_nearest_dist = {}
    local path_eval_cells_built = 0
    local path_eval_dist_calls = 0
    local path_eval_reuse_hits = 0
    local chain_eval_cache = {}
    function get_camp_eval(meepo_key, camp_id)
        local row = meepo_key and camp_eval_by_meepo[meepo_key] or nil
        local rec = row and row[camp_id] or nil
        if rec then
            path_eval_reuse_hits = path_eval_reuse_hits + 1
        end
        return rec
    end
    function get_chain_eval_dist(chain_origin, camp_id, camp_world, fallback_dist)
        if not chain_origin or not camp_id or not camp_world then
            return fallback_dist or 999999
        end
        local ox = script.af_num(chain_origin.x, 0)
        local oy = script.af_num(chain_origin.y, 0)
        local origin_key = tostring(round_int(ox / 56)) .. ":" .. tostring(round_int(oy / 56))
        local row = chain_eval_cache[origin_key]
        if not row then
            row = {}
            chain_eval_cache[origin_key] = row
        end
        local cached = row[camp_id]
        if cached ~= nil then
            path_eval_reuse_hits = path_eval_reuse_hits + 1
            return cached
        end
        local dist = get_path_cost(chain_origin, camp_world)
        path_eval_dist_calls = path_eval_dist_calls + 1
        row[camp_id] = dist
        return dist
    end
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local meepo_key = entry and entry.key or nil
        local row = {}
        camp_eval_by_meepo[meepo_key] = row
        local nearest_active = nil
        local nearest_creep = nil
        local nearest_any = nil
        for j = 1, #camps do
            local camp = camps[j]
            local camp_id = camp and camp.id or nil
            if camp and camp_id then
                local tier, ready_at, status, is_active = script.af_camp_tier(camp, now_time)
                local dist = (entry and entry.pos and camp.world) and get_path_cost(entry.pos, camp.world) or 999999
                path_eval_dist_calls = path_eval_dist_calls + 1
                local travel_time = dist / math.max(1, AUTOFARM_TRAVEL_SPEED_ESTIMATE)
                local time_until_ready = math.max(0, ready_at - now_time)
                local wait_on_arrival = math.max(0, time_until_ready - travel_time)
                row[camp_id] = {
                    dist_meepo = dist,
                    ready_at = ready_at,
                    status = status,
                    tier = tier,
                    is_active = is_active,
                    wait_on_arrival = wait_on_arrival,
                    ready_by_arrival = wait_on_arrival <= respawn_fuzz_cfg,
                    has_creeps = camp.has_creeps == true,
                }
                path_eval_cells_built = path_eval_cells_built + 1
                if (not nearest_any) or dist < nearest_any then
                    nearest_any = dist
                end
                if is_active and ((not nearest_active) or dist < nearest_active) then
                    nearest_active = dist
                end
                if is_active and camp.has_creeps == true and ((not nearest_creep) or dist < nearest_creep) then
                    nearest_creep = dist
                end
                local camp_best = camp_nearest_dist[camp_id]
                if (not camp_best) or dist < camp_best then
                    camp_nearest_dist[camp_id] = dist
                    camp_nearest_key[camp_id] = meepo_key
                end
            end
        end
        nearest_active_dist_by_meepo[meepo_key] = nearest_active
        nearest_creep_dist_by_meepo[meepo_key] = nearest_creep
        entry.priority_dist = nearest_active or nearest_any or 999999
    end
    script._autofarm_tick_camp_eval = camp_eval_by_meepo
    script._autofarm_tick_camp_eval_time = now_time
    script.autofarm_metric_set("path_eval_cells_built", path_eval_cells_built)

    local owners_by_camp = {}
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local assigned = script._autofarm_assignment_by_meepo[entry.key]
        local camp_id = assigned and assigned.id or nil
        if camp_id and camp_by_id[camp_id] then
            owners_by_camp[camp_id] = owners_by_camp[camp_id] or {}
            owners_by_camp[camp_id][#owners_by_camp[camp_id] + 1] = entry
        end
    end
    for camp_id, owners in pairs(owners_by_camp) do
        if owners and #owners > 1 then
            local camp = camp_by_id[camp_id]
            local keeper_key = nil
            local keeper_score = nil
            local camp_has_creeps = camp and camp.has_creeps == true
            for i = 1, #owners do
                local entry = owners[i]
                local dist = (entry and entry.pos and camp) and vec_dist_2d(entry.pos, camp.world) or 999999
                local score = dist
                if camp_has_creeps and dist <= AUTOFARM_CAMP_REACH_RADIUS then
                    score = score - 100000
                end
                if (not keeper_score) or score < keeper_score then
                    keeper_score = score
                    keeper_key = entry and entry.key or nil
                end
            end
            for i = 1, #owners do
                local entry = owners[i]
                if entry and entry.key and entry.key ~= keeper_key then
                    script._autofarm_assignment_by_meepo[entry.key] = nil
                    script._autofarm_assignment_hold_until_by_meepo[entry.key] = nil
                    script._autofarm_empty_since[entry.key] = nil
                end
            end
        end
    end

    local camp_owner_by_id = {}
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local assigned = script._autofarm_assignment_by_meepo[entry.key]
        local camp_id = assigned and assigned.id or nil
        if camp_id and camp_by_id[camp_id] and not camp_owner_by_id[camp_id] then
            camp_owner_by_id[camp_id] = entry.key
        end
    end

    table.sort(meepo_entries, function(a, b)
        local ad = script.af_num(a and a.priority_dist or 999999, 999999)
        local bd = script.af_num(b and b.priority_dist or 999999, 999999)
        if math.abs(ad - bd) > 0.01 then
            return ad < bd
        end
        return script.af_num(a and a.key or 0, 0) < script.af_num(b and b.key or 0, 0)
    end)

    function choose_camp(meepo_pos, meepo_key, opts)
        opts = opts or {}
        local exclude_ids = opts.exclude_ids or nil
        local explicit_origin = opts.origin or nil
        local last_camp_id = meepo_key and script._autofarm_last_camp_by_meepo[meepo_key] or nil
        local last_camp = last_camp_id and camp_by_id[last_camp_id] or nil
        local chain_origin = explicit_origin or (last_camp and last_camp.world) or meepo_pos

        local best = nil
        local best_score = nil
        local best_ready_at = nil
        local best_tier = 4
        local nearest_active_dist = meepo_key and nearest_active_dist_by_meepo[meepo_key] or nil
        local nearest_creep_dist = meepo_key and nearest_creep_dist_by_meepo[meepo_key] or nil

        for i = 1, #camps do
            local camp = camps[i]
            local camp_id = camp and camp.id or nil
            local owner_key = camp and camp_owner_by_id[camp_id] or nil
            local excluded = exclude_ids and camp_id and exclude_ids[camp_id] == true
            if camp and camp_id and (not excluded) and (not taken[camp_id]) and (not owner_key or owner_key == meepo_key) then
                local eval = get_camp_eval(meepo_key, camp_id)
                local ready_at = eval and eval.ready_at or script.af_num(camp.ready_at or get_autofarm_camp_ready_at(camp_id) or 0, 0)
                local status = eval and eval.status or tostring(camp.status or "")
                local tier = eval and eval.tier or select(1, script.af_camp_tier(camp, now_time))
                local dist_meepo = eval and eval.dist_meepo or (meepo_pos and get_path_cost(meepo_pos, camp.world) or 999999)
                if not eval and meepo_pos then
                    path_eval_dist_calls = path_eval_dist_calls + 1
                end
                local wait_on_arrival = eval and eval.wait_on_arrival or nil
                if wait_on_arrival == nil then
                    local travel_time = dist_meepo / math.max(1, AUTOFARM_TRAVEL_SPEED_ESTIMATE)
                    local time_until_ready_fallback = math.max(0, ready_at - now_time)
                    wait_on_arrival = math.max(0, time_until_ready_fallback - travel_time)
                end
                local ready_by_arrival = eval and eval.ready_by_arrival
                if ready_by_arrival == nil then
                    ready_by_arrival = wait_on_arrival <= respawn_fuzz_cfg
                end
                local time_until_ready = math.max(0, ready_at - now_time)
                local dist_chain = dist_meepo
                if chain_origin and camp.world then
                    local same_origin = false
                    if meepo_pos then
                        local cx = script.af_num(chain_origin.x, 0)
                        local cy = script.af_num(chain_origin.y, 0)
                        local mx = script.af_num(meepo_pos.x, 0)
                        local my = script.af_num(meepo_pos.y, 0)
                        same_origin = math.abs(cx - mx) <= 1 and math.abs(cy - my) <= 1
                    end
                    if not same_origin then
                        dist_chain = get_chain_eval_dist(chain_origin, camp_id, camp.world, dist_meepo)
                    end
                end
                local consider = true
                if nearest_creep_dist and nearest_creep_dist <= near_pick_radius_cfg then
                    -- Hard guard: when a creep camp is close, do not send this meepo far or to non-creep camps.
                    if tier ~= 1 or dist_meepo > (nearest_creep_dist + near_pick_delta_cfg) then
                        consider = false
                    end
                elseif nearest_active_dist and nearest_active_dist <= near_pick_radius_cfg then
                    -- If any active camp is close, avoid long jumps unless this camp will be ready by arrival.
                    if dist_meepo > (nearest_active_dist + near_pick_delta_cfg) and not (tier == 4 and ready_by_arrival) then
                        consider = false
                    end
                end
                if consider then
                    local score = (dist_meepo * 0.68) + (dist_chain * 0.32)
                    if tier == 4 then
                        if ready_by_arrival then
                            score = score + (wait_on_arrival * 280) + 860
                        else
                            local delayed_wait = math.max(0, wait_on_arrival - respawn_fuzz_cfg)
                            score = score + (wait_on_arrival * 980) + (delayed_wait * 420) + 2500
                        end
                        if time_until_ready > queue_plan_max_wait_cfg then
                            score = score + 3200
                        end
                    else
                        if tier == 1 then
                            score = score - 220
                        elseif tier == 2 then
                            score = score + 560
                        else
                            score = score + 980
                        end
                        if nearest_active_dist and dist_meepo > (nearest_active_dist + 420) then
                            score = score + 9000
                        end
                        if nearest_creep_dist and tier == 1 and dist_meepo > (nearest_creep_dist + 420) then
                            score = score + 5200
                        end
                        local nearest_key = camp_nearest_key[camp_id]
                        local nearest_dist = tonumber(camp_nearest_dist[camp_id] or 999999) or 999999
                        if nearest_key and meepo_key and nearest_key ~= meepo_key and dist_meepo > (nearest_dist + AUTOFARM_POOF_MOVE_ADVANTAGE) then
                            score = score + 16000
                        end
                        if dist_meepo > AUTOFARM_QUEUE_MAX_TRAVEL and nearest_active_dist and nearest_active_dist <= AUTOFARM_QUEUE_MAX_TRAVEL then
                            score = score + 12000
                        end
                    end
                    if last_camp_id and camp_id == last_camp_id then
                        score = score - script._autofarm_cfg.LAST_CAMP_SCORE_BONUS
                    elseif last_camp_id and tier <= 2 then
                        local prev_camp = camp_by_id[last_camp_id]
                        if prev_camp and prev_camp.has_creeps == true then
                            score = score + math.floor(script._autofarm_cfg.LAST_CAMP_SCORE_BONUS * 0.65)
                        end
                    end

                    local better = false
                    if not best then
                        better = true
                    elseif score < best_score then
                        better = true
                    elseif math.abs(score - best_score) <= 0.01 and ready_at < best_ready_at then
                        better = true
                    end

                    if better then
                        best = camp
                        best_score = score
                        best_ready_at = ready_at
                        best_tier = tier
                    end
                end
            end
        end

        if best then
            if best_tier and best_tier >= 2 then
                local spawn_eta = math.max(0, next_spawn_time - now_time)
                if spawn_eta <= AUTOFARM_RESPAWN_WAIT_WINDOW then
                    local best_eval = best and meepo_key and get_camp_eval(meepo_key, best.id) or nil
                    local best_dist = best_eval and best_eval.dist_meepo or (meepo_pos and get_path_cost(meepo_pos, best.world) or 999999)
                    if (not best_eval) and meepo_pos then
                        path_eval_dist_calls = path_eval_dist_calls + 1
                    end
                    local travel_time = best_dist / math.max(1, AUTOFARM_TRAVEL_SPEED_ESTIMATE)
                    local move_budget = math.max(0, spawn_eta - AUTOFARM_RESPAWN_WAIT_BUFFER)
                    local best_ready_at = best_eval and best_eval.ready_at or script.af_num(best.ready_at or get_autofarm_camp_ready_at(best.id) or now_time, now_time)
                    if travel_time > move_budget and best_ready_at > (now_time + travel_time + respawn_fuzz_cfg) then
                        return nil
                    end
                end
            end
            return best
        end

        local fallback = nil
        local fallback_dist = nil
        for i = 1, #camps do
            local camp = camps[i]
            local camp_id = camp and camp.id or nil
            local owner_key = camp and camp_owner_by_id[camp_id] or nil
            local excluded = exclude_ids and camp_id and exclude_ids[camp_id] == true
            if camp and camp_id and (not excluded) and (not owner_key or owner_key == meepo_key) then
                local eval = get_camp_eval(meepo_key, camp_id)
                local d = eval and eval.dist_meepo or (meepo_pos and get_path_cost(meepo_pos, camp.world) or 999999)
                if (not eval) and meepo_pos then
                    path_eval_dist_calls = path_eval_dist_calls + 1
                end
                if (not fallback) or d < fallback_dist then
                    fallback = camp
                    fallback_dist = d
                end
            end
        end
        return fallback
    end
    function choose_wait_camp(meepo_pos, meepo_key, opts)
        opts = opts or {}
        local exclude_ids = opts.exclude_ids or nil
        local best = nil
        local best_score = nil
        for i = 1, #camps do
            local camp = camps[i]
            local camp_id = camp and camp.id or nil
            local owner_key = camp and camp_owner_by_id[camp_id] or nil
            local excluded = exclude_ids and camp_id and exclude_ids[camp_id] == true
            if camp and camp_id and (not excluded) and (not taken[camp_id]) and (not owner_key or owner_key == meepo_key) then
                local eval = get_camp_eval(meepo_key, camp_id)
                local ready_at = eval and eval.ready_at or script.af_num(camp.ready_at or get_autofarm_camp_ready_at(camp_id) or next_spawn_time, next_spawn_time)
                local dist = eval and eval.dist_meepo or (meepo_pos and get_path_cost(meepo_pos, camp.world) or 999999)
                if (not eval) and meepo_pos then
                    path_eval_dist_calls = path_eval_dist_calls + 1
                end
                local wait_on_arrival = eval and eval.wait_on_arrival or nil
                if wait_on_arrival == nil then
                    local travel_time = dist / math.max(1, AUTOFARM_TRAVEL_SPEED_ESTIMATE)
                    wait_on_arrival = math.max(0, ready_at - (now_time + travel_time))
                end
                local score = (wait_on_arrival * 900) + dist
                if wait_on_arrival <= respawn_fuzz_cfg then
                    score = score - 420
                end
                local has_creeps = eval and eval.has_creeps or camp.has_creeps == true
                local status = eval and eval.status or tostring(camp.status or "")
                if has_creeps == true then
                    score = score - 3000
                elseif status == "unseen" then
                    score = score - 700
                end
                if (not best) or score < best_score then
                    best = camp
                    best_score = score
                end
            end
        end
        return best
    end
    function handle_autostack_for_camp(meepo, key, meepo_pos, assigned, creeps)
        if auto_stack_enabled ~= true then
            return false, false
        end
        if not meepo or not key or not assigned or not assigned.data or not creeps or #creeps == 0 then
            return false, false
        end
        if second_in_minute < AUTOFARM_STACK_PREP_SECOND or second_in_minute >= 59.8 then
            return false, false
        end
        local center = get_camp_center(assigned.data)
        local dist_center = (center and meepo_pos) and vec_dist_2d(meepo_pos, center) or 999999
        if dist_center > AUTOFARM_STACK_TRIGGER_RADIUS then
            return false, false
        end
        local stack_state = script._autofarm_stack_state_by_meepo[key] or {}
        if stack_state.minute ~= minute_index or stack_state.camp_id ~= assigned.id then
            stack_state = { minute = minute_index, camp_id = assigned.id, phase = "prep", pull_time = 0, retreat_time = 0, last_retreat_order = 0 }
        end
        local issued_stack = false
        if second_in_minute < AUTOFARM_SPAWN_CLEAR_SECOND then
            stack_state.phase = "prep"
            -- keep meepo near camp before :55, but do not aggro too early
            local prep_dist = dist_center
            local prep_target = center or assigned.world
            if prep_target and prep_dist > (AUTOFARM_STACK_TRIGGER_RADIUS * 0.55) then
                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                if autofarm_issue_order(local_player, meepo, order, nil, prep_target, "meepo_autofarm_stack_prep", now_time) then
                    issued_stack = true
                end
            end
        else
            local target = autofarm_pick_nearest(creeps, meepo_pos or assigned.world)
            if (tonumber(stack_state.pull_time or 0) or 0) <= 0 then
                if target then
                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
                    if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_stack_pull", now_time) then
                        issued_stack = true
                        stack_state.phase = "pull"
                        stack_state.pull_time = now_time
                    end
                end
            else
                stack_state.phase = "pull"
                local pull_time = tonumber(stack_state.pull_time or 0) or 0
                local retreat_elapsed = now_time - pull_time
                if retreat_elapsed >= AUTOFARM_STACK_RETREAT_DELAY then
                    local retreat_distance = AUTOFARM_STACK_RETREAT_DISTANCE
                    if assigned.data and assigned.data.camp_box and assigned.data.camp_box.min and assigned.data.camp_box.max then
                        local box_dx = math.abs((assigned.data.camp_box.max.x or 0) - (assigned.data.camp_box.min.x or 0)) * 0.5
                        local box_dy = math.abs((assigned.data.camp_box.max.y or 0) - (assigned.data.camp_box.min.y or 0)) * 0.5
                        local min_clear = math.max(box_dx, box_dy) + 480
                        if retreat_distance < min_clear then
                            retreat_distance = min_clear
                        end
                    end
                    local retreat_pos = get_camp_offset_point(assigned.data, meepo_pos, retreat_distance)
                    if retreat_pos then
                        local should_reissue = (tonumber(stack_state.last_retreat_order or 0) or 0) <= 0
                            or (now_time - (tonumber(stack_state.last_retreat_order or 0) or 0)) >= 0.45
                        if should_reissue then
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, retreat_pos, "meepo_autofarm_stack_retreat", now_time) then
                                issued_stack = true
                                stack_state.phase = "retreat"
                                stack_state.retreat_time = now_time
                                stack_state.last_retreat_order = now_time
                            end
                        end
                    end
                end
            end
        end
        script._autofarm_stack_state_by_meepo[key] = stack_state
        return true, issued_stack
    end

    function try_autofarm_poof_move(meepo, meepo_key, meepo_pos, assigned)
        if use_poof_move ~= true then
            return false
        end
        if not meepo or not meepo_key or not meepo_pos or not assigned or not assigned.world then
            return false
        end
        local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
        local max_mana = tonumber(safe_call(NPC.GetMaxMana, meepo) or 0) or 0
        local mana_pct = (max_mana > 0) and ((mana / max_mana) * 100) or 0
        if mana_pct <= (tonumber(mana_reserve_pct or 0) or 0) then
            return false
        end
        local dist_to_camp = vec_dist_2d(meepo_pos, assigned.world)
        if dist_to_camp < AUTOFARM_POOF_MOVE_MIN_DIST then
            return false
        end
        local last_poof = tonumber(script._autofarm_last_poof_move_by_meepo[meepo_key] or -9999) or -9999
        if (now_time - last_poof) < AUTOFARM_POOF_MOVE_RECAST then
            return false
        end
        local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
        if not poof or not can_cast_ability_for_npc(meepo, poof) then
            return false
        end
        if safe_call(Ability.IsInAbilityPhase, poof) == true or safe_call(Ability.IsChannelling, poof) == true then
            return false
        end

        local best_anchor = nil
        local best_anchor_dist = dist_to_camp
        local assigned_id = assigned and assigned.id or nil
        for i = 1, #meepo_entries do
            local entry = meepo_entries[i]
            if entry and entry.key ~= meepo_key and entry.unit and entry.pos and Entity.IsAlive(entry.unit) then
                local can_use_anchor = true
                local anchor_last_poof = tonumber(script._autofarm_last_poof_move_by_meepo[entry.key] or -9999) or -9999
                if (now_time - anchor_last_poof) < 1.10 then
                    can_use_anchor = false
                end
                if can_use_anchor and assigned_id then
                    local anchor_assigned = script._autofarm_assignment_by_meepo[entry.key]
                    local anchor_assigned_id = anchor_assigned and anchor_assigned.id or nil
                    if anchor_assigned_id and anchor_assigned_id ~= assigned_id then
                        can_use_anchor = false
                    end
                end
                if can_use_anchor then
                    local anchor_dist = vec_dist_2d(entry.pos, assigned.world)
                    if anchor_dist + AUTOFARM_POOF_MOVE_ADVANTAGE < dist_to_camp and anchor_dist < best_anchor_dist then
                        best_anchor = entry.unit
                        best_anchor_dist = anchor_dist
                    end
                end
            end
        end
        if not best_anchor then
            return false
        end
        if script.issue_group_poof_target_order(local_player, { meepo }, best_anchor, now_time, "meepo_autofarm_poof_move") then
            script._autofarm_last_poof_move_by_meepo[meepo_key] = now_time
            script._autofarm_last_order_by_meepo[meepo_key] = now_time
            script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
            script._autofarm_move_commit_until_by_meepo[meepo_key] = now_time + 0.95
            return true
        end
        return false
    end
    function get_alive_wave_creeps(creeps)
        local out = {}
        if not creeps then
            return out
        end
        for i = 1, #creeps do
            local creep = creeps[i]
            if creep and Entity.IsAlive(creep) and safe_call(NPC.IsWaitingToSpawn, creep) ~= true then
                out[#out + 1] = creep
            end
        end
        return out
    end
    function choose_wave_target_for_meepo(meepo_pos, meepo_key)
        if not script.autofarm_can_assign_wave_to(meepo_key, now_time) then
            return nil, nil
        end
        local best = nil
        local best_creeps = nil
        local best_score = nil
        local last_wave_id = script._autofarm_wave_target_by_meepo and script._autofarm_wave_target_by_meepo[meepo_key] or nil
        for i = 1, #wave_defense_targets do
            local marker = wave_defense_targets[i]
            if marker and marker.id and marker.center and not wave_taken[marker.id] then
                local alive_creeps = get_alive_wave_creeps(marker.creeps)
                local creep_count = #alive_creeps
                if creep_count >= script._autofarm_cfg.WAVE_DEFENSE_MIN_CREEPS then
                    local dist_wave = meepo_pos and vec_dist_2d(meepo_pos, marker.center) or 999999
                    local tower_dist = tonumber(marker.dist_to_tower or 999999) or 999999
                    local urgency = math.max(0, script._autofarm_cfg.WAVE_DEFENSE_TOWER_RADIUS - tower_dist)
                    local score = (dist_wave * 0.78) + (tower_dist * 0.55) - (creep_count * 88) - (urgency * 0.22)
                    if last_wave_id and marker.id == last_wave_id then
                        score = score - script._autofarm_cfg.WAVE_KEEP_SAME_TARGET_BONUS
                    end
                    if (not best_score) or score < best_score then
                        best = marker
                        best_creeps = alive_creeps
                        best_score = score
                    end
                end
            end
        end
        return best, best_creeps
    end
    function handle_wave_defense_for_meepo(meepo, meepo_key, meepo_pos, wave_target, alive_creeps)
        if not meepo or not meepo_key or not meepo_pos or not wave_target or not wave_target.center then
            return false, false
        end
        local creeps = alive_creeps or {}
        if #creeps <= 0 then
            return false, false
        end
        local wave_center = wave_target.center
        local dist_wave = vec_dist_2d(meepo_pos, wave_center)
        if dist_wave > script._autofarm_cfg.WAVE_DEFENSE_REACH_RADIUS then
            local move_order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
            if autofarm_issue_order(local_player, meepo, move_order, nil, wave_center, "meepo_autofarm_wave_move", now_time) then
                return true, true
            end
            return true, false
        end
        local target = autofarm_pick_nearest(creeps, meepo_pos or wave_center)
        if not target then
            return true, false
        end
        local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
        local max_mana = tonumber(safe_call(NPC.GetMaxMana, meepo) or 0) or 0
        local mana_pct = (max_mana > 0) and ((mana / max_mana) * 100) or 0
        local poof_used = false
        if use_poof_damage and mana_pct > mana_reserve_pct and #creeps >= script._autofarm_cfg.WAVE_DEFENSE_POOF_MIN_CREEPS then
            local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
            if poof and safe_call(Ability.IsReady, poof) == true
                and safe_call(Ability.IsInAbilityPhase, poof) ~= true
                and safe_call(Ability.IsChannelling, poof) ~= true
            then
                local poof_radius = get_poof_damage_radius(poof)
                if poof_radius <= 0 then
                    poof_radius = AUTOFARM_POOF_DAMAGE_RANGE
                end
                local effective_radius = math.max(190, poof_radius - 60)
                local packed = 0
                for ci = 1, #creeps do
                    local creep_pos = safe_call(Entity.GetAbsOrigin, creeps[ci])
                    if creep_pos and vec_dist_2d(meepo_pos, creep_pos) <= effective_radius then
                        packed = packed + 1
                    end
                end
                if packed >= script._autofarm_cfg.WAVE_DEFENSE_POOF_MIN_CREEPS then
                    if script.issue_group_poof_target_order(local_player, { meepo }, meepo, now_time, "meepo_autofarm_wave_poof") then
                        script._autofarm_last_order_by_meepo[meepo_key] = now_time
                        poof_used = true
                        return true, true
                    end
                end
            end
        end
        if not poof_used then
            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
            if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_wave_attack", now_time) then
                return true, true
            end
        end
        return true, false
    end

    local issued = false
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local meepo = entry and entry.unit or nil
        local key = entry and entry.key or nil
        local meepo_pos = entry and entry.pos or nil
        if meepo and key and Entity.IsAlive(meepo) and not is_combo_cast_in_progress(meepo) then

            local assigned = script._autofarm_assignment_by_meepo[key]
            local hold_until = tonumber(script._autofarm_assignment_hold_until_by_meepo[key] or 0) or 0
            local handled_wave = false
            local skip_farm_logic = false
            local hp_pct = get_health_pct(meepo)
            local mana_pct_now = get_mana_pct(meepo)
            local was_healing = heal_mode_by_meepo[key] == true
            local healing_mode = was_healing
            if hp_pct < AUTOFARM_LOW_HP_RETREAT_PCT then
                healing_mode = true
            end
            if healing_mode and (not was_healing) then
                local resume_state = heal_resume_by_meepo[key] or {}
                local q = get_queue_entry(key)
                if assigned and assigned.id then
                    resume_state.camp_id = assigned.id
                elseif q and q.primary_id then
                    resume_state.camp_id = q.primary_id
                end
                if q then
                    resume_state.primary_id = q.primary_id
                    resume_state.secondary_id = q.secondary_id
                end
                resume_state.saved_at = now_time
                heal_resume_by_meepo[key] = resume_state
                script.autofarm_timeline_set(key, "heal-enter", "to fountain", now_time)
            end
            if healing_mode then
                if not fountain_pos then
                    heal_mode_by_meepo[key] = nil
                    healing_mode = false
                end
            end
            if healing_mode then
                local full_healed = hp_pct >= (AUTOFARM_HEAL_EXIT_PCT - 0.05)
                local full_mana = mana_pct_now >= 99.95
                local dist_fountain = (fountain_pos and meepo_pos) and vec_dist_2d(meepo_pos, fountain_pos) or 999999
                local at_fountain = fountain_pos and dist_fountain <= AUTOFARM_FOUNTAIN_RADIUS
                if at_fountain and full_healed and full_mana then
                    heal_mode_by_meepo[key] = nil
                    script.autofarm_timeline_set(key, "heal-ready", "resume", now_time)
                else
                    heal_mode_by_meepo[key] = true
                    heal_active_count = heal_active_count + 1
                    skip_farm_logic = true
                    local resume_state = heal_resume_by_meepo[key] or {}
                    if (not resume_state.camp_id) and assigned and assigned.id then
                        resume_state.camp_id = assigned.id
                    end
                    local q = get_queue_entry(key)
                    if q then
                        resume_state.primary_id = q.primary_id
                        resume_state.secondary_id = q.secondary_id
                    end
                    resume_state.saved_at = now_time
                    heal_resume_by_meepo[key] = resume_state
                    local released_camp_id = assigned and assigned.id or nil
                    script._autofarm_assignment_by_meepo[key] = nil
                    script._autofarm_assignment_hold_until_by_meepo[key] = 0
                    script._autofarm_empty_since[key] = nil
                    script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
                    script._autofarm_wave_target_by_meepo[key] = nil
                    script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
                    script._autofarm_move_commit_until_by_meepo[key] = now_time + 0.72
                    set_queue_plan(key, nil, nil)
                    if released_camp_id then
                        queue_clear_if_matches(key, released_camp_id)
                        camp_owner_by_id[released_camp_id] = nil
                        taken[released_camp_id] = nil
                    end
                    if fountain_pos then
                        local move_order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                        local need_move = (not at_fountain) or (dist_fountain > (AUTOFARM_FOUNTAIN_RADIUS * 0.72))
                        if need_move then
                            if autofarm_issue_order(local_player, meepo, move_order, nil, fountain_pos, "meepo_autofarm_heal_fountain", now_time) then
                                issued = true
                                script.autofarm_metric_inc("heal_orders", 1)
                            else
                                script.autofarm_timeline_set(key, "heal", "holding at fountain path", now_time)
                            end
                        else
                            script.autofarm_timeline_set(key, "heal", "waiting full hp+mana", now_time)
                        end
                    end
                end
            end
            if not skip_farm_logic then
            if not assigned then
                local resume_state = heal_resume_by_meepo[key]
                local resume_camp_id = resume_state and resume_state.camp_id or nil
                local resume_camp = resume_camp_id and camp_by_id[resume_camp_id] or nil
                if resume_camp then
                    local owner_key = camp_owner_by_id[resume_camp_id]
                    local available = (not taken[resume_camp_id]) or owner_key == nil or owner_key == key
                    if available then
                        assigned = resume_camp
                        script._autofarm_assignment_by_meepo[key] = resume_camp
                        script._autofarm_assignment_hold_until_by_meepo[key] = math.max(
                            tonumber(script._autofarm_assignment_hold_until_by_meepo[key] or 0) or 0,
                            now_time + 0.90
                        )
                        camp_owner_by_id[resume_camp_id] = key
                        taken[resume_camp_id] = true
                        script.autofarm_metric_inc("heal_resumes", 1)
                        script.autofarm_timeline_set(key, "resume", "camp " .. tostring(resume_camp_id), now_time)
                        local q_primary = resume_state and resume_state.primary_id or resume_camp_id
                        if not q_primary then
                            q_primary = resume_camp_id
                        end
                        local q_secondary = resume_state and resume_state.secondary_id or nil
                        if q_secondary == q_primary then
                            q_secondary = nil
                        end
                        set_queue_plan(key, q_primary, q_secondary)
                    end
                end
                if heal_resume_by_meepo[key] then
                    heal_resume_by_meepo[key] = nil
                end
            end
            -- validate current assignment
            local valid = assigned and assigned.world and true or false
            if valid then
                local found = false
                for _, camp in ipairs(camps) do
                    if camp.id == assigned.id then
                        assigned = camp
                        found = true
                        break
                    end
                end
                if not found then
                    valid = false
                end
            end
            if valid and assigned then
                local owner_key = camp_owner_by_id[assigned.id]
                if owner_key and owner_key ~= key then
                    local dist_assigned = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 999999
                    local engaged_here = assigned.has_creeps == true and dist_assigned <= AUTOFARM_CAMP_REACH_RADIUS
                    local committed_here = hold_until > now_time
                        or ((tonumber(script._autofarm_move_commit_until_by_meepo[key] or 0) or 0) > now_time)
                        or dist_assigned <= (AUTOFARM_CAMP_REACH_RADIUS * 1.10)
                    if engaged_here or committed_here then
                        camp_owner_by_id[assigned.id] = key
                    else
                        valid = false
                    end
                elseif not owner_key then
                    camp_owner_by_id[assigned.id] = key
                end
            end
            if valid and assigned and taken[assigned.id] and camp_owner_by_id[assigned.id] ~= key then
                valid = false
            end
            if valid and assigned and assigned.has_creeps ~= true then
                local assigned_ready_at = tonumber(assigned.ready_at or get_autofarm_camp_ready_at(assigned.id) or 0) or 0
                local still_committed = meepo_pos and (vec_dist_2d(meepo_pos, assigned.world) <= script._autofarm_cfg.ASSIGN_STICKY_RADIUS) or false
                if assigned_ready_at > now_time
                    and hold_until <= now_time
                    and (tonumber(script._autofarm_move_commit_until_by_meepo[key] or 0) or 0) <= now_time
                    and not still_committed
                then
                    valid = false
                end
            end
            if valid and assigned and assigned.has_creeps ~= true and hold_until <= now_time and script.autofarm_can_assign_wave_to(key, now_time) then
                local wave_target, wave_creeps = choose_wave_target_for_meepo(meepo_pos, key)
                if wave_target and wave_creeps and #wave_creeps > 0 then
                    local released_camp_id = assigned and assigned.id or nil
                    script._autofarm_assignment_by_meepo[key] = nil
                    script._autofarm_assignment_hold_until_by_meepo[key] = 0
                    script._autofarm_empty_since[key] = nil
                    if released_camp_id then
                        queue_clear_if_matches(key, released_camp_id)
                        camp_owner_by_id[released_camp_id] = nil
                        taken[released_camp_id] = nil
                    end
                    script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
                    script._autofarm_wave_target_by_meepo[key] = wave_target.id
                    local wave_handled, wave_issued = handle_wave_defense_for_meepo(meepo, key, meepo_pos, wave_target, wave_creeps)
                    wave_taken[wave_target.id] = true
                    handled_wave = wave_handled == true
                    if handled_wave then
                        script.autofarm_claim_wave_owner(key, now_time, 1.15)
                    end
                    if wave_issued then
                        issued = true
                    end
                    valid = false
                    assigned = nil
                end
            end
            if not valid then
                script.autofarm_metric_inc("repicks", 1)
                if assigned and assigned.id then
                    queue_clear_if_matches(key, assigned.id)
                end
                if (not handled_wave) and #wave_defense_targets > 0 and script.autofarm_can_assign_wave_to(key, now_time) then
                    local wave_target, wave_creeps = choose_wave_target_for_meepo(meepo_pos, key)
                    if wave_target and wave_creeps and #wave_creeps > 0 then
                        local released_camp_id = assigned and assigned.id or nil
                        script._autofarm_assignment_by_meepo[key] = nil
                        script._autofarm_assignment_hold_until_by_meepo[key] = 0
                        script._autofarm_empty_since[key] = nil
                        if released_camp_id then
                            queue_clear_if_matches(key, released_camp_id)
                            camp_owner_by_id[released_camp_id] = nil
                            taken[released_camp_id] = nil
                        end
                        script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
                        script._autofarm_wave_target_by_meepo[key] = wave_target.id
                        local wave_handled, wave_issued = handle_wave_defense_for_meepo(meepo, key, meepo_pos, wave_target, wave_creeps)
                        wave_taken[wave_target.id] = true
                        handled_wave = wave_handled == true
                        if handled_wave then
                            script.autofarm_claim_wave_owner(key, now_time, 1.15)
                        end
                        if wave_issued then
                            issued = true
                        end
                    end
                end
                if not handled_wave then
                    assigned = queue_primary_candidate(key)
                    if assigned then
                        local owner_key = camp_owner_by_id[assigned.id]
                        if owner_key and owner_key ~= key then
                            assigned = nil
                        else
                            script.autofarm_metric_inc("queue_hits", 1)
                        end
                    end
                    if not assigned then
                        script.autofarm_metric_inc("queue_misses", 1)
                    end
                    if not assigned then
                        assigned = choose_camp(meepo_pos, key)
                    end
                    if not assigned then
                        assigned = choose_wait_camp(meepo_pos, key)
                    end
                    script._autofarm_assignment_by_meepo[key] = assigned
                    script._autofarm_assignment_hold_until_by_meepo[key] = 0
                    script._autofarm_empty_since[key] = nil
                    script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
                    script._autofarm_wave_target_by_meepo[key] = nil
                    script._autofarm_move_commit_until_by_meepo = script._autofarm_move_commit_until_by_meepo or {}
                    script._autofarm_move_commit_until_by_meepo[key] = now_time + 0.70
                    if assigned then
                        local q = get_queue_entry(key)
                        local secondary_id = q and q.secondary_id or nil
                        local secondary_valid = secondary_id and camp_by_id[secondary_id] and secondary_id ~= assigned.id and not taken[secondary_id]
                        if not secondary_valid then
                            local exclude = { [assigned.id] = true }
                            local secondary = choose_camp(assigned.world or meepo_pos, key, {
                                exclude_ids = exclude,
                                origin = assigned.world,
                            })
                            if not secondary then
                                secondary = choose_wait_camp(assigned.world or meepo_pos, key, { exclude_ids = exclude })
                            end
                            secondary_id = secondary and secondary.id or nil
                            if secondary_id then
                                script.autofarm_metric_inc("queue_plans", 1)
                            end
                        end
                        set_queue_plan(key, assigned.id, secondary_id)
                    else
                        set_queue_plan(key, nil, nil)
                    end
                end
            end
            if assigned and not handled_wave then
                local q = get_queue_entry(key)
                if q and q.primary_id ~= assigned.id then
                    if q.secondary_id == assigned.id then
                        q.secondary_id = nil
                    end
                    q.primary_id = assigned.id
                    q.updated_at = now_time
                end
                script._autofarm_wave_target_by_meepo = script._autofarm_wave_target_by_meepo or {}
                script._autofarm_wave_target_by_meepo[key] = nil
                camp_owner_by_id[assigned.id] = camp_owner_by_id[assigned.id] or key
                script._autofarm_last_camp_by_meepo[key] = assigned.id
                taken[assigned.id] = true
                local has, creeps = assigned.has_creeps, assigned.creeps
                if not has then
                    has, creeps = script.autofarm_camp_has_creeps(assigned.data, script._autofarm_neutral_tick_entries)
                end
                if has and creeps and #creeps > 0 then
                    local dist_to_camp = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 99999
                    if dist_to_camp <= (AUTOFARM_CAMP_REACH_RADIUS * 1.18) then
                        script._autofarm_assignment_hold_until_by_meepo[key] = now_time + AUTOFARM_ASSIGN_LOCK_SEC
                    end
                    if dist_to_camp > AUTOFARM_CAMP_REACH_RADIUS then
                        if script.autofarm_can_assign_wave_to(key, now_time) then
                            local path_wave_handled, path_wave_issued = script.try_autofarm_path_wave_intercept(local_player, local_hero, meepo, key, meepo_pos, assigned.world, wave_markers, wave_taken, now_time, use_poof_damage, mana_reserve_pct)
                            if path_wave_handled then
                                script.autofarm_claim_wave_owner(key, now_time, 1.15)
                                handled_wave = true
                                if path_wave_issued then
                                    issued = true
                                end
                                script._autofarm_assignment_by_meepo[key] = assigned
                                script._autofarm_assignment_hold_until_by_meepo[key] = math.max(
                                    tonumber(script._autofarm_assignment_hold_until_by_meepo[key] or 0) or 0,
                                    now_time + 1.20
                                )
                                script._autofarm_empty_since[key] = nil
                                camp_owner_by_id[assigned.id] = key
                                taken[assigned.id] = true
                                script.autofarm_metric_inc("path_wave_returns", 1)
                                script.autofarm_timeline_set(key, "path-wave", "return camp " .. tostring(assigned.id), now_time)
                                script._autofarm_move_commit_until_by_meepo[key] = now_time + 0.95
                            else
                                if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                                    issued = true
                                else
                                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                    if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move_to_camp", now_time) then
                                        issued = true
                                    end
                                end
                            end
                        else
                            if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                                issued = true
                            else
                                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move_to_camp", now_time) then
                                    issued = true
                                end
                            end
                        end
                    elseif not handled_wave then
                        local stack_active, stack_issued = handle_autostack_for_camp(meepo, key, meepo_pos, assigned, creeps)
                        if stack_active then
                            if stack_issued then
                                issued = true
                            end
                        else
                            local ready_state = mark_autofarm_camp_state(assigned.id, now_time, true, "ready", key)
                            local presence = script._autofarm_camp_presence or {}
                            local camp_presence = presence[assigned.id] or {}
                            camp_presence.has = true
                            camp_presence.last_seen_creeps = now_time
                            camp_presence.last_cleared = nil
                            camp_presence.status = "ready"
                            camp_presence.ready_at = tonumber(ready_state and ready_state.ready_at or now_time) or now_time
                            camp_presence.next_spawn = tonumber(ready_state and ready_state.next_spawn or get_next_neutral_spawn_time(now_time)) or get_next_neutral_spawn_time(now_time)
                            presence[assigned.id] = camp_presence
                            script._autofarm_camp_presence = presence
                            script._autofarm_empty_since[key] = nil
                            local target = autofarm_pick_nearest(creeps, meepo_pos or assigned.world)
                            if target then
                                local mana = tonumber(safe_call(NPC.GetMana, meepo) or 0) or 0
                                local max_mana = tonumber(safe_call(NPC.GetMaxMana, meepo) or 0) or 0
                                local mana_pct = (max_mana > 0) and ((mana / max_mana) * 100) or 0
                                local poof_action_taken = false
                                if use_poof_damage and mana_pct > mana_reserve_pct and #creeps >= AUTOFARM_POOF_DAMAGE_MIN_CREEPS then
                                    local poof = safe_call(NPC.GetAbility, meepo, C.ABILITY_POOF)
                                    local meepo_origin = meepo_pos or assigned.world
                                    local target_pos = safe_call(Entity.GetAbsOrigin, target) or assigned.world
                                    local dist_target = vec_dist_2d(meepo_origin, target_pos)
                                    local camp_center = get_camp_center(assigned.data) or assigned.world
                                    local dist_center_now = vec_dist_2d(meepo_origin, camp_center)
                                    if poof and safe_call(Ability.IsReady, poof) == true then
                                        local poof_radius = get_poof_damage_radius(poof)
                                        if poof_radius <= 0 then
                                            poof_radius = AUTOFARM_POOF_DAMAGE_RANGE
                                        end
                                        local effective_radius = math.max(180, poof_radius - 70)
                                        local packed_count = 0
                                        for ci = 1, #creeps do
                                            local creep_pos = safe_call(Entity.GetAbsOrigin, creeps[ci])
                                            if creep_pos and vec_dist_2d(meepo_origin, creep_pos) <= effective_radius then
                                                packed_count = packed_count + 1
                                            end
                                        end
                                        local close_to_center = dist_center_now <= (AUTOFARM_CAMP_REACH_RADIUS * 0.58)
                                        local can_poof_now = dist_target <= AUTOFARM_POOF_DAMAGE_RANGE
                                            and packed_count >= AUTOFARM_POOF_DAMAGE_MIN_CREEPS
                                            and close_to_center
                                        if can_poof_now then
                                            if script.issue_group_poof_target_order(local_player, { meepo }, meepo, now_time, "meepo_autofarm_poof_damage") then
                                                poof_action_taken = true
                                                issued = true
                                                script._autofarm_last_order_by_meepo[key] = now_time
                                            end
                                        else
                                            if camp_center and dist_center_now > (AUTOFARM_POINT_REACH_RADIUS * 0.62) then
                                                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                                if autofarm_issue_order(local_player, meepo, order, nil, camp_center, "meepo_autofarm_poof_setup", now_time) then
                                                    poof_action_taken = true
                                                    issued = true
                                                end
                                            end
                                        end
                                    end
                                end
                                if not poof_action_taken then
                                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or nil
                                    if autofarm_issue_order(local_player, meepo, order, target, nil, "meepo_autofarm_attack", now_time) then
                                        issued = true
                                    end
                                end
                            end
                        end
                    end
                else
                    local dist = meepo_pos and vec_dist_2d(meepo_pos, assigned.world) or 99999
                    local camp_center = get_camp_center(assigned.data)
                    local dist_center = (camp_center and meepo_pos) and vec_dist_2d(meepo_pos, camp_center) or dist
                    local camp_has_box = assigned.data and assigned.data.camp_box
                    local in_spawn_box = camp_has_box and is_pos_in_box(meepo_pos, assigned.data.camp_box) or false
                    local camp_point_visible = camp_center and FogOfWar and FogOfWar.IsPointVisible and (safe_call(FogOfWar.IsPointVisible, camp_center) == true) or false
                    local spawn_clear_window = second_in_minute >= AUTOFARM_SPAWN_CLEAR_SECOND and next_spawn_eta <= AUTOFARM_SPAWN_CLEAR_WINDOW
                    if spawn_clear_window then
                        local wait_pos = get_camp_offset_point(assigned.data, meepo_pos, AUTOFARM_SPAWN_CLEAR_DISTANCE)
                        local target_pos = wait_pos or assigned.world
                        local target_dist = (target_pos and meepo_pos) and vec_dist_2d(meepo_pos, target_pos) or 99999
                        if target_pos and (in_spawn_box or dist_center <= AUTOFARM_CAMP_REACH_RADIUS or target_dist > (AUTOFARM_POINT_REACH_RADIUS * 0.6)) then
                            local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                            if autofarm_issue_order(local_player, meepo, order, nil, target_pos, "meepo_autofarm_spawn_clear_wait", now_time) then
                                issued = true
                            end
                        end
                        script._autofarm_empty_since[key] = nil
                    elseif dist > AUTOFARM_POINT_REACH_RADIUS then
                        if script.autofarm_can_assign_wave_to(key, now_time) then
                            local path_wave_handled, path_wave_issued = script.try_autofarm_path_wave_intercept(local_player, local_hero, meepo, key, meepo_pos, assigned.world, wave_markers, wave_taken, now_time, use_poof_damage, mana_reserve_pct)
                            if path_wave_handled then
                                script.autofarm_claim_wave_owner(key, now_time, 1.15)
                                handled_wave = true
                                if path_wave_issued then
                                    issued = true
                                end
                                script._autofarm_assignment_by_meepo[key] = assigned
                                script._autofarm_assignment_hold_until_by_meepo[key] = math.max(
                                    tonumber(script._autofarm_assignment_hold_until_by_meepo[key] or 0) or 0,
                                    now_time + 1.20
                                )
                                script._autofarm_empty_since[key] = nil
                                camp_owner_by_id[assigned.id] = key
                                taken[assigned.id] = true
                                script.autofarm_metric_inc("path_wave_returns", 1)
                                script.autofarm_timeline_set(key, "path-wave", "return camp " .. tostring(assigned.id), now_time)
                                script._autofarm_move_commit_until_by_meepo[key] = now_time + 0.95
                            else
                                if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                                    issued = true
                                else
                                    local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                    if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move", now_time) then
                                        issued = true
                                    end
                                end
                            end
                        else
                            if try_autofarm_poof_move(meepo, key, meepo_pos, assigned) then
                                issued = true
                            else
                                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                if autofarm_issue_order(local_player, meepo, order, nil, assigned.world, "meepo_autofarm_move", now_time) then
                                    issued = true
                                end
                            end
                        end
                    elseif not handled_wave then
                        local empty_since = tonumber(script._autofarm_empty_since[key] or 0) or 0
                        local close_no_box = (not camp_has_box) and (dist_center <= (AUTOFARM_POINT_REACH_RADIUS * 0.55))
                        local close_with_box = camp_has_box and (dist_center <= (AUTOFARM_POINT_REACH_RADIUS * 0.45))
                        local can_confirm_farmed = in_spawn_box or close_no_box or close_with_box or camp_point_visible
                        local empty_confirm_delay = camp_point_visible and 0.35 or 0.6
                        if not can_confirm_farmed then
                            script._autofarm_empty_since[key] = nil
                            local verify_pos = camp_center or assigned.world
                            local need_verify_move = false
                            if verify_pos then
                                if camp_has_box then
                                    -- For boxed camps, step into a position that reveals/validates the spawn area.
                                    need_verify_move = (not in_spawn_box) or (camp_point_visible ~= true)
                                else
                                    need_verify_move = dist_center > (AUTOFARM_POINT_REACH_RADIUS * 0.45)
                                end
                            end
                            if need_verify_move and verify_pos then
                                local order = Enum and Enum.UnitOrder and Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or nil
                                if autofarm_issue_order(local_player, meepo, order, nil, verify_pos, "meepo_autofarm_verify_empty", now_time) then
                                    issued = true
                                end
                            end
                        elseif empty_since == 0 then
                            script._autofarm_empty_since[key] = now_time
                        elseif (now_time - empty_since) >= empty_confirm_delay then
                            -- confirmed as recently farmed only when meepo is really inside camp area
                            local farmed_state = force_autofarm_camp_not_ready(assigned.id, now_time, "farmed", key)
                            local presence = script._autofarm_camp_presence or {}
                            local camp_presence = presence[assigned.id] or {}
                            camp_presence.has = false
                            camp_presence.last_cleared = now_time
                            camp_presence.status = "farmed"
                            camp_presence.ready_at = tonumber(farmed_state and farmed_state.ready_at or get_autofarm_camp_ready_at(assigned.id)) or now_time
                            camp_presence.next_spawn = camp_presence.ready_at
                            presence[assigned.id] = camp_presence
                            script._autofarm_camp_presence = presence
                            queue_clear_if_matches(key, assigned.id)
                            script._autofarm_assignment_by_meepo[key] = nil
                            script._autofarm_assignment_hold_until_by_meepo[key] = nil
                            script._autofarm_empty_since[key] = nil
                        end
                    end
                end
            end
            end
        end
    end
    if path_block_events_tick > 0 then
        script.autofarm_metric_inc("path_block_events", path_block_events_tick)
    end
    local queue_active = 0
    for i = 1, #meepo_entries do
        local entry = meepo_entries[i]
        local key = entry and entry.key or nil
        local q = key and camp_queue[key] or nil
        if q and q.primary_id then
            queue_active = queue_active + 1
        end
    end
    local cache_size = tonumber(script._autofarm_path_cost_cache_size or 0) or 0
    if now_time >= (tonumber(script._autofarm_path_cost_cache_size_next or 0) or 0) then
        cache_size = 0
        for _ in pairs(path_cost_cache) do
            cache_size = cache_size + 1
        end
        script._autofarm_path_cost_cache_size = cache_size
        script._autofarm_path_cost_cache_size_next = now_time + 0.45
    end
    script.autofarm_metric_set("queue_active", queue_active)
    script.autofarm_metric_set("path_cache_entries", cache_size)
    script.autofarm_metric_set("heal_active", heal_active_count)
    script.autofarm_metric_set("path_eval_dist_calls", path_eval_dist_calls)
    script.autofarm_metric_set("path_eval_reuse_hits", path_eval_reuse_hits)
    return issued
end



function script.draw_autofarm_map_panel(local_hero, meepos, now)
    if script._autofarm_map_visible ~= true then
        return
    end
    if not Render or not Render.Text or not Render.FilledRect or not Render.TextSize then
        return
    end
    local scale = autofarm_get_ui_number(ui.autofarm_map_scale, 100) / 100.0
    if scale < 0.6 then
        scale = 0.6
    elseif scale > 2.2 then
        scale = 2.2
    end
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local ui_font = script._autofarm_ui_font
    if ui_font == nil and Render and Render.LoadFont then
        local font_flags = (Enum and Enum.FontCreate and (Enum.FontCreate.FONTFLAG_ANTIALIAS or Enum.FontCreate.FONTFLAG_NONE or 0)) or 0
        local font_weight = (Enum and Enum.FontWeight and (Enum.FontWeight.REGULAR or Enum.FontWeight.NORMAL or Enum.FontWeight.MEDIUM or Enum.FontWeight.BOLD)) or 0
        local loaded = safe_call(Render.LoadFont, "Verdana", font_flags, font_weight)
        script._autofarm_ui_font = loaded or false
        ui_font = loaded
    elseif ui_font == false then
        ui_font = nil
    end
    ui_font = ui_font or font
    local map_title_size = math.max(13, math.floor(tactical_font_size * 1.12))
    local map_tab_size = math.max(12, math.floor(tactical_font_size * 1.02))
    local points = get_all_autofarm_points()
    local selected_set = script._autofarm_selected_points or {}
    script._autofarm_selected_points = selected_set
    local anim = script._autofarm_point_anim or {}
    script._autofarm_point_anim = anim
    local radiant_active = script._autofarm_settings_side_r
    local dire_active = script._autofarm_settings_side_d
    if radiant_active == nil or dire_active == nil then
        local legacy_side = script._autofarm_settings_side or "r"
        radiant_active = legacy_side ~= "d"
        dire_active = legacy_side == "d"
    end
    if radiant_active == nil then radiant_active = false end
    if dire_active == nil then dire_active = false end
    local function set_side_selection(points_list, side, enabled)
        if not points_list or not side then
            return
        end
        for i = 1, #points_list do
            local p = points_list[i]
            if p and p.id and p.side == side then
                selected_set[p.id] = enabled == true
            end
        end
    end
    local function store_side_selection_state()
        script._autofarm_settings_side_r = radiant_active == true
        script._autofarm_settings_side_d = dire_active == true
        if dire_active == true and radiant_active ~= true then
            script._autofarm_settings_side = "d"
        else
            script._autofarm_settings_side = "r"
        end
    end
    store_side_selection_state()
    local slider_x = autofarm_get_ui_number(ui.autofarm_map_x, 28)
    local slider_y = autofarm_get_ui_number(ui.autofarm_map_y, 820)
    if script._autofarm_map_pos_y == nil then script._autofarm_map_pos_y = slider_y end
    local panel_w = math.floor(360 * scale) -- slightly wider to fit map edge-to-edge feel
    local header_h = math.floor(38 * scale)
    local pad = math.max(2, math.floor(4 * scale))
    local footer_h = 0
    local map_size = panel_w - (pad * 2)
    local panel_h = header_h + pad + map_size + pad + footer_h
    local screen = Render.ScreenSize and Render.ScreenSize() or nil
    script._autofarm_map_pos_migrated = script._autofarm_map_pos_migrated or false
    if screen and script._autofarm_map_pos_migrated ~= true then
        local cur_x = tonumber(script._autofarm_map_pos_x)
        if (not cur_x) or cur_x <= 64 then
            script._autofarm_map_pos_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 24)
        end
        script._autofarm_map_pos_migrated = true
    end
    if script._autofarm_map_pos_x == nil then
        if screen then
            local default_right = math.max(0, (tonumber(screen.x) or 0) - panel_w - 24)
            script._autofarm_map_pos_x = default_right
        else
            script._autofarm_map_pos_x = slider_x
        end
    end
    local px = tonumber(script._autofarm_map_pos_x) or slider_x
    local py = tonumber(script._autofarm_map_pos_y) or slider_y
    if screen then
        local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
        local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
        px = clamp_value(px, 0, max_x)
        py = clamp_value(py, 0, max_y)
        script._autofarm_map_pos_x = px
        script._autofarm_map_pos_y = py
    end
    local mouse1 = get_mouse1_code()
    local click_once_left = mouse1 and safe_call(Input.IsKeyDownOnce, mouse1) == true
    local mouse_down_left = mouse1 and safe_call(Input.IsKeyDown, mouse1) == true
    local input_captured = safe_call(Input.IsInputCaptured) == true
    local cursor_x, cursor_y = get_cursor_position()
    local drag_header_w = panel_w - math.floor(140 * scale)
    local hover_drag_header = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, px, py, drag_header_w, header_h) == true
    if input_captured then
        script._autofarm_map_drag_active = false
    end
    if (not input_captured) and click_once_left and hover_drag_header and cursor_x and cursor_y then
        script._autofarm_map_drag_active = true
        script._autofarm_map_drag_offset_x = cursor_x - px
        script._autofarm_map_drag_offset_y = cursor_y - py
    end
    if script._autofarm_map_drag_active then
        if input_captured or (not mouse_down_left) or (not cursor_x) or (not cursor_y) then
            script._autofarm_map_drag_active = false
        else
            local nx = math.floor((cursor_x - (script._autofarm_map_drag_offset_x or 0)) + 0.5)
            local ny = math.floor((cursor_y - (script._autofarm_map_drag_offset_y or 0)) + 0.5)
            if screen then
                local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
                local max_y = math.max(0, (tonumber(screen.y) or 0) - panel_h - 2)
                nx = clamp_value(nx, 0, max_x)
                ny = clamp_value(ny, 0, max_y)
            end
            px = nx
            py = ny
            script._autofarm_map_pos_x = nx
            script._autofarm_map_pos_y = ny
        end
    end
    -- helpers
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    local function blend_rgb(r1, g1, b1, r2, g2, b2, t)
        return math.floor(lerp(r1, r2, t) + 0.5), math.floor(lerp(g1, g2, t) + 0.5), math.floor(lerp(b1, b2, t) + 0.5)
    end
    -- panel shell
    local panel_bg = Color(14, 18, 26, 200)
    local header_bg = Color(26, 30, 40, 225)
    local border = Color(178, 208, 240, 128)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), panel_bg, 6, Enum.DrawFlags.RoundCornersAll)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + header_h), header_bg, 6, Enum.DrawFlags.RoundCornersAll)
    if Render.Rect then
        Render.Rect(Vec2(px, py), Vec2(px + panel_w, py + panel_h), border, 6, Enum.DrawFlags.RoundCornersAll, 0.9)
    end
    -- title + side tabs
    local title = "Meepo Farm Settings"
    local title_size = script._autofarm_get_text_size_cached(ui_font, map_title_size, title, now_time)
    Render.Text(ui_font, map_title_size, title, Vec2(px + pad, py + math.floor((header_h - map_title_size) * 0.5)), Color(214, 226, 238, 238))
    local side_btn_w = math.max(76, math.floor(84 * scale))
    local side_btn_h = math.max(22, math.floor(24 * scale))
    local side_btn_y = py + math.floor((header_h - side_btn_h) * 0.5)
    local side_gap = math.max(4, math.floor(6 * scale))
    local side_btn_x = px + pad + title_size.x + math.floor(12 * scale)
    local rad_x = side_btn_x
    local dire_x = side_btn_x + side_btn_w + side_gap
    local hover_radiant = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, rad_x, side_btn_y, side_btn_w, side_btn_h) == true
    local hover_dire = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, dire_x, side_btn_y, side_btn_w, side_btn_h) == true
    local function draw_side_btn(x, label, active, hover, active_col)
        local base = active and active_col or Color(40, 46, 58, 205)
        if hover then
            base = Color(base.r + 18, base.g + 18, base.b + 18, math.min(255, (base.a or 205) + 10))
        end
        Render.FilledRect(Vec2(x, side_btn_y), Vec2(x + side_btn_w, side_btn_y + side_btn_h), base, 4, Enum.DrawFlags.RoundCornersAll)
        if Render.Rect then
            Render.Rect(Vec2(x, side_btn_y), Vec2(x + side_btn_w, side_btn_y + side_btn_h), Color(190, 210, 240, 120), 4, Enum.DrawFlags.RoundCornersAll, 0.7)
        end
        local text_col = active and Color(235, 241, 247, 240) or Color(192, 204, 218, 238)
        local label_size = script._autofarm_get_text_size_cached(ui_font, map_tab_size, label, now_time)
        Render.Text(ui_font, map_tab_size, label, Vec2(x + math.floor((side_btn_w - label_size.x) * 0.5), side_btn_y + math.floor((side_btn_h - map_tab_size) * 0.5)), text_col)
    end
    draw_side_btn(rad_x, "Radiant", radiant_active, hover_radiant, Color(180, 88, 88, 230))
    draw_side_btn(dire_x, "Dire", dire_active, hover_dire, Color(94, 114, 166, 230))
    if click_once_left and (not input_captured) then
        if hover_radiant then
            local new_state = not (radiant_active == true)
            radiant_active = new_state
            set_side_selection(points, "r", new_state)
            store_side_selection_state()
        elseif hover_dire then
            local new_state = not (dire_active == true)
            dire_active = new_state
            set_side_selection(points, "d", new_state)
            store_side_selection_state()
        end
    end
    -- map body
    local map_x = px + pad
    local map_y = py + header_h + pad
    local map_size_i = map_size
    local map_image = autofarm_get_map_image()
    if map_image and Render.Image then
        Render.Image(map_image, Vec2(map_x, map_y), Vec2(map_size_i, map_size_i), Color(255, 255, 255, 255), 0, Enum.DrawFlags.None, AUTOFARM_MAP_UV_MIN, AUTOFARM_MAP_UV_MAX)
    else
        Render.FilledRect(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(42, 56, 78, 196), 4, Enum.DrawFlags.RoundCornersAll)
        if Render.Line then
            Render.Line(Vec2(map_x, map_y + map_size_i), Vec2(map_x + map_size_i, map_y), Color(146, 174, 220, 110), 1.1)
            Render.Line(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(132, 162, 210, 84), 1.0)
        end
    end
    if (not map_image) and Render.Rect then
        Render.Rect(Vec2(map_x, map_y), Vec2(map_x + map_size_i, map_y + map_size_i), Color(170, 205, 244, 122), 4, Enum.DrawFlags.RoundCornersAll, 0.8)
    end
    if (not map_image) and Render.Line then
        for i = 1, 3 do
            local t = i / 4.0
            local gx = map_x + (map_size_i * t)
            local gy = map_y + (map_size_i * t)
            Render.Line(Vec2(gx, map_y), Vec2(gx, map_y + map_size_i), Color(122, 150, 194, 58), 1.0)
            Render.Line(Vec2(map_x, gy), Vec2(map_x + map_size_i, gy), Color(122, 150, 194, 58), 1.0)
        end
    end
    local hover_map = cursor_x and cursor_y and safe_call(Input.IsCursorInRect, map_x, map_y, map_size_i, map_size_i) == true
    local point_by_id = {}
    local point_render = {}
    for i = 1, #points do
        local point = points[i]
        if point and point.id and point.nx ~= nil and point.ny ~= nil then
            local sx, sy = autofarm_map_to_screen(point.nx, point.ny, map_x, map_y, map_size_i)
            local rec = {
                point = point,
                id = point.id,
                sx = sx,
                sy = sy,
            }
            point_render[#point_render + 1] = rec
            point_by_id[tostring(point.id)] = rec
        end
    end
    local marker_radius_base = math.max(7, math.floor(9 * scale))
    local hover_radius_sq = (marker_radius_base + 7) * (marker_radius_base + 7)
    local hovered_point_id = nil
    local hovered_dist = nil
    if hover_map and cursor_x and cursor_y then
        for i = 1, #point_render do
            local rec = point_render[i]
            local sx, sy = rec.sx, rec.sy
            local dx = (cursor_x - sx)
            local dy = (cursor_y - sy)
            local dist_sq = dx * dx + dy * dy
            if dist_sq <= hover_radius_sq then
                if (not hovered_dist) or dist_sq < hovered_dist then
                    hovered_dist = dist_sq
                    hovered_point_id = rec.id
                end
            end
        end
    end
    local ui_wave_ttl = tonumber((script._autofarm_cfg and script._autofarm_cfg.UI_WAVE_MARKER_CACHE_TTL) or 0.16) or 0.16
    local wave_markers, ally_towers, local_team = script.get_cached_autofarm_wave_markers(local_hero, now, ui_wave_ttl)
    script._autofarm_ui_icons = script._autofarm_ui_icons or {}
    local ui_icons = script._autofarm_ui_icons
    if ui_icons.wave_creep == nil then
        ui_icons.wave_creep = autofarm_get_image_handle("panorama/images/hud/reborn/minimap_creepicon_png.vtex_c")
            or autofarm_get_image_handle("panorama/images/hud/reborn/minimap_creep_icon_png.vtex_c")
            or autofarm_get_image_handle("panorama/images/minimap/minimap_creepicon_png.vtex_c")
            or false
    end
    local wave_icon = ui_icons.wave_creep ~= false and ui_icons.wave_creep or nil
    local wave_icon_size = math.max(9, math.floor(12 * scale))
    local wave_icon_half = wave_icon_size * 0.5
    -- lines from meepos to camps (kept)
    if Render.Line and meepos and #meepos > 0 then
        local assignments = script._autofarm_assignment_by_meepo or {}
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local meepo_key = get_entity_key(meepo)
                local assigned_ref = assignments[meepo_key]
                local assigned_id = (type(assigned_ref) == "table" and assigned_ref.id) or assigned_ref
                local camp_point = assigned_id and point_by_id[tostring(assigned_id)] or nil
                if camp_point and camp_point.sx ~= nil and camp_point.sy ~= nil then
                    local pos = safe_call(Entity.GetAbsOrigin, meepo)
                    local nx, ny = script.autofarm_world_to_norm(pos)
                    if nx and ny then
                        local from_x, from_y = autofarm_map_to_screen(nx, ny, map_x, map_y, map_size_i)
                        local to_x, to_y = camp_point.sx, camp_point.sy
                        Render.Line(Vec2(from_x, from_y), Vec2(to_x, to_y), Color(132, 206, 255, 198), 1.2)
                    end
                end
            end
        end
    end
    -- meepo dots (kept)
    if meepos and #meepos > 0 then
        if ui_icons.meepo == nil then
            ui_icons.meepo = autofarm_get_image_handle("panorama/images/heroes/icons/npc_dota_hero_meepo_png.vtex_c") or false
        end
        local meepo_icon = ui_icons.meepo ~= false and ui_icons.meepo or nil
        local meepo_icon_size = math.max(10, math.floor(14 * scale))
        local meepo_icon_half = meepo_icon_size * 0.5
        for i = 1, #meepos do
            local meepo = meepos[i]
            if meepo and Entity.IsAlive(meepo) then
                local pos = safe_call(Entity.GetAbsOrigin, meepo)
                local nx, ny = script.autofarm_world_to_norm(pos)
                if nx and ny then
                    local sx, sy = autofarm_map_to_screen(nx, ny, map_x, map_y, map_size_i)
                    local is_main = (meepo == local_hero)
                    local col = is_main and Color(255, 210, 120, 245) or Color(125, 215, 255, 235)
                    if meepo_icon and Render.Image then
                        Render.Image(meepo_icon, Vec2(sx - meepo_icon_half, sy - meepo_icon_half), Vec2(meepo_icon_size, meepo_icon_size), col, 2)
                    else
                        if Render.Circle then
                            Render.Circle(Vec2(sx, sy), math.max(3, marker_radius_base - 4), col, 2.0)
                        end
                        Render.FilledRect(Vec2(sx - 1, sy - 1), Vec2(sx + 1, sy + 1), col, 1, Enum.DrawFlags.RoundCornersAll)
                    end
                end
            end
        end
    end
    -- allied tower mini-icons (alive towers only)
    if ally_towers and #ally_towers > 0 then
        local tower_core_half = math.max(5, math.floor(6 * scale))
        local tower_cap_half = math.max(3, math.floor(3 * scale))
        local tower_col = Color(255, 228, 120, 232)
        local tower_cap = Color(255, 246, 186, 238)
        local tower_text_col = Color(34, 25, 8, 240)
        for i = 1, #ally_towers do
            local tower = ally_towers[i]
            if tower and tower.nx and tower.ny then
                local sx, sy = autofarm_map_to_screen(tower.nx, tower.ny, map_x, map_y, map_size_i)
                if Render.FilledRect then
                    Render.FilledRect(
                        Vec2(sx - tower_core_half, sy - tower_core_half),
                        Vec2(sx + tower_core_half, sy + tower_core_half),
                        tower_col,
                        math.max(1, tower_core_half - 1),
                        Enum.DrawFlags.RoundCornersAll
                    )
                    Render.FilledRect(
                        Vec2(sx - tower_cap_half, sy - tower_core_half - tower_cap_half),
                        Vec2(sx + tower_cap_half, sy - tower_core_half + 1),
                        tower_cap,
                        math.max(1, tower_cap_half - 1),
                        Enum.DrawFlags.RoundCornersAll
                    )
                end
                if Render.Rect then
                    Render.Rect(
                        Vec2(sx - tower_core_half - 1, sy - tower_core_half - 1),
                        Vec2(sx + tower_core_half + 1, sy + tower_core_half + 1),
                        Color(28, 32, 42, 180),
                        math.max(1, tower_core_half),
                        Enum.DrawFlags.RoundCornersAll,
                        1.0
                    )
                end
                if Render.Text then
                    local label_size = math.max(9, math.floor(9 * scale))
                    Render.Text(ui_font, label_size, "T", Vec2(sx - math.floor(label_size * 0.32), sy - math.floor(label_size * 0.55)), tower_text_col)
                end
            end
        end
    end
    -- ally/enemy hero icons on map (excluding meepo units, already drawn above)
    do
        local hero_entries
        hero_entries, local_team = script.get_cached_autofarm_map_heroes(local_hero, now)
        local hero_icon_size = math.max(9, math.floor(12 * scale))
        local hero_icon_half = hero_icon_size * 0.5
        for i = 1, #hero_entries do
            local entry = hero_entries[i]
            if entry and entry.nx and entry.ny then
                local sx, sy = autofarm_map_to_screen(entry.nx, entry.ny, map_x, map_y, map_size_i)
                if entry.icon and Render.Image then
                    Render.Image(entry.icon, Vec2(sx - hero_icon_half, sy - hero_icon_half), Vec2(hero_icon_size, hero_icon_size), entry.tint or Color(255, 255, 255, 245), 2)
                elseif Render.Circle then
                    Render.Circle(Vec2(sx, sy), math.max(3, hero_icon_half - 2), entry.tint or Color(255, 255, 255, 245), 2.2)
                end
            end
        end
    end
    -- wave markers (non-clickable creep icon style)
    for i = 1, #wave_markers do
        local wave = wave_markers[i]
        local sx, sy = autofarm_map_to_screen(wave.nx, wave.ny, map_x, map_y, map_size_i)
        if local_team == nil then
            local_team = tonumber(safe_call(Entity.GetTeamNum, local_hero) or -1) or -1
        end
        local is_ally_wave = (local_team < 0) or (wave.team == local_team)
        local is_threat = wave.threatens_ally_tower == true
        local icon_tint = nil
        if is_threat then
            icon_tint = Color(255, 212, 118, 246)
        else
            icon_tint = is_ally_wave and Color(105, 235, 190, 232) or Color(255, 128, 128, 232)
        end
        if is_threat and Render.Line and wave.tower and wave.tower.nx and wave.tower.ny then
            local tx, ty = autofarm_map_to_screen(wave.tower.nx, wave.tower.ny, map_x, map_y, map_size_i)
            Render.Line(Vec2(sx, sy), Vec2(tx, ty), Color(255, 188, 96, 220), 1.3)
        end
        local icon_half = math.max(4, math.floor(wave_icon_size * 0.45))
        if Render.FilledRect then
            Render.FilledRect(
                Vec2(sx - icon_half, sy - icon_half),
                Vec2(sx + icon_half, sy + icon_half),
                Color(16, 22, 30, 210),
                math.max(2, icon_half - 1),
                Enum.DrawFlags.RoundCornersAll
            )
            local core_half = math.max(2, math.floor(icon_half * 0.55))
            Render.FilledRect(
                Vec2(sx - core_half, sy - core_half),
                Vec2(sx + core_half, sy + core_half),
                icon_tint,
                math.max(1, core_half - 1),
                Enum.DrawFlags.RoundCornersAll
            )
        end
        if wave_icon and Render.Image then
            Render.Image(
                wave_icon,
                Vec2(sx - wave_icon_half, sy - wave_icon_half),
                Vec2(wave_icon_size, wave_icon_size),
                icon_tint,
                2
            )
        elseif Render.Text then
            local label_size = math.max(8, math.floor(9 * scale))
            Render.Text(ui_font, label_size, "C", Vec2(sx - math.floor(label_size * 0.28), sy - math.floor(label_size * 0.5)), Color(224, 232, 242, 230))
        end
        if is_threat and Render.Rect then
            local threat_half = math.max(6, math.floor(wave_icon_size * 0.55))
            Render.Rect(
                Vec2(sx - threat_half, sy - threat_half),
                Vec2(sx + threat_half, sy + threat_half),
                Color(255, 205, 124, 225),
                math.max(2, threat_half - 1),
                Enum.DrawFlags.RoundCornersAll,
                1.1
            )
        end
    end
    -- camp circles with smooth hover/select and color blend
    for i = 1, #point_render do
        local rec = point_render[i]
        local point = rec.point
        local sx, sy = rec.sx, rec.sy
        local selected = selected_set[point.id] == true
        local state = anim[point.id] or { scale = 1.0, sel = selected and 1 or 0 }
        local target_sel = selected and 1 or 0
        state.sel = state.sel + (target_sel - state.sel) * 0.18
        local target_scale = 1.0 + (0.12 * state.sel)
        if hovered_point_id == point.id then
            target_scale = target_scale + 0.14
        end
        state.scale = state.scale + (target_scale - state.scale) * 0.18
        anim[point.id] = state

        local radius = marker_radius_base * state.scale
        local base_col = Color(6, 10, 14, 230)
        if point.side == "d" then base_col = Color(10, 14, 20, 230) end

        -- ring color blends smoothly from red -> high-contrast green as state.sel moves 0..1
        local ring_r, ring_g, ring_b = blend_rgb(196, 76, 76, 70, 230, 110, state.sel)
        if hovered_point_id == point.id then
            ring_r = math.min(255, ring_r + 18)
            ring_g = math.min(255, ring_g + 18)
            ring_b = math.min(255, ring_b + 18)
        end
        local ring_color = Color(ring_r, ring_g, ring_b, 250)

        -- keep fill/background constant for on/off; only ring/dot change
        local fill_col = Color(base_col.r + 6, base_col.g + 8, base_col.b + 10, 205)

        local center = Vec2(sx, sy)
        if Render.Circle then
            -- single outline
            Render.Circle(center, radius, ring_color, 4.0)
        end
        -- fill
        if Render.FilledRect then
            local fill_rad = math.max(2, radius - 1)
            Render.FilledRect(
                Vec2(sx - fill_rad, sy - fill_rad),
                Vec2(sx + fill_rad, sy + fill_rad),
                fill_col,
                fill_rad,
                Enum.DrawFlags.RoundCornersAll
            )
        end
        -- mini dot appears only on green/selected state
        if Render.FilledRect and state.sel > 0.55 then
            -- keep hover/selection scaling perfectly in sync with outer ring
            local mini_rad = math.max(4, radius * 0.55)
            local mini_alpha = math.floor(245 * state.sel)
            local mini_col = Color(ring_r, ring_g, ring_b, mini_alpha)
            Render.FilledRect(
                Vec2(sx - mini_rad, sy - mini_rad),
                Vec2(sx + mini_rad, sy + mini_rad),
                mini_col,
                mini_rad,
                Enum.DrawFlags.RoundCornersAll
            )
        end
    end

    local metrics = script._autofarm_metrics or {}
    local started_at = tonumber(metrics.started_at or now_time) or now_time
    local uptime = math.max(0, now_time - started_at)
    local m_orders = tonumber(metrics.orders_sent or 0) or 0
    local m_deduped = tonumber(metrics.orders_deduped or 0) or 0
    local m_coalesced = tonumber(metrics.orders_coalesced or 0) or 0
    local m_q_hits = tonumber(metrics.queue_hits or 0) or 0
    local m_q_miss = tonumber(metrics.queue_misses or 0) or 0
    local m_q_plan = tonumber(metrics.queue_plans or 0) or 0
    local m_q_active = tonumber(metrics.queue_active or 0) or 0
    local m_repicks = tonumber(metrics.repicks or 0) or 0
    local m_path_block = tonumber(metrics.path_block_events or 0) or 0
    local m_path_cache = tonumber(metrics.path_cache_entries or 0) or 0
    local metrics_lines = {
        string.format("AF %.0fs | O:%d D:%d C:%d", uptime, m_orders, m_deduped, m_coalesced),
        string.format("Q H:%d M:%d P:%d A:%d", m_q_hits, m_q_miss, m_q_plan, m_q_active),
        string.format("R:%d | Path B:%d C:%d", m_repicks, m_path_block, m_path_cache),
    }
    local m_font_size = math.max(10, math.floor(tactical_font_size * 0.95))
    local m_line_h = math.max(10, m_font_size + 1)
    local m_pad = math.max(3, math.floor(4 * scale))
    local m_w = 0
    for i = 1, #metrics_lines do
        local ts = script._autofarm_get_text_size_cached(ui_font, m_font_size, metrics_lines[i], now_time)
        if ts and ts.x and ts.x > m_w then
            m_w = ts.x
        end
    end
    local m_h = (#metrics_lines * m_line_h) + (m_pad * 2)
    local m_x = map_x + m_pad
    local m_y = (map_y + map_size_i) - m_h - m_pad
    if Render.FilledRect then
        Render.FilledRect(
            Vec2(m_x - 2, m_y - 1),
            Vec2(m_x + m_w + (m_pad * 2), m_y + m_h),
            Color(10, 16, 22, 188),
            4,
            Enum.DrawFlags.RoundCornersAll
        )
    end
    for i = 1, #metrics_lines do
        Render.Text(
            ui_font,
            m_font_size,
            metrics_lines[i],
            Vec2(m_x + m_pad - 1, m_y + m_pad + ((i - 1) * m_line_h)),
            Color(188, 210, 228, 238)
        )
    end

    local can_click_map = (not input_captured) and (not script._autofarm_map_drag_active)
    if can_click_map and click_once_left and hover_map and cursor_x and cursor_y then
        if hovered_point_id then
            selected_set[hovered_point_id] = not (selected_set[hovered_point_id] == true)
        end
    end
end

function script.draw_autofarm_performance_panel(local_hero, meepos, now)
    if not ui.autofarm_perf_panel or not ui.autofarm_perf_panel.Get or ui.autofarm_perf_panel:Get() ~= true then
        return
    end
    if not Render or not Render.Text or not Render.FilledRect or not Render.TextSize then
        return
    end
    local scale = autofarm_get_ui_number(ui.autofarm_perf_scale, 100) / 100.0
    if scale < 0.6 then
        scale = 0.6
    elseif scale > 2.2 then
        scale = 2.2
    end
    local px = autofarm_get_ui_number(ui.autofarm_perf_x, 420)
    local py = autofarm_get_ui_number(ui.autofarm_perf_y, 840)
    local now_time = tonumber(now or get_game_time() or 0) or 0
    local ui_font = script._autofarm_ui_font
    if ui_font == nil and Render and Render.LoadFont then
        local font_flags = (Enum and Enum.FontCreate and (Enum.FontCreate.FONTFLAG_ANTIALIAS or Enum.FontCreate.FONTFLAG_NONE or 0)) or 0
        local font_weight = (Enum and Enum.FontWeight and (Enum.FontWeight.REGULAR or Enum.FontWeight.NORMAL or Enum.FontWeight.MEDIUM or Enum.FontWeight.BOLD)) or 0
        local loaded = safe_call(Render.LoadFont, "Verdana", font_flags, font_weight)
        script._autofarm_ui_font = loaded or false
        ui_font = loaded
    elseif ui_font == false then
        ui_font = nil
    end
    ui_font = ui_font or font
    local metrics = script._autofarm_metrics or {}
    local started_at = tonumber(metrics.started_at or now_time) or now_time
    local uptime = math.max(0, now_time - started_at)
    local last_tick = tonumber(metrics.last_tick or now_time) or now_time
    local tick_age = math.max(0, now_time - last_tick)
    local active_meepos = tonumber(metrics.active_meepos or (meepos and #meepos or 0)) or 0
    local farm_meepos = tonumber(metrics.farm_meepos or 0) or 0
    local selected_camps = tonumber(metrics.selected_camps or 0) or 0
    local orders_sent = tonumber(metrics.orders_sent or 0) or 0
    local orders_deduped = tonumber(metrics.orders_deduped or 0) or 0
    local orders_coalesced = tonumber(metrics.orders_coalesced or 0) or 0
    local heal_orders = tonumber(metrics.heal_orders or 0) or 0
    local queue_hits = tonumber(metrics.queue_hits or 0) or 0
    local queue_miss = tonumber(metrics.queue_misses or 0) or 0
    local queue_plans = tonumber(metrics.queue_plans or 0) or 0
    local queue_active = tonumber(metrics.queue_active or 0) or 0
    local repicks = tonumber(metrics.repicks or 0) or 0
    local path_blocks = tonumber(metrics.path_block_events or 0) or 0
    local path_wave_returns = tonumber(metrics.path_wave_returns or 0) or 0
    local path_cache = tonumber(metrics.path_cache_entries or 0) or 0
    local heal_active = tonumber(metrics.heal_active or 0) or 0
    local heal_resumes = tonumber(metrics.heal_resumes or 0) or 0
    local hp_retreat = tonumber(metrics.hp_retreat_pct or AUTOFARM_LOW_HP_RETREAT_PCT) or AUTOFARM_LOW_HP_RETREAT_PCT
    local hp_resume = tonumber(metrics.hp_resume_pct or AUTOFARM_HEAL_EXIT_PCT) or AUTOFARM_HEAL_EXIT_PCT
    local q_npcs_getall = tonumber(metrics.q_npcs_getall or 0) or 0
    local q_gridnav = tonumber(metrics.q_gridnav_traversable or 0) or 0
    local q_gridnav_link = tonumber(metrics.q_gridnav_traversable_from_to or 0) or 0

    local title = "AutoFarm Performance"
    local lines = {
        string.format("Uptime %.0fs | Tick Age %.2f", uptime, tick_age),
        string.format("Meepos %d | Farming %d | Camps %d", active_meepos, farm_meepos, selected_camps),
        string.format("Orders %d | Deduped %d | Coalesced %d", orders_sent, orders_deduped, orders_coalesced),
        string.format("HealOrders %d", heal_orders),
        string.format("Queue H:%d M:%d P:%d A:%d", queue_hits, queue_miss, queue_plans, queue_active),
        string.format("Repicks %d | PathBlocks %d | Path->Camp %d", repicks, path_blocks, path_wave_returns),
        string.format("PathCache %d | Heal Active %d | HealResume %d", path_cache, heal_active, heal_resumes),
        string.format("Q NPCs %d | Grid %d/%d", q_npcs_getall, q_gridnav, q_gridnav_link),
        string.format("Retreat <%.0f%% | Resume %.0f%% HP+Mana", hp_retreat, hp_resume),
    }
    local perf_af_avg = tonumber(metrics.perf_autofarm_logic_avg_ms or 0) or 0
    local perf_af_p95 = tonumber(metrics.perf_autofarm_logic_p95_ms or 0) or 0
    local perf_map_avg = tonumber(metrics.perf_map_draw_avg_ms or 0) or 0
    local perf_map_p95 = tonumber(metrics.perf_map_draw_p95_ms or 0) or 0
    local perf_world_avg = tonumber(metrics.perf_world_status_draw_avg_ms or 0) or 0
    local perf_world_p95 = tonumber(metrics.perf_world_status_draw_p95_ms or 0) or 0
    lines[#lines + 1] = string.format("Perf AF %.2f/%.2f | Map %.2f/%.2f", perf_af_avg, perf_af_p95, perf_map_avg, perf_map_p95)
    lines[#lines + 1] = string.format("Perf World %.2f/%.2f", perf_world_avg, perf_world_p95)
    local timeline_lines = script.autofarm_collect_timeline_lines(meepos, now_time, 4)
    if #timeline_lines > 0 then
        lines[#lines + 1] = "Timeline"
        for i = 1, #timeline_lines do
            lines[#lines + 1] = timeline_lines[i]
        end
    end
    local title_size = math.max(13, math.floor(tactical_font_size * 1.08))
    local line_size = math.max(11, math.floor(tactical_font_size * 0.96))
    local pad = math.max(4, math.floor(6 * scale))
    local line_h = math.max(10, line_size + 2)
    local w = script._autofarm_get_text_size_cached(ui_font, title_size, title, now_time).x or 0
    for i = 1, #lines do
        local lw = script._autofarm_get_text_size_cached(ui_font, line_size, lines[i], now_time).x or 0
        if lw > w then
            w = lw
        end
    end
    local header_h = title_size + pad + 2
    local h = header_h + (#lines * line_h) + pad + 2
    local panel_w = w + (pad * 2)
    local screen = Render.ScreenSize and Render.ScreenSize() or nil
    if screen then
        local max_x = math.max(0, (tonumber(screen.x) or 0) - panel_w - 2)
        local max_y = math.max(0, (tonumber(screen.y) or 0) - h - 2)
        px = clamp_value(px, 0, max_x)
        py = clamp_value(py, 0, max_y)
    end

    local bg = Color(14, 20, 28, 198)
    local header_bg = Color(24, 32, 42, 216)
    local border = Color(148, 178, 210, 118)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + h), bg, 6, Enum.DrawFlags.RoundCornersAll)
    Render.FilledRect(Vec2(px, py), Vec2(px + panel_w, py + header_h), header_bg, 6, Enum.DrawFlags.RoundCornersAll)
    if Render.Rect then
        Render.Rect(Vec2(px, py), Vec2(px + panel_w, py + h), border, 6, Enum.DrawFlags.RoundCornersAll, 0.9)
    end
    Render.Text(ui_font, title_size, title, Vec2(px + pad, py + math.floor((header_h - title_size) * 0.5)), Color(214, 224, 236, 240))
    for i = 1, #lines do
        Render.Text(
            ui_font,
            line_size,
            lines[i],
            Vec2(px + pad, py + header_h + ((i - 1) * line_h)),
            Color(184, 206, 226, 236)
        )
    end
end

function script.draw_autofarm_world_status(local_hero, meepos, now)
    if not Render or not Render.WorldToScreen or not Render.Text then
        return
    end
    local selected = script.get_autofarm_selected_locations and script.get_autofarm_selected_locations() or {}
    if #selected == 0 then
        return
    end
    local presence = script._autofarm_camp_presence or {}
    local camp_status = script._autofarm_camp_status or {}
    local raw_now_time = tonumber(now or get_game_time() or 0) or 0
    local now_time = get_neutral_clock_time(raw_now_time)
    for i = 1, #selected do
        local camp = selected[i]
        if camp and camp.id then
            local state = presence[camp.id]
            local status_state = camp_status[camp.id]
            local center = (state and state.center) or get_camp_center(camp)
            if center then
                local pos = center + Vector(0, 0, AUTOFARM_CAMP_STATUS_TEXT_OFFSET)
                local screen, visible = Render.WorldToScreen(pos)
                if visible and screen then
                    local status_name = (status_state and status_state.state) or (state and state.status) or "ready"
                    local remembered_ready = status_state and status_state.remembered_ready == true
                    local has = state and state.has == true
                    if status_name == "unseen" and remembered_ready then
                        status_name = "ready"
                    end
                    local label = "Ready"
                    local col = Color(96, 230, 130, 245)
                    if status_name == "unseen" and not has then
                        label = "Ready | Unseen"
                        col = Color(120, 215, 255, 245)
                    elseif not (has or status_name == "ready") then
                        local eta = math.max(0, get_next_neutral_spawn_time(now_time) - now_time)
                        if status_name == "farmed" then
                            label = "Farmed (" .. format_time_short(eta) .. ")"
                            col = Color(255, 170, 95, 240)
                        else
                            label = "Empty (" .. format_time_short(eta) .. ")"
                            col = Color(240, 200, 90, 240)
                        end
                    end
                    Render.Text(font, tactical_font_size, label, Vec2(screen.x - 18, screen.y - tactical_font_size), col)
                end
            end
        end
    end
end
function script.has_meepo_clones()
    collect_meepos()
    local cache = script._meepo_collect_cache or {}
    return (tonumber(cache.clone_count or 0) or 0) > 0
end
function script.get_autofarm_neutral_creep_snapshot(now_time)
    local t = tonumber(now_time or get_game_time() or 0) or 0
    script._autofarm_neutral_cache = script._autofarm_neutral_cache or { t = -9999, entries = {} }
    local cache = script._autofarm_neutral_cache
    local cache_t = tonumber(cache.t or -9999) or -9999
    local ttl = math.max(0.05, (tonumber(AUTOFARM_LOGIC_TICK or 0.08) or 0.08) * 0.95)
    if cache.entries and (t - cache_t) <= ttl then
        if not script._autofarm_neutral_spatial or script._autofarm_neutral_spatial.entries ~= cache.entries then
            local cell_size = tonumber((script._autofarm_cfg and script._autofarm_cfg.NEUTRAL_SPATIAL_CELL) or 760) or 760
            if cell_size < 180 then
                cell_size = 180
            end
            local bins = {}
            local entries = cache.entries or {}
            for i = 1, #entries do
                local rec = entries[i]
                local pos = rec and rec.pos or nil
                if pos then
                    local cx = math.floor((tonumber(pos.x or 0) or 0) / cell_size)
                    local cy = math.floor((tonumber(pos.y or 0) or 0) / cell_size)
                    local key = tostring(cx) .. ":" .. tostring(cy)
                    local bucket = bins[key]
                    if not bucket then
                        bucket = {}
                        bins[key] = bucket
                    end
                    bucket[#bucket + 1] = rec
                end
            end
            script._autofarm_neutral_spatial = { t = cache_t, cell = cell_size, bins = bins, entries = entries }
        end
        return cache.entries
    end
    local creep_flag = Enum and Enum.UnitTypeFlags and Enum.UnitTypeFlags.TYPE_CREEP or nil
    local candidates = {}
    if NPCs and NPCs.GetAll then
        script.autofarm_metric_inc("q_npcs_getall", 1)
        candidates = creep_flag and (safe_call(NPCs.GetAll, creep_flag) or {}) or (safe_call(NPCs.GetAll) or {})
    end
    local out = {}
    for i = 1, #candidates do
        local npc = candidates[i]
        if npc and Entity.IsAlive(npc) and (NPC.IsNeutral and safe_call(NPC.IsNeutral, npc) == true) then
            if safe_call(Entity.IsDormant, npc) ~= true and safe_call(NPC.IsWaitingToSpawn, npc) ~= true then
                local pos = safe_call(Entity.GetAbsOrigin, npc)
                if pos then
                    out[#out + 1] = { npc = npc, pos = pos }
                end
            end
        end
    end
    local cell_size = tonumber((script._autofarm_cfg and script._autofarm_cfg.NEUTRAL_SPATIAL_CELL) or 760) or 760
    if cell_size < 180 then
        cell_size = 180
    end
    local bins = {}
    for i = 1, #out do
        local rec = out[i]
        local pos = rec and rec.pos or nil
        if pos then
            local cx = math.floor((tonumber(pos.x or 0) or 0) / cell_size)
            local cy = math.floor((tonumber(pos.y or 0) or 0) / cell_size)
            local key = tostring(cx) .. ":" .. tostring(cy)
            local bucket = bins[key]
            if not bucket then
                bucket = {}
                bins[key] = bucket
            end
            bucket[#bucket + 1] = rec
        end
    end
    cache.t = t
    cache.entries = out
    script._autofarm_neutral_cache = cache
    script._autofarm_neutral_spatial = { t = t, cell = cell_size, bins = bins, entries = out }
    return out
end
function script.OnParticleCreate(data)
    script.track_tp_particle_data(data, "create")
end
function script.OnParticleUpdate(data)
    script.track_tp_particle_data(data, "update")
end
function script.OnParticleUpdateFallback(data)
    script.track_tp_particle_data(data, "update")
end
function script.OnParticleUpdateEntity(data)
    script.track_tp_particle_data(data, "update")
end
function script.OnParticleDestroy(data)
    script.track_tp_particle_data(data, "destroy")
end
function script.OnDraw()
    if not Engine.IsInGame() then
        return
    end
    local now = get_game_time()
    local ctx = script._frame_context_get(now)
    local local_hero = ctx.local_hero
    if local_hero == nil then
        local_hero = Heroes.GetLocal()
        ctx.local_hero = local_hero
    end
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    local meepos = ctx.meepos
    if meepos == nil then
        meepos = collect_meepos(local_hero, now)
        ctx.meepos = meepos
    end
    script.draw_combo_target_focus(local_hero, meepos)
    local perf_map = script.profiler_begin("map_draw")
    script.draw_autofarm_map_panel(local_hero, meepos, now)
    script.profiler_end("map_draw", perf_map)
    script.draw_autofarm_performance_panel(local_hero, meepos, now)
    local perf_world_status = script.profiler_begin("world_status_draw")
    script.draw_autofarm_world_status(local_hero, meepos, now)
    script.profiler_end("world_status_draw", perf_world_status)
    if not ui.enabled:Get() then
        return
    end
    script.draw_floating_meepo_panel(local_hero, meepos, now)
    local meepo_display_index_by_key = {}
    local ordered_meepos = build_floating_panel_units(local_hero, meepos)
    for i = 1, #ordered_meepos do
        local unit = ordered_meepos[i]
        if unit then
            meepo_display_index_by_key[get_entity_key(unit)] = i
        end
    end
    local override_status, override_color = script.get_global_override_status(meepos)
    local has_meepo_clones = script.has_meepo_clones()
    for idx, meepo in ipairs(meepos) do
        local is_clone = NPC.IsMeepoClone and NPC.IsMeepoClone(meepo) or false
        if (is_clone and ui.show_clones:Get()) or (not is_clone and ui.show_main:Get()) then
            local meepo_key = get_entity_key(meepo)
            local display_index = tonumber(meepo_display_index_by_key[meepo_key] or idx) or idx
            local status, color, tactical = script.get_meepo_status(meepo)
            if override_status and override_color then
                status = override_status
                color = override_color
            end
            local should_show_status = true
            if should_show_status then
                if ui.draw_world:Get() then
                    script.draw_meepo_status_world(meepo, status, color, tactical, display_index)
                end
                if ui.draw_portraits:Get() and has_meepo_clones then
                    script.draw_meepo_status_portrait(display_index, status, color, tactical)
                end
            end
        end
    end
end
function script.OnFrame()
    if not Engine.IsInGame() then
        return
    end
    local now = get_game_time()
    local ctx = script._frame_context_get(now)
    local local_hero = ctx.local_hero
    if local_hero == nil then
        local_hero = Heroes.GetLocal()
        ctx.local_hero = local_hero
    end
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    local meepos = ctx.meepos
    if meepos == nil then
        meepos = collect_meepos(local_hero, now)
        ctx.meepos = meepos
    end
    local local_player = ctx.local_player
    if local_player == nil then
        local_player = safe_call(Players.GetLocal)
        ctx.local_player = local_player
    end
    script.update_autofarm_runtime_toggle(now)
    script.update_autofarm_map_toggle(now)
    local perf_autofarm = script.profiler_begin("autofarm_logic")
    script.run_autofarm_logic(local_player, local_hero, meepos, now)
    script.profiler_end("autofarm_logic", perf_autofarm)
    begin_item_frame_budget()
    if local_player then
        local utility_issued = script.handle_poof_utilities(local_player, local_hero, meepos, now)
        if utility_issued then
            script.process_poof_queue(now)
            return
        end
    end
    if script.try_net_on_teleport(local_hero, meepos, now) then
        return
    end
    local combo_tick = tonumber(C and C.COMBO_LOGIC_TICK_INTERVAL or 0.03) or 0.03
    if combo_tick < 0 then
        combo_tick = 0
    end
    local preblink_active = script._combo_preblink_phase and script._combo_preblink_phase ~= "idle"
    if preblink_active then
        script._combo_logic_next_tick = now
        script.run_combo_logic(local_hero, meepos, now)
    elseif now >= (tonumber(script._combo_logic_next_tick or 0) or 0) then
        script._combo_logic_next_tick = now + combo_tick
        script.run_combo_logic(local_hero, meepos, now)
    end
    script.process_blink_queue(now)
    script.process_poof_queue(now)
end
function script.OnUpdate()
    if not Engine.IsInGame() then
        return
    end
    local now = get_game_time()
    local ctx = script._frame_context_get(now)
    local local_hero = ctx.local_hero
    if local_hero == nil then
        local_hero = Heroes.GetLocal()
        ctx.local_hero = local_hero
    end
    if not local_hero or not is_meepo_hero(local_hero) then
        return
    end
    local meepos = ctx.meepos
    if meepos == nil then
        meepos = collect_meepos(local_hero, now)
        ctx.meepos = meepos
    end
    local auto_safe_enabled = ui.auto_safe_enable:Get() and (ui.auto_safe_enemy_poof:Get() or ui.auto_safe_poof_hp_enable:Get())
    if not ui.auto_dig:Get() and not ui.auto_mega:Get() and not auto_safe_enabled then
        return
    end
    if now < auto_dig_next_tick then
        return
    end
    auto_dig_next_tick = now + C.AUTO_DIG_TICK_INTERVAL
    script.update_auto_save_hp_samples(meepos, now)
    if auto_safe_enabled then
        local local_player = ctx.local_player
        if local_player == nil then
            local_player = safe_call(Players.GetLocal)
            ctx.local_player = local_player
        end
        script.run_auto_safe_poof(local_hero, meepos, local_player, now)
    end
    local dig_triggered = false
    if ui.auto_dig:Get() then
        for i = 1, #meepos do
            if script.try_auto_dig(meepos[i], now) then
                dig_triggered = true
            end
        end
    end
    if ui.auto_mega:Get() and not dig_triggered then
        script.try_auto_mega(meepos, now)
    end
end
return script
