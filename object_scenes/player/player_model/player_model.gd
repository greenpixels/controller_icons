extends Node2D
class_name PlayerModel

@onready var animation := $AnimationPlayer

@onready var head_sprite : Sprite2D = %HeadSprite
@onready var torso_sprite : Sprite2D= %TorsoSprite
@onready var left_foot_sprite : Sprite2D= %LeftFootSprite
@onready var right_foot_sprite : Sprite2D= %RightFootSprite
