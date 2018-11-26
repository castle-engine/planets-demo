# Earth with stuff orbiting it (Castle Game Engine demo)

## How it works

The code loads a couple of (static) 3D models:

- data/camera_and_light.x3d
- data/earth.x3d
- data/moon.x3d
- data/satellite.x3d

Each model is loaded to a `TCastleScene` instance, which can be animated
(using properties like `TCastleTransform.Translation`, `TCastleTransform.Rotation`;
TCastleScene descends from TCastleTransform).

We also access the light source transformation (`Transform` node in X3D,
`TTransformNode` in Pascal) inside the `data/camera_and_light.x3d`
and animate it.

## Alternative ways

There are various alternative ways of doing this
(also valid and efficient, at least for this simple demo).
Basically, it's your choice (and, in simple cases, it doesn't matter
for performance) how do you split your world in models.

- Instead of a couple of separate models, we could create only one model,
  like `data/planets.x3d`. And load it to a single TCastleScene.

  In this case the Earth, the Moon and the satellite would be animated
  by finding their `TTransformNode`. Just like the Sun is animated right now.

  Note that in case of an object composed from a couple of Blender objects
  (like the satellite right now) you could use Blender parent-child reliationship,
  which is exported to a proper transformation hierarchy in X3D.
  This way the code always needs to update only a single `TTransformNode`
  to animate whole object (like a satellite).

- We could even design the whole animation in Blender,
  and then export it to `data/planets.castle-anim-frames`.

  This way the code wouldn't have to do much:
  you would just load `data/planets.castle-anim-frames` into a single
  TCastleScene and start the animation (`Scene.PlayAnimation`).

*As for the light source:*

Note that this is a crazy CGE demo :), it doesn't try to present what
is actually happening with the Earth, the Moon and the Sun.

- The Sun (point light) is orbiting the Earth in this demo.
  Ignoring almost 500 years of science
  ( https://en.wikipedia.org/wiki/Nicolaus_Copernicus ),
  the Earth is in the middle of the coordinate system,
  and the Sun rotates around it :)
  I wanted to keep the demo as simple as possible, and this seemed like a good idea.

- The animated rotations are just random craziness :)
  They are actually different each time you run the application.
  I didn't bother making them real.
  The way Sun orbits around the Earth has no relation with
  the day and night cycle, and seasons of the year, that you are familiar with :)

*As for the camera:*

Right now `data/camera_and_light.x3d` contains a default camera view
(exported by Blender). This seemed easiest to use, but the camera could
be initialized differently. E.g. you could set from code
`SceneManager.WalkCamera.SetView(...)` or
`SceneManager.ExamineCamera.SetView(...)`.
You don't need a camera in the Blender file.

## Compiling

Get Castle Game Engine https://castle-engine.io/ ,
follow https://castle-engine.io/documentation.php .
Either compile and run from Lazarus (open `code/planets.lpi`)
or compile and run using CGE build (run `castle-engine compile && castle-engine run`
on the command-line).

Requires Castle Game Engine >= 6.5 from
https://github.com/castle-engine/castle-engine/ .
We're near CGE 6.6 release.

## 3D data

I used Castle Game Engine exporter from Blender to X3D.

It can export normal map, height map, specular map
(when exporting with "Use CommonSurfaceShader" and materials properly set up),
see
https://castle-engine.io/creating_data_blender.php and
https://github.com/castle-engine/castle-engine/wiki/Blender .
These additional textures nicely enhance how the planets look.

Note: height maps (present on Earth and Moon models) are unused now.

- Although they are present in Earth and Moon textures,
  as alpha channel of their normal_map_combined_with_height_map_in_alpha.png
  textures.

- They could be used for "Steep parallax mapping (with optional self-shadowing)",
  all you need to do to activate it is to export from Blender with
  "Displace" checkbox set in "Influence" settings
  for normal_map_combined_with_height_map_in_alpha.png.

- ...But the "Steep parallax mapping (with optional self-shadowing)" didn't actually
  look good on these planet models. So I resigned from it.

- So we use only a classic bump mapping,
  looking only at RGB channels of normal_map_combined_with_height_map_in_alpha.png.

## Authors

Code, 3D models and some texture processing by Michalis Kamburelis.
My work here is covered by Apache License 2.0,
which is a permissive license that basically allows you to do everything
with this.

Original textures authors and copyrights:

- earth-textures/
  Extracted from model on https://opengameart.org/content/earth
  Created by Justin Nichol
  License(s): CC-BY 3.0

- moon-textures/
  From http://planetpixelemporium.com/earth.html

Normal maps generated from height maps using
http://cpetry.github.io/NormalMap-Online/ .
(Normally I recommend using gimp-normalmap plugin for this,
unfortunately it doesn't compile with GIMP 2.10 according to Debian).
