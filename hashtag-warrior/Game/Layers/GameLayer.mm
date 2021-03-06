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

#import "AccelerometerSimulation.h"

#include <stdlib.h>

#import "GameLayer.h"
#import "Constants.h"
#import "GameManager.h"

@implementation GameLayer

- (id)init
{
    if ((self=[super init]))
    {
        self.AccelerometerEnabled = YES;
        
        _state = [GameState sharedInstance];
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        
        // Set up the world
        [self createWorld:windowSize];
        if(kHWIsDebug) {
            [self setupDebugDraw];
        }
        [self createContactListener];
        
        // Schedule Box2D updates
        [self scheduleUpdate];
        
        // Initialise spritebatchnode, loading all the textures
        // for the layer (excludes background)
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"atlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"atlas.png"];
        [self addChild:sceneSpriteBatchNode];
        
        // Reset the score.
        _state._score = 0;
        
        // Set up players
        [self createHero:windowSize];
        [self createProjectile:ccp(0, windowSize.height)];
    }
    return self;
}

- (void) setupDebugDraw
{
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(GLESDebugDraw::e_shapeBit | GLESDebugDraw::e_centerOfMassBit | GLESDebugDraw::e_aabbBit);
}

- (void) createWorld: (CGSize)windowSize
{
    // Create our world.
    _world = new b2World(_state._gravity);
    _world->SetAllowSleeping(TRUE);
    
    // Create edges around the entire screen.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    b2EdgeShape groundEdge;
    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &groundEdge;
    groundEdge.Set(b2Vec2(0,0), b2Vec2(windowSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(0,0), b2Vec2(0, windowSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(0, windowSize.height/PTM_RATIO),
                   b2Vec2(windowSize.width/PTM_RATIO, windowSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(windowSize.width/PTM_RATIO,
                          windowSize.height/PTM_RATIO), b2Vec2(windowSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&boxShapeDef);
}

- (void) createHero: (CGSize)windowSize
{
    // Create Hero
    CGPoint location = ccp(windowSize.width/2, 0);
    _hero = [[Hero alloc] initWithWorld:_world atLocation:location];
    [sceneSpriteBatchNode addChild:_hero z:1 tag:kHeroTagValue];
    
    // Restrict our hero to only run along the bottom.
    b2PrismaticJointDef jointDef;
    b2Vec2 axis = b2Vec2(1.0f, 0.0f);
    jointDef.collideConnected = true;
    jointDef.Initialize(_hero.physicsBody, _groundBody, _hero.physicsBody->GetWorldCenter(), axis);
    _world->CreateJoint(&jointDef);
}

- (void) createProjectile: (CGPoint)p
{
    CCLOG(@"Adding new projectile! %0.2f x %0.2f",p.x,p.y);
    
    // Create projectile
    CGPoint location = ccp(p.x, p.y);
    _projectile = [[Projectile alloc] initWithWorld:_world atLocation:location];
    [sceneSpriteBatchNode addChild:_projectile];
    
    // Fire!
    b2Vec2 force = b2Vec2(2.5f, -5.0f);
    _projectile.physicsBody->ApplyLinearImpulse(force, _projectile.physicsBody->GetWorldCenter());
}

- (void) createContactListener
{
    _contactListener = new HeroContactListener();
    _world->SetContactListener(_contactListener);
}

- (void) draw
{
    glDisable(GL_TEXTURE_2D);
    
    _world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
}

- (void) update:(ccTime)dt {
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    
    // Use a fixed timestep - Box2D works better with this
    static double timeAccumulator = 0;
    timeAccumulator += dt;
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 3;
    int32 positionIterations = 2;
    while (timeAccumulator >= UPDATE_INTERVAL)
    {
        timeAccumulator -= UPDATE_INTERVAL;
        _world->Step(UPDATE_INTERVAL,
                    velocityIterations, positionIterations);
    }
    
    // Update sprite positions from world
    for(b2Body *b=_world->GetBodyList(); b!=NULL; b=b->GetNext())
    {
        // TODO should be able to get these from the bodies themselves
        // Update our hero's position.
        if (b == _hero.physicsBody)
        {
            _hero.position = ccp(b->GetPosition().x * PTM_RATIO,
                                 b->GetPosition().y * PTM_RATIO);
            _hero.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
        }
        // Update the projectiles position.
        else if (b == _projectile.physicsBody)
        {
            _projectile.position = ccp(b->GetPosition().x * PTM_RATIO,
                                       b->GetPosition().y * PTM_RATIO);
            _projectile.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    // Instruct the objects to update themselves
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    for (GameObject *obj in listOfGameObjects)
    {
        [obj updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
    }
    
    // Check to see if the Hero is dead
    GameObject *obj = (GameObject*)[sceneSpriteBatchNode getChildByTag:kHeroTagValue];
    if (([obj state] == kStateDead) && ([obj numberOfRunningActions] == 0)) {
        [[GameManager sharedGameManager] runSceneWithID:kHWGameOverScene];
    }
    
    // Update the score randomly for now until we've got many balls and can score correctly.
    int r = arc4random() % 25;
    _state._score = _state._score + r;
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [_hero accelerometer:accelerometer didAccelerate:acceleration];
}

@end
