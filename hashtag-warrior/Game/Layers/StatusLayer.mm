//
//  StatusLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 13/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Constants.h"
#import "StatusLayer.h"

@implementation StatusLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Get an instance of the game state singleton.
        _state = [GameState sharedInstance];
        
        // Create and initialize a label for the title.
        CCLabelTTF *hashtag = [CCLabelTTF labelWithString:@"#biebs4evalol"
                                               fontName:kHWTextBodyFamily
                                               fontSize:12];
        hashtag.color = kHWTextColor;
        
        CCLabelTTF *score = [CCLabelTTF labelWithString:@"1337"
                                         fontName:kHWTextBodyFamily
                                         fontSize:12];
        score.color = kHWTextColor;
        
        // Position the labels atop the screen
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        hashtag.position = ccp([hashtag boundingBox].size.width, size.height-20);
        score.position = ccp(size.width-[score boundingBox].size.width, size.height-20);
        
        // Add the labels as a child to this Layer.
        [self addChild: hashtag];
        [self addChild: score];
    }
    
    return self;
}

@end
