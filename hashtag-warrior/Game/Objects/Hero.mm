//
//  Hero.m
//  hashtag-warrior
//
//  Created by Nick James on 27/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "Hero.h"

@implementation Hero

- (id) initWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    if ((self=[super init]))
    {
        self.gameObjectType = kHeroType;
        
        [self initWithSpriteFrameName:@"hero_01.png"];
        
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
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    // Create the body
    b2Body *heroBody = world->CreateBody(&heroBodyDef);
    heroBody->SetUserData(self);
    [self setPhysicsBody:heroBody];
    
    // Create the shape
    b2PolygonShape heroShape;
    heroShape.SetAsBox(self.contentSize.width/PTM_RATIO/2,
                       self.contentSize.height/PTM_RATIO/2);
    
    // Create the definition and add to body
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.2f;
    heroFixtureDef.restitution = 0.0f;
    heroBody->CreateFixture(&heroFixtureDef);
}

- (void) changeState:(GameObjectState)newState
{
    [self stopAllActions];
    [self setState:newState];
    
    id action = nil; // the state machine below will decide if/what action to run
    
    switch(newState)
    {
        case kStateIdle:
            // TODO show the idle frame (facing player)
            break;
        case kStateRunningLeft:
            // TODO show the frame/animation for running, and ensure it is facing left
        case kStateRunningRight:
            // TODO show the frame/animation for running, and ensure it is facing right
        case kStateDead:
            // TODO show the splat frame or animation
            break;
        default:
            CCLOG(@"Unrecognised state!");
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

- (void) updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    if(self.state == kStateDead) {
        return;
    }
    
    // TODO move collision detection here
    // 1. Get own adjusted bounding box
    // 2. Loop through listOfGameObjects
    // 3. If the object is Hero, continue
    // 4. If not, get the adjusted bounding box of the object, and check for a collision
    // 5. If there is a collision, set the Hero to kStateDead and break
    
    // TODO this is probably where we change state between
    // kStateIdle, kStateRunningLeft and kStateRunningRight, depending on the accelerometer
}

@end
