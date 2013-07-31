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

#import "Projectile.h"

@implementation Projectile

- (id) initWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    if (self=[self initWithSpriteFrameName:@"projectile.png"])
    {
        self.gameObjectType = kTweetType;
        [self createBodyWithWorld:world atLocation:location];
    }
    
    return self;
}

- (void) createBodyWithWorld:(b2World*)world atLocation:(CGPoint)location
{
    // Create the body definition first, position this
    b2BodyDef projectileBodyDef;
    projectileBodyDef.type = b2_dynamicBody;
    projectileBodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    // Create the body
    b2Body *projectileBody = world->CreateBody(&projectileBodyDef);
    projectileBody->SetUserData((__bridge void*)self);
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
