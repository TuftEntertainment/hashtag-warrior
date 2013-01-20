//
//  GameState.h
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//
//

#import <Foundation/Foundation.h>

#import "SynthesizeSingleton.h"
#import "cocos2d.h"

@interface GameState : NSObject <NSCoding>
{
    NSInteger _score;
    Boolean _won;
}

@property (readwrite) NSInteger _score;
@property (readwrite) Boolean _won;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GameState);

@end
