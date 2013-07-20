//
//  ChooseHashtagScene.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/07/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "ChooseHashtagScene.h"
#import "BackgroundLayer.h"
#import "ChooseHashtagLayer.h"

@implementation ChooseHashtagScene

- (id)init
{
    if ((self = [super init]))
    {
        BackgroundLayer *bgLayer = [BackgroundLayer node];
        [self addChild:bgLayer z:0];
        
        ChooseHashtagLayer *uiLayer = [ChooseHashtagLayer node];
        [self addChild:uiLayer];
    }
    
    return self;
}

@end
