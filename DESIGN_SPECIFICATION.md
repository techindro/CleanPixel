# CleanPixel AI — UI/UX Design System Specification & Layout Architecture

**Author:** Principal Product Designer & UI/UX Architect  
**Version:** 2.4.0 (Enterprise SaaS / Silicon Valley Standard)  
**Theme:** Deep Slate Dark Mode with Electric Blue Chroma Accents  
**Target Viewports:** Mobile (360px–480px), Tablet (768px–1024px), Desktop (1280px–1920px+)

---

## 1. Design Philosophy & Aesthetic Blueprint

CleanPixel AI embodies the sleek, distraction-free aesthetic pioneered by elite Silicon Valley creative suites (Linear, Raycast, Figma). The interface operates on an **OLED-friendly Deep Slate** canvas (`#0F172A`), establishing depth through optical luminance stepping rather than heavy drop shadows. High-frequency interactions are amplified using **Electric Blue chromatic tokens** (`#38BDF8` / `#2563EB`) that guide optical attention to primary creative nodes.

### 1.1 Color Tokens & Luminance Architecture

```css
:root {
  /* Surface Luminance Steps */
  --surface-canvas:      #0B0F19; /* Ultra-deep background */
  --surface-base:        #0F172A; /* Slate foundation */
  --surface-panel:       #1E293B; /* Card & container panels */
  --surface-panel-elev:  #243248; /* Floating contextual menus */
  --surface-glass:       rgba(30, 41, 59, 0.72); /* Glassmorphism backdrop */
  
  /* Chroma Accent: High-Contrast Electric Blue */
  --chroma-primary:      #38BDF8; /* Electric Cyan-Blue 400 */
  --chroma-primary-glow: rgba(56, 189, 248, 0.28);
  --chroma-action:       #2563EB; /* Deep Electric Blue 600 */
  --chroma-action-hover: #1D4ED8;
  --chroma-neon-trace:   rgba(56, 189, 248, 0.45); /* Mask inpainting stroke */
  
  /* Semantic Tints */
  --semantic-success:    #10B981;
  --semantic-warning:    #F59E0B;
  --semantic-danger:     #EF4444;
  --semantic-pro-gold:   linear-gradient(135deg, #F59E0B 0%, #EC4899 50%, #8B5CF6 100%);
  
  /* Monochrome Typography Hierarchy */
  --text-primary:        #F8FAFC; /* 98% Luminance */
  --text-secondary:      #94A3B8; /* 65% Slate Neutral */
  --text-muted:          #64748B; /* 45% Sub-label Neutral */
  --text-inverse:        #0F172A;
  
  /* Border & Radii Tokens */
  --radius-container:    16px;   /* Soft rounded panels */
  --radius-pill:         9999px; /* Badges & tool nodes */
  --radius-action:       12px;   /* Buttons & inputs */
  --border-subtle:       1px solid rgba(255, 255, 255, 0.08);
  --border-glow:         1px solid rgba(56, 189, 248, 0.4);
}
```

---

## 2. Core Component Architecture & Interaction States

### 2.1 The Retention Welcome Appbar
* **Spatial Layout:** Sticky top header (64px desktop / 56px mobile), `padding: 0 24px`, backdrop blur `16px`.
* **Brand Identity:** Minimalist 32px geometric icon with inner optical refraction + crisp 15px font (`Plus Jakarta Sans 700`, tracking `-0.02em`).
* **Subscription Gating Anchor Badge:**
  * Pill contour (`padding: 4px 12px`, `border-radius: 9999px`).
  * Gradient boundary contour created with `conic-gradient` / `linear-gradient(#F59E0B, #EC4899, #8B5CF6)`.
  * Micro-sparkle pulse animation (3s infinite loop).
  * Hover state: Elevates luminance by 12% and reveals credit quota (`"PRO • 120 / 150 Credits"`).

### 2.2 The Compact Interactive Canvas Container
Centralized viewport container bounded by 16px corner radii and soft inner ambient occlusion.

| State | Visual Manifestation & Micro-Interactions |
| :--- | :--- |
| **Idle Upload** | Responsive dashed border (`2px dashed rgba(56,189,248,0.3)`), pulsating drop-zone vector glyph, dynamic drag-over scale (`scale(1.01)` + `#38BDF8` border flood), multi-format badges (PNG, JPEG, WebP, MP4). |
| **Drawing Active** | Active source asset rendered with pixel-grid clarity. Cursor replaced with a dynamic circular brush reticle matching exact stroke-width. Traced strokes rendered with semi-transparent neon glow (`rgba(56, 189, 248, 0.55)` with `stroke-linecap: round; stroke-linejoin: round`). Instant HUD display of mask coverage percentage. |
| **Processing** | Source asset blurred with `backdrop-filter: blur(8px)`. Fluid shimmering skeleton overlay (`linear-gradient(90deg, transparent, rgba(56, 189, 248, 0.15), transparent)` at 1.4s cycle). High-speed AI scanning laser bar oscillating vertically across the inpaint mask bounding box. |
| **Comparison / Result** | Interactive side-by-side or split-slider comparing original watermarked asset against inpaint-cleaned output with 1-click HD download. |

### 2.3 The Floating Contextual Actions Toolbar
* **Placement:** Bottom-anchored floating pill bar (floating 24px above bottom viewport on mobile, pinned to canvas bottom-center on desktop).
* **Backdrop:** Ultra-glassmorphism (`rgba(15, 23, 42, 0.85)` + `backdrop-filter: blur(20px)`).
* **Controls Row:**
  * **Stroke-Width Controller:** Micro range-slider (8px to 96px) + quick preset pills (Small: 16px, Medium: 32px, Large: 64px) with real-time brush preview node.
  * **History Stack Controllers:** Undo (`Cmd+Z`) and Redo (`Cmd+Shift+Z`) with disabled optical opacity (`0.35`) and haptic pulse on trigger.
  * **Canvas Tools:** Brush Mask, Eraser Mode, Clear Mask, Zoom / Pan toggle.

### 2.4 The Async Action Sub-Panel
* **Geometry:** Full-bleed action container with ergonomic 52px touch-height button.
* **Idle State:** High-contrast Electric Blue button with gradient flare (`linear-gradient(135deg, #38BDF8 0%, #2563EB 100%)`), text: `"Remove Watermark • 1 Credit"`, hover sheen animation.
* **Computing State (Stepper Micro-Copy):**
  * Button transforms into an integrated multi-phase status stepper with smooth micro-fade transitions:
    * **Step 1 (0–25%):** `"Segmenting watermark contours..."`
    * **Step 2 (25–65%):** `"Synthesizing neural inpaint tensor..."`
    * **Step 3 (65–90%):** `"Reconstructing background textures..."`
    * **Step 4 (90–100%):** `"Finalizing 4K pixel blending..."`
  * Embedded animated radial progress ring + micro-percentage metric.

---

## 3. Ergonomics & Handheld Accessibility Architecture

1. **48px Minimum Hit Targets:** All interactive controls (toolbar buttons, undo/redo, file triggers) maintain a minimum touch bounding box of `48px × 48px` to guarantee zero miss-taps (WCAG 2.5.5).
2. **Thumb-Zone Optimization:** Critical action buttons and the floating contextual toolbar are positioned within the **Natural Thumb Arc** (bottom 35% of mobile screen).
3. **High-Contrast Typography:** Strict adherence to WCAG AAA contrast ratio (`> 7:1` for primary text, `> 4.5:1` for secondary metadata).
4. **Haptic & Keyboard Accelerators:** Full keyboard parity (`[B]` Brush, `[E]` Eraser, `[Ctrl+Z]` Undo, `[Space+Drag]` Pan) with ARIA live regions for async state announcements.
