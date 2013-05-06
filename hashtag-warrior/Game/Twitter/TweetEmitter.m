//
//  TweetEmitter.m
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TweetEmitter.h"

#define MAX_RETRY 5
#define RETRY_DELAY_MS 500.00
#define MIN_TWEET_LEVEL 10

@implementation TweetEmitter

- (id)initWithDelegate:(id)delegate
{
    if(![super init])
    {
        return nil;
    }
    
    _delegate = delegate;
    
    _tm = [[TwitterManager alloc] init];
    _tst = [[TwitterSearchTweets alloc] init];
    _tweetCache = [[Queue alloc] init];
    
    return self;
}

- (void)startTweetStream
{
    // Default to "#Warrior"
    [self startTweetStream:@"#Warrior"];
}

- (void)startTweetStream:(NSString*)hashtag
{
    // Only start if there's a delegate listening and we've not already started.
    if ( _delegate && !_started )
    {
        // Next ensure we've been granted permission for Twitter.
        // Note: As the request for a Twitter account is asynchronous, it's possible that
        //       we've requested permission but the system hasn't responded yet. In this
        //       scenario we queue up a few more attempts before declaring that we've got
        //       no permission whatsoever.
        if ( [_tm twitterPermission] )
        {
            // Flag that we've started the tweet stream.
            _started = true;
            
            // Get some tweets!
            [self processStream];
        }
        else
        {
            if ( _retryCount < MAX_RETRY )
            {
                // Queue up another go.
                ++_retryCount;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                        (int64_t)(RETRY_DELAY_MS * NSEC_PER_MSEC));
                
                NSLog(@"Failed to start tweet stream (attempt %d of %d), trying again in %f ms",
                      _retryCount, MAX_RETRY, RETRY_DELAY_MS);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    [self startTweetStream:hashtag];
                });
            }
        }
    }
}

- (void)stopTweetStream
{
    // Flag that we've stopped the tweet stream.
    _started = false;
}

- (void)processStream
{
    NSTimeInterval secondsBetween = 1.0;
    
    // Get the next tweet.
    Tweet* nextTweet = [_tweetCache popQueue];
    
    // Get the future tweet.
    Tweet* futureTweet = [_tweetCache peekQueue];
    
    // Ensure there is a next tweet.
    if ( nextTweet )
    {
        // Send the next tweet to the delegate.
        [_delegate newTweet:nextTweet];
        
        // Queue up the next tweet.
        secondsBetween = [[futureTweet getTweetTime] timeIntervalSinceDate:[nextTweet getTweetTime]];
    }
    
    // Check we've still got enough Tweets in the cache.
    if ( [_tweetCache count] < MIN_TWEET_LEVEL )
    {
        // Check if we've got some data back from a previous request.
        if ( [_tst isStale] )
        {
            // Get some more tweets.
            [_tm talkToTwitter:_tst];
        }
        else
        {
            NSArray* results = [_tst getSearchResults];
            
            // Add them all to the cache.
            for ( int i = 0; i < results.count; ++i )
            {
                [_tweetCache addToQueue:results[i]];
            }
        }
    }
    
    // Queue up the next go around.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)secondsBetween);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self processStream];
    });
}

@end
