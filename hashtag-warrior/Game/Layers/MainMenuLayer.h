//
//  MainMenuLayer.h
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//  Copyright 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

#import "Tweet.h"
#import "TweetEmitter.h"

@interface MainMenuLayer : CCLayer
{
    TweetEmitter* _tweetEmitter;
    CCLabelTTF* _tweet;
}

- (void)newTweet:(Tweet*)tweet;

@end
