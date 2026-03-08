# Product Requirements Document (PRD)

## 📌 Resumen del Proyecto
**Nombre del Juego:** [Nombre de tu Juego]
**Plataforma Objetivo:** [Android / iOS / PC]
**Género:** [Ej. Arcade Híbrido-Casual]
**Audiencia:** [Ej. Jugadores ocasionales de 13 a 35 años]
**Visión Principal:** [1-2 oraciones que describan la experiencia central del juego]

---

## 🎯 Objetivos de Negocio y Métricas (KPIs)
* **Objetivo de Retención D1:** [Ej. 35%]
* **Objetivo de Retención D7:** [Ej. 10%]
* **Monetización:** [Ej. Ads (Interstitials/Rewarded) + IAP (No Ads)]
* **Métrica Principal a Medir:** [Ej. Tiempo de vida promedio por sesión]

---

## 🎮 Experiencia de Juego (Core Loop)
1. **Paso 1:** [Ej. El jugador entra y es recibido por el menú principal]
2. **Paso 2:** [Ej. Toca 'Jugar' y se lanza a la partida donde debe esquivar obstáculos]
3. **Paso 3:** [Ej. Al perder, ve su puntaje, se le ofrece un Ad por una segunda vida, y luego vuelve al menú con monedas ganadas]
4. **Paso 4:** [Ej. Gasta monedas en upgrades para su personaje]

---

## 📐 Requisitos de Arte y Audio
* **Estilo Visual:** [Ej. Low Poly / Pixel Art / Cartoon 2D]
* **Paleta de Colores:** [Ej. Colores pastel y vibrantes]
* **Música y SFX:** [Ej. Música alegre y efectos satisfactorios de recompensa]

---

## 🏗️ Arquitectura Técnica (Glapi Framework)

### Módulos a Utilizar
- [ ] **Ads:** (AdMob / AppLovin / etc.)
- [ ] **Analytics:** (Firebase / GameAnalytics / etc.)
- [ ] **Crashlytics:** (Firebase)
- [ ] **Storage:** (Local / Cloud Firebase)
- [ ] **Remote Config:** (Firebase)
- [ ] **IAP:** (Google Play / App Store)

### Eventos de Dominio Clave
*(Lista de eventos que el juego emitirá hacia el framework)*
* `GameStartedEvent`
* `LevelCompletedEvent`
* `PlayerDiedEvent`
* `ItemPurchasedEvent`

---

## 📅 Roadmap (Fases de Desarrollo)

### Fase 1: MVP (Mínimo Producto Viable)
* Movimiento básico y mecánicas core.
* Ciclo de juego completo (Jugar -> Perder -> Menú).
* Integración base de `glapi` (Bootstrap).

### Fase 2: Metajuego y Retención
* Tienda y economía del juego (Monedas, Upgrades).
* Guardado de progreso (`StorageService`).

### Fase 3: Monetización y Analytics
* Integración de Anuncios (Rewarded / Interstitial).
* Tracking de eventos (`AnalyticsService`).

### Fase 4: Pulido y Lanzamiento
* Feedback visual y Game Feel.
* Pruebas en dispositivos reales.
* Publicación.
