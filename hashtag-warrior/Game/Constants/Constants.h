//
//  Constants.h
//  hashtag-warrior
//
//  Created by Daniel Wood on 20/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#ifndef hashtag_warrior_Constants_h
#define hashtag_warrior_Constants_h

// UI & appearance
#define kHWBackgroundColor ccc4(142, 193, 218, 255)
#define kHWTextColor ccc3(8, 90, 124);
#define kHWTextHeadingFamily @"Marker Felt"
#define kHWTextBodyFamily @"Arial12.fnt"

// Define macros to position items according to percentages on screen
#define PCT_FROM_TOP(__f__)\
[[CCDirector sharedDirector] winSize].height - [[CCDirector sharedDirector] winSize].height * __f__

#define PCT_FROM_LEFT(__f__)\
[[CCDirector sharedDirector] winSize].width - [[CCDirector sharedDirector] winSize].width * __f__

// Define macros to convert from an iPhone ccp to iPad ccp.
// Note: Not much use when using the size from the director
// (e.g. [[CCDirector sharedDirector] winSize].width) as this returns size of current device
#define kXoffsetiPad        64
#define kYoffsetiPad        32

#define ADJUST_X(__x__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__x__ * 2) + kXoffsetiPad : __x__)

#define ADJUST_Y(__y__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? (__y__ * 2) + kYoffsetiPad : __y__)

#define ADJUST_CCP(__p__)\
(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? ccp( ADJUST_X(__p__.x), ADJUST_Y(__p__.y) ) : __p__)

// Gameplay
#define kHeroTagValue 0
#define kHWMinProjectileSize 2.0f          // TODO net yet used
#define kHWMaxProjectileSize 10.0f         // TODO net yet used
#define kHWMinProjectileStartVelocity 2.0f // TODO net yet used
#define kHWMaxProjectileStartVelocity 8.0f // TODO net yet used
#define kHWMinProjectileStartAngle -5      // TODO net yet used
#define kHWMaxProjectileStartAngle 30      // TODO net yet used

// Environment
#define kHWMaxVelocity 10.0f
#define kHWForceMagnifier 5
#define PTM_RATIO 32

// Misc
#define kHWIsDebug 1

#endif
