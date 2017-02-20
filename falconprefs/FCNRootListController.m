#include "FCNRootListController.h"

@implementation FCNRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FalconPrefs.bundle/twitter.png"] style:UIBarButtonItemStyleDone target:self action:@selector(share:)], nil];
}

- (void)viewWillAppear:(BOOL)arg1 {
	[self.navigationItem setTitle:@""];

	[super viewWillAppear:arg1];
}

- (void)viewDidAppear:(BOOL)arg1 {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FalconPrefs.bundle/icon.png"]];
    imageView.frame = CGRectMake(0, 0, 29, 29);
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.navigationItem.titleView = imageView;

    [super viewDidAppear:arg1];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist" isDirectory:nil]) {
		[fileManager createFileAtPath:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist" contents:nil attributes:nil];
		[[NSMutableDictionary dictionary] writeToFile:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist" atomically:YES];
	}
}

- (void)respring {
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[[UIAlertView alloc] initWithTitle:@"Respring?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    #pragma clang diagnostic pop
}

- (void)followLogan {
	NSString *user = @"logandev22";

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	}
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	}
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	}
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	}
	
	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
	}
	#pragma clang diagnostic pop
}

- (void)share:(id)sender {
    TWTweetComposeViewController *tweetComposeViewController = [TWTweetComposeViewController new];
    [tweetComposeViewController setInitialText:@"#Falcon - A powerful, dynamic lock screen and NC add-on! Developed by @logandev22"];
    
    [self.navigationController presentViewController:tweetComposeViewController animated:YES completion:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)arg1 clickedButtonAtIndex:(NSInteger)arg2 {
	if (arg2 == 1) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.tweaksbylogan.falcon/respring"), NULL, NULL, YES);
    }
}
#pragma clang diagnostic pop
@end

@interface FalconPrefsCustomCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *firstLabel;
	UILabel *secondLabel;
	UILabel *thirdLabel;
}
@end

@implementation FalconPrefsCustomCell
- (id)initWithSpecifier:(id)arg1 {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FalconCell"]) {
		firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, [[UIScreen mainScreen] bounds].size.width, 60)];
		[firstLabel setNumberOfLines:1];
		firstLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:36];
		[firstLabel setBackgroundColor:[UIColor clearColor]];
		firstLabel.textColor = [UIColor blackColor];
		firstLabel.textAlignment = NSTextAlignmentCenter;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		    [firstLabel setText:@"Falcon" automaticWritingAnimationWithDuration:0.1 blinkingMode:UILabelAWBlinkingModeUntilFinish]; 
		});
		[self addSubview:firstLabel];

		secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 60)];
		[secondLabel setNumberOfLines:1];
		secondLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[secondLabel setText:@"A powerful, dynamic lock screen and NC add-on!"];
		[secondLabel setBackgroundColor:[UIColor clearColor]];
		secondLabel.textColor = [UIColor grayColor];
		secondLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:secondLabel];

		thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 60)];
		[thirdLabel setNumberOfLines:1];
		thirdLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[thirdLabel setText:@"Created by Logan O’Connell"];
		[thirdLabel setBackgroundColor:[UIColor clearColor]];
		thirdLabel.textColor = [UIColor grayColor];
		thirdLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:thirdLabel];
	}
	
	return self;
}
 
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 90;
}
@end

@interface FalconSupportController : PSListController <MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mailComposeViewController;
}
@end

@implementation FalconSupportController
- (id)specifiers {
	if ([MFMailComposeViewController canSendMail]) {
		mailComposeViewController = [MFMailComposeViewController new];
	    mailComposeViewController.mailComposeDelegate = self;
	    [mailComposeViewController setToRecipients:[NSArray arrayWithObjects:@"Logan O'Connell <logan.developeremail@gmail.com>", nil]];
	    [mailComposeViewController setSubject:[NSString stringWithFormat:@"Falcon Support"]];
	    [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"\n\n\nDevice: %@ on iOS %@", (NSString *)MGCopyAnswer(CFSTR("ProductType")), (NSString *)MGCopyAnswer(CFSTR("ProductVersion"))] isHTML:NO];

	    [self.navigationController presentViewController:mailComposeViewController animated:YES completion:nil];
	}

	else {
		[self.navigationController popViewControllerAnimated:YES];

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have no configured mail accounts." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	    #pragma clang diagnostic pop
	}

    return nil;
}

- (void)viewWillAppear:(BOOL)arg1 {
	[self.navigationItem setTitle:@""];

	[super viewWillAppear:arg1];
}

- (void)viewDidAppear:(BOOL)arg1 {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FalconPrefs.bundle/support.png"]];
    imageView.frame = CGRectMake(0, 0, 29, 29);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;

    [super viewDidAppear:arg1];
}

- (void)mailComposeController:(MFMailComposeViewController *)arg1 didFinishWithResult:(id)arg2 error:(NSError *)arg3 {
    [arg1 dismissViewControllerAnimated:YES completion:nil];

    [self.navigationController popViewControllerAnimated:YES];
}
@end

@interface FalconCustomSwitchCell : PSSwitchTableCell
@end

@implementation FalconCustomSwitchCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
   	if (self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3]) {
        [[self control] setOnTintColor:[UIColor blackColor]];
    }
    
    return self;
}
@end

@interface FalconLSDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *enabledViews;
@property (nonatomic, strong) NSMutableArray *disabledViews;
@property (nonatomic, strong) NSMutableDictionary *prefs;
@end

@implementation FalconLSDelegate
- (id)init {
	if (self = [super init]) {
		self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist"];
        self.enabledViews = [self.prefs objectForKey:@"LSenabledViews"] ? [[self.prefs objectForKey:@"LSenabledViews"] mutableCopy] : [NSMutableArray arrayWithObjects:@"Today", @"Main", @"Camera", nil];
        self.disabledViews = [self.prefs objectForKey:@"LSdisabledViews"] ? [[self.prefs objectForKey:@"LSdisabledViews"] mutableCopy] : [NSMutableArray arrayWithObjects:@"Notes", @"Search", @"Toggle", nil];
	}

	return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Enabled";
        case 1:
            return @"Disabled";
        default:
        	return @"Header";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == 0) ? self.enabledViews.count : self.disabledViews.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FalconLSCell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FalconLSCell"];

    cell.textLabel.text = (indexPath.section == 0) ? self.enabledViews[indexPath.row] : self.disabledViews[indexPath.row];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.enabledViews.count > indexPath.row && indexPath.section == 0) {
    	if ([self.enabledViews[indexPath.row] isEqualToString:@"Main"])
    		return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if (destinationIndexPath.section == 0 && sourceIndexPath.section == 0) {
		NSString *temp = self.enabledViews[sourceIndexPath.row];
		[self.enabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.enabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	else if (destinationIndexPath.section == 1 && sourceIndexPath.section == 1) {
		NSString *temp = self.disabledViews[sourceIndexPath.row];
		[self.disabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.disabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}
	else if (destinationIndexPath.section == 0 && sourceIndexPath.section == 1) {
		NSString *temp = self.disabledViews[sourceIndexPath.row];
		[self.disabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.enabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	else if (destinationIndexPath.section == 1 && sourceIndexPath.section == 0) {
		NSString *temp = self.enabledViews[sourceIndexPath.row];
		[self.enabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.disabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	[self.prefs setObject:self.enabledViews forKey:@"LSenabledViews"];
	[self.prefs setObject:self.disabledViews forKey:@"LSdisabledViews"];
	[self.prefs writeToFile:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist" atomically:YES];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.tweaksbylogan.falcon/saved"), NULL, NULL, YES);
	[tableView reloadData];
}
@end

@interface FalconLSController : PSListController
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation FalconLSController
- (id)initForContentSize:(CGSize)size {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        FalconLSDelegate *delegate = [FalconLSDelegate new];
        self.tableView.delegate = delegate;
        self.tableView.dataSource = delegate;
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        self.view = self.tableView;
        self.tableView.editing = YES;

    return self;
}
@end

@interface FalconNCDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *enabledViews;
@property (nonatomic, strong) NSMutableArray *disabledViews;
@property (nonatomic, strong) NSMutableDictionary *prefs;
@end

@implementation FalconNCDelegate
- (id)init {
	if (self = [super init]) {
		self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist"];
        self.enabledViews = [self.prefs objectForKey:@"NCenabledViews"] ? [[self.prefs objectForKey:@"NCenabledViews"] mutableCopy] : [NSMutableArray arrayWithObjects:@"Today", @"Main", nil];
        self.disabledViews = [self.prefs objectForKey:@"NCdisabledViews"] ? [[self.prefs objectForKey:@"NCdisabledViews"] mutableCopy] : [NSMutableArray arrayWithObjects:@"Notes", @"Search", @"Toggle", nil];
	}

	return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Enabled";
        case 1:
            return @"Disabled";
        default:
        	return @"Header";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == 0) ? self.enabledViews.count : self.disabledViews.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FalconNCCell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FalconNCCell"];

    cell.textLabel.text = (indexPath.section == 0) ? self.enabledViews[indexPath.row] : self.disabledViews[indexPath.row];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.enabledViews.count > indexPath.row && indexPath.section == 0) {
    	if ([self.enabledViews[indexPath.row] isEqualToString:@"Main"])
    		return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if (destinationIndexPath.section == 0 && sourceIndexPath.section == 0) {
		NSString *temp = self.enabledViews[sourceIndexPath.row];
		[self.enabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.enabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	else if (destinationIndexPath.section == 1 && sourceIndexPath.section == 1) {
		NSString *temp = self.disabledViews[sourceIndexPath.row];
		[self.disabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.disabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}
	else if (destinationIndexPath.section == 0 && sourceIndexPath.section == 1) {
		NSString *temp = self.disabledViews[sourceIndexPath.row];
		[self.disabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.enabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	else if (destinationIndexPath.section == 1 && sourceIndexPath.section == 0) {
		NSString *temp = self.enabledViews[sourceIndexPath.row];
		[self.enabledViews removeObjectAtIndex:sourceIndexPath.row];
		[self.disabledViews insertObject:temp atIndex:destinationIndexPath.row];
	}

	[self.prefs setObject:self.enabledViews forKey:@"NCenabledViews"];
	[self.prefs setObject:self.disabledViews forKey:@"NCdisabledViews"];
	[self.prefs writeToFile:@"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist" atomically:YES];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.tweaksbylogan.falcon/saved"), NULL, NULL, YES);
	[tableView reloadData];
}
@end

@interface FalconNCController : PSListController
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation FalconNCController
- (id)initForContentSize:(CGSize)size {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];        
        FalconNCDelegate *delegate = [FalconNCDelegate new];
        self.tableView.delegate = delegate;
        self.tableView.dataSource = delegate;
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        self.view = self.tableView;
        self.tableView.editing = YES;

    return self;
}
@end