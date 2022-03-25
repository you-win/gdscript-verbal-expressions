extends "res://tests/base_test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	.before_each()

func after_each():
	pass

func after_all():
	pass

###############################################################################
# Utils                                                                       #
###############################################################################

###############################################################################
# Tests                                                                       #
###############################################################################

func test_url_pass():
	assert_ok(ve \
		.start_of_line() \
		.then("http") \
		.maybe("s") \
		.then("://") \
		.maybe("www.") \
		.anything_but(" ") \
		.end_of_line() \
		.build().build_result)
	search_and_assert_eq(ve, "https://godotengine.org/", "https://godotengine.org/")
	search_and_assert_eq(ve, "https://www.godotengine.org/", "https://www.godotengine.org/")

func test_url_fail():
	assert_ok(ve \
		.start_of_line() \
		.then("http") \
		.maybe("s") \
		.then("://") \
		.maybe("www.") \
		.anything_but(" ") \
		.end_of_line() \
		.build().build_result)
	assert_null(ve.search("This is neat"))

func test_telephone_number_pass():
	assert_ok(ve \
		.start_of_line() \
		.then("+") \
		.capture() \
		.RANGE(["0", "9"]) \
		.count(["3"]) \
		.maybe("-") \
		.maybe(" ") \
		.end_capture() \
		.count(["3"]) \
		.end_of_line() \
		.build().build_result)
	
	search_and_assert_eq(ve, "+097 234 243", "+097 234 243")
	search_and_assert_eq(ve, "+097234243", "+097234243")
	search_and_assert_eq(ve, "+097-234-243", "+097-234-243")

func test_telephone_number_fail():
	assert_ok(ve \
		.start_of_line() \
		.then("+") \
		.capture() \
		.RANGE(["0", "9"]) \
		.count(["3"]) \
		.maybe("-") \
		.maybe(" ") \
		.end_capture() \
		.count(["3"]) \
		.end_of_line() \
		.build().build_result)
	
	assert_null(ve.search("hello world"))

func test_complex_multiple_capture_pass():
	var expected := "3\t4\t1\thttp://localhost:20001\t1\t63528800\t0\t63528800\t1000000000\t0\t63528800\tSTR1"
	
	assert_ok(ve \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().RANGE(["0", "1"]).count(["1"]).end_capture().tab() \
		.capt().find("http://localhost:20").digit().count(["3"]).end_capture().tab() \
		.capt().RANGE(["0", "1"]).count(["1"]).end_capture().tab() \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().RANGE(["0", "1"]).count(["1"]).end_capture().tab() \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().RANGE(["0", "1"]).count(["1"]).end_capture().tab() \
		.capt().digit().one_or_more().end_capture().tab() \
		.capt().find("STR").RANGE(["0", "2"]).count(["1"]).end_capture().build().build_result)
	
	search_and_assert_eq(ve, expected, expected)
	
	var digits = VerbalExpressions.new().capt().digit().one_or_more().end_capt().tab()
	var ve_range = VerbalExpressions.new().capt().RANGE([0, 1]).count([1]).end_capt().tab()
	var host = VerbalExpressions.new().capt().find("http://localhost:20").digit().count([3]).end_capt().tab()
	var fake = VerbalExpressions.new().capt().find("STR").RANGE([0, 2]).count([1])
	
	var ve2 = VerbalExpressions.new() \
		.add(digits).add(digits) \
		.add(ve_range).add(host).add(ve_range).add(digits).add(ve_range) \
		.add(digits).add(digits) \
		.add(ve_range).add(digits).add(fake).build()
	
	search_and_assert_eq(ve2, expected, expected)

func test_unusual_regex():
	assert_eq(ve.add("[A-Z0-1!-|]").to_string(), "[A-Z0-1!-|]")

func test_one_of_star_wars_movie_pass():
	assert_ok(ve \
		.find("Star Wars: ") \
		.one_of([
			"The Phantom Menace",
			"Attack of the Clonse",
			"Revenge of the Sith",
			"The Force Awakens",
			"A New Hope",
			"The Empire Strikes Back",
			"Return of the Jedi"
		]) \
		.build().build_result)

	search_and_assert_eq(ve, "Star Wars: The Empire Strikes Back", "Star Wars: The Empire Strikes Back")
	search_and_assert_eq(ve, "Star Wars: Return of the Jedi", "Star Wars: Return of the Jedi")

func test_capture_after_new_line_has_group_number_one_pass():
	var line_break := "\n"
	var some := "some"
	var text := "text"
	assert_ok(ve.line_break().capture().find(some).end_capture().then(text).build().build_result)
	
	gut.p(ve.get_pattern())
	
	for i in ve.search_all(line_break + some + text):
		print(i.get_string())

	assert_eq(ve.search_all(line_break + some + text)[0].get_string(), some)
