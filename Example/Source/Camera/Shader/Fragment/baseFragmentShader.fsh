precision mediump float;
uniform sampler2D u_Texture;
varying vec2 v_TexCoordOut;

void main(void) {
    vec4 color = texture2D(u_Texture, v_TexCoordOut);
  gl_FragColor = color;
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
