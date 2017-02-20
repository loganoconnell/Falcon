#import "substrate.h"
#import <flipswitch/flipswitch.h>
#import "UAObfuscatedString/UAObfuscatedString.h"

// SpringBoard
@interface SBDashBoardComponent : NSObject
+ (id)dateView;
- (void)setHidden:(BOOL)arg1;
@end

@interface SBDashBoardAppearance : NSObject
- (void)addComponent:(SBDashBoardComponent *)arg1;
@end

@interface SBDashBoardBehavior : NSObject
- (void)setIdleTimerDuration:(long long)arg1;
@end

@interface SBDashBoardPageViewController : UIViewController
- (void)didTransitionToVisible:(BOOL)arg1;
- (void)aggregateAppearance:(SBDashBoardAppearance *)arg1;
- (void)aggregateBehavior:(SBDashBoardBehavior *)arg1;
- (UIView *)view;
- (id)dashBoardViewController;
@end

@interface FalconBrowserPageViewController : SBDashBoardPageViewController
@end

@interface FalconTogglePageViewController : SBDashBoardPageViewController
@end

@interface FalconNotesPageViewController : SBDashBoardPageViewController
@end

@interface SBPagedScrollView : UIScrollView <UITableViewDelegate, UITableViewDataSource>
- (NSArray *)pageViews;
- (void)setPageViews:(NSArray *)arg1;
- (void)_bs_willBeginScrolling;
- (BOOL)scrollToPageAtIndex:(unsigned long long)arg1 animated:(BOOL)arg2;
- (void)setVisiblePageRange:(NSRange)arg1;
@end

@interface SBDashBoardViewController : UIViewController
- (id)initWithPageViewControllers:(NSArray *)arg1 mainPageViewController:(SBDashBoardPageViewController *)arg2 legibilityProvider:(id)arg3;
- (void)activatePage:(unsigned long long)arg1 animated:(BOOL)arg2 withCompletion:(id)arg3;
- (void)activateMainPageWithCompletion:(id)arg1;
@end

@interface SPUIHeaderBlurView : UIVisualEffectView
@end

@interface SPUITextField : UITextField
@end

@interface SPUISearchHeader : UIView
- (SPUITextField *)searchField;
- (void)clearSearchFieldWhyQuery:(unsigned long long)arg1 allowZKW:(BOOL)arg2;
- (void)showCancelButton:(BOOL)arg1 animated:(BOOL)arg2;
- (void)cancelButtonClicked:(id)arg1;
- (BOOL)textFieldShouldReturn:(id)arg1;
- (BOOL)isOnDarkBackground;
- (void)enableDictationIfRequired;
@end

@interface FalconLSSearchHeader : SPUISearchHeader
@end

@interface FalconLSNotesSearchHeader : SPUISearchHeader
@end

@interface FalconNCSearchHeader : SPUISearchHeader
- (void)loadRequestFromString:(NSString *)string;
@end

@interface FalconNCNotesSearchHeader : SPUISearchHeader
@end

@interface SBNotificationCenterViewController : UIViewController
@end

@interface SBSearchEtceteraIsolatedViewController : UIViewController
- (void)dismissSearchViewWithReason:(unsigned long long)arg1;
- (void)searchFieldDidFocus;
@end

@interface SBFLockScreenDateView : UIView
@end

@interface SBBrightnessController : NSObject
+ (id)sharedBrightnessController;
- (void)setBrightnessLevel:(float)level;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (float)volume;
- (void)setVolume:(float)volume;
@end

@interface SBDashBoardPageControl
- (BOOL)isCameraPageEnabled;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)_setUILocked:(BOOL)arg1;
@end

// FrontBoard
@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
- (void)shutdownAndReboot:(BOOL)arg1;
@end

@interface SBSRelaunchAction : NSObject
+ (id)actionWithReason:(id)arg1 options:(unsigned int)arg2 targetURL:(id)arg3;
@end

@interface FBSSystemService : NSObject
+ (id)sharedService;
- (void)sendActions:(NSSet *)arg1 withResult:(id)arg2;
@end

// WebKit
@interface WKWebViewConfiguration : NSObject
@end

@protocol WKNavigationDelegate
@optional
- (void)webView:(id)webView didCommitNavigation:(id)navigation;
- (void)webView:(id)webView didStartProvisionalNavigation:(id)navigation;
- (void)webView:(id)webView didFinishNavigation:(id)navigation;
- (void)webView:(id)webView didFailNavigation:(id)navigation withError:(NSError *)error;
- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error;
@end

@protocol WKUIDelegate
@optional
- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)())completionHandler;
- (void)webView:(id)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *))completionHandler;
- (void)webView:(id)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)(BOOL))completionHandler;
@end

@interface WKWebView : UIView
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSURL *URL;
@property (nonatomic, weak) id <WKNavigationDelegate> navigationDelegate;
@property (nonatomic, weak) id <WKUIDelegate> UIDelegate;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
- (id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration;
- (id)reload;
- (void)stopLoading;
- (id)goBack;
- (id)goForward;
- (id)loadRequest:(NSURLRequest *)request;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(id)completionHandler;
@end

@interface WKWebView (Falcon)
- (UIScrollView *)scrollView;
- (void)_setPageZoomFactor:(double)arg1;
@end

// LocalAuthentication
@interface LAContext : NSObject
- (BOOL)canEvaluatePolicy:(int)arg1 error:(id *)arg2;
- (void)evaluatePolicy:(int)arg1 localizedReason:(id)arg2 reply:(void (^)(BOOL success, NSError *error))arg3;
@end

typedef NS_ENUM (NSInteger, LAPolicy) {
   LAPolicyDeviceOwnerAuthenticationWithBiometrics = 1 
};

// Falcon
@interface FalconLSDelegate : NSObject <WKNavigationDelegate, WKUIDelegate, UITableViewDelegate, UITableViewDataSource>
- (void)updateWebView;
@end

@interface FalconNCDelegate : NSObject <WKNavigationDelegate, WKUIDelegate>
- (void)updateWebView;
@end