//
//  Particle.h
//  OpenGLTextureTesting
//
//  Created by Simon Haycock on 17/02/2017.
//  Copyright © 2017 oxygn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface Particle : NSObject

+(void)addExplosionToScene:(SCNScene*)scene position:(SCNVector3)position;

@end
