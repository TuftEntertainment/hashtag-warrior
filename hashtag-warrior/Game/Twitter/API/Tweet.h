//
//  Tweet.h
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject
{
    NSDictionary* _tweet;
    
    NSString* _screenName;
    NSString* _tweetText;
    NSDate* _tweetTime;
}

- (id)initWithTweet:(NSDictionary*)tweet;

- (void)parseTweet:(NSDictionary*)tweet;

- (NSString*)getScreenName;
- (NSString*)getTweetText;
- (NSDate*)getTweetTime;

@end
