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
