# AGENTS.md - Glapi Framework Contributor Guide

## Project Overview

**Glapi** es un framework de infraestructura para Godot 4.x que abstrae servicios externos (Ads, Analytics, Storage, Crashlytics, Remote Config, IAP, Game Services).

## Tech Stack

- **Engine**: Godot 4.6+
- **Language**: GDScript
- **Renderer**: GL Compatibility (mobile-first)
- **Pattern**: Adapter Pattern (Service → Interface → Adapter)

## Code Style Guidelines

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `AdsService`, `IAdsAdapter` |
| Interfaces | PascalCase with `I` prefix | `IAdsAdapter`, `IStorageAdapter` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Enums | PascalCase | `AdFormat.BANNER` |
| Variables | snake_case | `ads_adapter`, `_is_initialized` |
| Functions | snake_case | `load_ad()`, `_ready()` |
| Signals | snake_case | `ad_loaded`, `ad_closed` |
| File names | snake_case.gd | `ads_service.gd`, `i_ads_adapter.gd` |

### Type Annotations (Required)

```gdscript
# Variables
var ads_adapter: IAdsAdapter = null
var score: int = 0
var is_loaded: bool = false
var items: Array[String] = []

# Function returns
func get_score() -> int:
    return _score

func initialize() -> void:
    pass
```

### Class Structure

```gdscript
class_name MyService extends GlapiService

signal something_happened(data: String)

@export var config_path: String = ""
var _internal_state: int = 0

func _init(adapter: IMyAdapter) -> void:
    _adapter = adapter

func public_method(param: String) -> void:
    _internal_method()

func _internal_method() -> void:
    pass
```

### Error Handling

```gdscript
# Interface methods - use push_error
func not_implemented() -> void:
    push_error("ServiceName: method() not implemented.")

# Runtime errors
func _on_failure(error_msg: String) -> void:
    push_error("Failed to load ad: " + error_msg)

# Warnings
func deprecated_method() -> void:
    push_warning("This method is deprecated, use new_method() instead.")
```

### Comments
- Use Spanish comments (project convention): `# Inicializamos el servicio`
- Document public APIs with docstrings (optional)
- Code should be self-explanatory

---

## Architecture

### Module Structure

```
addons/Glapi/
├── core/
│   ├── GlapiService.gd      # Base class for services
│   ├── GlapiAdapter.gd      # Base class for adapters
│   └── GlapiEvent.gd       # Base class for events
├── modules/
│   ├── ads/
│   │   ├── ads_service.gd
│   │   ├── i_ads_adapter.gd
│   │   └── adapters/
│   │       ├── mock_ads_adapter.gd
│   │       └── poingstudios_admob_adapter.gd
│   ├── analytics/
│   │   ├── analytics_service.gd
│   │   ├── i_analytics_adapter.gd
│   │   ├── events/
│   │   │   └── *.gd
│   │   └── adapters/
│   └── ... (other modules)
├── auto_Glapi.gd           # Main autoload entry point
└── plugin.gd                # EditorPlugin
```

### Adding a New Module

1. **Create interface**: `modules/<name>/i_<name>_adapter.gd`
2. **Create service**: `modules/<name>/<name>_service.gd`
3. **Create mock adapter**: `modules/<name>/adapters/mock_<name>_adapter.gd`
4. **Create real adapter**: `modules/<name>/adapters/real_<name>_adapter.gd`
5. **Register in auto_Glapi.gd**:
   - Add `var <name>: <Name>Service`
   - Add `_setup_<name>(adapter)` method
   - Add parameter to `initialize()` function
6. **Export in plugin.cfg** if needed

### Service Pattern

```gdscript
class_name AdsService extends GlapiService

func _init(adapter: IAdsAdapter) -> void:
    _adapter = adapter
    _adapter.initialize()
    _connect_signals()

func _connect_signals() -> void:
    _adapter.ad_loaded.connect(_on_ad_loaded)
```

### Adapter Pattern

```gdscript
class_name IAdsAdapter extends GlapiAdapter

enum AdFormat { BANNER, INTERSTITIAL, REWARDED }
enum BannerPosition { TOP, BOTTOM, CENTER }

signal ad_loaded(format: AdFormat)
signal ad_failed_to_load(format: AdFormat, error_msg: String)
signal ad_closed(format: AdFormat)

func load_ad(format: AdFormat, ad_unit_id: String = "") -> void:
    push_error("IAdsAdapter: load_ad() not implemented.")
```

---

## Git Submodule Workflow

```bash
# Make changes in the submodule
cd addons/Glapi
git add .
git commit -m "Your commit message"
git push

# Update main repo reference
cd ../..
git add addons/Glapi
git commit -m "Update Glapi submodule"
git push
```

---

## Testing

- No formal test framework (gdUnit4 not installed)
- Test via `framework_test.tscn` in the main project
- Use Mock Adapters for PC/editor testing
- Physical device testing required for Ads/IAP

---

## Notes

- Type hints are **required** on all functions and variables
- All modules should work with Mock adapters for offline/PC development
- Events are automatically dispatched (e.g., AdImpressionEvent)
- Use `await` for async operations (ads, IAP)
