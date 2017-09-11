//
//  MHPictureEffect.m
//  MHVideoExport+OpenGLES
//
//  Created by FUZE on 2017/8/29.
//  Copyright © 2017年 FUZE. All rights reserved.
//

#import "MHPictureEffect.h"

#define kTextureWidth 150.f
//#import "GLSLProgram.h"

typedef struct {
    GLKVector2 positionCoords;  // 顶点数据
    GLKVector2 textureCoords;   // 纹理坐标
} SceneVertex;

@interface MHPictureEffect ()
{
    GLKTextureInfo *texture;
}
@property SceneVertex *pictureVertex;
@end



@implementation MHPictureEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _pictureVertex = calloc(6, sizeof(SceneVertex));
    glGenBuffers(1, &vertexsId);
    [self setupShaders];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, bounds.size.width, 0, bounds.size.height, -1, 1);
    glUniformMatrix4fv(MPMtxUniform, 1, GL_FALSE, projectionMatrix.m);
}
- (void)setContextSize:(CGSize)size
{
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, size.width, 0, size.height, -1, 1);
    glUniformMatrix4fv(MPMtxUniform, 1, GL_FALSE, projectionMatrix.m);
}

- (void)setupShaders
{
    pictureShader = [[GLSLProgram alloc]initWithVertexShaderFilename:@"PictureShader" fragmentShaderFilename:@"PictureShader"];
    
    [pictureShader addAttribute:@"inPosition"];
    [pictureShader addAttribute:@"inTexCoord"];
    
    
    if (![pictureShader link]) {
        NSLog(@"Linking failed");
        NSLog(@"Program log: %@", [pictureShader programLog]);
        NSLog(@"Vertex log: %@", [pictureShader vertexShaderLog]);
        NSLog(@"Fragment log: %@", [pictureShader fragmentShaderLog]);
        pictureShader = nil;
        exit(1);
    }
    
    inPositionAttrib = [pictureShader attributeIndex:@"inPosition"];
    inTexCoordAttrib = [pictureShader attributeIndex:@"inTexCoord"];
    
    [pictureShader use];
    
    textureUniform = [pictureShader uniformIndex:@"texture"];
    MPMtxUniform = [pictureShader uniformIndex:@"MPMatrix"];
}



- (void)renderWithImage:(CGImageRef)image andPosition:(CGPoint)aPoint andRadian:(CGFloat)radian andScale:(CGFloat)scale
{
    [pictureShader use];
    
    if (texture) {
        GLuint name = texture.name;
        glDeleteTextures(1, &name);
    }
    
    CGFloat radio = (CGFloat)CGImageGetWidth(image)/CGImageGetHeight(image);
    CGFloat height = kTextureWidth/radio;
    
    texture = [GLKTextureLoader textureWithCGImage:image options:nil error:nil];
    
    glBindTexture(GL_TEXTURE_2D, texture.name);
    
    
    
    if (aPoint.x > 0 && aPoint.y > 0) {
        [self packageVertexsWithPosition:aPoint andTextureSize:CGSizeMake(kTextureWidth, height) andRadian:radian andScale:scale];
    }else{
        
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexsId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SceneVertex) * 6, _pictureVertex, GL_DYNAMIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), 0);
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), (GLfloat *)NULL + 2);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDrawArrays(GL_TRIANGLES,
                 0,
                 6);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}

- (void)packageVertexsWithPosition:(CGPoint)aPoint andTextureSize:(CGSize)aSize andRadian:(CGFloat)radian andScale:(CGFloat)scale
{
    if (radian != 0 || scale != 1)
    {
        float x1 = -aSize.width * scale/2;
        float y1 = -aSize.height * scale/2;
        float x2 = aSize.width * scale/2;
        float y2 = aSize.height * scale/2;
        float x = aPoint.x;
        float y = aPoint.y;
        float r = radian;
        float cr = cosf(r);
        float sr = sinf(r);
        
        float ax = x1 * cr - y1 * sr + x;
        float ay = x1 * sr + y1 * cr + y;
        float bx = x2 * cr - y1 * sr + x;
        float by = x2 * sr + y1 * cr + y;
        float cx = x2 * cr - y2 * sr + x;
        float cy = x2 * sr + y2 * cr + y;
        float dx = x1 * cr - y2 * sr + x;
        float dy = x1 * sr + y2 * cr + y;
        
        
        _pictureVertex[0].positionCoords = GLKVector2Make(bx, by);
        _pictureVertex[0].textureCoords = GLKVector2Make(1.0f, 0.0f);

        _pictureVertex[1].positionCoords = GLKVector2Make(dx, dy);
        _pictureVertex[1].textureCoords = GLKVector2Make(0.0f, 1.0f);
        
        _pictureVertex[2].positionCoords = GLKVector2Make(ax, ay);
        _pictureVertex[2].textureCoords = GLKVector2Make(0.0f, 0.0f);
        
        _pictureVertex[3].positionCoords = GLKVector2Make(cx, cy);
        _pictureVertex[3].textureCoords = GLKVector2Make(1.0f, 1.0f);
        
        _pictureVertex[4].positionCoords = GLKVector2Make(dx, dy);
        _pictureVertex[4].textureCoords = GLKVector2Make(0.0f, 1.0f);
        
        _pictureVertex[5].positionCoords = GLKVector2Make(bx, by);
        _pictureVertex[5].textureCoords = GLKVector2Make(1.0f, 0.0f);
    }else{
        // Using the position of the particle, work out the four vertices for the quad that will hold the particle
        // and load those into the quads array.
        
        _pictureVertex[0].positionCoords = GLKVector2Make(aPoint.x + aSize.width/2, aPoint.y - aSize.height/2);
        _pictureVertex[0].textureCoords = GLKVector2Make(1.0f, 0.0f);
        
        _pictureVertex[1].positionCoords = GLKVector2Make(aPoint.x - aSize.width/2, aPoint.y + aSize.height/2);
        _pictureVertex[1].textureCoords = GLKVector2Make(0.0f, 1.0f);
        
        _pictureVertex[2].positionCoords = GLKVector2Make(aPoint.x - aSize.width/2, aPoint.y - aSize.height/2);
        _pictureVertex[2].textureCoords = GLKVector2Make(0.0f, 0.0f);
        
        _pictureVertex[3].positionCoords = GLKVector2Make(aPoint.x + aSize.width/2, aPoint.y + aSize.height/2);
        _pictureVertex[3].textureCoords = GLKVector2Make(1.0f, 1.0f);
        
        _pictureVertex[4].positionCoords = GLKVector2Make(aPoint.x - aSize.width/2, aPoint.y + aSize.height/2);
        _pictureVertex[4].textureCoords = GLKVector2Make(0.0f, 1.0f);
        
        _pictureVertex[5].positionCoords = GLKVector2Make(aPoint.x + aSize.width/2, aPoint.y - aSize.height/2);
        _pictureVertex[5].textureCoords = GLKVector2Make(1.0f, 0.0f);
        
    }
}




@end
