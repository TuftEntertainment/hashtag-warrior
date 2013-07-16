//
//  Hero.h
//  hashtag-warrior
//
//  Created by Nick James on 27/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import "GameObject.h"

@interface Hero : GameObject
{
    CCAnimation *walkingAnim;
    CCAnimation *idleAnim;
}
@property (nonatomic, retain) CCAnimation *walkingAnim;
@property (nonatomic, retain) CCAnimation *idleAnim;

- (id)initWithWorld:(b2World*)world atLocation:(CGPoint)location;
- (void)accelerometer:(UIAccelerometer*)accelerometer
        didAccelerate:(UIAcceleration*)acceleration;

@end
