//
//  Hero.m
//  hashtag-warrior
//
//  Created by Nick James on 27/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "Hero.h"

@implementation Hero
@synthesize walkingAnim;
@synthesize idleAnim;

- (id) initWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    if (self=[self initWithSpriteFrameName:@"hero_1.png"])
    {
        self.gameObjectType = kHeroType;
        [self initAnimations];
        [self createBodyWithWorld:world atLocation:location];
    }
    
    return self;
}

- (void) createBodyWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    // Create the body definition first, position this
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    // Create the body
    b2Body *heroBody = world->CreateBody(&heroBodyDef);
    heroBody->SetUserData((__bridge void*)self);
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

- (void) initAnimations
{
    [self setWalkingAnim: [self loadPlistForAnimationWithName:@"walkingAnim"
                                                 andClassName:NSStringFromClass([self class])]];
    [self setIdleAnim: [self loadPlistForAnimationWithName:@"idleAnim"
                                              andClassName:NSStringFromClass([self class])]];
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
            action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: idleAnim]];
            break;
            
        case kStateRunningLeft:
            // TODO show the frame/animation for running, and ensure it is facing left
            action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: walkingAnim]];
            break;
            
        case kStateRunningRight:
            // TODO show the frame/animation for running, and ensure it is facing right
            action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: walkingAnim]];
            break;
            
        case kStateDead:
            // TODO show the splat frame or animation
            // currently this is part of the gameover sprite
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
    
    // Check for collisions
    // TODO reintegrate the HeroContactListener
    CGRect myBoundingBox = [self adjustedBoundingBox];
    for (GameObject *obj in listOfGameObjects) {
        // No need to check collision with one's self
        if ([obj tag] == kHeroTagValue) {
            continue;
        }
        
        CGRect characterBox = [obj adjustedBoundingBox];
        if (CGRectIntersectsRect(myBoundingBox, characterBox)) {
            if ([obj gameObjectType] == kTweetType) {
                [self changeState:kStateDead];
                break;
            }
        }
    }
    
    // TODO check/clamp X position to prevent falling off screen
    
    // TODO this is probably where we change state between
    // kStateIdle, kStateRunningLeft and kStateRunningRight, depending on the accelerometer
}

@end
