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
#import "Box2D.h"

@interface GameState : NSObject <NSCoding>
{
    // Hashtag.
    NSString *_hashtag;
    
    // Score.
    NSInteger _score;
    
    // Gravity.
    b2Vec2 _gravity;
}

@property (readwrite) NSString *_hashtag;
@property (readwrite) NSInteger _score;
@property (readwrite) b2Vec2 _gravity;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GameState);

@end
