//
//  Tweet.m
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithTweet:(NSDictionary*)tweet
{
    if(![super init])
    {
        return nil;
    }
    
    [self parseTweet:tweet];
    
    return self;
}

- (void)parseTweet:(NSDictionary*)tweet
{
    // First store the raw tweet.
    _tweet = tweet;
    
    // Parse the user block.
    NSDictionary* userDetails = [_tweet objectForKey:@"user"];
    _screenName = [userDetails objectForKey:@"screen_name"];
    
    // Get the tweet text.
    _tweetText = [_tweet objectForKey:@"text"];
    
    // Get the tweet created at time.
    NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    _tweetTime = [dateFormat dateFromString:[_tweet objectForKey:@"created_at"]];
}

- (NSString*)getScreenName
{
    return _screenName;
}

- (NSString*)getTweetText
{
    return _tweetText;
}

- (NSDate*)getTweetTime
{
    return _tweetTime;
}

@end
