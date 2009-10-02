//
//  DemoViewController.h
//  Demo
//
//  Created by Lee Buck on 8/23/09.
//  Copyright Blue Bright Ventures 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoViewController : UIViewController {
	
	IBOutlet UITextView* textView;
	IBOutlet UISegmentedControl* segmentControl;
	NSString* source;
	NSString* pattern;
	NSString* result;
	int selectedIndex;
}

@property (nonatomic, retain) NSString* source;
@property (nonatomic, retain) NSString* pattern;
@property (nonatomic, retain) NSString* result;

-(IBAction)updateView:(id)sender;

@end

