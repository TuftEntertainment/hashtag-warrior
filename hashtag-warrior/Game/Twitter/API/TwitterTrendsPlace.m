//
//  TwitterTrendsPlace.m
//  hashtag-warrior
//
//  Created by Nick James on 29/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TwitterTrendsPlace.h"

@implementation TwitterTrendsPlace

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    return self;
}

-(NSURL*)getURL
{
    // The Twitter API URL for returning the top 10 trending topics for a specific WOEID,
    // if trending information is available for it.
    // See https://dev.twitter.com/docs/api/1.1/get/trends/place for more details.
    
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json"];
}

-(NSDictionary*)getParams
{
    // Params
    //
    // id - The Yahoo! Where On Earth ID of the location to return trending information for.
    //      Global information is available by using 1 as the WOEID.
    
    return @{@"id" : @"1"};;
}

-(bool)parseResponse:(NSArray*)json;
{
    bool parseOk = FALSE;
    
    NSArray* trends = nil;
    
    // Iterate over the response and find the block of trends.
    for ( int i = 0; i < json.count && !trends; ++i )
    {
        // Try and get the trends.
        trends = (json[i])[@"trends"];
    }
    
    // Did we get any trends?
    if ( trends )
    {
        // We did! Now extract them all.
        for ( int i = 0; i < trends.count; ++i )
        {
            // Pull out the trend name, that's the only bit we care about.
            NSString* trend = (trends[i])[@"name"];
            
            // Log it to gloat of our success.
            NSLog(@"\n\tTrend: %@", trend);
        }
        
        parseOk = TRUE;
    }
    else
    {
        // We didnt. Log an error.
        NSLog(@"Trends not found in response");
    }
    
    return parseOk;
}

@end
