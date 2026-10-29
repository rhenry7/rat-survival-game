class_name Tuning
extends RefCounted
## All gameplay numbers live here. Difficulty functions take the current level (1-based).

const VIEW_W := 720.0
const VIEW_H := 980.0
const GROUND_Y := 820.0

# Rat
const RAT_SCALE := 0.6
const RAT_SPEED := 460.0
const RAT_ACCEL := 3500.0
const RAT_MIN_X := 85.0
const RAT_MAX_X := 635.0
const BOB_FREQ := 14.0
const BOB_HEIGHT := 7.0
const BOB_TILT := 0.07

# Feet
const FOOT_START_H := 900.0
const FOOT_GROUND_PAUSE := 0.40
const FOOT_LIFT_TIME := 0.55
const FOOT_LETHAL_LIFT_CLEARANCE := 90.0
const FOOT_MIN_SEPARATION := 180.0
const FOOT_X_MIN := 90.0
const FOOT_X_MAX := 630.0
const SHADOW_RADIUS := 135.0
const SHADOW_Y_SQUASH := 0.22

# Pizzas
const PIZZA_X_MIN := 60.0
const PIZZA_X_MAX := 660.0
const PIZZA_AVOID_FOOT := 170.0
const PIZZA_DESPAWN_Y := 920.0
const PIZZAS_PER_LEVEL := 5

# Flow
const FIRST_FOOT_DELAY := 1.5
const FIRST_PIZZA_DELAY := 0.6
const RESTART_DELAY_MS := 700
const SHAKE_PX := 8.0
const SHAKE_TIME := 0.18


static func fall_speed(level: int) -> float:
	# Scaled to the 900px drop so fall *time* matches the original tuning.
	return minf(1275.0 + 165.0 * (level - 1), 2850.0)


static func warn_time(level: int) -> float:
	return maxf(0.75 - 0.04 * (level - 1), 0.38)


static func foot_interval(level: int) -> float:
	return maxf(1.7 * pow(0.9, level - 1), 0.55)


static func max_feet(level: int) -> int:
	return mini(2 + level / 2, 5)


static func target_chance(level: int) -> float:
	return minf(0.35 + 0.03 * (level - 1), 0.6)


static func pizza_interval(level: int) -> float:
	return maxf(1.15 - 0.04 * (level - 1), 0.70)


static func pizza_speed(level: int) -> float:
	return minf(225.0 + 11.0 * (level - 1), 360.0)


static func target(level: int) -> int:
	return PIZZAS_PER_LEVEL * level
