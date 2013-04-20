//
//  StatusLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 13/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

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
                                               fontName:@"Marker Felt"
                                               fontSize:12];
        hashtag.color = ccc3(8, 90, 124);
        
        CCLabelTTF *score = [CCLabelTTF labelWithString:@"1337"
                                         fontName:@"Marker Felt"
                                         fontSize:12];
        score.color = ccc3(8, 90, 124);
        
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
