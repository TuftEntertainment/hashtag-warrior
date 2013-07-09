//
//  GameOverLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameManager.h"
#import "GameState.h"
#import "Constants.h"

@implementation GameOverLayer

- (id)init
{
    if ((self=[super init]))
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Create title
        CCLabelTTF *title = [CCLabelTTF labelWithString:NSLocalizedString(@"Game Over!", nil)
                                               fontName:kHWTextHeadingFamily
                                               fontSize:64];
        title.color = kHWTextColor;
        title.position = ccp(size.width/2 , size.height/2);
        [self addChild: title];
        
        // Create menu
        CCMenuItemLabel *playAgain = [CCMenuItemFont itemWithString:NSLocalizedString(@"Play again", nil) block:^(id sender)
                                    {
                                        [[GameManager sharedGameManager] runSceneWithID:kHWGameScene];
                                    }];
        playAgain.color = kHWTextColor;
        CCMenuItemLabel *mainMenu = [CCMenuItemFont itemWithString:NSLocalizedString(@"Main menu", nil) block:^(id sender)
                                  {
                                      [[GameManager sharedGameManager] runSceneWithID:kHWMainMenuScene];
                                  }];
        mainMenu.color = kHWTextColor;
        CCMenuItemLabel *shareIt = [CCMenuItemFont itemWithString:NSLocalizedString(@"Share", nil) block:^(id sender)
                                     {
                                         // TODO share score to Twitter
                                         // For example: "@fooface just scored 3,339 on #Warrior against #Biebs4EvaLol. Try your luck at is.gd/hashtagwarrior"
                                         CCLOG(@"Haha, sharing doesn't actually work yet.");
                                     }];
        shareIt.color = kHWTextColor;
        CCMenu *menu = [CCMenu menuWithItems:playAgain, mainMenu, shareIt, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(size.width/2, size.height - 200);
        [self addChild: menu];
    }
    return self;
}

-(void) backToMain:(ccTime)dt
{
    [[GameManager sharedGameManager] runSceneWithID:kHWMainMenuScene];
}

@end
