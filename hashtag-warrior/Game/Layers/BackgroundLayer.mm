//
//  BackgroundLayer.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 06/03/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCSprite *backgroundImage;
        
        backgroundImage = [CCSprite spriteWithFile:@"Background.png"];
        
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        [backgroundImage setPosition:CGPointMake(windowSize.width/2, windowSize.height/2)];
        
        [self addChild:backgroundImage z:0 tag:0];
    }
    
    return self;
}

@end
