#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER

uniform float width;
uniform float height;
uniform sampler2D right;
uniform sampler2D left;
uniform float divPoint;

// varying vec4 vertTexCoord;

void main() {

  vec2 n = vec2(gl_FragCoord.x / width, gl_FragCoord.y / height);

  if(n.x < divPoint){
    gl_FragColor = texture2D(right, n).rgba;
  } else {
    gl_FragColor = texture2D(left, n).rgba;
  }
}