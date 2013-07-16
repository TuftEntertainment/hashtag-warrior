//
//  TwitterSearchTweets.h
//  hashtag-warrior
//
//  Created by Nick James on 30/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TwitterProtocol.h"

@interface TwitterSearchTweets : NSObject<TwitterProtocol>
{
    NSString* _searchCriteria;
    NSMutableArray* _searchResults;
    bool _stale;
}

-(void)setSearchCriteria:(NSString*)criteria;

-(NSArray*)getSearchResults;
-(bool)isStale;

@end
