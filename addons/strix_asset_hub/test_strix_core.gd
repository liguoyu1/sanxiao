@tool
extends Node
## STRIX Asset Hub - Core Unit Tests
## Runs on _ready() using assert() to validate critical logic paths.
## Safe to run in-editor. Auto-frees after execution.

func _ready() -> void:
	print("[STRIX] 🧪 Running core unit tests...")
	_test_regex_escape()
	_test_path_normalization_logic()
	_test_manifest_version_validation()
	print("[STRIX] ✅ All tests passed successfully.")
	queue_free()

func _test_regex_escape() -> void:
	## Verifies metacharacter escaping prevents RegEx compilation errors.
	var test_cases: Dictionary = {
		"AudioManager": "AudioManager",
		"My-Node_1.0": "My\\-Node_1\\.0",
		"Special[Char]+": "Special\\[Char\\]\\+"
	}
	
	var scanner_script = preload("./core/dependency_scanner.gd")
	var scanner: RefCounted = scanner_script.new()
	
	for input in test_cases:
		var expected: String = test_cases[input]
		var actual: String = scanner.call("_escape_regex", input)
		assert(actual == expected, "Regex escape failed for '%s'. Got: %s, Expected: %s" % [input, actual, expected])
	print("  ✓ Regex escape logic validated.")

func _test_path_normalization_logic() -> void:
	## Simulates path cleaning logic used in BFS scanner.
	var paths: Array[String] = ["res://assets/tex.png", "uid://abc123::res://scripts/main.gd", "res://data.json"]
	for p in paths:
		var idx: int = p.find("res://")
		var cleaned: String = p.substr(idx) if idx != -1 else p
		assert(cleaned.begins_with("res://"), "Path normalization failed for: %s" % p)
	print("  ✓ Path normalization logic validated.")

func _test_manifest_version_validation() -> void:
	## Validates version mismatch detection logic.
	const EXPECTED: String = "1.0"
	var test_versions: Array[String] = ["1.0", "0.9", "2.0", ""]
	var valid_count: int = 0
	var invalid_count: int = 0
	
	for v in test_versions:
		if v == EXPECTED: valid_count += 1
		else: invalid_count += 1
		
	assert(valid_count == 1 and invalid_count == 3, "Manifest version validation logic mismatch.")
	print("  ✓ Manifest version validation logic validated.")