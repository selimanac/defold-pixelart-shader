components {
  id: "orbit_camera"
  component: "/example/scripts/orbit_camera.script"
}
embedded_components {
  id: "camera"
  type: "camera"
  data: "aspect_ratio: 1.0\n"
  "fov: 1.0\n"
  "near_z: -20.0\n"
  "far_z: 20.0\n"
  "auto_aspect_ratio: 1\n"
  "orthographic_projection: 1\n"
  "orthographic_zoom: 50.0\n"
  ""
}
