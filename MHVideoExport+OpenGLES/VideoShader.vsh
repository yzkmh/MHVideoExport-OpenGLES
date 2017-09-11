attribute vec3 inPosition;
attribute vec2 inTexCoord;

varying lowp vec2 varTexCoord;

uniform             mat4        MPMatrix;


void main(){
    
    varTexCoord = inTexCoord;
    
    gl_Position = MPMatrix * vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);
    
}
