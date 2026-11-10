# Dodu — Technical notes

These notes describe the design constraints and selected implementation details behind **Dodu**. For gameplay and an introduction to the project, see the [README](README.md).

## Design and rendering architecture

Dodu is written in **QB64**, with a logical viewport designed around **80 × 64 pixels**. The game does not rely on a conventional 3D engine. Instead, a custom `Viewport` abstraction handles composition, clipping, panning, and graphical layers, including animated elements.

The separation between the game image and its final presentation makes it possible to reuse the same gameplay logic across different visual modes and display effects.

## Graphics modes and artwork

Artwork is developed in **EGA** first. Other modes use corresponding assets with the **same relative filenames and directory structure**, so choosing a mode amounts to selecting its asset directory.

The principal asset families are **EGA, CGA, MCGA, and Hercules**. More restrictive modes are adapted by hand: a palette conversion alone often fails to preserve the legibility or appearance of a sprite. A TI-83-inspired presentation is also available.

Monochrome CGA is an exception. It is obtained by mapping the four CGA palette entries to four green intensity levels, rather than by maintaining a separate set of images. The current approximation uses green values of 0, 85, 170, and 255.

An asset coverage check can therefore use EGA as its reference, flagging missing counterparts in the other directories. Modification times may suggest assets worth reviewing, but they do not establish that a hand-adapted sprite is obsolete.

<!-- Add the actual asset root and the name/usage of the coverage-checking script once committed. -->

## Display emulation

Graphics modes and display effects are separate concerns. In addition to selecting artwork and palettes, the `Viewport` can simulate **scanlines** and, for the TI-83-inspired display, a **pixel grid**. These are presentation effects; they do not require duplicate game assets.

This is an approximation of the appearance of historical hardware, not an attempt at cycle-accurate display emulation. In particular, the green CGA palette is a simple visual approximation inspired by an Epson Equity I+ with a green monitor.

<!-- Add comparison screenshots showing the same scene with and without display effects. -->

## Stereoscopic rendering

The renderer can produce **side-by-side left-eye and right-eye images**. Each graphical depth layer receives a different horizontal displacement for each eye. This creates binocular disparity without reconstructing the scene as 3D geometry.

The technique is deliberately limited: a layer behaves approximately as a flat plane at a chosen depth. Nevertheless, it works well for graphics that can be organized into a few depth planes, and the game remains playable without stereoscopy.

### Experimental smartphone viewing setup

The working demonstration uses the following pipeline:

1. QB64 renders side-by-side frames and saves them as JPEG images.
2. A PHP endpoint serves the latest image as an MJPEG stream (`multipart/x-mixed-replace`).
3. A smartphone browser on the same local network displays the stream.
4. A simple phone-based VR headset directs one half of the image to each eye.

In the tested setup, the transmitted images are **540 × 192 pixels**, at approximately **25 frames per second**, with no discernible latency during use. These figures describe one particular configuration, not a general performance guarantee.

This approach prioritizes ease of implementation and readily available tools over compression efficiency. It requires neither a dedicated phone app nor a VR runtime or head tracking.

<!-- Add actual PHP script names, launch instructions, and network URL once verified against the repository. -->

## Input and progression

Keyboard and joystick inputs are handled through an input abstraction rather than being hard-wired into the gameplay logic.

Progress is represented by a **four-playing-card password**. The card-selection interface deliberately evokes password systems from older games.

<!-- Add verified control mappings and password details only if useful to developers. -->

## Music

The music is composed and arranged as **MIDI**, consistent with the project's retro-computing inspiration. The precise playback setup may depend on the platform and available MIDI synthesizer.

<!-- Document the actual playback mechanism, required soundfont/synthesizer, and any bundled music assets. -->

## Scope

Dodu's alternate display modes and stereoscopic output are implemented features, but they are optional. Proposed ports to other architectures or to JavaScript are not part of the currently documented working setup.

The project is a playable puzzle game, not a general-purpose emulator or VR engine.
