//
//  IntroScene.m
//  hashtag-warrior
//
//  Created by Nick James on 19/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "IntroScene.h"
#import "IntroLayer.h"


@implementation IntroScene

- (id)init
{
    if ((self = [super init]))
    {
        // All this scene does upon initialization is init & add the layer class.
        IntroLayer *layer = [IntroLayer node];
        [self addChild:layer];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
