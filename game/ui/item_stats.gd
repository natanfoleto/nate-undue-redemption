class_name ItemStats
## Os atributos de cada item no inventário (09-interface): o nome (chave de tradução), o texto, o valor para
## comparar com o equipado e se o maior é o melhor. Números com vírgula, como no português.


static func rows(item: Resource) -> Array[Dictionary]:
	if item is MeleeWeaponData:
		return _melee(item)
	if item is RangedWeaponData:
		return _ranged(item)
	if item is ArmorData:
		return _armor(item)
	if item is ElementData:
		return _element(item)
	if item is PotionData:
		return _potion()
	return []


static func _melee(weapon: MeleeWeaponData) -> Array[Dictionary]:
	var critical := Balance.player.critical_chance + weapon.critical_bonus
	var rows: Array[Dictionary] = [
		_row(&"STAT_DAMAGE", "%d / %d" % [weapon.damage, weapon.damage_third], weapon.damage, true),
		_row(&"STAT_HIT_TIME", _seconds(weapon.time_per_hit), weapon.time_per_hit, false),
		_row(&"STAT_REACH", _blocks(weapon.reach), weapon.reach, true),
		_row(&"STAT_ANGLE", "%s°" % _number(weapon.angle), weapon.angle, true),
		_row(&"STAT_CRITICAL", "%s%%" % _number(critical * 100.0), critical, true),
	]
	if weapon.third_effect >= 0:
		rows.append(_text_row(&"STAT_THIRD_HIT", _effect(weapon.third_effect, weapon.third_effect_duration)))
	if weapon.cooldown_cut > 0.0:
		rows.append(_row(&"STAT_COOLDOWN_CUT", _seconds(weapon.cooldown_cut), weapon.cooldown_cut, true))
	return rows


static func _ranged(weapon: RangedWeaponData) -> Array[Dictionary]:
	var rows: Array[Dictionary] = [
		_row(&"STAT_DAMAGE", str(weapon.damage), weapon.damage, true),
		_row(&"STAT_DRAW_TIME", _seconds(weapon.draw_time), weapon.draw_time, false),
		_row(&"STAT_REACH", _blocks(weapon.reach), weapon.reach, true),
		_row(&"STAT_PROJECTILE_SPEED", _speed(weapon.projectile_speed), weapon.projectile_speed, true),
		_row(&"STAT_KNOCKBACK", TranslationServer.translate(_knockback_key(weapon.knockback)), weapon.knockback, true),
	]
	if weapon.effect >= 0:
		rows.append(_text_row(&"STAT_EFFECT", _effect(weapon.effect, weapon.effect_duration)))
	if weapon.pierce:
		rows.append(_text_row(&"STAT_PIERCE", TranslationServer.translate(&"VALUE_YES")))
	return rows


static func _armor(armor: ArmorData) -> Array[Dictionary]:
	var dash := armor.dash_cooldown if armor.dash_cooldown > 0.0 else Balance.player.dash_cooldown
	var rows: Array[Dictionary] = [
		_row(&"STAT_HEALTH", "+%d" % armor.extra_health, armor.extra_health, true),
		_row(&"STAT_SPEED", _speed(armor.move_speed), armor.move_speed, true),
		_row(&"STAT_DASH_COOLDOWN", _seconds(dash), dash, false),
		_row(&"STAT_DAMAGE_BONUS", "+%s%%" % _number(armor.damage_bonus * 100.0), armor.damage_bonus, true),
	]
	return rows


static func _potion() -> Array[Dictionary]:
	var stats := Balance.player
	return [
		_text_row(&"STAT_HEAL", "+%d" % stats.flask_heal),
		_text_row(&"STAT_CHARGES", str(GameState.flask_charges())),
		_text_row(&"STAT_DRINK_TIME", _seconds(stats.flask_time)),
	]


static func _element(element: ElementData) -> Array[Dictionary]:
	var spell := element.spell
	var attack := spell.explosion if spell.explosion else spell.attack
	var rows: Array[Dictionary] = [
		_text_row(&"STAT_SPELL", TranslationServer.translate(spell.name_key)),
		_row(&"STAT_COOLDOWN", _seconds(spell.cooldown), spell.cooldown, false),
	]
	if attack.damage_points > 0:
		rows.append(_row(&"STAT_DAMAGE", str(attack.damage_points), attack.damage_points, true))
	if attack.knockback != AttackData.Knockback.NONE:
		rows.append(_text_row(&"STAT_KNOCKBACK", TranslationServer.translate(_knockback_key(attack.knockback))))
	if spell.effect >= 0:
		var duration := Balance.status.burn_duration if spell.effect == StatusEffects.Effect.BURN else spell.effect_duration
		rows.append(_text_row(&"STAT_EFFECT", _effect(spell.effect, duration)))
	if spell.self_speed_bonus > 0.0:
		rows.append(_text_row(&"STAT_SPEED_BOOST", "+%s%%, %s" % [_number(spell.self_speed_bonus * 100.0), _seconds(spell.self_duration)]))
	if spell.shield:
		rows.append(_text_row(&"STAT_SHIELD", TranslationServer.translate(&"SHIELD_ONE_HIT")))
	return rows


static func _row(key: StringName, text: String, value: float, higher_is_better: bool) -> Dictionary:
	return {"key": key, "text": text, "value": value, "higher_is_better": higher_is_better}


static func _text_row(key: StringName, text: String) -> Dictionary:
	return {"key": key, "text": text}


static func _effect(effect: int, duration: float) -> String:
	var name := TranslationServer.translate(StringName("EFFECT_" + StatusEffects.Effect.keys()[effect]))
	return "%s, %s" % [name, _seconds(duration)] if duration > 0.0 else name


static func _knockback_key(knockback: int) -> StringName:
	return StringName("KNOCKBACK_" + AttackData.Knockback.keys()[knockback])


static func _seconds(value: float) -> String:
	return TranslationServer.translate(&"UNIT_SECONDS") % _number(value)


static func _blocks(value: float) -> String:
	return TranslationServer.translate(&"UNIT_BLOCK" if value < 2.0 else &"UNIT_BLOCKS") % _number(value)


static func _speed(value: float) -> String:
	return TranslationServer.translate(&"UNIT_SPEED") % _number(value)


static func _number(value: float) -> String:
	return String.num(value, 2).replace(".", ",")
