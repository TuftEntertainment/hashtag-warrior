//
//  GameOverLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameOverLayer.h"
#import "MainMenuScene.h"

@implementation GameOverLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Get an instance of the game state singleton.
        _state = [GameState sharedInstance];
        
        // Create and initialize a label for the title.
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Game Over!"
                                               fontName:@"Marker Felt"
                                               fontSize:64];
        
        CCLabelTTF *victory;
        if ( _state._won == YES )
        {
            victory = [CCLabelTTF labelWithString:NSLocalizedString(@"Winner", nil)
                                         fontName:@"Marker Felt"
                                         fontSize:32];
        }
        else
        {
            victory = [CCLabelTTF labelWithString:NSLocalizedString(@"Loser", nil)
                                         fontName:@"Marker Felt"
                                         fontSize:32];
        }
        
        // Ask director for the window size.
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Position the labels on the center of the screen.
        title.position = ccp(size.width /2 , size.height/2);
        victory.position = ccp(size.width /2, size.height /3);
        
        // Add the labels as a child to this Layer.
        [self addChild: title];
        [self addChild: victory];
    }
    return self;
}

-(void) onEnter
{
    [super onEnter];
    
    // In three seconds transition to the new scene.
    [self scheduleOnce:@selector(makeTransition:) delay:3];
}

-(void) makeTransition:(ccTime)dt
{
    // Go back to the game.
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[MainMenuScene node]
                                                                             withColor:ccBLACK]];
}

- (void) dealloc
{
    // Destroy the GameState ready for a new game.
    [GameState purgeSharedInstance];
    
    // Nothing else to deallocate.
    [super dealloc];
}

@end
