class_name IAdsAdapter extends GlapiAdapter

enum AdFormat {
	BANNER,
	INTERSTITIAL,
	REWARDED,
	REWARDED_INTERSTITIAL,
	NATIVE,
	APP_OPEN
}

# 🌟 NUEVO: Estandarizamos las posiciones para el framework
enum BannerPosition {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CENTER
}

signal ad_loaded(format: AdFormat)
signal ad_failed_to_load(format: AdFormat, error_msg: String)
signal ad_closed(format: AdFormat)
signal ad_rewarded(format: AdFormat, reward_type: String, reward_amount: int)
signal ad_impression_recorded(format_name: String, ad_unit_name: String, currency: String, value: float)

func initialize() -> void:
	push_error("AdsProvider: initialize() no implementado.")

# Cambiamos load_ad para que reciba la posición y dejamos show_ad simple
func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM) -> void:
	push_error("AdsProvider: load_ad() no implementado.")

func show_ad(format: AdFormat) -> void:
	push_error("AdsProvider: show_ad() no implementado.")

func hide_ad(format: AdFormat) -> void:
	push_error("AdsProvider: hide_ad() no implementado.")

func destroy_ad(format: AdFormat) -> void:
	push_error("AdsProvider: destroy_ad() no implementado.")
