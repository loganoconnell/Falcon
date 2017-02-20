#import "UILabel+AutomaticWriting/UILabel+AutomaticWriting.h"

@interface PSViewController : UIViewController
@end

@interface PSListController : PSViewController {
	id _specifiers;
}
- (id)specifiers;
- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;
@end

@interface FCNRootListController : PSListController
@end

@interface TWTweetComposeViewController : UIViewController
+ (BOOL)canSendTweet;
- (void)setInitialText:(NSString *)arg1;
@end

@interface PSTableCell : UITableView
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;
@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
@end

@interface PSSwitchTableCell : UITableViewCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
- (UISwitch *)control;
@end

@interface PSSpecifier : NSObject
- (id)propertyForKey:(NSString *)arg1;
- (NSString *)name;
@end

@interface PSRootController : UINavigationController
+ (id)readPreferenceValue:(id)arg1;
+ (void)setPreferenceValue:(id)arg1 specifier:(id)arg2;
@end

@interface PSSliderTableCell : UITableViewCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
- (void)setValue:(id)arg1;
- (PSSpecifier *)specifier;
@end

@protocol MFMailComposeViewControllerDelegate
@optional
- (void)mailComposeController:(id)arg1 didFinishWithResult:(id)arg2 error:(NSError *)arg3;
@end

@interface MFMailComposeViewController : UIViewController
@property (nonatomic, assign) id <MFMailComposeViewControllerDelegate> mailComposeDelegate;
+ (BOOL)canSendMail;
- (void)setToRecipients:(NSArray *)arg1;
- (void)setSubject:(NSString *)arg1;
- (void)setMessageBody:(NSString *)arg1 isHTML:(BOOL)arg2;
@end

@interface LAContext : NSObject
- (BOOL)canEvaluatePolicy:(int)arg1 error:(id *)arg2;
- (void)evaluatePolicy:(int)arg1 localizedReason:(id)arg2 reply:(void (^)(BOOL success, NSError *error))arg3;
@end

typedef NS_ENUM (NSInteger, LAPolicy) {
   LAPolicyDeviceOwnerAuthenticationWithBiometrics = 1 
};

CFPropertyListRef MGCopyAnswer(CFStringRef property);