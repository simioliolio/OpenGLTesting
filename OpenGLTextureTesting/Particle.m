//
//  Particle.m
//  OpenGLTextureTesting
//
//  Created by Simon Haycock on 17/02/2017.
//  Copyright © 2017 oxygn. All rights reserved.
//

#import "Particle.h"

@implementation Particle

+(void)addExplosionToScene:(SCNScene*)scene position:(SCNVector3)position {
    SCNParticleSystem *explosion = [SCNParticleSystem particleSystemNamed:@"Explode.scnp" inDirectory:nil];
    SCNSphere *sphere = [SCNSphere sphereWithRadius:100.0];
    explosion.emitterShape = sphere;
    explosion.birthLocation = SCNParticleBirthLocationSurface;
    SCNMatrix4 translation = SCNMatrix4MakeTranslation(position.x, position.y, position.z);
    [scene addParticleSystem:explosion withTransform:translation];
}

@end
