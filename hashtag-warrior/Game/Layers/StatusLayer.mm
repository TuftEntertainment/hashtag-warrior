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
        CCLabelTTF *hashtag = [CCLabelTTF labelWithString:_state._hashtag
                                               fontName:kHWTextBodyFamily
                                               fontSize:12];
        hashtag.color = kHWTextColor;
        
        _score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", _state._score]
                                    fontName:kHWTextBodyFamily
                                    fontSize:12];
        _score.color = kHWTextColor;
        
        // Position the labels atop the screen
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        hashtag.position = ccp([hashtag boundingBox].size.width, size.height-20);
        _score.position = ccp(size.width-[_score boundingBox].size.width, size.height-20);
        
        // Add the labels as a child to this Layer.
        [self addChild:hashtag];
        [self addChild:_score];
        
        // Listen to updates on the score.
        [self addObserver:self
               forKeyPath:@"_state._score"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self
              forKeyPath:@"_state._score"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"_state._score"])
    {
        [_score setString:[NSString stringWithFormat:@"Score: %d", _state._score]];
    }
}

@end
