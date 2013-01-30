//
//  TwitterManager.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TwitterManager.h"

@implementation TwitterManager

@synthesize trendsLastFetched;
@synthesize twitterAccount;
@synthesize trends;

- (id)init
{
    if(![super init]) {
        return nil;
    }
    
    // Get first configured Twitter account
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType: accountType
                                     options: nil
                                  completion: ^(BOOL granted, NSError *error) {
                                      
        if (granted == YES) {
            NSArray *arrayOfAccounts = [account accountsWithAccountType: accountType];
            
            if ([arrayOfAccounts count] > 0) {
                twitterAccount = [arrayOfAccounts lastObject];
                
                [self loadTrends];
            }
        }
    }];
    
    return self;
}

- (void)loadTrends
{
    if(twitterAccount != nil) {
        // Configure the request
        // TODO locale-specific trends based on the WOEID
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json?id=1"];
        SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter
                                                requestMethod: SLRequestMethodGET
                                                          URL: url
                                                   parameters: nil];
        request.account = twitterAccount;
        
        // Actually make the request
        [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
            if(responseData) {
                // Data is returned as JSON, parse it
                NSError *jsonError;
                NSArray *json = [NSJSONSerialization JSONObjectWithData: responseData
                                                                         options: 0
                                                                        error: &jsonError];
                if(json) {
                    trends = [[json objectAtIndex: 0] objectForKey: @"trends"];
                    trendsLastFetched = [NSDate date];
                    
                } else {
                    NSLog(@"Error during JSON parsing: %@", [jsonError localizedDescription]);
                }
            } else {
                NSLog(@"Network/API error: %@", [error localizedDescription]);
            }
        }];
    }
}

- (NSArray*)getTrends
{
    if(trends == nil || [trendsLastFetched timeIntervalSinceNow] > 1800) {
        [self loadTrends];
    }
    
    return trends;
}

@end
