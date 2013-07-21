//
//  TwitterTrendsPlace.h
//  hashtag-warrior
//
//  Created by Nick James on 29/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TwitterProtocol.h"

@interface TwitterTrendsPlace : NSObject<TwitterProtocol>
{
    NSString* _location;
    NSDate* _lastFetched;
    NSMutableArray* _results;
}

-(void)setLocation:(NSString*)woeid;
-(NSArray*)getResults;
-(bool)isStale;

@end
