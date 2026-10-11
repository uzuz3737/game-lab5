# Asset sources and modifications

The game is based on Silver Demon Studios' 3D Platformer Starter Kit.
Source: https://github.com/SilverDemons-PK/3D-Platformer-Kit
Asset listing: https://store.godotengine.org/asset/the-silver-demons/platformer-3d-starter-kit/
The repository contains an MIT license; its complete text is retained in STARTER_LICENSE.md.
The unmodified starter controller is retained in starter_player.gd.txt for comparison.
scripts/player.gd adapts its movement, camera-relative input, double-jump, model turning,
and Idle / Run / Jump / Flip state logic. Movement runs in the physics loop; coyote time,
jump buffering, collision-aware camera and checkpoint respawn were added.

Player: Hooded Adventurer by Quaternius, downloaded from Poly Pizza.
https://poly.pizza/m/y9KWOVG21R
https://static.poly.pizza/3186b8e9-afd5-4d48-846c-b2b530cd23e2.glb
License: CC0 Public Domain, as listed on the model page.

Animation remapping:
- CharacterArmature|Idle → courier/Idle, looping.
- CharacterArmature|Run → courier/Run, looping.
- A held pose derived from Idle → courier/Jump, with a jump stretch tween.
- CharacterArmature|Roll → courier/Flip, non-looping and played at 2x speed for the double jump.
All animations use the new model's own skeleton; no Gobot bone paths are retained.

Environment meshes, scene layouts, UI and synthesized sound effects were created for this lab.
They use Godot primitive low-poly meshes and shared materials with no large terrain textures.
The bundled Noto Sans Thai font is from the Google Fonts repository (SIL Open Font License).
https://github.com/google/fonts/tree/main/ofl/notosansthai
The full license is retained in FONT_LICENSE.txt.
