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

#import "TwitterManager.h"

#import <Twitter/Twitter.h>

@implementation TwitterManager

@synthesize _twitterAccount;

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    // Initialise the account store.
    _accountStore = [[ACAccountStore alloc] init];
    
    // Set the account type to Twitter.
    _accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Ask the user for permission to access their Twitter account(s).
    [_accountStore requestAccessToAccountsWithType:_accountType
                             withCompletionHandler:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            // Create an array of all the users Twitter accounts.
            NSArray *accounts = [_accountStore accountsWithAccountType:_accountType];
            if (accounts.count > 0)
            {
                // To keep it simple, just take the last Twitter account.
                // In the future we should really provide a choice.
                _twitterAccount = [accounts lastObject];
                
                // Store if we've been granted permission for later.
                _granted = granted;
            }
        }
        else
        {
            NSLog(@"No Twitter access granted");
        }
    }];
    
    return self;
}

- (bool)twitterPermission
{
    return _granted;
}

- (bool)talkToTwitter:(NSObject<TwitterProtocol>*)protocol
{
    __block bool success = FALSE;
    
    // Make 100% sure we've got a Twitter account.
    if ( _twitterAccount != nil )
    {
        // Build the Twitter request.
        TWRequest* twitterInfoRequest = [[TWRequest alloc] initWithURL:[protocol getURL]
                                                            parameters:[protocol getParams]
                                                         requestMethod:TWRequestMethodGET];

        // Attach the Twitter account for authentication.
        [twitterInfoRequest setAccount:_twitterAccount];
    
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
                        NSData *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:&jsonError];
                        
                        // Ensure the JSON deserialised correctly.
                        if ( json )
                        {
                            success = [protocol parseResponse:json];
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
    
    return success;
}

@end
