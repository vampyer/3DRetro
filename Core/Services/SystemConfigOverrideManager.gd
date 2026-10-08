class_name SystemConfigOverrideManager
extends RefCounted

## System Configuration & Per-Game Override Manager in GDScript.

var _configs: Dictionary = {}

func get_system_config(platform_id: String) -> Dictionary:
    if _configs.has(platform_id):
        return _configs[platform_id]
    return {
        "platform": platform_id,
        "mode": "Standalone",
        "aspect": "4:3",
        "bezel": "ConsoleThemed",
        "shader": "CRT-Scanlines",
        "auto_pad": true,
        "args": ""
    }

func save_system_config(config: Dictionary) -> void:
    if config.has("platform"):
        _configs[config["platform"]] = config
