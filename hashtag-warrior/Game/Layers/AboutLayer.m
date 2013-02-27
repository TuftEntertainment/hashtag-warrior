//
//  AboutLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "AboutLayer.h"
#import "MainMenuScene.h"

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
                                        fontName:@"Marker Felt"
                                        fontSize:48];
        title.position = ccp(size.width/2, posY);
        posY -= 80;
        
        CCLabelTTF *blurb = [CCLabelTTF labelWithString:NSLocalizedString(@"About Blurb", nil)
                                        fontName:@"Arial"
                                        fontSize:18];
        blurb.position = ccp(size.width/2, posY);
        posY -= 80;
        
        CCLabelTTF *credits = [CCLabelTTF labelWithString:NSLocalizedString(@"About Credits", nil)
                                          fontName:@"Arial"
                                          fontSize:14];
        credits.position = ccp(size.width/2, posY);
        
        [self addChild: title];
        [self addChild: blurb];
        [self addChild: credits];
        
        // Add return to menu... menu
        [CCMenuItemFont setFontSize:18];
        CCMenuItemLabel *home = [CCMenuItemFont itemWithString:NSLocalizedString(@"Main Menu", nil) block:^(id sender)
                                  {
                                      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                          scene:[MainMenuScene node]]];
                                  }];
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
