//
//  DemoAppDelegate.h
//  Demo
//
//  Created by Lee Buck on 8/23/09.
//  Copyright Blue Bright Ventures 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoViewController;

@interface DemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DemoViewController *viewController;

@end

