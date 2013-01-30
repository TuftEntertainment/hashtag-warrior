//
//  GameLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"

#import "AccelerometerSimulation.h"

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
        // Enable the accelerometer.
        self.isAccelerometerEnabled = YES;
        
        // Get an instance of the game state singleton.
        _state = [GameState sharedInstance];
        
        // Ask director for the window size.
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Create the world.
        [self createWorld:size];
        
        // Create our hero.
        [self createHero:ccp(size.width/2, ADJUST_Y(200))];
        
        // Schedule animations.
        [self schedule:@selector(tick:)];
        
        // Add the game over menu (so we can escape the layer until game logic is implemented)
        [self addGameOverMenu:size];
    }
    return self;
}

- (void) dealloc
{
    // Destroy the world.
    delete _world;
    _world = NULL;
    
    // Nothing else to deallocate.
    [super dealloc];
}

- (void) createWorld: (CGSize)size
{
    // Create our world.
    _world = new b2World(_state._gravity);
    
    // Create edges around the entire screen
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    b2Body *groundBody = _world->CreateBody(&groundBodyDef);
    b2EdgeShape groundEdge;
    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &groundEdge;
    groundEdge.Set(b2Vec2(0,0), b2Vec2(size.width/PTM_RATIO, 0));
    groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(0,0), b2Vec2(0, size.height/PTM_RATIO));
    groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(0, size.height/PTM_RATIO),
                   b2Vec2(size.width/PTM_RATIO, size.height/PTM_RATIO));
    groundBody->CreateFixture(&boxShapeDef);
    groundEdge.Set(b2Vec2(size.width/PTM_RATIO,
                          size.height/PTM_RATIO), b2Vec2(size.width/PTM_RATIO, 0));
    groundBody->CreateFixture(&boxShapeDef);
}

- (void) createHero: (CGPoint)p
{
    CCLOG(@"Add hero to %0.2f x %0.2f",p.x,p.y);
    
    // Our hero.
    _hero = [Hero spriteWithFile:@"Hero.png"];
    
    // Add him to the layer.
    [self addChild:_hero];
    
    // Position him where requested.
    _hero.position = ccp(p.x, p.y);
    
    // Create the dynamic body definition.
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    
    // Position it where requested.
    heroBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    
    // Create the body.
    b2Body *heroBody = _world->CreateBody(&heroBodyDef);
    
    // Create the shape.
    b2PolygonShape heroShape;
    heroShape.SetAsBox(_hero.contentSize.width/PTM_RATIO/2,
                       _hero.contentSize.height/PTM_RATIO/2);
    
    // Create the definition and add to body.
    b2FixtureDef heroShapeDef;
    heroShapeDef.shape = &heroShape;
    heroShapeDef.density = 1.0f;
    heroShapeDef.friction = 0.2f;
    heroShapeDef.restitution = 0.8f;
    heroBody->CreateFixture(&heroShapeDef);
    
    // Add the physics to the sprite.
	[_hero setPhysicsBody:heroBody];
}

- (void) tick: (ccTime) dt {
    
    int32 velocityIterations = 10;
    int32 positionIterations = 10;
    
    _world->Step(dt, velocityIterations, positionIterations);
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
    {
        if (b == _hero.getPhysicsBody)
        {
            _hero.position = ccp(b->GetPosition().x * PTM_RATIO,
                                 b->GetPosition().y * PTM_RATIO);
            _hero.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // Setup the gravity x & y coordinates.
    float32 gravityX = acceleration.y * 15;
    float32 gravityY = acceleration.x * 15;

    // Alter the gravity based on the devices orientation.
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ( orientation == UIInterfaceOrientationLandscapeLeft )
    {
    	//The device is in landscape mode, 
    	//with the device held upright and the home button on the right side.
    	// (rot(90) counterclockwise)
        gravityX = gravityY * -1;
        gravityY = gravityX;
    }
    else if ( orientation == UIInterfaceOrientationLandscapeRight )
    {
    	//The device is in landscape mode, 
    	//with the device held upright and the home button on the left side.
    	// (rot(-90) counterclockwise)
        gravityX = gravityY;
        gravityY = gravityX *-1;
    }
    
    // Update the world with the new gravity.
    b2Vec2 gravity(gravityX, gravityY);
    _world->SetGravity(gravity);
}

- (void) addGameOverMenu: (CGSize) screenSize
{
    // Default font size will be 32 points.
    [CCMenuItemFont setFontSize:32];
    
    // Win Button.
    CCMenuItemLabel *win = [CCMenuItemFont itemWithString:NSLocalizedString(@"Win Game", nil) block:^(id sender)
    {
       _state._won = YES;
       [[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.0
                                                                                        scene:[GameOverScene node]]];
    }];
    
    // Lose Button
    CCMenuItemLabel *lose = [CCMenuItemFont itemWithString:NSLocalizedString(@"Lose Game", nil) block:^(id sender)
    {
        _state._won = NO;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:2.0
                                                                                          scene:[GameOverScene node]]];
    }];
    
    CCMenu *menu = [CCMenu menuWithItems:win, lose, nil];
    
    [menu alignItemsHorizontallyWithPadding:30.0f];
    
    [menu setPosition:ccp(screenSize.width/2, ADJUST_Y(304))];
    
    [self addChild: menu z:-1];
}

@end
