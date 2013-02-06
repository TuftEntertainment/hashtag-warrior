//
//  Hero.h
//  hashtag-warrior
//
//  Created by Nick James on 27/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"

@interface Hero : CCSprite
{
    b2Body *_body;
}

- (void) setPhysicsBody:(b2Body*)body;

- (b2Body*) getPhysicsBody;

@end
