extends Node

enum AllyState {
	DEFEND_CARRIAGE,
	ATTACK_TARGET,
	DYING,
}

enum PhysicLayer {
	ENEMY = 1,
	CARRIAGE = 2,
	ALLY = 3,
	GROUND = 9,
}
