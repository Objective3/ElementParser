//
//  DemoViewController.m
//  Demo
//
//  Created by Lee Buck on 8/23/09.
//  Copyright Blue Bright Ventures 2009. All rights reserved.
//

#import "DemoViewController.h"
#import "Element.h"
#import "DocumentRoot.h"

@implementation DemoViewController

@synthesize source, pattern, result;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	/* pre populate source with the source.html file */
	NSString* path = [[NSBundle mainBundle] pathForResource: @"source" ofType: @"html"];
	NSStringEncoding encoding;
	self.source = [NSString stringWithContentsOfFile: path usedEncoding: &encoding error: NULL];
	textView.text = self.source;
	self.pattern = @"*";
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[source dealloc];
	[pattern dealloc];
	[result dealloc];
    [super dealloc];
}

-(NSString*)matchResult{
	DocumentRoot* document = [Element parseHTML: source];
	NSArray* elements = [document selectElements: pattern];	
	NSMutableArray* results = [NSMutableArray array];
	for (Element* element in elements){
		NSString* snipet = [element contentsSource];
		snipet = ([snipet length]  > 5) ? [snipet substringToIndex: 5] : snipet;
		snipet = [[element description] stringByAppendingFormat: @"%@...", snipet];
		[results addObject: snipet];
	}
	return [results componentsJoinedByString: @"\n—————————————————\n"];
}

-(IBAction)updateView:(id)sender{
	if (selectedIndex == [segmentControl selectedSegmentIndex]) return;
	
	if (selectedIndex == 0){
		self.source = [textView text];
	}
	else if (selectedIndex == 1){
		self.pattern = [textView text];
	}
	else if (selectedIndex == 2){
	}
	
	if ([segmentControl selectedSegmentIndex] == 0) {
		textView.text = self.source;
		textView.editable = YES;
	}
	else if ([segmentControl selectedSegmentIndex] == 1) {
		textView.text = self.pattern;
		textView.editable = YES;
	}
	else if ([segmentControl selectedSegmentIndex] == 2) {
		textView.editable = NO;
		textView.text = [self matchResult];
	}
	selectedIndex = [segmentControl selectedSegmentIndex];
}


@end
