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
        title.position = ccp(size.width/2, (size.height/2)+100);
        [self addChild: title];
        
        // Show score
        CCLabelTTF *score = [CCLabelTTF labelWithString:[NSString stringWithFormat:NSLocalizedString(@"You scored", nil), [GameState sharedInstance]._score, [GameState sharedInstance]._hashtag]
                                               fontName:kHWTextHeadingFamily
                                               fontSize:24];
        score.color = kHWTextColor;
        score.position = ccp(size.width/2, size.height/2);
        [self addChild: score];
        
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
        [menu alignItemsHorizontallyWithPadding:25.0f];
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
