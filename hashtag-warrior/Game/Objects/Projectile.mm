//
//  Projectile.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 06/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

- (id) initWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    if ((self=[super init]))
    {
        self.gameObjectType = kTweetType;
        
        // TODO show initial frame/animation instead
        [self initWithFile:@"Projectile.png"];
        
        [self createBodyWithWorld:world atLocation:location];
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) createBodyWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    // Create the body definition first, position this
    b2BodyDef projectileBodyDef;
    projectileBodyDef.type = b2_dynamicBody;
    projectileBodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    // Create the body
    b2Body *projectileBody = world->CreateBody(&projectileBodyDef);
    projectileBody->SetUserData(self);
    [self setPhysicsBody:projectileBody];
    
    // Create the shape
    b2CircleShape projectileShape;
    projectileShape.m_radius = (self.contentSize.width/2)/PTM_RATIO;
    
    // Create the definition and add to body
    b2FixtureDef projectileFixtureDef;
    projectileFixtureDef.shape = &projectileShape;
    projectileFixtureDef.density = 1.0f;
    projectileFixtureDef.friction = 0.5f;
    projectileFixtureDef.restitution = 0.6f;
    projectileBody->CreateFixture(&projectileFixtureDef);
}

@end
