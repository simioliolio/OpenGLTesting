//
//  OpenGLView.h
//  OpenGLTextureTesting
//
//  Created by Simon Haycock on 16/06/2016.
//  Copyright © 2016 oxygn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    
}

- (id)initWithFrame:(CGRect)frame textureImagePath:(NSString*)path;
-(void)touch:(CGPoint)touch;

@end
