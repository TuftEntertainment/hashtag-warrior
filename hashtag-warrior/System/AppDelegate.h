//
//  AppDelegate.h
//  hashtag-warrior
//
//  Created by Nick James on 13/01/2013.
//  Copyright Ossum Games 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
    UIWindow *window_;
    UINavigationController *navController_;
    
    CCDirectorIOS    *director_;                            // weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
