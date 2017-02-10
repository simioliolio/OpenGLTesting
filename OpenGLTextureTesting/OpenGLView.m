//
//  OpenGLView.m
//  OpenGLTextureTesting
//
//  Created by Simon Haycock on 16/06/2016.
//  Copyright © 2016 oxygn. All rights reserved.
//

#import "OpenGLView.h"
#import <GLKit/GLKit.h>
//#import "CC3GLMatrix.h"
#import "Texture.h"
#import <SceneKit/SceneKit.h>

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, -0}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -0}, {0, 1, 0, 1}, {1, 1}},
    {{-1, 1, -0}, {0, 0, 1, 1}, {0, 1}},
    {{-1, -1, -0}, {0, 0, 0, 1}, {0, 0}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@implementation OpenGLView {
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelviewUniform;
    GLuint _depthRenderBuffer;
    
//    GLuint _floorTexture;
//    GLuint _fishTexture;
    GLuint _randomTexture;
    
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    
    float _rotate;
    CADisplayLink *displayLink;
    
    Texture *testTexture;
    GLKTextureInfo *glkTexture;
    
    SCNRenderer *scnRenderer;
    CFAbsoluteTime startTime;
    SCNNode *cameraNode;
    
    SCNNode *textNode;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// Replace initWithFrame with this
- (id)initWithFrame:(CGRect)frame textureImagePath:(NSString*)path
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        
        /*
        NSError *theError;
        glkTexture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&theError];
        if (theError) {
            NSLog(@"error whilst loading texture: %@", theError);
            return nil;
        }
         */
        
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
//        [self compileShaders];
//        [self setupVBOs];
//        [self loadTestTexture];
        [self checkForErrorInOpenGL];
//        [self render];
        
//        _randomTexture = [self setupTexture:@"emojiGuy"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        });
        
        
        // scenekit
        /*
        SCNScene *scene = [SCNScene sceneNamed:@"Ari.scnassets/box2.scn"];
        if (!scene) {
            NSException *exception = [NSException exceptionWithName:@"guff" reason:@"no scene found" userInfo:nil];
            @throw exception;
        }
        */
        
        /*
        NSURL *urlOfScene = [[NSBundle mainBundle] URLForResource:@"box2URL" withExtension:@"scn"];
        NSError *sceneError = nil;
        SCNScene *scene = [SCNScene sceneWithURL:urlOfScene options:nil error:&sceneError];
        if (sceneError) {
            NSException *exception = [NSException exceptionWithName:@"guff" reason:@"could not open scene at url" userInfo:nil];
            @throw exception;
        }
        */
        
        SCNScene *scene = [SCNScene scene];
        
        
        SCNText *text = [SCNText textWithString:@"init" extrusionDepth:5.0];
        textNode = [SCNNode nodeWithGeometry:text];
        [scene.rootNode addChildNode:textNode];
        
         
        
//         SCNScene *scene = [[SCNScene alloc] init];
        /*
         // box
         CGFloat boxHeight = 10.0;
         SCNBox *boxGeo = [SCNBox boxWithWidth:boxHeight height:boxHeight length:boxHeight chamferRadius:boxHeight / 10.0];
         SCNMaterial *mat = [[SCNMaterial alloc] init];
         mat.locksAmbientWithDiffuse = YES;
         NSURL *imageFileURL = [[NSBundle mainBundle] URLForResource:@"logo-turquoise" withExtension:@"png"];
         UIImage *image = [UIImage imageWithContentsOfFile:imageFileURL.path];
         mat.diffuse.contents = image;
         mat.specular.contents = [UIColor whiteColor];
         boxGeo.firstMaterial = mat;
         
         // box node
         SCNNode *boxNode = [SCNNode nodeWithGeometry:boxGeo];
         boxNode.position = SCNVector3Make(0, 0, boxHeight / 2.0);
         boxNode.pivot = SCNMatrix4MakeRotation(M_PI_2, 0, 0, 0);
        // animation
        CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"rotation"];
        spin.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, 0)];
        spin.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, 2 * M_PI)];
        spin.duration = 3;
        spin.repeatCount = HUGE_VALF;
        [boxNode addAnimation:spin forKey:@"spin around"];
        
         [scene.rootNode addChildNode:boxNode];
        */
        NSError *manError;
        NSURL *manURL = [[NSBundle mainBundle] URLForResource:@"man" withExtension:@"scn"];
        SCNScene *man = [SCNScene sceneWithURL:manURL options:nil error:&manError];
        SCNNode *manNode = [SCNNode node];
        for (SCNNode *node in man.rootNode.childNodes) {
            [manNode addChildNode:node];
        }
        [scene.rootNode addChildNode:manNode];
        
        scnRenderer = [SCNRenderer rendererWithContext:_context options:nil];
        scnRenderer.scene = scene;
        
        startTime = CFAbsoluteTimeGetCurrent();
        
        SCNCamera *camera = [SCNCamera camera];
        cameraNode = [SCNNode node];
        cameraNode.camera = camera;
        [scnRenderer.scene.rootNode addChildNode:cameraNode];
        scnRenderer.pointOfView = cameraNode;
        scnRenderer.autoenablesDefaultLighting = YES;
//        scnRenderer.playing = YES;
        
    }
    return self;
}

-(void)loadTestTexture { // using Texture.h
    testTexture = [[Texture alloc] initWithImageFile:@"emojiGuy" useTopLeftAsOrigin:NO];
    //    testTexture = [[Texture alloc] initWithImageFile:[NSString stringWithCString:"emojiGuy.png" encoding:NSASCIIStringEncoding]];
    GLuint textureID;
    glGenTextures(1, &textureID);
    [testTexture setTextureID:textureID];
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [testTexture width], [testTexture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[testTexture pngData]);
    [self checkForErrorInOpenGL];
}

// Replace dealloc method with this
- (void)dealloc
{
    _context = nil;
}

-(void)displayLinkCallback:(CADisplayLink*)sender {
    _rotate += 1.0;
    [self render];
}

- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    // Projection
    
    const GLfloat aspectRatio = (GLfloat)(self.bounds.size.width) / (GLfloat)(self.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 1.0f, 100.0f);
    /*
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.m);
     */
    // Model View
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 20.0f, 100.0f);
    
    /*
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(0.0f));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(0.0f  + _rotate ));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(0.0f));
    glUniformMatrix4fv(_modelviewUniform, 1, GL_FALSE, modelViewMatrix.m);
     */
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    /*
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, glkTexture.name);
//    glBindTexture(GL_TEXTURE_2D, _randomTexture);
    glBindTexture(GL_TEXTURE_2D, testTexture.textureID);
    glUniform1i(_textureUniform, 0);
    */
//    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    // update time with current time float
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - startTime;
    textNode.geometry = [SCNText textWithString:[NSString stringWithFormat:@"time: %f", time] extrusionDepth:5.0];
    
    cameraNode.camera.projectionTransform = SCNMatrix4FromGLKMatrix4(projectionMatrix);
    [cameraNode setTransform:SCNMatrix4FromGLKMatrix4(modelViewMatrix)];
    if (scnRenderer.isPlaying == NO) {
        scnRenderer.playing = YES;
    }
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime calcTime = time;
    NSLog(@"currentTime: %f, calcTime: %f, startTime: %f", currentTime, calcTime, startTime);
    
    
    [scnRenderer renderAtTime:currentTime];
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    [self checkForErrorInOpenGL];
    

    
    
    
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelviewUniform = glGetUniformLocation(programHandle, "Modelview");
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

-(void)checkForErrorInOpenGL {
    GLint error = glGetError();
    if (error) {
        NSException *ex = [NSException exceptionWithName:@"openGL error" reason:[NSString stringWithFormat:@"OpenGL Error: (0x%x)\n", error] userInfo:nil];
        @throw ex;
    }
}

@end
