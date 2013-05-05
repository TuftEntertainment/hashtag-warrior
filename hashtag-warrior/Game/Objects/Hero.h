//
//  Hero.h
//  hashtag-warrior
//
//  Created by Nick James on 27/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameObject.h"

@interface Hero : GameObject

- (id)initWithWorld:(b2World*)world atLocation:(CGPoint)location;

@end
