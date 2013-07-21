//
//  ChooseHashtagLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/07/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Constants.h"
#import "GameState.h"
#import "GameManager.h"
#import "ChooseHashtagLayer.h"

@implementation ChooseHashtagLayer

- (id)init
{
    if ((self=[super init]))
    {
        _tf = [[TrendFinder alloc] init];
        
        // Create title
        CCLabelTTF *title = [CCLabelTTF labelWithString:NSLocalizedString(@"Pick hashtag", nil)
                                               fontName:kHWTextHeadingFamily
                                               fontSize:32];
        title.color = kHWTextColor;
        title.position = CGPointMake(PCT_FROM_LEFT(0.5), PCT_FROM_TOP(0.1));
        [self addChild: title];
        
        // Load current hashtags
        [self loadChoices];
    }
    
    return self;
}

- (void)loadChoices
{
    NSArray* choices = [_tf getTrendingHashtags];
    
    if(choices.count > 0) {
        // Create menu
        CCMenu *menu = [[CCMenu alloc] init];
        
        // Add a menu item for each hashtag
        int maxToShow = MIN(choices.count, 5);
        for (int n = 0; n < maxToShow; n = n + 1) {
            NSString* currentHashtag = choices[n];
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:currentHashtag fontName: kHWTextHeadingFamily fontSize: 24];
            CCMenuItemLabel *item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
            {
                [self makeChoice:currentHashtag];
            }];
            item.color = kHWTextColor;
            [menu addChild: item];
        }
        
        [menu alignItemsVertically];
        [menu setPosition:CGPointMake(PCT_FROM_LEFT(0.5), PCT_FROM_TOP(0.5))];
        [self addChild: menu];
        
    } else {
        if(_retryCount < 5) {
            // Trends not found, try again in a bit
            ++_retryCount;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                    (int64_t)(500.00 * NSEC_PER_MSEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               [self loadChoices];
                           });
            
        } else {
            // Trends really don't want to load, offer practice mode instead
            // TODO implement practice mode..
        }
    }
}

- (void)makeChoice: (NSString*)hashtag
{
    [[GameState sharedInstance] set_hashtag:hashtag];
    [[GameManager sharedGameManager] runSceneWithID:kHWGameScene];
}

@end
