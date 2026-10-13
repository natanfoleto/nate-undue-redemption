class_name Damage
## Fórmula do dano que Nate causa (03-regras), numa função só, coberta por teste:
## dano do ataque × (1 + soma dos bônus) × variação × crítico, arredondado para o inteiro mais próximo.
## O dano contra Nate não tem sorte: cada golpe tira sempre os mesmos corações.


## Dano em pontos. [param bonus] é a soma dos bônus como fração (20% = 0,2).
static func points(base: float, bonus: float, variation: float, critical: bool, critical_multiplier: float) -> int:
	var multiplier := critical_multiplier if critical else 1.0
	return roundi(base * (1.0 + bonus) * variation * multiplier)


## Sorteia a variação e o crítico e devolve o golpe pronto, com o dano em pontos.
static func roll(base: float, bonus: float, critical_chance: float, rules: CombatRules, rng: RandomNumberGenerator) -> Hit:
	var hit := Hit.new()
	hit.critical = rng.randf() < critical_chance
	var variation := rng.randf_range(rules.damage_variation_min, rules.damage_variation_max)
	hit.points = points(base, bonus, variation, hit.critical, rules.critical_multiplier)
	return hit
