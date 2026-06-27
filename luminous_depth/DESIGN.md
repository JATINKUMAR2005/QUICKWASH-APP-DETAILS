---
name: Luminous Depth
colors:
  surface: '#0e1322'
  surface-dim: '#0e1322'
  surface-bright: '#343949'
  surface-container-lowest: '#090e1c'
  surface-container-low: '#161b2b'
  surface-container: '#1a1f2f'
  surface-container-high: '#25293a'
  surface-container-highest: '#2f3445'
  on-surface: '#dee1f7'
  on-surface-variant: '#c2c6d4'
  inverse-surface: '#dee1f7'
  inverse-on-surface: '#2b3040'
  outline: '#8c919e'
  outline-variant: '#424752'
  surface-tint: '#aac7ff'
  primary: '#aac7ff'
  on-primary: '#002f64'
  primary-container: '#1a6bcc'
  on-primary-container: '#eaefff'
  inverse-primary: '#005db9'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#d0bcff'
  on-tertiary: '#3c0091'
  tertiary-container: '#7c4ce6'
  on-tertiary-container: '#f5ecff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#aac7ff'
  on-primary-fixed: '#001b3e'
  on-primary-fixed-variant: '#00458d'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#0e1322'
  on-background: '#dee1f7'
  surface-variant: '#2f3445'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 20px
  gutter: 16px
---

## Brand & Style
The design system is built on a "Luminous Depth" narrative, targeting tech-forward users who value efficiency and high-end aesthetics. The brand personality is professional yet futuristic, evoking a sense of calm reliability through dark, expansive space. 

The visual style is a rigorous implementation of **Glassmorphism**. It utilizes multi-layered translucency to create a sense of physical hierarchy without heavy shadows. The UI feels like a series of etched glass panes floating in a deep, midnight void, using light refraction and vibrant accent glows to guide the user's eye and indicate interactivity.

## Colors
The palette is rooted in a deep midnight navy background that provides the necessary contrast for glass effects to thrive. 

- **Primary Blue (#1A6BCC):** Used for primary actions and core branding elements.
- **Accent Cyan (#06B6D4):** Employed for high-visibility highlights, success states, and secondary action glows.
- **Accent Purple (#8B5CF6):** Used sparingly for premium features, notifications, and subtle gradients.
- **Surface Glass:** All interactive surfaces use a base of `rgba(255, 255, 255, 0.06)` to maintain legibility against the dark backdrop while preserving the translucent quality.

## Typography
The typography system relies on **Inter** for its systematic, utilitarian clarity, which balances the expressive nature of the glass textures. 

Headlines use tighter letter spacing and heavier weights to maintain authority. The body text is optimized at 15px for density and readability on mobile devices. Use white (`#FFFFFF`) for primary text and a reduced opacity white (`rgba(255, 255, 255, 0.7)`) for secondary descriptions to maintain the hierarchy within glass containers.

## Layout & Spacing
The layout follows a fluid-width model optimized for mobile-first interaction. 

- **Grid:** A 4-column grid for mobile and 12-column for desktop. 
- **Margins:** A standard 20px horizontal margin ensures content does not touch the edge of the glass effect.
- **Rhythm:** Vertical spacing follows an 8px scale. Glass cards should have a minimum internal padding of 16px (md) to prevent content from feeling cramped against the frosted borders.
- **Reflow:** On larger screens, glass panels should expand horizontally but maintain a maximum content width of 800px for readability, centering the primary "pane."

## Elevation & Depth
Elevation is expressed through background blur intensity and border luminosity rather than traditional drop shadows.

- **Surface Level:** `backdrop-filter: blur(20px)` and `background: rgba(255, 255, 255, 0.06)`.
- **Border:** A consistent `1px solid rgba(255, 255, 255, 0.12)` acts as a "specular highlight" on the edge of the glass.
- **Floating Depth:** For high-priority elements (modals/tooltips), increase the background opacity to `0.1` and add a subtle cyan glow (`box-shadow: 0 8px 32px 0 rgba(6, 182, 212, 0.15)`).
- **Hierarchy:** Elements appearing "higher" in the stack should have slightly higher blur values (up to 30px) to simulate a greater distance from the background.

## Shapes
This design system utilizes a **Rounded** shape language to soften the futuristic aesthetic and make the "glass" feel approachable. 

The standard corner radius is 0.5rem (8px), which scales up to 1rem (16px) for large glass cards and containers. This consistency ensures that the light refraction at the corners of the glass panes appears uniform across the interface.

## Components
- **Glass Buttons:** Primary buttons use a linear gradient (Primary Blue to Accent Cyan) with a `0.8` opacity to allow the background to bleed through slightly. On press, they scale down to `0.96`.
- **Glass Input Fields:** Surfaces are `rgba(255, 255, 255, 0.04)` with an inner 1px border. Focus state changes the border to Accent Cyan with a soft outer glow.
- **Glass Pills/Chips:** Compact elements with `rounded-xl` (pill-shaped) geometry. Backgrounds are tinted slightly with the primary color (e.g., `rgba(26, 107, 204, 0.2)`).
- **Cards:** The core container. Must feature the 20px blur and 1px white border. 
- **Navigation:** A persistent bottom bar using a high-blur glass effect (30px). Active states are indicated by a 4px thick horizontal blue bar at the top of the icon and a soft blue radial glow behind the icon.
- **Animations:** All transitions use a `cubic-bezier(0.4, 0, 0.2, 1)`. New screens or modals must use a "fade-in + slide-up" entry (20px travel).