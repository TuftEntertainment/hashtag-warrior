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
    NSDictionary* userDetails = _tweet[@"user"];
    _screenName = userDetails[@"screen_name"];
    
    // Get the tweet text.
    _tweetText = _tweet[@"text"];
    
    // Get the tweet created at time.
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    _tweetTime = [dateFormat dateFromString:_tweet[@"created_at"]];
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
