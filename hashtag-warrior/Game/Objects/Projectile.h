//
//  Projectile.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 06/02/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "GameObject.h"

@interface Projectile : GameObject

- (id)initWithWorld:(b2World*)world atLocation:(CGPoint)location;

@end

