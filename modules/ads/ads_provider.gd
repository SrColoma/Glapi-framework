class_name AdsProvider extends GlapiProvider

enum AdFormat {
	BANNER,
	INTERSTITIAL,
	REWARDED,
	REWARDED_INTERSTITIAL,
	NATIVE,
	APP_OPEN
}

# Señales que los SDKs reales (o Mocks) emitirán
signal ad_loaded(format: AdFormat)
signal ad_failed_to_load(format: AdFormat, error_msg: String)
signal ad_closed(format: AdFormat)
signal ad_rewarded(format: AdFormat, reward_type: String, reward_amount: int)
signal ad_impression_recorded(format_name: String, ad_unit_name: String, currency: String, value: float)

func initialize() -> void:
	push_error("AdsProvider: initialize() no implementado.")

func load_ad(format: AdFormat, ad_unit_id: String = "") -> void:
	push_error("AdsProvider: load_ad() no implementado.")

func show_ad(format: AdFormat) -> void:
	push_error("AdsProvider: show_ad() no implementado.")
