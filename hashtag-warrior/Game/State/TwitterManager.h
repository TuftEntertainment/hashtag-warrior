//
//  TwitterManager.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterManager : NSObject {
    NSArray* trends;
    NSDate* trendsLastFetched;
    ACAccount* twitterAccount;
}

@property (retain) NSArray* trends;
@property (retain) NSDate* trendsLastFetched;
@property (retain) ACAccount* twitterAccount;

- (void)loadTrends;
- (NSArray*)getTrends;

@end
