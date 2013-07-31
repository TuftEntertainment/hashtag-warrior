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
        CCLabelBMFont *hashtag = [CCLabelBMFont labelWithString:_state._hashtag
                                                        fntFile:kHWTextBodyFamily];
        hashtag.color = kHWTextColor;
        
        _score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Score: %d", _state._score]
                                        fntFile:kHWTextBodyFamily];
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
