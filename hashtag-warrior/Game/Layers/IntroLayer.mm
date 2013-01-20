//
//  IntroLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 13/01/2013.
//  Copyright Ossum Games 2013. All rights reserved.
//

#import "IntroLayer.h"
#import "MainMenuScene.h"

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

    // add the label as a child to this Layer.
    [self addChild: background];
    
    // In one second transition to the new scene.
    [self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
    // Fade from the launch image into the application.
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[MainMenuScene node]
                                                                             withColor:ccBLACK]];
}

- (void) dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}
@end
