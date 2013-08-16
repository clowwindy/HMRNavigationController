HMRNavigationController
=======================

Drop-in replacement with UINavigationController

Features
--------

1. Go back with pan gesture
2. iOS 7 like animation
3. Just replace your UINavigationController

Screenshot
----------

![Screenshot](https://raw.github.com/clowwindy/HMRNavigationController/master/screenshot.png)

Usage
-----

Drag Products/HMRNavigationController.framework to your project.

Import the header:

    #import "HMRNavigationController/HMRNavigationController.h

Replace your UINavigationController with HMRNavigationController:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{	
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    MyViewController *mainViewController = [[MyViewController alloc] init];
	    UINavigationController *navigationController = [[HMRNavigationController alloc] initWithRootViewController:mainViewController];
	    [navigationController setNavigationBarHidden:YES animated:NO];
	    self.window.rootViewController = navigationController;
	    [self.window makeKeyAndVisible];
	    return YES;
	}