extends GdUnitTestSuite
## As saídas das áreas (08-mapa, 12-tecnico): cada saída leva a uma área que tem o ponto de chegada dela, e o caminho
## principal liga a Mina ao Bosque, o Bosque às Ruínas e as Ruínas à Grande Prisão, e volta.

const AREAS: Array[String] = ["mine", "forest", "ruins", "prison"]


func test_every_exit_arrives_somewhere() -> void:
	var exit := RegEx.create_from_string("next_area = \"([^\"]+)\"\\narrival = &\"([^\"]+)\"")
	var links := 0
	for area in AREAS:
		var text := FileAccess.get_file_as_string("res://world/areas/%s.tscn" % area)
		for found in exit.search_all(text):
			var target := FileAccess.get_file_as_string(found.get_string(1))
			assert_bool(target.contains("id = &\"%s\"" % found.get_string(2))).override_failure_message(
				"%s leva a %s, que não tem o ponto %s" % [area, found.get_string(1), found.get_string(2)]).is_true()
			links += 1
	# A passagem escura, a saída do Selo e a volta da Grande Prisão.
	assert_int(links).is_equal(3)
