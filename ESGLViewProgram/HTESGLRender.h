//
//  HTESGLRender.h
//  ESGLViewProgram
//
//  Created by wb-shangguanhaitao on 14-2-13.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  渲染类
 */
@interface HTESGLRender : NSObject

/**
 *  生成渲染单例
 *
 *  @return 生成渲染单例
 */
+ (instancetype)standardRender;

/**
 *  通知GPU绘制
 */
- (void)render;

/**
 *  根据layer的变化重置状态
 *
 *  @param layer 一个CAEAGLLayer类
 *
 *  @return 状态重置是否成功
 */
- (BOOL)resizeFromLayer:(CAEAGLLayer*)layer;

@end
