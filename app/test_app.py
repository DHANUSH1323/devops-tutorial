from app import greeting


def test_greeting_defaults_to_world_when_name_is_none():
    assert greeting(None) == "Hello, world!"


def test_greeting_defaults_to_world_when_name_is_empty():
    assert greeting("") == "Hello, world!"


def test_greeting_defaults_to_world_when_name_is_whitespace():
    assert greeting("   ") == "Hello, world!"


def test_greeting_uses_provided_name():
    assert greeting("Dhanush") == "Hello, Dhanush!"
