/*===============================================================================
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States
 and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
 ===============================================================================*/

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Texture : NSObject {
@private
    int channels;
}


// --- Properties ---
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readwrite) int textureID;
@property (nonatomic, readonly) unsigned char* pngData;
@property (nonatomic, readonly) BOOL topLeftOrigin;


// --- Public methods ---
- (id)initWithImageFile:(NSString*)filename useTopLeftAsOrigin:(BOOL)topLeftAsOrigin;

@end
