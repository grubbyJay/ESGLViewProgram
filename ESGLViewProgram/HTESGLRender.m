//
//  HTESGLRender.m
//  ESGLViewProgram
//
//  Created by wb-shangguanhaitao on 14-2-13.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTESGLRender.h"
#import "Shaders.h"
#import "matrix.h"

// uniform index
enum {
	UNIFORM_MODELVIEW_PROJECTION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
	ATTRIB_VERTEX,
	ATTRIB_COLOR,
	NUM_ATTRIBUTES
};

//typedef struct {
//    float Position[3];
//    float Color[4];
//} Vertex;
//
//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}}
//};
//
//const GLubyte Indices[] = {
//    0, 1, 2,
//    2, 3, 0
//};

@interface HTESGLRender ()

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint defaultFramebuffer;

@property (nonatomic, assign) GLuint program;

@property (nonatomic, assign) GLfloat rotz;

//@property (nonatomic, assign) GLuint positionSlot;
//@property (nonatomic, assign) GLuint colorSlot;

/**
 *  加载着色器
 *
 *  @return 加载是否成功
 */
- (BOOL)loadShaders;

///**
// *  设置着色器所需的变量
// */
//- (void)setupVBOs;

@end

@implementation HTESGLRender

#pragma mark - Superclass API

- (void) dealloc
{
	// tear down GL
	if (_defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &_defaultFramebuffer);
		_defaultFramebuffer = 0;
	}
	
	if (_colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_colorRenderbuffer);
		_colorRenderbuffer = 0;
	}
	
	// realease the shader program object
	if (_program)
	{
		glDeleteProgram(_program);
		_program = 0;
	}
	
	// tear down context
	if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
	
	_context = nil;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders])
        {
            return nil;
        }
        
        _backingWidth = 0;
        _backingHeight = 0;
        
        _rotz = 0.0f;
        
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &_defaultFramebuffer);
		glGenRenderbuffers(1, &_colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    }
    return self;
}

#pragma mark - Private API

- (BOOL)loadShaders {
	
	GLuint vertShader = 0, fragShader = 0;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	// create shader program
	_program = glCreateProgram();
	
	// create and compile vertex shader
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"vsh"];
	if (!compileShader(&vertShader, GL_VERTEX_SHADER, 1, vertShaderPathname)) {
		destroyShaders(vertShader, fragShader, _program);
		return NO;
	}
	
	// create and compile fragment shader
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"fsh"];
	if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, 1, fragShaderPathname)) {
		destroyShaders(vertShader, fragShader, _program);
		return NO;
	}
	
	// attach vertex shader to program
	glAttachShader(_program, vertShader);
	
	// attach fragment shader to program
	glAttachShader(_program, fragShader);
    
	// link program
	if (!linkProgram(_program)) {
		destroyShaders(vertShader, fragShader, _program);
		return NO;
	}
    
    glUseProgram(_program);
    
    // bind attribute locations
	// this needs to be done prior to linking
	glBindAttribLocation(_program, ATTRIB_VERTEX, "Position");
	glBindAttribLocation(_program, ATTRIB_COLOR, "SourceColor");
    
    // get uniform locations
	uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX] = glGetUniformLocation(_program, "Projection");

    
	// release vertex and fragment shaders
	if (vertShader) {
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
		glDeleteShader(fragShader);
		fragShader = 0;
	}
    
	return YES;
}

#pragma mark - Public API

+ (instancetype)standardRender
{
    static HTESGLRender *render = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        render = [[HTESGLRender alloc] init];
    });
    return render;
}

- (void)render
{
    glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    /**
     *  xyz <= 1
     */
//    const GLfloat squareVertices[] = {
//        -1.0f, -1.5f,  -1.0f,
//        1.0f,  -1.5f,  -1.0f,
//        -1.0f,  1.5f,  -1.0f,
//        1.0f,   1.5f,  -1.0f,
//    };
    const GLfloat squareVertices[] = {
        -1.0f, -1.5f,  -0.9f,
        0.5f,  -0.5f,  -1.1f,
        -0.5f,  1.5f,  -1.1f,
//        0.5f,   0.5f,  -1.0f,
    };
    const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
//        255,   0, 255, 255,
    };
//    const GLfloat proj[16] = {
//        1.0f, 0.0f, 0.0f, 0.0f,
//        0.0f, 2.0f/3.0f, 0.0f, 0.0f,
//        0.0f, 0.0f, 1.0f, 0.0f,
//        0.0f, 0.0f, 0.0f, 1.0f,
//    };
	GLfloat proj[16], modelview[16], modelviewProj[16];
    
//    mat4f_LoadOrtho(-1.0f, 1.0f, -480.0f/320.0f, 480.0f/320.0f, 1.0f, -1.0f, proj);
//    mat4f_LoadPerspective(M_PI_2, 320.0f/480.0f, 0.0f, -1.0f, proj);
    mat4f_LoadPerspective(-1.0f, 1.0f, -480.0f/320.0f, 480.0f/320.0f, 1.0f, 2.0f, proj);
//    mat4f_LoadZRotation(-_rotz, modelview);
//    mat4f_MultiplyMat4f(proj, modelview, modelviewProj);
//    
//    _rotz += 3.0f * M_PI / 180.0f;
    
    glViewport(0.0f, 0.0f, _backingWidth, _backingHeight);
    
    // update uniform values
	glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX], 1, GL_FALSE, proj);
    
	// update attribute values4
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors); //enable the normalized flag
    glEnableVertexAttribArray(ATTRIB_COLOR);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer*)layer
{
	// Allocate color buffer backing based on the current layer size
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
	
    return YES;
}

@end
