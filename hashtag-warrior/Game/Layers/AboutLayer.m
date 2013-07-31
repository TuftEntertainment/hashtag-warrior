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

#import "AboutLayer.h"
#import "Constants.h"
#import "GameManager.h"

@implementation AboutLayer

- (id)init
{
    if ((self=[super init]))
    {
        // Window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Add labels
        int posY = size.height-60;
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"#Warrior"
                                        fontName:kHWTextHeadingFamily
                                        fontSize:48];
        title.position = ccp(size.width/2, posY);
        title.color = kHWTextColor;
        posY -= 80;
        
        CCLabelTTF *blurb = [CCLabelTTF labelWithString:NSLocalizedString(@"About Blurb", nil)
                                        fontName:@"Arial"
                                        fontSize:18];
        blurb.position = ccp(size.width/2, posY);
        blurb.color = kHWTextColor;
        posY -= 80;
        
        CCLabelTTF *credits = [CCLabelTTF labelWithString:NSLocalizedString(@"About Credits", nil)
                                          fontName:@"Arial"
                                          fontSize:14];
        credits.position = ccp(size.width/2, posY);
        credits.color = kHWTextColor;
        
        [self addChild: title];
        [self addChild: blurb];
        [self addChild: credits];
        
        // Add return to menu... menu
        [CCMenuItemFont setFontSize:18];
        CCMenuItemLabel *home = [CCMenuItemFont itemWithString:NSLocalizedString(@"Main Menu", nil) block:^(id sender)
                                  {
                                      [[GameManager sharedGameManager] runSceneWithID:kHWMainMenuScene];
                                  }];
        home.color = kHWTextColor;
        CCMenu *menu = [CCMenu menuWithItems:home, nil];
        [menu alignItemsVertically];
        [menu setPosition:ccp(size.width/2, 20)];
        
        [self addChild: menu];
    }
    return self;
}

@end
