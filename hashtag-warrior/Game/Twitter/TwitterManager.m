//
//  TwitterManager.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TwitterManager.h"

@implementation TwitterManager

@synthesize twitterAccount;

- (id)init
{
    if(![super init]) {
        return nil;
    }
    
    // Initialise the account store.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Set the account type to Twitter.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Ask the user for permission to access their Twitter account(s).
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            // Create an array of all the users Twitter accounts.
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                // To keep it simple, just take the last Twitter account.
                // In the future we should really provide a choice.
                twitterAccount = [accounts lastObject];
                
                // Now we've got hold of a Twitter account, go get all the trends.
                [self loadTrends];
            }
        }
        else
        {
            NSLog(@"No Twitter access granted");
        }
    }];
    
    return self;
}

- (void)loadTrends
{
    // Make 100% sure we've got a Twitter account.
    if ( twitterAccount != nil )
    {
        // The Twitter API URL for returning the top 10 trending topics for a specific WOEID,
        // if trending information is available for it.
        // https://dev.twitter.com/docs/api/1.1/get/trends/place
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json"];
        
        // Parameters for the above URL.
        NSDictionary *params = @{@"id" : @"1"};
        
        // Build the Twitter request.
        SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                           requestMethod:SLRequestMethodGET
                                                                     URL:url
                                                              parameters:params];
        
        // Attach the Twitter account for authentication.
        [twitterInfoRequest setAccount:twitterAccount];
        
        // Actually talk to Twitter.
        [twitterInfoRequest performRequestWithHandler:^(NSData *responseData,
                                                        NSHTTPURLResponse *urlResponse,
                                                        NSError *error)
        {
            // Wait asynchronically so that we don't hold up other important processing. 
            dispatch_async(dispatch_get_main_queue(), ^
            {
                // Ensure we've got some data.
                if ( responseData )
                {
                    // Ensure we've got a valid response.
                    if ( urlResponse.statusCode >= 200 && urlResponse.statusCode < 300 )
                    {
                        // Parse the JSON from the response.
                        NSError *jsonError;
                        NSDictionary *trendData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                  options:NSJSONReadingAllowFragments
                                                                                    error:&jsonError];
                        
                        // Ensure the JSON parsed correctly.
                        if ( trendData )
                        {
                            NSLog(@"Twitter Response: %@\n", trendData);
                        }
                        else
                        {
                            // The JSON deserialisation went wrong. Log the error.
                            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                        }
                    }
                    else
                    {
                        // Twitter was unhappy with us. Log the status code.
                        NSLog(@"The response status code was %d", urlResponse.statusCode);
                    }
                }
            });
        }];
    }
}

@end
