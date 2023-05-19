extends CharacterBody2D

const EnemyAttackScene = preload("res://Scenes/EnemyAttack.tscn");
const EnemyTrapScene = preload("res://Scenes/EnemyTrap.tscn");

@export var state = SPAWNING

enum {
    SPAWNING,
    WANDER,
    DYING
}

var enemy_type
var enemy_speed
var enemy_health
var enemy_score
var attack_timer_min
var attack_timer_max
var attack_type
var trap_timer_min
var trap_timer_max
var stored_modulate;
var hit_to_be_processed;
var ai_mode = ''
var ai_mode_setting = ''
var initial_direction = 0
var enemy_is_split = false
var instant_spawn = false
var grouped_enemy = false
var child_of_enemy = false
var child_number
var desired_velocity
var parent_node
var enemy_group_id

func _ready():
    pass
    
func spawn_random():
    var mob_types
    
    # Determine spawn list for this wave.
    for local_wave_number in constants.ENEMY_SPAWN_WAVE_CONFIGURATION:
        if get_parent().wave_number >= local_wave_number: 
            mob_types = constants.ENEMY_SPAWN_WAVE_CONFIGURATION[local_wave_number] 

    enemy_type = mob_types[randi() % mob_types.size()]
    spawn_specific(enemy_type)

func spawn_specific(enemy_type_in):
    enemy_type = enemy_type_in
    
    if constants.DEV_SPAWN_ONE_ENEMY_TYPE and !child_of_enemy:
        print("[spawn_specific] Forcibly spawning: " + str(constants.DEV_SPAWN_ONE_ENEMY_TYPE))
        enemy_type = constants.DEV_SPAWN_ONE_ENEMY_TYPE
    
    $AnimatedSprite2D.animation = enemy_type + str('-run')
    
    # TODO: Change this to use JSON as complexity is too much now.
    
    var enemy_settings = constants.ENEMY_SETTINGS[enemy_type]
    enemy_speed = enemy_settings[0]
    enemy_health = enemy_settings[1]
    ai_mode_setting = enemy_settings[2]
    enemy_score = enemy_settings[3]
    attack_timer_min = enemy_settings[4]
    attack_timer_max = enemy_settings[5]
    attack_type = enemy_settings[6]
    trap_timer_min = enemy_settings[7]
    trap_timer_max = enemy_settings[8]
    grouped_enemy = enemy_settings[9]
    
    # Special settings for necromancer.
    match enemy_type:
        'necromancer':
            $AnimatedSprite2D.offset = Vector2(0,-25)
            $CollisionShape2D.scale = Vector2(1.5, 1.5)
            set_collision_mask_value(7,true)
        'snake':
            $AnimatedSprite2D.scale = Vector2(6,6)
    
    # Increase enemy speed as waves progress.
    var i=1
    while i <= get_parent().wave_number - 1:
        enemy_speed = enemy_speed + int( (constants.ENEMY_SPEED_WAVE_PERCENTAGE_MULTIPLIER / enemy_speed)*100 )
        i+=1
    
    if !instant_spawn:
        $StateTimer.start();
    
    if ai_mode == "":
        ai_mode = ai_mode_setting
    
    if ai_mode == 'SPAWN_OUTWARDS':
        $SpawnOutwardsTimer.start()
    
    if enemy_is_split:
        scale = constants.ENEMY_SPLIT_SIZE
        enemy_speed = enemy_speed * constants.ENEMY_SPLIT_SPEED_MULTIPLIER
    
    # 'Grouped' enemy (i.e. snake) handling code.
    if grouped_enemy:
        if child_of_enemy:
            # TO GO HERE: Spawning of child components. 
            print("[Enemy] This is a child.")
            print("[Enemy] My parent is: " + str(parent_node))
        else:
            # Parent / Head spawning code.
            print("[Enemy] This is the head.")
            get_parent().grouped_enemy_id = get_parent().grouped_enemy_id + 1
            enemy_group_id = get_parent().grouped_enemy_id
            add_to_group("groupedEnemy-" + str( enemy_group_id ))
            for grouped_count in range(1,6):
                var mob = get_parent().enemy_scene.instantiate()
                
                mob.get_node('.').set_position(position)
                mob.add_to_group('enemyGroup')
                mob.add_to_group("groupedEnemy-" + str( enemy_group_id ))
                mob.set_enemy_group_id(enemy_group_id)
                mob.set_child_of_enemy(true)
                mob.set_child_number(grouped_count)
                mob.set_parent_node(self)
                get_parent().add_child(mob)
                mob.spawn_specific(enemy_type)
                
                print("[Enemy] Group ID: " + str(get_parent().grouped_enemy_id) + " - Child spawned at: " + str(position))
                
    
    set_modulate(Color(0,0,0,0));
    hit_to_be_processed = false
    $SpawnParticles.emitting = true

func set_ai_mode(ai_mode_in):
    ai_mode = ai_mode_in
    
func set_initial_direction(initial_direction_in):
    initial_direction = initial_direction_in
    
    if initial_direction.x < 0:
        $AnimatedSprite2D.set_flip_h(true)
    
func set_instant_spawn(spawn):
    instant_spawn = spawn
    
func set_enemy_is_split(is_split):
    enemy_is_split = is_split
    
func set_child_of_enemy(is_child_of_enemy):
    child_of_enemy = is_child_of_enemy
    
func set_parent_node(in_parent_node):
    parent_node = in_parent_node

func set_child_number(in_child_number):
    child_number = in_child_number
    
func set_enemy_group_id(in_enemy_group_id):
    enemy_group_id = in_enemy_group_id

func _physics_process(delta):
    set_modulate(lerp(get_modulate(), Color(1,1,1,1), 0.02));
    
    match state:
        SPAWNING:
            velocity = Vector2(0,0);
            
            if $FlashHitTimer.time_left == 0 and hit_to_be_processed:
                set_modulate(stored_modulate);
                hit_to_be_processed = false
                
            if $StateTimer.time_left == 0:
                $SpawnParticles.emitting = false
                state = WANDER;
                $AnimatedSprite2D.play();
                               
                set_collision_mask_value(1,true)    # Allow player collisions.
                set_collision_layer_value(3,true)   # Identify as an Enemy

                if attack_timer_min:
                    $AttackTimer.start(randf_range(attack_timer_min, attack_timer_max));
                    
                if trap_timer_min:
                    $TrapTimer.start(randf_range(trap_timer_min, trap_timer_max));

        WANDER:
            if $FlashHitTimer.time_left == 0:
                set_modulate(Color(1,1,1,1));
            
            if $StateTimer.time_left == 0:
                match ai_mode:
                    # Keep running until enemy hits a wall.
                    'DEFERRED_UNTIL_WALL':
                        velocity = initial_direction * (enemy_speed * constants.ENEMY_SPEED_DEFERRED_AI_MULTIPLIER)
                        
                    # (For mini skeletons) - Spawns outwards. Then will switch to CHASE after timer expires.
                    'SPAWN_OUTWARDS':
                        velocity = initial_direction * (enemy_speed * constants.ENEMY_SPEED_DEFERRED_AI_MULTIPLIER)
                        
                        if $SpawnOutwardsTimer.time_left==0:
                            ai_mode='CHASE'
                        
                    # Pursue the player.
                    'CHASE':
                        var target_direction = (get_parent().get_node("Player").global_position - global_position).normalized();
                        velocity = target_direction * enemy_speed;
                        $StateTimer.start(randf_range(constants.ENEMY_CHASE_REORIENT_MINIMUM_SECONDS,
                                                    constants.ENEMY_CHASE_REORIENT_MAXIMUM_SECONDS));
                    
                    # 1. Try and eat fish
                    # 2. Pursue player.                            
                    'FISH':
                        var target_direction;
                        
                        var fish_points = get_tree().get_nodes_in_group("fishGroup");
                        
                        # In Pacifist mode, Necros do not go after fish.
                        if fish_points.size() and get_parent().game_mode == 'ARCADE':
                            var nearest_fish = fish_points[0];
                        
                            for single_fish in fish_points:
                                if single_fish.global_position.distance_to(global_position) < nearest_fish.global_position.distance_to(global_position):
                                        nearest_fish = single_fish
                            
                            target_direction = (nearest_fish.global_position - global_position).normalized();
                            velocity = target_direction * enemy_speed;
                            $StateTimer.start(randf_range(constants.ENEMY_CHASE_REORIENT_MINIMUM_SECONDS,
                                                        constants.ENEMY_CHASE_REORIENT_MAXIMUM_SECONDS));
                        else:
                            # Pacifist mode.
                            $StateTimer.start(randf_range(constants.ENEMY_DEFAULT_CHANGE_DIRECTION_MINIMUM_SECONDS,
                                                    constants.ENEMY_DEFAULT_CHANGE_DIRECTION_MAXIMUM_SECONDS));
                            velocity = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * enemy_speed;
                            
                    'WANDER':        
                        # Wander around a bit randomly.
                        $StateTimer.start(randf_range(constants.ENEMY_DEFAULT_CHANGE_DIRECTION_MINIMUM_SECONDS,
                                                    constants.ENEMY_DEFAULT_CHANGE_DIRECTION_MAXIMUM_SECONDS));
                        velocity = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * enemy_speed;
                           
                    'GROUP':
                        # Used for a snake sort of enemy.
                        # The head sets the direction.  Children follow the head.                        
                        if !child_of_enemy:
                            # I set the direction.
                            # Wander.
                            $StateTimer.start(randf_range(1,3));
                            desired_velocity = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * enemy_speed;
                
                # OVERRIDE AI - Always chase the player when wave population is low.   
                if get_parent().enemies_left_this_wave <= constants.ENEMY_ALL_CHASE_WHEN_POPULATION_LOW:
                    var target_direction = (get_parent().get_node("Player").global_position - global_position).normalized();
                    
                    if (get_parent().enemies_left_this_wave <= constants.ENEMY_ALL_CHASE_WHEN_POPULATION_LOW):
                        velocity = target_direction * (enemy_speed * constants.ENEMY_SPEED_POPULATION_LOW_MULTIPLIER)
                    else:
                        velocity = target_direction * enemy_speed;
                    
                    $StateTimer.start(randf_range(constants.ENEMY_CHASE_REORIENT_MINIMUM_SECONDS,
                                                constants.ENEMY_CHASE_REORIENT_MAXIMUM_SECONDS));
                                                                                
        DYING:
            if $FlashHitTimer.time_left == 0:
                set_modulate(Color(1,1,1,1));
                
            if $DeathParticlesTimer.time_left == 0:
                $DeathParticles.emitting = false
                
            if $StateTimer.time_left == 0:
                self.queue_free();

    
    if desired_velocity and !child_of_enemy:
        velocity = velocity.lerp(desired_velocity, 0.01)
    
    if child_of_enemy and state != DYING:
        # Always move towards my parent, keeping a set distance.
        var target = parent_node.global_position + ((child_number-1)*50) * parent_node.global_position.direction_to(global_position)
        global_position = global_position.move_toward(target, 2000 * delta)
        
    var collision = move_and_collide(velocity * delta);	
    
    if velocity.x > 0:
        $AnimatedSprite2D.set_flip_h(false);
    
    if velocity.x < 0:
        $AnimatedSprite2D.set_flip_h(true);	
 
    if $AttackTimer.time_left == 0 && state == WANDER && attack_timer_min:
        match attack_type:
            'STANDARD':
                var enemy_attack = EnemyAttackScene.instantiate()
                get_parent().add_child(enemy_attack)
                enemy_attack.add_to_group('enemyAttack')
                
                var target_direction = (get_parent().get_node("Player").global_position - global_position).normalized()
                
                # We don't want enemies to always be a perfect shot.
                target_direction = target_direction.rotated( deg_to_rad(randf_range(0,constants.ENEMY_ATTACK_ARC_DEGREES)))
                
                enemy_attack.global_position = position

                enemy_attack.velocity = target_direction * enemy_attack.enemy_attack_speed
            
            'SPIRAL':
                # Spiral attack pattern.
                var i = 1
                while (i <= 16):
                    var enemy_attack = EnemyAttackScene.instantiate()
                    get_parent().add_child(enemy_attack);
                    enemy_attack.add_to_group('enemyAttack')
                    var target_direction = Vector2(1,1).normalized();
                    target_direction = target_direction.rotated ( deg_to_rad(360.0/16.0) * i)
                    enemy_attack.global_position = position
                    enemy_attack.velocity = target_direction * enemy_attack.enemy_attack_speed
                    i+=1
            
        $AttackTimer.start(randf_range(attack_timer_min, attack_timer_max))
                  
    if $TrapTimer.time_left == 0 && state == WANDER && trap_timer_min:
        var enemy_trap = EnemyTrapScene.instantiate();
        get_parent().add_child(enemy_trap)
        enemy_trap.add_to_group('enemyTrap')
        enemy_trap.global_position = position
        
        $TrapTimer.start(randf_range(trap_timer_min, trap_timer_max))
        
    if collision and !child_of_enemy:
        if enemy_type == 'necromancer' && collision.get_collider().name.contains('Fish') && get_parent().game_mode == 'ARCADE':
            var collided_with = collision.get_collider()
            collided_with.get_node('.')._death(1)
            $AudioStreamPlayerFishSplat.play()
        else:
            if collision.get_collider().name == 'Player':
                var collided_with = collision.get_collider()
                collided_with._player_hit()
                _death('PLAYER-BODY')
            else:
                # Hit a wall? Ensure AI mode is standard.
                if ai_mode == 'CHASE':
                    # Slide around the wall to get to player.
                    velocity = velocity.slide(collision.get_normal())
                else: 
                    # Boing!
                    velocity = velocity.bounce(collision.get_normal())
                    if desired_velocity:
                        desired_velocity = desired_velocity.bounce(collision.get_normal())
                    ai_mode=ai_mode_setting
    
func _death(death_source):
    if state == SPAWNING && !constants.ENEMY_ALLOW_DAMAGE_WHEN_SPAWNING:
        return
    
    if state != DYING:
        enemy_health = enemy_health - 1;
        
        hit_to_be_processed = true
        
        if enemy_health <=0 :
            $CollisionShape2D.set_deferred("disabled", true)
            velocity = Vector2(0,0);
            $AnimatedSprite2D.animation = enemy_type + str('-death');
            $AnimatedSprite2D.play()
            $AudioStreamPlayer.play();
            $StateTimer.start(2);
            $SpawnParticles.emitting = false
            $DeathParticles.emitting = true
            $DeathParticlesTimer.start()
            state = DYING;
            
            var grouped_enemy_has_died = true
            
            if grouped_enemy:
                grouped_enemy_has_died = grouped_enemy_death()
            
            var actual_scored = get_parent()._on_enemy_update_score(enemy_score,global_position,death_source,enemy_type,enemy_is_split,grouped_enemy_has_died)
            
            score_label_animation(str(actual_scored))
            
            if get_parent().game_mode == 'ARCADE' && (get_parent().dropped_items_on_screen < constants.ARCADE_MAXIMUM_DROPPED_ITEMS_ON_SCREEN):
                if !(grouped_enemy and !grouped_enemy_has_died):        
                    leave_behind_item()
        else:
            stored_modulate = get_modulate()
            set_modulate(Color(10,10,10,10));
            $FlashHitTimer.start()
     
# Handle grouped enemy death.
# Basically, keep the group (snake!) together properly.  
func grouped_enemy_death():
        var remember_the_parent
    
        print("[Death] Enemy group ID: " + str(enemy_group_id))
    
        # What was destroyed?
        if child_of_enemy:
            print("[Death] Child.")
            # I am a child.
            # We just need to recompute child numbers for everything except the parent.
            var i = 0
            for single_enemy in get_tree().get_nodes_in_group("groupedEnemy-" + str( enemy_group_id )):
                if single_enemy.name == name:
                    print("[Death] Skip: It's me.")
                    continue
                    
                if single_enemy.state == DYING:
                    print("[Death] Skip: Dying")
                    continue
                    
                i+=1
                single_enemy.set_child_number(i)
                print("[Death] New child number: " + str(i))
        else:
            # I am the parent.
            print("[Death] Parent")
            var i = 0
             
            for single_enemy in get_tree().get_nodes_in_group("groupedEnemy-" + str( enemy_group_id)):
                if single_enemy.name == name:
                    print("[Death] Skip: It's me.")
                    continue
            
                if single_enemy.state == DYING:
                    print("[Death] Skip: Dying.")
                    continue  
                        
                i+=1
                if i == 1:
                    # Congratulations.  You are the new parent.
                    print("[Death] NEW PARENT WOOOO")
                    single_enemy.set_child_of_enemy(false)
                    remember_the_parent = single_enemy
                else:
                    # You are a child.
                    print("[Death] Child: Set to " + str(i-1))
                    single_enemy.set_child_number(i-1)
                    single_enemy.set_parent_node(remember_the_parent)
                            
            if !i:
                # If we didn't count anything - we must have been the last piece.
                return true
                        
        return false
                        
func leave_behind_item():
    var percentage_calc  = (get_parent().get_node('Player').upgrades['LOOT LOVER'][0] * 10.0) / 100.0
    var leave_percentage = constants.ENEMY_LEAVE_BEHIND_ITEM_PERCENTAGE + (percentage_calc * constants.ENEMY_LEAVE_BEHIND_ITEM_PERCENTAGE)
    
    if randi_range(1,100) <= leave_percentage:
        var item = get_parent().item_scene.instantiate()
        get_parent().add_child(item)
        item.spawn_random(true)
        item.set_source('DROPPED')
        item.get_node('.').set_position(position)
        item.add_to_group('itemGroup')
        get_parent().dropped_items_on_screen += 1

func score_label_animation(label_text):
    var new_label = $ScoreLabel.duplicate()
    add_child(new_label)
    
    new_label.set_modulate(Color(1,1,1,1));
    new_label.text = label_text
    new_label.visible = true
    
    # Text should move upwards slightly.
    var target_position = new_label.position
    target_position.y += -50
    
    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(new_label, "modulate", Color(0,0,0,0), 2)
    tween.tween_property(new_label, "position", target_position, 2)
    tween.tween_callback(new_label.queue_free).set_delay(2)
    
func is_enemy_alive():
    if state == WANDER:
        return true
    else:
        return false
