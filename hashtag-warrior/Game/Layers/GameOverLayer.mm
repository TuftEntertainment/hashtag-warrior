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
                                         // First check if we are able to send a Tweet.
                                         if ( [TWTweetComposeViewController canSendTweet] )
                                         {
                                             // We are! Now create the Tweet Sheet.
                                             TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
                                             
                                             // Set the initial text.
                                             NSString *tweetText = [NSString stringWithFormat:NSLocalizedString(@"Glory Tweet", nil), [GameState sharedInstance]._score, [GameState sharedInstance]._hashtag];
                                             [tweetSheet setInitialText:tweetText];
                                             
                                             // Attach our URL.
                                             NSURL *url = [[NSURL alloc] initWithString:NSLocalizedString(@"URL", nil)];
                                             [tweetSheet addURL:url];
                                             
                                             // Popup the Tweet Sheet for Tweeting with.
                                             [[CCDirector sharedDirector] presentModalViewController:tweetSheet animated:YES];
                                         }
                                         else
                                         {
                                             // Alert the user to our inability to Tweet anything.
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tweetastrophe", nil)
                                                                                                 message:NSLocalizedString(@"No Twitter", nil)
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                                                       otherButtonTitles:nil];
                                             [alertView show];
                                         }
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
