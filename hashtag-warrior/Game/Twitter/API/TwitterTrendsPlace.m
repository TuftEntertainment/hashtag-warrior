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
    
    // Default the WOE ID to "global"
    // For more information on WOE IDs, see developer.yahoo.com/geo/geoplanet
    _location = @"1";
    
    _lastFetched = [NSDate distantPast];
    _results = [[NSMutableArray alloc] init];
    
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
    
    return @{@"id" : _location};
}

-(bool)parseResponse:(NSArray*)json;
{
    bool parseOk = FALSE;
    
    // Store the datetime the trends are from
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    _lastFetched = [df dateFromString:((json[0])[@"as_of"])];
    
    // Iterate over the response and find the block of trends
    NSArray* trends = nil;
    for ( int i = 0; i < json.count && !trends; ++i )
    {
        trends = (json[i])[@"trends"];
    }
    
    // Did we get any trends?
    if ( trends )
    {
        // We did! Now extract them all
        NSLog(@"%i trends received", trends.count);
        for ( int i = 0; i < trends.count; ++i )
        {
            [_results addObject:(trends[i])[@"name"]];
        }
        
        parseOk = TRUE;
    }
    else
    {
        // We didnt. Log an error
        NSLog(@"Trends not found in response");
    }
    
    return parseOk;
}

-(void)setLocation:(NSString *)woeid
{
    _location = woeid;
}

-(NSArray*)getResults
{
    return _results;
}

-(bool)isStale
{
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:_lastFetched];
    
    return diff > 300;
}

@end
