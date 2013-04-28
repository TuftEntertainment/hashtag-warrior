//
//  Projectile.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 06/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

- (id)init
{
    if ((self=[super init]))
    {
    }
    
    return self;
}

- (void) dealloc
{
    // Nothing else to deallocate.
    [super dealloc];
}

- (void) setPhysicsBody:(b2Body*)body
{
	_body = body;
}

- (b2Body*) getPhysicsBody
{
	return _body;
}

@end
