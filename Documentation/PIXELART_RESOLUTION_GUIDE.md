# PIXELART RESOLUTION GUIDE

## Übersicht

Dieses Template ist für Pixelart 2D Games optimiert. Die richtige Resolution ist entscheidend für den authentischen Retro-Look.

## Aktuelle Resolution

**640×360 (16:9 Format)**
- Native Viewport-Größe
- Größere Pixelart mit mehr Details
- Integer Scaling-freundlich
- Perfekt für UI-reiche Spiele wie Card Games

## Gängige Pixelart-Resolutions

### Für 2D Side Scroller (wie Celeste)

| Resolution | Aspect Ratio | Beschreibung | Beispiele |
|------------|--------------|--------------|-----------|
| **320×180** | 16:9 | Sehr klein, authentischer Retro-Look | Celeste |
| **480×270** | 16:9 | Guter Mittelweg | - |
| **640×360** | 16:9 | Größere Pixelart, mehr Details (Template Standard) | - |
| **256×224** | 4:3 | SNES-ähnlich, klassischer Look | Super Mario World |
| **400×240** | 5:3 | GBA-ähnlich | - |

### Für Card Games / UI-lastige Spiele

| Resolution | Aspect Ratio | Beschreibung |
|------------|--------------|--------------|
| **480×270** | 16:9 | Gut für UI und Menüs |
| **640×360** | 16:9 | Mehr Platz für Cards/UI (Template Standard) |
| **320×240** | 4:3 | Retro Card Game Look |

## Integer Scaling

**Kritisch für scharfe Pixel!** Die native Resolution sollte sich ganzzahlig auf gängige Monitor-Auflösungen skalieren lassen.

### Scaling-Faktoren für 640×360 (Template Standard)

| Faktor | Output Resolution | Monitor |
|--------|-------------------|---------|  
| **1x** | 640×360 | Native (klein) |
| **2x** | 1280×720 | HD |
| **3x** | 1920×1080 | Full HD ✓ Perfekt! |
| **4x** | 2560×1440 | 2K |
| **6x** | 3840×2160 | 4K ✓ Perfekt! |

### Scaling-Faktoren für 480×270

| Faktor | Output Resolution | Monitor |
|--------|-------------------|---------|
| **1x** | 480×270 | Native (sehr klein) |
| **2x** | 960×540 | HD-ready |
| **3x** | 1440×810 | 2K |
| **4x** | 1920×1080 | Full HD ✓ Perfekt! |
| **5x** | 2400×1350 | - |
| **6x** | 2880×1620 | - |
| **8x** | 3840×2160 | 4K ✓ Perfekt! |

### Scaling-Faktoren für 320×180 (Celeste-Style)

| Faktor | Output Resolution | Monitor |
|--------|-------------------|---------|
| **2x** | 640×360 | - |
| **3x** | 960×540 | HD-ready |
| **4x** | 1280×720 | HD |
| **6x** | 1920×1080 | Full HD ✓ Perfekt! |
| **9x** | 2880×1620 | - |
| **12x** | 3840×2160 | 4K ✓ Perfekt! |

## Resolution ändern

### In project.godot

```ini
[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/stretch/mode="canvas_items"  # Für Pixelart
window/stretch/aspect="keep"        # Behält Aspect Ratio
```

### Texture-Import-Einstellungen

**Wichtig für Pixelart:**
- **Filter**: `Nearest` (niemals `Linear` - macht Pixel verschwommen!)
- **Mipmaps**: Deaktiviert
- **Compress Mode**: Lossless oder Uncompressed

Im Template bereits konfiguriert in `[importer_defaults]`:
```ini
texture={
    "compress/mode": 0,           # Keine Kompression
    "mipmaps/generate": false,    # Keine Mipmaps
    # Filter wird per-texture gesetzt, aber Standard sollte Nearest sein
}
```

### SceneManager Zelda-Transition Dimensionen

Wenn du die Resolution änderst, passe auch die Zelda-Transition Konstanten an:

In [Autoloads/SceneManager.gd](Autoloads/SceneManager.gd):
```gdscript
const LEVEL_H:int = 360  # Deine Viewport-Höhe
const LEVEL_W:int = 640  # Deine Viewport-Breite
```

## Best Practices

### 1. Wähle eine Resolution basierend auf deinem Art Style

- **Sehr Retro (NES/GB-Style)**: 160×144, 256×224
- **Moderater Retro (SNES/GBA)**: 320×180, 400×240
- **Modern Pixelart**: 480×270, 640×360

### 2. Teste Integer Scaling

Stelle sicher, dass deine gewählte Resolution gut auf gängige Monitor-Größen skaliert:
- Full HD (1920×1080) - Am wichtigsten!
- 4K (3840×2160)

### 3. UI-Design berücksichtigen

Kleinere Resolutions = weniger Platz für UI:
- **320×180**: Minimalistisches UI erforderlich
- **480×270**: Gutes Gleichgewicht
- **640×360**: Viel Platz für Details

### 4. Sprites & Assets entsprechend erstellen

Deine Sprite-Größen sollten zur Resolution passen:
- Bei 320×180: 16×16 oder 32×32 Sprites
- Bei 480×270: 16×16, 24×24, oder 32×32 Sprites
- Größere Sprites bei höheren Resolutions

## Häufige Probleme

### Verschwommene Pixel

**Problem**: Pixel sehen unscharf aus
**Lösung**: 
- Texture Filter auf `Nearest` setzen
- `window/stretch/mode="canvas_items"` verwenden
- Integer Scaling sicherstellen

### UI zu klein/groß

**Problem**: UI-Elemente passen nicht zum Rest
**Lösung**: 
- UI in passender Pixel-Größe designen
- Control-Nodes mit passenden Anchors verwenden
- Theme mit Pixel-Font erstellen

### Unterschiedliche Zoom-Level

**Problem**: Game sieht auf verschiedenen Monitoren unterschiedlich aus
**Lösung**:
- Integer Scaling erzwingen in Godot Project Settings
- Fullscreen mit `aspect="keep"` verwenden
- Letterboxing akzeptieren (schwarze Balken)

## Empfehlung für dieses Template

**Current: 640×360** ist ein guter Standard weil:
- ✓ Perfektes 3x Scaling auf Full HD (1920×1080)
- ✓ Perfektes 6x Scaling auf 4K (3840×2160)
- ✓ Viel Platz für UI, Karten und Gameplay-Elemente
- ✓ Authentischer Pixelart-Look mit mehr Details
- ✓ Ideal für Card Games und UI-lastige Spiele
- ✓ Gut lesbare Texte und Icons

**Alternative: 480×270** wenn du:
- Kleinere Sprites bevorzugst
- Noch mehr Retro-Look willst
- Einfacheres UI-Design hast

**Alternative: 320×180** wenn du:
- Extremen Retro-Look willst (wie Celeste)
- Sehr einfache Sprites verwendest
- Minimalistisches UI-Design bevorzugst
