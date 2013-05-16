//
//  Queue.m
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "Queue.h"

@implementation Queue

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    // Initialise the mutable array.
    _items = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)addToQueue:(id)item
{
    [_items addObject:item];
}

- (id)peekQueue
{
    id item = nil;
    
    // Ensure there's something left.
    if ( [_items count] > 0 )
    {
        // There is, take it from the queue.
        item = [_items objectAtIndex:0];
    }
    
    return item;
}

- (id)popQueue
{
    // Peek the top of the queue.
    id item = [self peekQueue];
    
    // If we got something back, remove it from the queue.
    if ( item )
    {
        [_items removeObjectAtIndex:0];
    }
    
    return item;
}

- (NSUInteger)count
{
    return [_items count];
}

@end
