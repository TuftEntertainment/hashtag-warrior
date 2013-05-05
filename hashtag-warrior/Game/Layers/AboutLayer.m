//
//  AboutLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "AboutLayer.h"
#import "Constants.h"
#import "GameManager.h"

@implementation AboutLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Add labels
        int posY = size.height-60;
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"#Hashtag Warrior"
                                        fontName:kHWTextHeadingFamily
                                        fontSize:48];
        title.position = ccp(size.width/2, posY);
        title.color = kHWTextColor;
        posY -= 80;
        
        CCLabelTTF *blurb = [CCLabelTTF labelWithString:NSLocalizedString(@"About Blurb", nil)
                                        fontName:kHWTextBodyFamily
                                        fontSize:18];
        blurb.position = ccp(size.width/2, posY);
        blurb.color = kHWTextColor;
        posY -= 80;
        
        CCLabelTTF *credits = [CCLabelTTF labelWithString:NSLocalizedString(@"About Credits", nil)
                                          fontName:kHWTextBodyFamily
                                          fontSize:14];
        credits.position = ccp(size.width/2, posY);
        credits.color = kHWTextColor;
        
        [self addChild: title];
        [self addChild: blurb];
        [self addChild: credits];
        
        // Add return to menu... menu
        [CCMenuItemFont setFontSize:18];
        CCMenuItemLabel *home = [CCMenuItemFont itemWithString:NSLocalizedString(@"Main Menu", nil) block:^(id sender)
                                  {
                                      [[GameManager sharedGameManager] runSceneWithID:kHWMainMenuScene];
                                  }];
        home.color = kHWTextColor;
        CCMenu *menu = [CCMenu menuWithItems:home, nil];
        [menu alignItemsVertically];
        [menu setPosition:ccp(size.width/2, 20)];
        
        [self addChild: menu];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

@end
