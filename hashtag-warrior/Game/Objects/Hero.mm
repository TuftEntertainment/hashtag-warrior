/*
 * #Warrior - http://tuftentertainment.github.io/hashtag-warrior/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Tuft Entertainment
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "Hero.h"

@implementation Hero
@synthesize walkingAnim;
@synthesize idleAnim;

- (id) initWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    if (self=[self initWithSpriteFrameName:@"hero_3.png"])
    {
        self.gameObjectType = kHeroType;
        [self initAnimations];
        [self createBodyWithWorld:world atLocation:location];
        [self changeState:kStateIdle];
    }
    
    return self;
}

- (void) createBodyWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    // Create the body definition first, position this
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y+(self.contentSize.height/2)/PTM_RATIO);
    
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
    heroFixtureDef.friction = 8.0f;
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
    if(newState == self.state) {
        return;
    }
    
    [self stopAllActions];
    [self setState:newState];
    
    id action = nil;
    switch(newState)
    {
        case kStateIdle:
            action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: idleAnim]];
            break;
            
        case kStateRunningLeft:
            [self setFlipX:YES];
            action = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: walkingAnim]];
            break;
            
        case kStateRunningRight:
            [self setFlipX:NO];
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
                return;
            }
        }
    }
    
    if(!self.physicsBody->IsAwake()) {
        // Not moving? Idle
        [self changeState:kStateIdle];
        
    } else {
        // If we're moving, ensure the state reflects which direction
        // (threshold the velocity to a sensible value)
        b2Vec2 velocity = self.physicsBody->GetLinearVelocity();
        if(velocity.x > 1.0f) {
            [self changeState:kStateRunningRight];
        } else if(velocity.x < -1.0f) {
            [self changeState:kStateRunningLeft];
        } else {
            [self changeState:kStateIdle];
        }
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if ( ABS(self.physicsBody->GetLinearVelocity().x) <= kHWMaxVelocity )
    {
        // Setup the force x & y.
        float32 forceX = acceleration.y * kHWForceMagnifier;
        float32 forceY = acceleration.x * kHWForceMagnifier;
        
        // Alter the force based on the devices orientation.
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if ( orientation == UIInterfaceOrientationLandscapeLeft )
        {
            forceY = forceY * -1;
        }
        else if ( orientation == UIInterfaceOrientationLandscapeRight )
        {
            forceX = forceX * -1;
        }
        
        // Apply the force to our hero.
        b2Vec2 force(forceX, forceY);
        self.physicsBody->ApplyLinearImpulse(force, self.physicsBody->GetWorldCenter());
    }
}

@end
