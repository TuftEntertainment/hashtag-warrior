//
//  TrendFinder.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 21/07/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TrendFinder.h"

#define MAX_RETRY 5
#define RETRY_DELAY_MS 500.00
#define MIN_TWEET_LEVEL 25

@implementation TrendFinder

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    _tm = [[TwitterManager alloc] init];
    _ttp = [[TwitterTrendsPlace alloc] init];
    
    [self requestTrends];
    
    return self;
}

- (void)requestTrends
{
    // Ensure we've been granted permission for Twitter
    // Note: As the request for a Twitter account is asynchronous, it's possible that
    //       we've requested permission but the system hasn't responded yet. In this
    //       scenario we queue up a few more attempts before declaring that we've got
    //       no permission whatsoever.
    if ( [_tm twitterPermission] )
    {
        // Set the location
        // TODO properly
        [_ttp setLocation:@"1"];
        
        // Get local trends
        NSLog(@"Fetching trends...");
        [_tm talkToTwitter:_ttp];
    }
    else
    {
        if ( _retryCount < MAX_RETRY )
        {
            // Queue up another go
            ++_retryCount;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                    (int64_t)(RETRY_DELAY_MS * NSEC_PER_MSEC));
            
            NSLog(@"Failed to get trends (attempt %d of %d), trying again in %f ms",
                  _retryCount, MAX_RETRY, RETRY_DELAY_MS);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               [self requestTrends];
                           });
        }
    }
}

- (NSArray*)getTrendingHashtags
{
    if([_ttp isStale]) {
        [self requestTrends];
    }
    
    NSArray* allTrends = [_ttp getResults];
    if(allTrends.count == 0) {
        return allTrends;
    }
    
    NSMutableArray *hashtags = [[NSMutableArray alloc] init];
    for(int i = 0; i < allTrends.count; i = i + 1)
    {
        NSString *currentTrend = allTrends[i];
        if([currentTrend hasPrefix:@"#"]) {
            [hashtags addObject:currentTrend];
        }
    }
    return hashtags;
}

@end
