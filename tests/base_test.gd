extends "res://addons/gut/test.gd"

# https://github.com/bitwes/Gut/wiki/Quick-Start

###############################################################################
# Builtin functions                                                           #
###############################################################################

func before_all():
	pass

func before_each():
	ve = VerbalExpressions.new()

func after_each():
	pass

func after_all():
	pass

###############################################################################
# Utils                                                                       #
###############################################################################

func assert_ok(input) -> bool:
	assert_eq(input, OK)
	
	return input == OK

func assert_build_ok(regex: VerbalExpressions) -> bool:
	assert_eq(regex.build_result, OK)
	
	return regex.build_result == OK

func assert_eq_and_return(a, b) -> bool:
	assert_eq(a, b)
	if a == b:
		return true
	return false

func search_and_assert_eq(regex: VerbalExpressions, input: String, expected = false) -> bool:
	"""
	Search the input using a given regex. If the search was successful, check against
	the input or the expected param
	
	Params:
		regex: VerbalExpressions - The VerbalExpressions regex object to use. Should be precompiled
		input: String - The text to search
		expected - Use input as the comparison: bool | The string to compare against String
	"""
	var res = regex.search(input)
	assert_not_null(res)
	if not res:
		return false
	
	assert_eq(res.get_string(), expected if expected is String else input)
	
	return res.get_string() == expected if expected is String else input

###############################################################################
# Tests                                                                       #
###############################################################################

const VerbalExpressions = preload("res://addons/verbal-expressions/verbal_expressions.gd")
var ve: VerbalExpressions
