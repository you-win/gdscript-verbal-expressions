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

func test_utils():
	ve.start_of_line().maybe("/").word().end_of_line()
	
	assert_eq(ve._prefixes, ["^"])
	assert_eq(ve._source, ["(?:\\/)", "?", "(?:\\w+)"])
	assert_eq(ve._suffixes, ["$"])
	
	assert_eq(ve.to_string(), "^(?:\\/)?(?:\\w+)$")
	
	assert_build_ok(ve.build())
	
	assert_eq(ve.get_pattern(), "^(?:\\/)?(?:\\w+)$")
	assert_true(ve.is_valid())
	
	ve.clear()
	
	assert_true(ve._prefixes.empty())
	assert_true(ve._source.empty())
	assert_true(ve._suffixes.empty())
	
	# The pattern doesn't actually get cleared after calling clear?
	assert_true(ve.get_pattern().length() > 0)
	assert_false(ve.is_valid())
	
	#region Static funcs
	
	var array := ["hello", " ", "world"]
	assert_eq(ve._build_string(array), "hello world")
	
	assert_eq(ve._count_occurrences_of("s fsd s", "s"), 3)
	
	#endregion

func test_something():
	assert_build_ok(ve.something().build())
	
	assert_not_null(ve.search("Null object doesn't have something"))
	assert_not_null(ve.search("empty string doesn't have something"))
	assert_not_null(ve.search("a"))

func test_anything():
	assert_build_ok(ve.start_of_line().anything().build())
	
	search_and_assert_eq(ve, "what")
	search_and_assert_eq(ve, "")
	search_and_assert_eq(ve, " ")

func test_anything_but():
	assert_build_ok(ve.start_of_line().anything_but("w").build())
	
	search_and_assert_eq(ve, "toaster")
	search_and_assert_eq(ve, "straw", "stra")
	search_and_assert_eq(ve, "what", "")
	search_and_assert_eq(ve, "w", "")

func test_something_but():
	assert_build_ok(ve.something_but_not("a").build())
	
	assert_null(ve.search(""))
	assert_null(ve.search("a"))
	search_and_assert_eq(ve, "b")
	search_and_assert_eq(ve, "abc", "bc")

func test_start_of_line():
	assert_build_ok(ve.start_of_line().then("a").build())
	
	assert_null(ve.search(""))
	search_and_assert_eq(ve, "a")
	search_and_assert_eq(ve, "ab", "a")
	assert_null(ve.search("bab"))
	
	ve.clear()
	
	assert_build_ok(ve.start_of_line(false).then("a").build())
	search_and_assert_eq(ve, "bab", "a")
	assert_null(ve.search("b"))

func test_end_of_line():
	assert_build_ok(ve.find("a").end_of_line().build())
	
	search_and_assert_eq(ve, "bba", "a")
	assert_null(ve.search("bab"))
	assert_null(ve.search("b"))
	assert_null(ve.search(""))
	
	ve.clear()
	
	assert_build_ok(ve.find("a").end_of_line(false).build())
	
	search_and_assert_eq(ve, "bba", "a")
	search_and_assert_eq(ve, "bab", "a")
	assert_null(ve.search("b"))
	assert_null(ve.search(""))

func test_range():
	assert_build_ok(ve.RANGE(["a", "c"]).build())
	
	search_and_assert_eq(ve, "a")
	search_and_assert_eq(ve, "b")
	search_and_assert_eq(ve, "c")
	assert_null(ve.search("d"))
	assert_null(ve.search("A"))
	assert_null(ve.search("1"))
	assert_null(ve.search(" "))
	assert_null(ve.search(""))

func test_maybe():
	assert_build_ok(ve.start_of_line().then("a").maybe("b").build())
	
	search_and_assert_eq(ve, "abc", "ab")
	search_and_assert_eq(ve, "acb", "a")
	assert_null(ve.search("b"))

func test_any_of():
	assert_build_ok(ve.start_of_line().then("a").any_of("xyz").anything().end_of_line().build())
	
	search_and_assert_eq(ve, "axbc")
	assert_null(ve.search("abc"))
	
	ve.clear()
	
	assert_build_ok(ve.start_of_line().then("a").any("xyz").anything().end_of_line().build())
	
	search_and_assert_eq(ve, "ayzzxbc")
	assert_null(ve.search("a"))

func test_or():
	assert_build_ok(ve.start_of_line().then("abc").OR("def").build())
	
	search_and_assert_eq(ve, "abc")
	search_and_assert_eq(ve, "def")
	search_and_assert_eq(ve, "abcdef", "abc")
	search_and_assert_eq(ve, "defabc", "def")
	search_and_assert_eq(ve, "abc def", "abc")
	assert_null(ve.search("ade"))

func test_line_break():
	assert_build_ok(ve.start_of_line().then("abc").line_break().then("def").build())
	
	# Linux
	search_and_assert_eq(ve, "abc\ndef")
	# Windows
	search_and_assert_eq(ve, "abc\r\ndef")
	# Mac
	search_and_assert_eq(ve, "abc\r\rdef")
	assert_null(ve.search("abcdef"))
	assert_null(ve.search("ab\ncdef"))
	
	ve.clear()
	
	assert_build_ok(ve.start_of_line().then("abc").br().then("def").build())
	
	search_and_assert_eq(ve, "abc\ndef")

func test_tab():
	assert_build_ok(ve.start_of_line().tab().then("abc").build())
	
	search_and_assert_eq(ve, "\tabc")
	assert_null(ve.search("abc"))

func test_word():
	assert_build_ok(ve.start_of_line().word().build())
	
	search_and_assert_eq(ve, "abc123")
	assert_null(ve.search("@#"))
	assert_null(ve.search(""))

func test_multiple():
	#region One or more times
	
	assert_build_ok(ve.start_of_line().multiple("abc").build())
	
	search_and_assert_eq(ve, "abc once", "abc")
	search_and_assert_eq(ve, "abcabc", "abcabc")
	assert_null(ve.search("def"))
	
	ve.clear()
	
	#endregion
	
	#region One or more times when too many params are passed
	
	assert_build_ok(ve.start_of_line().multiple("abc", [1, 2, 3]).build())
	
	search_and_assert_eq(ve, "abc once", "abc")
	search_and_assert_eq(ve, "abcabc", "abcabc")
	assert_null(ve.search("def"))
	
	ve.clear()
	
	#endregion
	
	#region 2-3 times
	
	assert_build_ok(ve.start_of_line().multiple("abc", [2, 3]).build())
	
	search_and_assert_eq(ve, "abcabc")
	search_and_assert_eq(ve, "abcabcabc")
	search_and_assert_eq(ve, "abcabcabcabc", "abcabcabc")
	assert_null(ve.search("abc"))
	
	ve.clear()
	
	#endregion
	
	#region Twice exactly to end of line
	
	assert_build_ok(ve.start_of_line().multiple("abc", [2]).end_of_line().build())
	
	search_and_assert_eq(ve, "abcabc")
	assert_null(ve.search("abc"))
	assert_null(ve.search("abcabcabc"))
	
	ve.clear()
	
	#endregion
	
	#region 2-3 times to end of line
	
	assert_build_ok(ve.start_of_line().multiple("abc", [2, 3]).end_of_line().build())
	
	search_and_assert_eq(ve, "abcabc")
	assert_null(ve.search("abcabcabcabc"))
	
	#endregion
