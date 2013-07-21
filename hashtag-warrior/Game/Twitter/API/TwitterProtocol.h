//
//  TwitterProtocol.h
//  hashtag-warrior
//
//  Created by Nick James on 29/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterProtocol

-(NSURL*)getURL;
-(NSDictionary*)getParams;
-(bool)parseResponse:(NSData*)json;

@end
