//
//  DemoAppDelegate.m
//  Demo
//
//  Created by Lee Buck on 8/23/09.
//  Copyright Blue Bright Ventures 2009. All rights reserved.
//

#import "DemoAppDelegate.h"
#import "DemoViewController.h"

@implementation DemoAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
