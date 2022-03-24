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

func search_and_assert(regex: RegEx, subject: String, expected: String) -> void:
	"""
	Use the provided regex to search for subject and compare against expected.

	Expected MUST be provided, since "" might be a valid expected value
	"""
	var res = regex.search(subject)
	assert_not_null(res)
	if res:
		assert_eq(res.get_string(), expected)

###############################################################################
# Tests                                                                       #
###############################################################################

const VerbalExpressions = preload("res://addons/verbal-expressions/verbal_expressions.gd")
var ve: VerbalExpressions

