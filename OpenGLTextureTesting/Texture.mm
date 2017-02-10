/*===============================================================================
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States
 and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
 ===============================================================================*/

#import "Texture.h"
//#import <UIKit/UIKit.h>


// Private method declarations
@interface Texture (PrivateMethods)
- (BOOL)loadImage:(NSString*)filename;
- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData fromTopToBottom:(BOOL)topToBottom;
@end


@implementation Texture

//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithImageFile:(NSString*)filename useTopLeftAsOrigin:(BOOL)topLeftAsOrigin
{
    self = [super init];
    
    _topLeftOrigin = topLeftAsOrigin;
    
    if (nil != self) {
        if (NO == [self loadImage:filename]) {
            NSLog(@"Failed to load texture image from file %@", filename);
            self = nil;
        }
    }
    
    return self;
}



- (void)dealloc
{
    if (_pngData) {
        delete[] _pngData;
    }
}


//------------------------------------------------------------------------------
#pragma mark - Private methods

- (BOOL)loadImage:(NSString*)filename
{
    BOOL ret = NO;
    
    // Build the full path of the image file
//    NSString* fullPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    
    // Create a UIImage with the contents of the file
//    UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
    UIImage* uiImage = [UIImage imageNamed:filename];
    
    if (uiImage) {
        // Get the inner CGImage from the UIImage wrapper
        CGImageRef cgImage = uiImage.CGImage;
        
        // Get the image size
        _width = (int)CGImageGetWidth(cgImage);
        _height = (int)CGImageGetHeight(cgImage);
        
        // Record the number of channels
        channels = (int)CGImageGetBitsPerPixel(cgImage)/CGImageGetBitsPerComponent(cgImage);
        
        // Generate a CFData object from the CGImage object (a CFData object represents an area of memory)
        CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
        
        // Copy the image data for use by Open GL
        ret = [self copyImageDataForOpenGL: imageData fromTopToBottom:_topLeftOrigin];
        
        CFRelease(imageData);
    } else {
        NSLog(@"UIImage named %@ not valid", filename);
    }
    
    return ret;
}


- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData fromTopToBottom:(BOOL)topToBottom
{    
    if (_pngData) {
        delete[] _pngData;
    }
    
    _pngData = new unsigned char[_width * _height * channels];
    const int rowSize = _width * channels;
    const unsigned char* pixels = (unsigned char*)CFDataGetBytePtr(imageData);

    if (topToBottom) {
        // Copy the row data from top to bottom
        for (int i = (_height - 1); i >= 0; i--) {
            memcpy(_pngData + rowSize * i, pixels + rowSize * (_height - 1 - i), _width * channels);
        }
    } else {
        // Copy the row data from bottom to top
        for (int i = 0; i < _height; ++i) {
            memcpy(_pngData + rowSize * i, pixels + rowSize * (_height - 1 - i), _width * channels);
        }
    }
    
    
    return YES;
}



@end
