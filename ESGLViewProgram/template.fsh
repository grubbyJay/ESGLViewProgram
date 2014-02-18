// define default precision for float, vec, mat.
precision highp float;

varying vec4 DestinationColor; // 1

void main(void) { // 2
    gl_FragColor = DestinationColor; // 3
}
