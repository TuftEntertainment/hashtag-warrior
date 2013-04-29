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
    ACAccount* twitterAccount;
}

@property (retain) ACAccount* twitterAccount;

- (void)loadTrends;

@end
