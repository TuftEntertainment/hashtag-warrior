//
//  IntroLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 13/01/2013.
//  Copyright Ossum Games 2013. All rights reserved.
//

#import "IntroLayer.h"
#import "GameManager.h"

// GameLayer implementation
@implementation IntroLayer

-(void) onEnter
{
    [super onEnter];

    // ask director for the window size.
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // The application is landscape only, set this scenes background image accordingly.
    CCSprite *background;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
        background = [CCSprite spriteWithFile:@"Default.png"];
        background.rotation = 90;
    }
    else
    {
        background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
    }

    background.position = ccp(size.width/2, size.height/2);

    [self addChild: background];
    
    // In one second transition to the new scene.
    [self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
    [[GameManager sharedGameManager] runSceneWithID:kHWMainMenuScene];
}

- (void) dealloc
{
    [super dealloc];
}
@end
