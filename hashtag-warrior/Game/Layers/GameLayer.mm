//
//  GameLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "AccelerometerSimulation.h"

#import "GameLayer.h"
#import "Constants.h"
#import "GameManager.h"




// TODO move these global?
// Define macros to convert from an iPhone ccp to iPad ccp.
// Note: Not much use when using the size from the director (e.g. [[CCDirector sharedDirector] winSize].width) as this
//       returns the size of the current device.
#define kXoffsetiPad        64
#define kYoffsetiPad        32

#define ADJUST_X(__x__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__x__ * 2) + kXoffsetiPad : __x__)

#define ADJUST_Y(__y__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__y__ * 2) + kYoffsetiPad : __y__)

#define ADJUST_CCP(__p__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? ccp( ADJUST_X(__p__.x), ADJUST_Y(__p__.y) ) : __p__)




@implementation GameLayer

- (id)init
{
    if ((self=[super init]))
    {
        self.isAccelerometerEnabled = YES;
        
        _state = [GameState sharedInstance];
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        
        // Set up the world
        [self createWorld:windowSize];
        [self createContactListener];
        
        // Schedule Box2D updates
        [self scheduleUpdate];
        
        // Initialise spritebatchnode, loading all the textures
        // for the layer (excludes background)
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"atlas-ipad.plist"];
            sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"atlas-ipad.png"];
        } else {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"atlas.plist"];
            sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"atlas.png"];
        }
        [self addChild:sceneSpriteBatchNode];
        
        // Set up players
        [self createHero:windowSize];
        [self createProjectile:ccp(0, windowSize.height)];
    }
    return self;
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

-(void)update:(ccTime)dt {
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
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [_hero accelerometer:accelerometer didAccelerate:acceleration];
}

@end
