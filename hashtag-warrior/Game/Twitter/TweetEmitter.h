//
//  TweetEmitter.h
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tweet.h"
#import "TwitterManager.h"
#import "TwitterSearchTweets.h"

#import <Queue.h>

@interface TweetEmitter : NSObject
{
    id _delegate;
    
    TwitterManager* _tm;
    TwitterSearchTweets* _tst;
    Queue* _tweetCache;
    
    bool _started;
    int _retryCount;
    
    NSTimer* _timer;
}

- (id)initWithDelegate:(id)delegate;

- (void)startTweetStream;
- (void)startTweetStream:(NSString*)hashtag;
- (void)stopTweetStream;
- (void)processStream;

- (void)timeout;

@end


@interface NSObject(TweetEmitterDelegate)

- (void)newTweet:(Tweet*)tweet;

@end
