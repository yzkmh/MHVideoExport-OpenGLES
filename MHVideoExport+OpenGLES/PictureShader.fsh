varying lowp vec2 varTexCoord;

uniform sampler2D uniTexture;

void main() {
    gl_FragColor = texture2D(uniTexture, varTexCoord);
}
