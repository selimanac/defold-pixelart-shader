
![defold-pixel-art](/.github/example.png?raw=true)


This is the pixel-art post-process shaders for 3D. 

## Example

There is a simple example included in this project. 

https://github.com/selimanac/defold-pixelart-shader-example


## Notes & Tips

This post-processing effect cannot make every 3D model perfect for pixel art. Do not expect miracles.

- This library does not contain any pixel-perfect solutions. It is up to you to handle camera, pixel size and up-scaling
- Use direct rotations (top, left, right, bottom) or isometric rotations(x:30, y:45) for camera views for better aligning pixels.
- Use an orthographic camera projection.
- Use simple/flat/basic 3D models. Small details looks bad.
- Use simple/flat textures. Even gradients are undesirable, stick to solid colors if you can.

## Setup

-  [optional] Add [pixelart.render](/pixelart/render/pixelart.render) to game.project -> Bootstrap -> Render section. You may also use your own solution.  Refer to [pixelart_render](#scriptspixelart_renderlua)
-  [optional] Add camera to your collection. 
- Add [pixelart_post_process.go](/pixelart/pixelart_post_process.go) gameobject file from library to your collection
- Add empty gameobject with ID `light_source` and change its position to desire location
- Add empty gameobject with ID `light_target` and change its position to desire location
- Use [pixelart.init()](#pixelartinitpixel_settings-light_settings-shadow_settings) to initialize 

## API

There are two lua modules to help you to setup

### scripts/pixelart.lua

#### pixelart.init(`pixel_settings`, `[light_settings]`, `[shadow_settings]`)

**`pixel_settings` (table)**

* `pixel_settings.pixel_size` (integer) Pixel size
* `pixel_settings.normal_edge_coefficient` (number) Normal edge for sharpening edges
* `pixel_settings.depth_edge_coefficient` (number) Depth edge for outline

**`light_settings` (table)[optional]**

* `light_settings.source` (string) Light source gameobject URL
* `light_settings.target` (string) Light target gameobject URL
* `light_settings.diffuse_light_color`  (vector3)[optional] Diffuse light color

**`shadow_settings` (table)[optional]**

Requires `light_settings`.

* `shadow_settings.projection_width` (number) Light projection width
* `shadow_settings.projection_height` (number) Light projection height
* `shadow_settings.projection_near` (number) Light projection near plane
* `shadow_settings.projection_far` (number) Light projection far plane
* `shadow_settings.depth_bias` (number)[optional] The 'depth_bias' value is per-scene dependent and must be tweaked accordingly. It is needed to avoid shadow acne, which is basically a  precision issue.
* `shadow_settings.shadow_opacity` (number)[optional]  Shadow opacity

#### pixelart.set_depth_bias(`depth_bias`)
Set shadow depth bias
* `depth_bias` (number) Depth Bias

#### pixelart.set_shadow_opacity(`shadow_opacity`)
Set shadow opacity
* `shadow_opacity` (number) Shadow opacity

#### pixelart.set_pixel_size(`pixel_size`)
Set Pixel-art pixel size for post-processing shader
* `pixel_size` (integer) Pixel size

#### pixelart.set_normal_edge(`normal_edge`)
Set Pixel-art normal edge for sharpening edges
* `normal_edge` (number) Normal edge

#### pixelart.set_depth_edge(`depth_edge`)
Set Pixel-art depth edge for outline
* `depth_edge` (number)  Depth edge

#### pixelart.set_ambient_light(`ambient_light`)
Set Pixel-art models ambient light
* `ambient_light` (vector3)  Ambient light


#### pixelart.set_resolution(`pixel_size`)
Set Pixel-art resolution for post-processing shader
* `pixel_size` (integer)  Pixel size


#### pixelart.set_light(`light_source`, `light_target`)
Set light source and target
* `light_source` (string)  Light source gameobject URL
* `light_target` (string)  Light target gameobject URL

---

### scripts/pixelart_render.lua

Use this file to render  pixel-art post-process.

#### pixelart_render.init(`self`)
Must be called on render_script's `init(self)` function

#### pixelart_render.update(`self`, `camera_frustum`, `view`, `proj`, `window_width`, `window_height`, `clear_buffers`)
Must be called on render_script's `update(self)` function

* `camera_frustum` (matrix4)  Camera frustum
* `view` (matrix4)  Camera view
* `proj` (matrix4)  Camera projection
* `window_width` (number)  Window width
* `window_height` (number)  Window height
* `clear_buffers` (table)  Clear buffer table

## Materials

Materials can be found in pixelart/materials folder.

### pixelart/model/pixelart_model.material
Very similar to build-in model_instanced material

### pixelart/model/pixelart_model_unlit.material
Unlit model material

### pixelart/model/pixelart_model_world.material
Same as pixelart_model.material but for World Vertex Space required by animated 3D models.

### pixelart/model/pixelart_model_world_unlit.material
Same as pixelart_model_unlit.material but for World Vertex Space required by animated 3D models.


### shadow/model/shadow_model_smooth.material
Shadow material from [Igor Suntsev](https://x.com/dragosha)'s (aka [@dragosha](https://x.com/dragosha)) [Light and Shadows](https://github.com/Dragosha/defold-light-and-shadows)

### shadow/model/shadow_model.material
Shadow material from [Jhonny Göransson](https://x.com/jhonnygoransson)'s [examples](https://github.com/Jhonnyg/my-public-defold-examples)


### Credits

- Shadow shaders are mostly from [Jhonny Göransson](https://x.com/jhonnygoransson)'s [examples](https://github.com/Jhonnyg/my-public-defold-examples) and [Igor Suntsev](https://x.com/dragosha)'s (aka [@dragosha](https://x.com/dragosha)) [Light and Shadows](https://github.com/Dragosha/defold-light-and-shadows)
- Slightly modified version of Abadonna's [orbit-camera](https://github.com/abadonna/defold-orbit-camera)
- [Björn Ritzl](https://x.com/bjornritzl)'s [extension-imgui](https://github.com/britzl/extension-imgui)

### Assets
- https://wizp.itch.io/lowpoly-stylized-fantasy-enviroment-pack
- https://gtibo.itch.io/hooded-fox
- https://dblob-ua.itch.io/low-poly-character-char-01
- https://dblob-ua.itch.io/low-poly-characterchar-ronin-01
 

