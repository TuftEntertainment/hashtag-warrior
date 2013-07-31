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
