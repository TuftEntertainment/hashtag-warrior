//
//  Projectile.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 06/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"

@interface Projectile : CCSprite
{
    b2Body *_body;
}

- (void) setPhysicsBody:(b2Body*)body;

- (b2Body*) getPhysicsBody;

@end

