//
//  ChooseHashtagLayer.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/07/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "cocos2d.h"
#import "TrendFinder.h"

@interface ChooseHashtagLayer : CCLayer
{
    int _retryCount;
    TrendFinder* _tf;
}

@end
