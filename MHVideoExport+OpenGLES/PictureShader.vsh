attribute vec4 inPosition;
attribute vec2 inTexCoord;

varying lowp vec2 varTexCoord;

uniform             mat4        MPMatrix;


void main(){
    
    varTexCoord = inTexCoord;
    
    gl_Position = MPMatrix * inPosition;
    
}
