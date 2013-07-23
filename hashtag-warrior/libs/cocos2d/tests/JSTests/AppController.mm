//
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "AppController.h"
#import "jsb_core.h"
#import "jsb_basic_conversions.h"

// CocosBuilder Reader
#import "CCBReader.h"

// SpiderMonkey
#include "jsapi.h"  

#pragma mark - AppDelegate - iOS

// CLASS IMPLEMENTATIONS

@implementation AppController

#pragma mark - AppController - iOS

#ifdef __CC_PLATFORM_IOS

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH24_STENCIL8_OES
							preserveBackbuffer:YES
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	// Multiple touches
	[glView setMultipleTouchEnabled:YES];
	
	director_.wantsFullScreenLayout = YES;
	// Display Milliseconds Per Frame
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];


	// Enables High Res mode (Retina Display) for CocosDragon
	NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	if( [name isEqual:@"JS CocosDragon"] ) {
		if( ! [director_ enableRetinaDisplay:YES] )
			CCLOG(@"Retina Display Not supported");
	}

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];


	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		[self run];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//	return YES;
	NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	
	if( [name isEqual:@"JS Watermelon"] )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	else if( [name isEqual:@"JS Tests"] )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	else if( [name isEqual:@"JS Moon Warriors"] )
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else if( [name isEqual:@"JS CocosDragon"] )
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else if( [name isEqual:@"JS Crystal Craze"] )
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	
	return YES;
}

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	glDisable( GL_DEPTH_TEST );
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	[director_ setResizeMode:kCCDirectorResize_AutoScale];
//	[director_ setResizeMode:kCCDirectorResize_NoScale];

	[self run];
}

#endif // Platform specific
	

#pragma mark - AppController - Common

-(void)dealloc
{
	[super dealloc];
}

-(void) run
{	
	NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];

	CCFileUtils *fileutils = [CCFileUtils sharedFileUtils];

	// Add the "js" folder in the search path, since it is a "blue folder"
	[fileutils setSearchPath:@[@"js", @""]];

	//
	// Watermelon
	//
	if( [name isEqual:@"JS Watermelon"] ) {
#if defined(__CC_PLATFORM_MAC)
		// Use ipad resources for Mac
		[[fileutils suffixesDict] setObject:@"-ipad" forKey:kCCFileUtilsMac];
		[[fileutils suffixesDict] setObject:@"-ipadhd" forKey:kCCFileUtilsMacHD];
		NSLog(@"%@", [fileutils suffixesDict]);
#endif
		[[JSBCore sharedInstance] runScript:@"boot-jsb.js"];
	}

	//
	// Tests
	//
	else if( [name isEqual:@"JS Tests"] ) {
		struct timeval	startTime, endTime;

		gettimeofday(&startTime, NULL);
		[[JSBCore sharedInstance] runScript:@"tests-boot-jsb.js"];
		gettimeofday(&endTime, NULL);
		timersub(&endTime, &startTime, &endTime);
		double duration = endTime.tv_sec * 1000.0 + endTime.tv_usec / 1000.0;
		printf("--> duration: %f ms\n", duration);
	}
	//
	// Moon Warriors
	//
	else if( [name isEqual:@"JS Moon Warriors"] )
		[[JSBCore sharedInstance] runScript:@"MoonWarriors-jsb.js"];
	//
	// CocosDragon
	//
	else if( [name isEqual:@"JS CocosDragon"] ) {
		[fileutils setSearchMode:kCCFileUtilsSearchDirectoryMode];
		[fileutils setSearchPath:@[@"Published files iOS", @"js", @""]];

#if defined(__CC_PLATFORM_MAC)
		// Use the iPad folder for Mac resources
		[[fileutils directoriesDict] setObject:@"resources-ipad" forKey:kCCFileUtilsMac];
		[[fileutils directoriesDict] setObject:@"resources-iphonehd" forKey:kCCFileUtilsiPhoneHD];

		// Serch on iPhoneHD resources as a fallback
		NSMutableArray *array = [[fileutils searchResolutionsOrder] mutableCopy];
		[array insertObject:kCCFileUtilsiPhoneHD atIndex:1];
		[fileutils setSearchResolutionsOrder:array];
		
		[CCBReader setResolutionScale:2];

#else
		[fileutils setEnableiPhoneResourcesOniPad:YES];
#endif
		[[JSBCore sharedInstance] runScript:@"main.js"];
	}

	//
	// Crystal Craze
	//
	else if( [name isEqual:@"JS Crystal Craze"] ) {
		[fileutils setSearchMode:kCCFileUtilsSearchDirectoryMode];
		[fileutils setSearchPath:@[@"Published-iOS", @"js", @""]];
		
#if defined(__CC_PLATFORM_MAC)
		// Use the iPhone folder for Mac resources
		[[fileutils directoriesDict] setObject:@"resources-iphone" forKey:kCCFileUtilsMac];
#else
		[fileutils setEnableiPhoneResourcesOniPad:YES];
#endif
		[[JSBCore sharedInstance] runScript:@"main.js"];
	}

}
@end


