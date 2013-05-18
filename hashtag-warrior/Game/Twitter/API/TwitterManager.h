//
//  TwitterManager.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

#import <TwitterProtocol.h>

@interface TwitterManager : NSObject
{
    ACAccountStore* _accountStore;
    ACAccountType*  _accountType;
    ACAccount*      _twitterAccount;
    
    bool _granted;
}

@property (retain) ACAccount* _twitterAccount;

- (bool)twitterPermission;
- (bool)talkToTwitter:(NSObject<TwitterProtocol>*)protocol;

@end
