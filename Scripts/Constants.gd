extends Node

const GAME_VERSION = "0.4-alpha"

# Developer settings.
const DEV_SKIP_INTRO = false
const DEV_START_GAME_IMMEDIATELY = false
const MUSIC_ENABLED = false

# Game settings
const START_WAVE = 1

const ARENA_SPAWN_MIN_X = 170
const ARENA_SPAWN_MAX_X = 2600 * 2
const ARENA_SPAWN_MIN_Y = 320
const ARENA_SPAWN_MAX_Y = 1250 * 2

const PLAYER_START_GAME_ENERGY = 100
const PLAYER_START_GAME_ENERGY_CHEATING = 99999
const PLAYER_LOW_ENERGY_BLINK = 30

const PLAYER_SPEED = 800
const PLAYER_SPEED_POWERUP_INCREASE = 25
const PLAYER_SPEED_ESCAPING = 1200;

const PLAYER_FIRE_DELAY = 0.35
const PLAYER_FIRE_DELAY_POWERUP_DECREASE = 0.05
const PLAYER_FIRE_SPEED = 1600;
const PLAYER_FIRE_SIZE_POWERUP_INCREASE = 0.25

const PLAYER_HIT_BY_ENEMY_DAMAGE = 10;

const PLAYER_FISH_FRENZY_DURATION = 1.5
const PLAYER_FISH_FRENZY_FIRE_DELAY = 0.1

const DINOSAUR_SPEED = 800
const DINOSAUR_ATTACK_DELAY = 0.5
const DINOSAUR_ATTACK_SPEED = 800
const DINOSAUR_SURVIVAL_TIME = 5

# Enemy spawning
const ENEMY_SPAWN_WAVE_CONFIGURATION = {
    1:      ['knight','wizard'],
    2:      ['knight','knight','wizard','rogue'],
    3:      ['knight','knight', 'wizard','wizard', 'rogue', 'necromancer'],
    5:      ['knight','knight', 'wizard','wizard', 'rogue', 'necromancer', 'bee'],
}

const ENEMY_SPAWN_WAVE_SPECIAL_MIN_WAVE = 2

const ENEMY_SPAWN_WAVE_SPECIAL_CONFIGURATION = {
    90:      ['STANDARD', '', ''],
    95:      ['ALL_THE_SAME', 'bee', 'Feel the buzz!'],
    100:     ['ALL_THE_SAME', 'necromancer', 'The fish become fearful!'],
    
}

const ENEMY_SPAWN_PLACEMENT_CONFIGURATION = {
    50:     'RANDOM',
    80:     'CIRCLE_SURROUND_PLAYER',
    85:     'HARD_TOP', 
    90:     'HARD_BOTTOM',
    95:     'HARD_LEFT',
    100:    'HARD_RIGHT'
}

const ENEMY_MULTIPLIER_AT_WAVE_START = 10
const ENEMY_MULTIPLIER_DURING_WAVE = 15

const ENEMY_REINFORCEMENTS_SPAWN_BASE_SECONDS = 5
const ENEMY_REINFORCEMENTS_SPAWN_BATCH_SIZE = 5
const ENEMY_REINFORCEMENTS_SPAWN_BATCH_MULTIPLIER = 1
const ENEMY_REINFORCEMENTS_SPAWN_MINIMUM_NUMBER = 5

# Enemy (General)

const ENEMY_SPEED = 450
const ENEMY_NECROMANCER_SPEED = 100
const ENEMY_BEE_SPEED = 600
const ENEMY_SPEED_WAVE_PERCENTAGE_MULTIPLIER = 10
const ENEMY_SPEED_DEFERRED_AI_MULTIPLIER = 1.5
const ENEMY_SPEED_POPULATION_LOW_MULTIPLIER = 1.5

const ENEMY_HEALTH = 1
const ENEMY_NECROMANCER_HEALTH = 3

const ENEMY_ATTACK_MINIMUM_SECONDS = 3;
const ENEMY_ATTACK_MAXIMUM_SECONDS = 5;
const ENEMY_ATTACK_ARC_DEGREES = 20;
const ENEMY_NECROMANCER_ATTACK_MINIMUM_SECONDS = 5;
const ENEMY_NECROMANCER_ATTACK_MAXIMUM_SECONDS = 10;

const ENEMY_CHASE_REORIENT_MINIMUM_SECONDS = 0.5;
const ENEMY_CHASE_REORIENT_MAXIMUM_SECONDS = 1.0;
const ENEMY_DEFAULT_CHANGE_DIRECTION_MINIMUM_SECONDS = 1;
const ENEMY_DEFAULT_CHANGE_DIRECTION_MAXIMUM_SECONDS = 3;

const ENEMY_ALL_CHASE_WHEN_POPULATION_LOW = 10

const ENEMY_TRAP_MINIMUM_SECONDS = 4;
const ENEMY_TRAP_MAXIMUM_SECONDS = 10;
const ENEMY_TRAP_HEALTH = 5

const KILL_ENEMY_SCORE = 10;
const KILL_ENEMY_NECROMANCER_SCORE = 30;

# Fish
const FISH_TO_SPAWN_ARCADE = 20;
const FISH_TO_SPAWN_PACIFIST_BASE = 5
const FISH_TO_SPAWN_PACIFIST_WAVE_MULTIPLIER = 2
const GET_FISH_SCORE = 50;
const FISH_TO_TRIGGER_FISH_FRENZY = 15

# Items
const ARCADE_SPAWNING_ITEMS = ['dinosaur']
const PACIFIST_SPAWNING_ITEMS = ['health']

const ITEM_SPAWN_MINIMUM_SECONDS = 10
const ITEM_SPAWN_MAXIMUM_SECONDS = 15
const ENEMY_LEAVE_BEHIND_ITEM_PERCENTAGE = 15
const ITEM_DESPAWN_TIME = 10
const ARCADE_MAXIMUM_DROPPED_ITEMS_ON_SCREEN = 5

const HEALTH_POTION_BONUS = 20;

# Power up levels
const POWERUP_SPEEDUP_MAX_LEVEL = 3
const POWERUP_FASTSPRAY_MAX_LEVEL = 3
const POWERUP_BIGSPRAY_MAX_LEVEL = 3
const POWERUP_MINISHARK_MAX_LEVEL = 3

const POWERUP_ACTIVE_DURATION = 10

# Upgrades
const ARMOUR_DAMAGE_REDUCTION_PERCENTAGE = 10
