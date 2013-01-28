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

- (id)init
{
    if(![super init]) {
        return nil;
    }
    
    [self loadTrends];
    
    return self;
}

- (void)loadTrends
{
    // Configure the request
    // TODO locale-specific trends based on the WOEID
    // TODO make amusing joke about WOE...IDs
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"id" forKey:@"1"];
    SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter
                                            requestMethod: SLRequestMethodGET
                                                      URL: url
                                               parameters: params];
    
    // Actually make the request
    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if(responseData) {
            // Data is returned as JSON, parse it
            NSError *jsonError;
            NSArray *currentTrends = [NSJSONSerialization JSONObjectWithData: responseData
                                                              options: NSJSONReadingMutableLeaves
                                                                error: &jsonError];
            
            if(currentTrends) {
                // TODO u r here
                NSLog(@"array: %@", currentTrends);
                
                trends = currentTrends;
                trendsLastFetched = [NSDate date];
                
            } else {
                // TODO make some attempt to handle JSON errors...
            }
        }
        
        // TODO make some attempt to handle network/API errors...
    }];
}

- (NSArray*)getTrends
{
    if([trendsLastFetched timeIntervalSinceNow] > 1800) {
        [self loadTrends];
    }
    
    return trends;
}

@end
