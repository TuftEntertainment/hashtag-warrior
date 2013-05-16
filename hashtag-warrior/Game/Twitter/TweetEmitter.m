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
#define MIN_TWEET_LEVEL 25

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
            
            // Set the hashtag.
            [_tst setSearchCriteria:hashtag];
            
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
    else if ( !_delegate )
    {
        // Log the missing delegate.
        NSLog(@"Tried to start tweet sream without delegate");
    }
    else if ( _started )
    {
        // Log the duplicate start attempt.
        NSLog(@"Tweet stream already started");
    }
}

- (void)stopTweetStream
{
    // Flag that we've stopped the tweet stream.
    _started = false;
    
    // Clear the timer.
    [_timer invalidate];
    _timer = nil;
}

- (void)processStream
{
    // Prevent us doing all this if we've already got an active timer.
    if ( !_timer )
    {
        // Default time interval if there are not enough tweets in the cache.
        NSTimeInterval interval = 2.0;
        
        // Check we've still got enough Tweets in the cache.
        // The health of the cache is our main priority. If we don't have enough tweets to meet the required
        // minimum, we must to get more before returning any to the delegate.
        if ( [_tweetCache count] < MIN_TWEET_LEVEL )
        {
            // Log the cache level.
            NSLog(@"Tweet cache count: %i", [_tweetCache count]);
            
            // Check if we've got some data back from a previous request.
            if ( [_tst isStale] )
            {
                // Log the request for more tweets.
                NSLog(@"Requesting more tweets");
                
                // Get some more tweets.
                [_tm talkToTwitter:_tst];
            }
            else
            {
                // Get the latest results.
                NSArray* results = [_tst getSearchResults];
                
                // Log the number of tweets we managed to get.
                NSLog(@"Adding %i tweets to the cache", results.count);
                
                // Add them all to the cache.
                for ( int i = 0; i < results.count; ++i )
                {
                    [_tweetCache addToQueue:results[i]];
                }
                
                // Log the new cache level.
                NSLog(@"Tweet cache count: %i", [_tweetCache count]);
            }
        }
        else
        {
            // Get the next tweet.
            Tweet* nextTweet = [_tweetCache popQueue];
            
            // Get the future tweet.
            Tweet* futureTweet = [_tweetCache peekQueue];
            
            // Ensure there is a next tweet and a future tweet.
            if ( nextTweet && futureTweet )
            {
                // Send the next tweet to the delegate.
                [_delegate newTweet:nextTweet];
                
                // Queue up the future tweet.
                interval = [[nextTweet getTweetTime] timeIntervalSinceDate:[futureTweet getTweetTime]];
            }
        }

        // Queue up the next go around.
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(timeout)
                                                userInfo:nil
                                                 repeats:NO];
    }
}

- (void)timeout
{
    // Clear the timer.
    [_timer invalidate];
    _timer = nil;
    
    // Do some work.
    [self processStream];
}

@end
