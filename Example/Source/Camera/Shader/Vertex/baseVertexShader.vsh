attribute vec4 position;
attribute vec4 inputTextureCoordinate;

varying vec4 textureCoordinate;

void main() {
    gl_Position = position
    textureCoordinate = inputTextureCoordinate
}
