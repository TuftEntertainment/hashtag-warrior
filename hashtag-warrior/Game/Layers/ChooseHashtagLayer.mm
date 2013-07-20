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
        // Create title
        CCLabelTTF *title = [CCLabelTTF labelWithString:NSLocalizedString(@"Pick hashtag", nil)
                                               fontName:kHWTextHeadingFamily
                                               fontSize:24];
        title.color = kHWTextColor;
        title.position = CGPointMake(PCT_FROM_LEFT(0.5), PCT_FROM_TOP(0.1));
        [self addChild: title];
        
        // Create menu
        CCMenu *menu = [[CCMenu alloc] init];
        
        // Add a menu item for each hashtag
        for (int n = 0; n < 5; n = n + 1) {
            NSString* currentHashtag = [NSString stringWithFormat:@"#foo%d", n];
            
            CCMenuItemLabel *item = [CCMenuItemFont itemWithString:currentHashtag block:^(id sender)
            {
                [self makeChoice:currentHashtag];
            }];
            item.color = kHWTextColor;
            [menu addChild: item];
        }
        
        [menu alignItemsVertically];
        [menu setPosition:CGPointMake(PCT_FROM_LEFT(0.5), PCT_FROM_TOP(0.5))];
        [self addChild: menu];
    }
    
    return self;
}

- (void)makeChoice: (NSString*)hashtag
{
    [[GameState sharedInstance] set_hashtag:hashtag];
    [[GameManager sharedGameManager] runSceneWithID:kHWGameScene];
}

@end
