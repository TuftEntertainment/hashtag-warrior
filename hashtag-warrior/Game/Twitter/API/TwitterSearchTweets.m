//
//  TwitterSearchTweets.m
//  hashtag-warrior
//
//  Created by Nick James on 30/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TwitterSearchTweets.h"

@implementation TwitterSearchTweets

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    // Default the search criteria to us!
    _searchCriteria = @"#Warrior";
    
    return self;
}

-(NSURL*)getURL
{
    // The Twitter API URL for searching for Tweets with a specific criteria.
    // See https://dev.twitter.com/docs/api/1.1/get/search/tweets for more details.
    
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
}

-(NSDictionary*)getParams
{
    // Params
    //
    // q           - A UTF-8, URL-encoded search query of 1,000 characters maximum, including operators.
    // required      Queries may additionally be limited by complexity.
    //
    // count       - The number of tweets to return per page, up to a maximum of 100. Defaults to 15.
    // optional      This was formerly the "rpp" parameter in the old Search API.
    //
    // result_type - Specifies what type of search results you would prefer to receive.
    // optional      The current default is "mixed." Valid values include:
    //                 * mixed: Include both popular and real time results in the response.
    //                 * recent: return only the most recent results in the response
    //                 * popular: return only the most popular results in the response.
    
    return @{@"q"           : _searchCriteria,
             @"count"       : @"100",
             @"result_type" : @"recent"};;
}

-(bool)parseResponse:(NSDictionary*)json;
{
    bool parseOk = FALSE;

    // Get the statuses.
    NSArray* statuses = [json objectForKey:@"statuses"];
    
    // Did we get any statuses?
    if ( statuses )
    {
        // We did! Now extract them all.
        for ( int i = 0; i < statuses.count; ++i )
        {
            // Pull out the user and their tweet.
            NSDictionary* userDetails = [statuses[i] objectForKey:@"user"];
            NSString* username = [userDetails objectForKey:@"screen_name"];
            NSString* tweet = [statuses[i] objectForKey:@"text"];

            // Log it to gloat of our success.
            NSLog(@"\n\t%@ tweeted: '%@'", username, tweet);
        }
    }
    else
    {
        // We didnt. Log an error.
        NSLog(@"Statuses not found in response");
    }
    
    return parseOk;
}

-(void)setSearchCriteria:(NSString*)criteria
{
    _searchCriteria = criteria;
}

@end
