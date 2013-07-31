/*
 * #Warrior - http://tuftentertainment.github.io/hashtag-warrior/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Tuft Entertainment
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
