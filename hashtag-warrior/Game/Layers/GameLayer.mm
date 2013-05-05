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
        
        [self createWorld:windowSize];
        
        // Schedule Box2D updates
        [self schedule:@selector(tick:)];
        //[self scheduleUpdate];
        
        // TODO initialise SpriteBatchNode here,
        // and add the hero/projectiles to it rather than the layer directly
        // as this decreases the number of OpenGL calls.
        
        [self createHero:windowSize];
        [self createProjectile:ccp(0, windowSize.height)];
        
        [self createContactListener];
    }
    return self;
}

- (void) dealloc
{
    // Destroy the contact listener.
    delete _contactListener;
    _contactListener = NULL;
    
    // Destroy the world.
    delete _world;
    _world = NULL;
    
    [super dealloc];
}

- (void) createWorld: (CGSize)windowSize
{
    // Create our world.
    _world = new b2World(_state._gravity);
    
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
    _hero = [[[Hero alloc]
             initWithWorld:_world atLocation:location] autorelease];
    [self addChild:_hero z:1 tag:1];
    
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
    
    _projectile = [Projectile spriteWithFile:@"Projectile.png"];
    [self addChild:_projectile];
    _projectile.position = ccp(p.x, p.y);
    
    // Create the body definition.
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    
    // Create the body
    b2Body *b = _world->CreateBody(&bd);
    
    // Create the shape and shape definition.
    b2CircleShape s;
    s.m_radius = (_projectile.contentSize.width/2)/PTM_RATIO;

    b2FixtureDef sd;
    sd.shape = &s;
    sd.density = 1.0f;
    sd.friction = 0.5f;
    sd.restitution = 0.6f;
    b->CreateFixture(&sd);
    
    // Add the physics to the sprite.
	[_projectile setPhysicsBody:b];
    
    // Zoom
    b2Vec2 force = b2Vec2(2.5f, -5.0f);
    b->ApplyLinearImpulse(force, bd.position);
}

- (void) createContactListener
{
    _contactListener = new HeroContactListener();
    _world->SetContactListener(_contactListener);
}

- (void) tick: (ccTime) dt
{    
    int32 velocityIterations = 10;
    int32 positionIterations = 10;
    
    _world->Step(dt, velocityIterations, positionIterations);
    
    // For every body in the world.
    for (b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
    {
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
    
    // Check for collisions.
    bool collided = false;
    b2Fixture* heroFixture = _hero.physicsBody->GetFixtureList();
    b2Fixture* projectileFixture = _projectile.physicsBody->GetFixtureList();
    
    std::vector<Collision>* tmp = _contactListener->GetCollisions();
    std::vector<Collision>::iterator pos;
    for(pos = tmp->begin(); pos != tmp->end(); ++pos)
    {
        Collision collision = *pos;
        
        if ((collision.fixtureA == projectileFixture && collision.fixtureB == heroFixture) ||
            (collision.fixtureA == heroFixture && collision.fixtureB == projectileFixture))
        {
            collided = true;
        }
    }
    
    // If we collided, game over!
    if ( collided )
    {
        [[GameManager sharedGameManager] runSceneWithID:kHWGameOverScene];
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if ( ABS(_hero.physicsBody->GetLinearVelocity().x) <= kHWMaxVelocity )
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
        _hero.physicsBody->ApplyLinearImpulse(force, _hero.physicsBody->GetWorldCenter());
    }
}

@end
