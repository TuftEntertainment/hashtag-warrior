//
//  AboutScene.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "AboutScene.h"
#import "AboutLayer.h"
#import "BackgroundLayer.h"


@implementation AboutScene

- (id)init
{
    if ((self = [super init]))
    {
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        
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
