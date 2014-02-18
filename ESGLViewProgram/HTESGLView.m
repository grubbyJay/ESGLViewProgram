//
//  HTESGLView.m
//  ESGLViewProgram
//
//  Created by wb-shangguanhaitao on 14-2-13.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTESGLView.h"
#import "HTESGLRender.h"

@implementation HTESGLView

#pragma mark - Superclass API

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [[HTESGLRender standardRender] resizeFromLayer:(CAEAGLLayer *)self.layer];
    [[HTESGLRender standardRender] render];
//    [self startAnimation];
}

#pragma mark - Private API

//- (void)startAnimation
//{
//    if (!_displayLink)
//    {
//        _displayLink = [CADisplayLink displayLinkWithTarget:[HTESGLRender standardRender] selector:@selector(render)];
//        [_displayLink setFrameInterval:1.0f];
//        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    }
//}

@end
