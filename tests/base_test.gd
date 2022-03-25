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

func assert_ok(input) -> void:
	assert_eq(input, OK)

func search_and_assert_eq(regex: VerbalExpressions, input: String, expected: String) -> void:
	var res = regex.search(input)
	assert_not_null(res)
	if res:
		assert_eq(res.get_string(), expected)

###############################################################################
# Tests                                                                       #
###############################################################################

const VerbalExpressions = preload("res://addons/verbal-expressions/verbal_expressions.gd")
var ve: VerbalExpressions
