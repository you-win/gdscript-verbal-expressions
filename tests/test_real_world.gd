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
	if not assert_build_ok(ve \
			.start_of_line() \
			.then("http") \
			.maybe("s") \
			.then("://") \
			.maybe("www.") \
			.anything_but(" ") \
			.end_of_line() \
			.build()):
		return
	search_and_assert_eq(ve, "https://godotengine.org/")
	search_and_assert_eq(ve, "https://www.godotengine.org/")

func test_url_fail():
	if not assert_build_ok(ve \
			.start_of_line() \
			.then("http") \
			.maybe("s") \
			.then("://") \
			.maybe("www.") \
			.anything_but(" ") \
			.end_of_line() \
			.build()):
		return
	assert_null(ve.search("This is neat"))

func test_telephone_number_pass():
	if not assert_build_ok(ve \
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
			.build()):
		return
	
	search_and_assert_eq(ve, "+097 234 243")
	search_and_assert_eq(ve, "+097234243")
	search_and_assert_eq(ve, "+097-234-243")

func test_telephone_number_fail():
	if not assert_build_ok(ve \
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
			.build()):
		return
	
	assert_null(ve.search("hello world"))

func test_complex_multiple_capture_pass():
	var expected := "3\t4\t1\thttp://localhost:20001\t1\t63528800\t0\t63528800\t1000000000\t0\t63528800\tSTR1"
	
	if not assert_build_ok(ve \
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
			.capt().find("STR").RANGE(["0", "2"]).count(["1"]).end_capture().build()):
		return
	
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
	if not assert_build_ok(ve \
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
			.build()):
		return

	search_and_assert_eq(ve, "Star Wars: The Empire Strikes Back")
	search_and_assert_eq(ve, "Star Wars: Return of the Jedi")

func test_capture_after_new_line_has_group_number_one_pass():
	var line_break := "\n"
	var some := "some"
	var text := "text"
	
	if not assert_build_ok(ve.line_break().capture().find(some).end_capture().then(text).build()):
		return

	var res = ve.search_all(line_break + some + text)
	assert_not_null(res)
	if not assert_eq_and_return(res.size(), 1):
		return
	
	var regex_match = res[0]
	if not assert_eq_and_return(regex_match.strings.size(), 2):
		return
	
	assert_eq(regex_match.strings[1], some)

func test_capture_after_new_line_has_named_group():
	var line_break := "\n"
	var some := "some"
	var text := "text"
	var capture_name := "name"
	
	if not assert_build_ok(ve.line_break().capture(capture_name).find(some).end_capture().then(text).build()):
		gut.p(ve.to_string())
		return

	var res = ve.search_all(line_break + some + text)
	assert_not_null(res)
	if not assert_eq_and_return(res.size(), 1):
		return
	
	var regex_match = res[0]
	if not assert_eq_and_return(regex_match.strings.size(), 2):
		return
	
	assert_eq(regex_match.get_string(capture_name), some)
