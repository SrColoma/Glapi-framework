class_name IAdsAdapter extends GlapiAdapter

enum AdFormat {
	BANNER,
	INTERSTITIAL,
	REWARDED,
	REWARDED_INTERSTITIAL,
	NATIVE,
	APP_OPEN
}

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

enum BannerSize {
	BANNER,             # 320x50 (Teléfonos)
	LARGE_BANNER,       # 320x100
	MEDIUM_RECTANGLE,   # 300x250 (Ideal para menús de pausa)
	FULL_BANNER,        # 468x60 (Tablets)
	LEADERBOARD         # 728x90 (Tablets)
}

signal ad_loaded(format: AdFormat)
signal ad_failed_to_load(format: AdFormat, error_msg: String)
signal ad_closed(format: AdFormat)
signal ad_rewarded(format: AdFormat, reward_type: String, reward_amount: int)
signal ad_impression_recorded(format_name: String, ad_unit_name: String, currency: String, value: float)

func initialize() -> void:
	push_error("Adsadapter: initialize() no implementado.")

# Cambiamos load_ad para que reciba la posición y dejamos show_ad simple
func load_ad(format: AdFormat, ad_unit_id: String = "", position: BannerPosition = BannerPosition.BOTTOM, size: BannerSize = BannerSize.BANNER) -> void:
	push_error("Adsadapter: load_ad() no implementado.")
	
func show_ad(format: AdFormat) -> void:
	push_error("Adsadapter: show_ad() no implementado.")

func hide_ad(format: AdFormat) -> void:
	push_error("Adsadapter: hide_ad() no implementado.")

func destroy_ad(format: AdFormat) -> void:
	push_error("Adsadapter: destroy_ad() no implementado.")
