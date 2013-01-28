//
//  TwitterManager.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

@interface TwitterManager : NSObject {
    NSArray* trends;
    NSDate* trendsLastFetched;
}

@property (readonly) NSDate* trendsLastFetched;

- (void)loadTrends;

@end
