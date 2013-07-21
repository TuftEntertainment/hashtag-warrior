//
//  TrendFinder.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 21/07/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TwitterManager.h"
#import "TwitterTrendsPlace.h"

@interface TrendFinder : NSObject
{
    int _retryCount;
    TwitterManager* _tm;
    TwitterTrendsPlace* _ttp;
}

- (id)init;
- (void)requestTrends;
- (NSArray*)getTrendingHashtags;

@end