//
//  AboutScene.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "AboutScene.h"
#import "AboutLayer.h"


@implementation AboutScene

- (id)init
{
    if ((self = [super init]))
    {
        // All this scene does upon initialization is init & add the layer class.
        AboutLayer *layer = [AboutLayer node];
        [self addChild:layer];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
