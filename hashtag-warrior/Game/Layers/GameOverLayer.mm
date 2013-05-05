//
//  GameOverLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameManager.h"
#import "Constants.h"

@implementation GameOverLayer

- (id)init
{
    if ((self=[super init]))
    { 
        // Create and initialize a label for the title.
        CCLabelTTF *title = [CCLabelTTF labelWithString:NSLocalizedString(@"Game Over", nil)
                                               fontName:kHWTextHeadingFamily
                                               fontSize:64];
        title.color = kHWTextColor;
        
        // Ask director for the window size.
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Position the labels on the center of the screen.
        title.position = ccp(size.width /2 , size.height/2);
        
        // Add the labels as a child to this Layer.
        [self addChild: title];
        
        // In three seconds transition to the new scene.
        [self scheduleOnce:@selector(makeTransition:) delay:1];
    }
    return self;
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
