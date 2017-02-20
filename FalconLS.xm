#import "Falcon.h"
#import "FalconLS.h"

NSBundle *templateBundleLS = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FalconPrefs.bundle/IconTemplate.bundle"];
FSSwitchPanel *switchPanelLS = [FSSwitchPanel sharedPanel];

NSString *filePathLS = @"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist";

BOOL enabled;
BOOL lockTogglesLS;

static void LSloadRequestFromString(NSString *string) {
    if (![NSURL URLWithString:string].scheme) {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if ([string containsString:@"."] && string.length - [string rangeOfString:@"."].location - 1 > 1 && ![string containsString:@" "])
            string = [@"http://" stringByAppendingString:string];
        
        else
            string = [NSString stringWithFormat:@"https://google.com/search?q=%@", [string stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    }
    
    [webViewLS loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
}

static void reloadDataLS() {
    prefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathLS] ? [NSMutableDictionary dictionaryWithContentsOfFile:filePathLS] : [NSMutableDictionary dictionary];
    LSenabledViews = [prefs objectForKey:@"LSenabledViews"] ? [[prefs objectForKey:@"LSenabledViews"] copy] : [NSArray arrayWithObjects:@"Today", @"Main", @"Camera", nil];
    notes = [prefs objectForKey:@"notes"] ? [[prefs objectForKey:@"notes"] mutableCopy] : [NSMutableArray array];
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;

    /* if (![[NSFileManager defaultManager] fileExistsAtPath:Obfuscate.forward_slash.v.a.r.forward_slash.l.i.b.forward_slash.d.p.k.g.forward_slash.i.n.f.o.forward_slash.o.r.g.dot.t.h.e.b.i.g.b.o.s.s.dot.f.a.l.c.o.n.dot.l.i.s.t]) {
        FILE *tmp = fopen([Obfuscate.forward_slash.v.a.r.forward_slash.m.o.b.i.l.e.forward_slash.L.i.b.r.a.r.y.forward_slash.P.r.e.f.e.r.e.n.c.e.s.forward_slash.c.o.m.dot.s.a.u.r.i.k.dot.m.o.b.i.l.e.s.u.b.s.t.r.a.t.e.dot.d.a.t UTF8String], [Obfuscate.w UTF8String]);
        fclose(tmp);

        [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
    } */
}
%end

// Falcon LS Search Bar
%subclass FalconLSSearchHeader : SPUISearchHeader
- (id)init {
	self = %orig;

	SPUITextField *searchField = [self searchField];
	searchField.textColor = [UIColor whiteColor];
	searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Google" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.45]}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NCDidUnlock:) name:@"FalconNCDidUnlock" object:nil];

	return self;
}

%new
- (void)keyboardWillHide {
    [self showCancelButton:NO animated:YES];
}

%new
- (void)NCDidUnlock:(NSNotification *)arg1 {
    unlockedLS = [[arg1 object] boolValue];
}

- (void)cancelButtonClicked:(id)arg1 {
	[self showCancelButton:NO animated:YES];
	[[self searchField] resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(SPUITextField *)arg1 {
	LSloadRequestFromString(arg1.text);
	[arg1 resignFirstResponder];
	[self showCancelButton:NO animated:YES];

	return YES;
}

- (BOOL)isOnDarkBackground {
	return YES;
}
%end

// Falcon LS View Controller
%subclass FalconBrowserPageViewController : SBDashBoardPageViewController
- (id)init {
	self = %orig;
	falconLSPageVC = (FalconBrowserPageViewController *)self;
    return self;
}

- (void)willTransitionToVisible:(BOOL)arg1 {
	%orig;

	if (!arg1)
		[[searchHeaderLS searchField] resignFirstResponder];
}

- (void)viewDidLoad {
	%orig;

	UIView *view = [self view];

	searchHeaderLS = [%c(FalconLSSearchHeader) new];
	searchHeaderLS.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 36);
	searchHeaderLS.tintColor = [UIColor whiteColor];
	[searchHeaderLS enableDictationIfRequired];
	[view addSubview:searchHeaderLS];

	SPUIHeaderBlurView *headerBlurLS = [%c(SPUIHeaderBlurView) new];
	headerBlurLS.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width - 16, 44);
	headerBlurLS.layer.cornerRadius = 10;
	headerBlurLS.clipsToBounds = YES;
	[view addSubview:headerBlurLS];

	bottomToolbarLS = [[UIToolbar alloc] initWithFrame:CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width - 16, 44)];
    backLS = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack:)];
    forwardLS = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward:)];
    shareLS = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    homeLS = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(home:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    [bottomToolbarLS setItems:[NSArray arrayWithObjects:backLS, spacer, forwardLS, spacer, shareLS, spacer, refresh, spacer, homeLS, nil]];
    [bottomToolbarLS setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
 	[bottomToolbarLS setBackgroundColor:[UIColor clearColor]];
 	bottomToolbarLS.tintColor = [UIColor whiteColor];
 	bottomToolbarLS.clipsToBounds = YES;
    [view addSubview:bottomToolbarLS];

    webViewLS = [[WKWebView alloc] initWithFrame:CGRectMake(8, 76, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 160) configuration:[WKWebViewConfiguration new]];
    webViewLS.backgroundColor = [UIColor clearColor];
    webViewLS.opaque = NO;
    webViewLS.layer.cornerRadius = 10;
    webViewLS.clipsToBounds = YES;
    [webViewLS scrollView].keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    FalconLSDelegate *delegate = [FalconLSDelegate new];
    webViewLS.navigationDelegate = delegate;
    webViewLS.UIDelegate = delegate;
    [view addSubview:webViewLS];

    [delegate updateWebView];
    [webViewLS _setPageZoomFactor:1];

   	progressViewLS = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressViewLS.frame = CGRectMake(18, 60, [UIScreen mainScreen].bounds.size.width - 36, 2);
    progressViewLS.progress = 0;
    progressViewLS.progressTintColor = [UIColor whiteColor];
    progressViewLS.trackTintColor = [UIColor clearColor];
    [view addSubview:progressViewLS];
}

%new
- (void)goBack:(id)sender {
    if (webViewLS.canGoBack)
        [webViewLS goBack];
}

%new
- (void)goForward:(id)sender {
    if (webViewLS.canGoForward)
        [webViewLS goForward];
}

%new
- (void)share:(id)sender {
	[self presentViewController:[[UIActivityViewController alloc] initWithActivityItems:@[webViewLS.URL] applicationActivities:nil] animated:YES completion:nil];
}

%new
- (void)refresh:(id)sender {
    [webViewLS reload];
}

%new
- (void)stop:(id)sender {
	[webViewLS stopLoading];
}

%new
- (void)home:(id)sender {
    [searchHeaderLS searchField].text = @"";

    [webViewLS loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [webViewLS _setPageZoomFactor:1];
}

- (void)aggregateBehavior:(SBDashBoardBehavior *)arg1 {
    [arg1 setIdleTimerDuration:120];
    
   	%orig(arg1);
}
%end

%subclass FalconTogglePageViewController : SBDashBoardPageViewController
- (id)init {
    self = %orig;
    falconLSTogglePageVC = (FalconTogglePageViewController *)self;
    return self;
}

- (void)didTransitionToVisible:(BOOL)arg1 {
    %orig;

    if (arg1) {
        brightnessSliderLS.value = [UIScreen mainScreen].brightness;
        volumeSliderLS.value = [[%c(SBMediaController) sharedInstance] volume];

        if (!unlockedLS && lockTogglesLS) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LAContext *context = [%c(LAContext) new];
                NSError *error = nil;

                if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Validate your fingerprint to unlock the Lock Screen toggles."
                    reply:^(BOOL success, NSError *error) {
                        if (success) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                unlockedLS = YES;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"FalconLSDidUnlock" object:[NSNumber numberWithBool:unlockedLS]];
                            }];
                        }

                        else {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [(SBDashBoardViewController *)[self dashBoardViewController] activateMainPageWithCompletion:nil];       
                            }];
                        }
                    }];
                }
            });
        }
    }
}

- (void)viewDidLoad {
    %orig;

    reloadDataLS();

    UIView *view = [self view];

    SPUIHeaderBlurView *respringBackground = [%c(SPUIHeaderBlurView) new];
    respringBackground.frame = CGRectMake(8, 24, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
    respringBackground.layer.cornerRadius = 10;
    respringBackground.clipsToBounds = YES;
    [view addSubview:respringBackground];

    SPUIHeaderBlurView *powerOffBackground = [%c(SPUIHeaderBlurView) new];
    powerOffBackground.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 24) / 2 + 16, 24, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
    powerOffBackground.layer.cornerRadius = 10;
    powerOffBackground.clipsToBounds = YES;
    [view addSubview:powerOffBackground];

    SPUIHeaderBlurView *safeModeBackground = [%c(SPUIHeaderBlurView) new];
    safeModeBackground.frame = CGRectMake(8, 76, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
    safeModeBackground.layer.cornerRadius = 10;
    safeModeBackground.clipsToBounds = YES;
    [view addSubview:safeModeBackground];

    SPUIHeaderBlurView *rebootBackground = [%c(SPUIHeaderBlurView) new];
    rebootBackground.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 24) / 2 + 16, 76, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
    rebootBackground.layer.cornerRadius = 10;
    rebootBackground.clipsToBounds = YES;
    [view addSubview:rebootBackground];

    SPUIHeaderBlurView *brightnessBackground = [%c(SPUIHeaderBlurView) new];
    brightnessBackground.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 116, [UIScreen mainScreen].bounds.size.width - 16, 44);
    brightnessBackground.layer.cornerRadius = 10;
    brightnessBackground.clipsToBounds = YES;
    [view addSubview:brightnessBackground];

    SPUIHeaderBlurView *volumeBackground = [%c(SPUIHeaderBlurView) new];
    volumeBackground.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width - 16, 44);
    volumeBackground.layer.cornerRadius = 10;
    volumeBackground.clipsToBounds = YES;
    [view addSubview:volumeBackground];

    SPUIHeaderBlurView *togglesBackground = [%c(SPUIHeaderBlurView) new];
    togglesBackground.frame = CGRectMake(8, 128, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 252);
    togglesBackground.layer.cornerRadius = 10;
    togglesBackground.clipsToBounds = YES;
    [view addSubview:togglesBackground];

    respringButtonLS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    respringButtonLS.frame = respringBackground.frame;
    respringButtonLS.backgroundColor = [UIColor clearColor];
    [respringButtonLS setTitle:@"Respring" forState:UIControlStateNormal];
    [respringButtonLS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [respringButtonLS setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
    [respringButtonLS setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [respringButtonLS addTarget:self action:@selector(respringButtonLSPressed:) forControlEvents:UIControlEventTouchUpInside];
    [respringButtonLS.titleLabel setFont:[UIFont systemFontOfSize:20]];
    UIImageView *respringButtonLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.respring" usingTemplate:templateBundleLS]];
    respringButtonLSImage.frame = CGRectMake(8, 7, 30, 30);
    [respringButtonLS addSubview:respringButtonLSImage];
    [view addSubview:respringButtonLS];

    powerOffButtonLS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    powerOffButtonLS.frame = powerOffBackground.frame;
    powerOffButtonLS.backgroundColor = [UIColor clearColor];
    [powerOffButtonLS setTitle:@"Power Off" forState:UIControlStateNormal];
    [powerOffButtonLS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [powerOffButtonLS setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
    [powerOffButtonLS setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [powerOffButtonLS addTarget:self action:@selector(powerOffButtonLSPressed:) forControlEvents:UIControlEventTouchUpInside];
    [powerOffButtonLS.titleLabel setFont:[UIFont systemFontOfSize:20]];
    UIImageView *powerOffButtonLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.rotation" usingTemplate:templateBundleLS]];
    powerOffButtonLSImage.frame = CGRectMake(8, 7, 30, 30);
    [powerOffButtonLS addSubview:powerOffButtonLSImage];
    [view addSubview:powerOffButtonLS];

    safeModeButtonLS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    safeModeButtonLS.frame = safeModeBackground.frame;
    safeModeButtonLS.backgroundColor = [UIColor clearColor];
    [safeModeButtonLS setTitle:@"Safe Mode" forState:UIControlStateNormal];
    [safeModeButtonLS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [safeModeButtonLS setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
    [safeModeButtonLS setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [safeModeButtonLS addTarget:self action:@selector(safeModeButtonLSPressed:) forControlEvents:UIControlEventTouchUpInside];
    [safeModeButtonLS.titleLabel setFont:[UIFont systemFontOfSize:20]];
    UIImageView *safeModeButtonLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.respring" usingTemplate:templateBundleLS]];
    safeModeButtonLSImage.frame = CGRectMake(8, 7, 30, 30);
    [safeModeButtonLS addSubview:safeModeButtonLSImage];
    [view addSubview:safeModeButtonLS];

    rebootButtonLS = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rebootButtonLS.frame = rebootBackground.frame;
    rebootButtonLS.backgroundColor = [UIColor clearColor];
    [rebootButtonLS setTitle:@"Reboot" forState:UIControlStateNormal];
    [rebootButtonLS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [rebootButtonLS setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
    [rebootButtonLS setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rebootButtonLS addTarget:self action:@selector(rebootButtonLSPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rebootButtonLS.titleLabel setFont:[UIFont systemFontOfSize:20]];
    UIImageView *rebootButtonLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.rotation" usingTemplate:templateBundleLS]];
    rebootButtonLSImage.frame = CGRectMake(8, 7, 30, 30);
    [rebootButtonLS addSubview:rebootButtonLSImage];
    [view addSubview:rebootButtonLS];

    CGFloat widthScale = togglesBackground.frame.size.width / 4;
    CGFloat heightScale = togglesBackground.frame.size.height / 4;

    UIButton *airplaneSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode" usingTemplate:templateBundleLS];
    airplaneSwitch.frame = CGRectMake(0, 0, widthScale, heightScale);
    [togglesBackground addSubview:airplaneSwitch];

    UIButton *autoBrightnessSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness" usingTemplate:templateBundleLS];
    autoBrightnessSwitch.frame = CGRectMake(widthScale, 0, widthScale, heightScale);
    [togglesBackground addSubview:autoBrightnessSwitch];

    UIButton *autoLockSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.autolock" usingTemplate:templateBundleLS];
    autoLockSwitch.frame = CGRectMake(widthScale * 2, 0, widthScale, heightScale);
    [togglesBackground addSubview:autoLockSwitch];

    UIButton *bluetoothSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth" usingTemplate:templateBundleLS];
    bluetoothSwitch.frame = CGRectMake(widthScale * 3, 0, widthScale, heightScale);
    [togglesBackground addSubview:bluetoothSwitch];

    UIButton *dataSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.cellular-data" usingTemplate:templateBundleLS];
    dataSwitch.frame = CGRectMake(0, heightScale, widthScale, heightScale);
    [togglesBackground addSubview:dataSwitch];

    UIButton *doNotDisturbSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb" usingTemplate:templateBundleLS];
    doNotDisturbSwitch.frame = CGRectMake(widthScale, heightScale, widthScale, heightScale);
    [togglesBackground addSubview:doNotDisturbSwitch];

    UIButton *flashlightSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.flashlight" usingTemplate:templateBundleLS];
    flashlightSwitch.frame = CGRectMake(widthScale * 2, heightScale, widthScale, heightScale);
    [togglesBackground addSubview:flashlightSwitch];

    UIButton *hotspotSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.hotspot" usingTemplate:templateBundleLS];
    hotspotSwitch.frame = CGRectMake(widthScale * 3, heightScale, widthScale, heightScale);
    [togglesBackground addSubview:hotspotSwitch];

    UIButton *locationSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.location" usingTemplate:templateBundleLS];
    locationSwitch.frame = CGRectMake(0, heightScale * 2, widthScale, heightScale);
    [togglesBackground addSubview:locationSwitch];

    UIButton *lowPowerSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.low-power" usingTemplate:templateBundleLS];
    lowPowerSwitch.frame = CGRectMake(widthScale, heightScale * 2, widthScale, heightScale);
    [togglesBackground addSubview:lowPowerSwitch];

    UIButton *nightShiftSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.night-shift" usingTemplate:templateBundleLS];
    nightShiftSwitch.frame = CGRectMake(widthScale * 2, heightScale * 2, widthScale, heightScale);
    [togglesBackground addSubview:nightShiftSwitch];

    UIButton *ringerSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundleLS];
    ringerSwitch.frame = CGRectMake(widthScale * 3, heightScale * 2, widthScale, heightScale);
    [togglesBackground addSubview:ringerSwitch];

    UIButton *rotationLockSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.rotation-lock" usingTemplate:templateBundleLS];
    rotationLockSwitch.frame = CGRectMake(0, heightScale * 3, widthScale, heightScale);
    [togglesBackground addSubview:rotationLockSwitch];

    UIButton *vibrationSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.vibration" usingTemplate:templateBundleLS];
    vibrationSwitch.frame = CGRectMake(widthScale, heightScale * 3, widthScale, heightScale);
    [togglesBackground addSubview:vibrationSwitch];

    UIButton *vpnSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.vpn" usingTemplate:templateBundleLS];
    vpnSwitch.frame = CGRectMake(widthScale * 2, heightScale * 3, widthScale, heightScale);
    [togglesBackground addSubview:vpnSwitch];

    UIButton *wifiSwitch = [switchPanelLS buttonForSwitchIdentifier:@"com.a3tweaks.switch.wifi" usingTemplate:templateBundleLS];
    wifiSwitch.frame = CGRectMake(widthScale * 3, heightScale * 3, widthScale, heightScale);
    [togglesBackground addSubview:wifiSwitch];

    brightnessSliderLS = [[UISlider alloc] initWithFrame:CGRectMake(54, [UIScreen mainScreen].bounds.size.height - 116, [UIScreen mainScreen].bounds.size.width - 70, 44)];
    brightnessSliderLS.backgroundColor = [UIColor clearColor];
    brightnessSliderLS.continuous = YES;
    brightnessSliderLS.minimumValue = 0.0;
    brightnessSliderLS.maximumValue = 1.0;
    brightnessSliderLS.value = [UIScreen mainScreen].brightness;
    brightnessSliderLS.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.45];
    brightnessSliderLS.minimumTrackTintColor = [UIColor whiteColor];
    [brightnessSliderLS addTarget:self action:@selector(brightnessSliderLSValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:brightnessSliderLS];
    UIImageView *brightnessSliderLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness" usingTemplate:templateBundleLS]];
    brightnessSliderLSImage.frame = CGRectMake(8, 7, 30, 30);
    [brightnessBackground addSubview:brightnessSliderLSImage];

    volumeSliderLS = [[UISlider alloc] initWithFrame:CGRectMake(54, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width - 70, 44)];
    volumeSliderLS.backgroundColor = [UIColor clearColor];
    volumeSliderLS.continuous = YES;
    volumeSliderLS.minimumValue = 0.0;
    volumeSliderLS.maximumValue = 1.0;
    volumeSliderLS.value = [[%c(SBMediaController) sharedInstance] volume];
    volumeSliderLS.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.45];
    volumeSliderLS.minimumTrackTintColor = [UIColor whiteColor];
    [volumeSliderLS addTarget:self action:@selector(volumeSliderLSValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:volumeSliderLS];
    UIImageView *volumeSliderLSImage = [[UIImageView alloc] initWithImage:[switchPanelLS imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundleLS]];
    volumeSliderLSImage.frame = CGRectMake(8, 7, 30, 30);
    [volumeBackground addSubview:volumeSliderLSImage];
}

%new
- (void)respringButtonLSPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Respring?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSSet *relaunchAction = [NSSet setWithObject:[%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:4 targetURL:nil]];
        [[%c(FBSSystemService) sharedService] sendActions:relaunchAction withResult:nil];
    }]];

    [falconLSTogglePageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)powerOffButtonLSPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Power Off?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[%c(FBSystemService) sharedInstance] shutdownAndReboot:NO];
    }]];

    [falconLSTogglePageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)safeModeButtonLSPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Safe Mode?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        FILE *tmp = fopen("/var/mobile/Library/Preferences/com.saurik.mobilesubstrate.dat", "w");
        fclose(tmp);

        [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
    }]];

    [falconLSTogglePageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)rebootButtonLSPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reboot?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[%c(FBSystemService) sharedInstance] shutdownAndReboot:YES];
    }]];

    [falconLSTogglePageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)volumeSliderLSValueChanged:(id)sender {
    [[%c(SBMediaController) sharedInstance] setVolume:volumeSliderLS.value];
}

%new
- (void)brightnessSliderLSValueChanged:(id)sender {
    [[%c(SBBrightnessController) sharedBrightnessController] setBrightnessLevel:brightnessSliderLS.value];
}

- (void)aggregateAppearance:(SBDashBoardAppearance *)arg1 {
    SBDashBoardComponent *dateView = [%c(SBDashBoardComponent) dateView];
    [dateView setHidden:YES];
    [arg1 addComponent:dateView];

    %orig(arg1);
}

- (void)aggregateBehavior:(SBDashBoardBehavior *)arg1 {
    [arg1 setIdleTimerDuration:120];
    
    %orig(arg1);
}
%end

%subclass FalconLSNotesSearchHeader : SPUISearchHeader
- (id)init {
    self = %orig;

    SPUITextField *searchField = [self searchField];
    searchField.textColor = [UIColor whiteColor];
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter note" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.45]}];
    searchField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    searchField.autocorrectionType = UITextAutocorrectionTypeYes;
    searchField.returnKeyType = UIReturnKeyDefault;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

%new
- (void)keyboardWillHide {
    [self showCancelButton:NO animated:YES];
}

- (void)cancelButtonClicked:(id)arg1 {
    [self showCancelButton:NO animated:YES];
    [[self searchField] resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(SPUITextField *)arg1 {
    reloadDataLS();

    [notes addObject:arg1.text];
    [prefs setObject:notes forKey:@"notes"];
    [prefs writeToFile:filePathLS atomically:YES];

    reloadDataLS();

    [notesTableViewLS reloadData];
    [searchHeaderLSNotes clearSearchFieldWhyQuery:0 allowZKW:NO];
    [arg1 resignFirstResponder];
    [self showCancelButton:NO animated:YES];

    return YES;
}

- (BOOL)isOnDarkBackground {
    return YES;
}
%end

%subclass FalconNotesPageViewController : SBDashBoardPageViewController
- (id)init {
    self = %orig;
    falconLSNotesPageVC = (FalconNotesPageViewController *)self;
    return self;
}

- (void)willTransitionToVisible:(BOOL)arg1 {
    %orig;

    if (!arg1)
        [[searchHeaderLSNotes searchField] resignFirstResponder];

    else
        reloadDataLS();
        [notesTableViewLS reloadData];
}

- (void)viewDidLoad {
    %orig;

    reloadDataLS();

    UIView *view = [self view];

    searchHeaderLSNotes = [%c(FalconLSNotesSearchHeader) new];
    searchHeaderLSNotes.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 36);
    searchHeaderLSNotes.tintColor = [UIColor whiteColor];
    [searchHeaderLSNotes enableDictationIfRequired];
    [view addSubview:searchHeaderLSNotes];

    SPUIHeaderBlurView *tableViewBackground = [%c(SPUIHeaderBlurView) new];
    tableViewBackground.frame = CGRectMake(8, 76, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 96);
    tableViewBackground.layer.cornerRadius = 10;
    tableViewBackground.clipsToBounds = YES;
    [view addSubview:tableViewBackground];

    notesTableViewLS = [[UITableView alloc] initWithFrame:tableViewBackground.frame style:UITableViewStylePlain];
    notesTableViewLS.rowHeight = 44;
    FalconLSDelegate *delegate = [FalconLSDelegate new];
    notesTableViewLS.delegate = delegate;
    notesTableViewLS.dataSource = delegate;
    notesTableViewLS.layer.cornerRadius = 10;
    notesTableViewLS.clipsToBounds = YES;
    notesTableViewLS.backgroundColor = [UIColor clearColor];
    [notesTableViewLS registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newNotesCell"];
    [view addSubview:notesTableViewLS];
}

- (void)aggregateAppearance:(SBDashBoardAppearance *)arg1 {
    SBDashBoardComponent *dateView = [%c(SBDashBoardComponent) dateView];
    [dateView setHidden:YES];
    [arg1 addComponent:dateView];

    %orig(arg1);
}

- (void)aggregateBehavior:(SBDashBoardBehavior *)arg1 {
    [arg1 setIdleTimerDuration:120];
    
    %orig(arg1);
}
%end

// Injection of Falcon
%hook SBDashBoardViewController
- (id)initWithPageViewControllers:(NSArray *)arg1 mainPageViewController:(SBDashBoardPageViewController *)arg2 legibilityProvider:(id)arg3 {
    reloadDataLS();

    NSMutableArray *newArray = [NSMutableArray array];

    for (NSString *view in LSenabledViews) {
        if ([view isEqualToString:@"Today"])
            [newArray addObject:[arg1 objectAtIndex:0]];

        else if ([view isEqualToString:@"Notes"])
            [newArray addObject:[%c(FalconNotesPageViewController) new]];

        else if ([view isEqualToString:@"Search"])
            [newArray addObject:[%c(FalconBrowserPageViewController) new]];

        else if ([view isEqualToString:@"Main"])
            [newArray addObject:[arg1 objectAtIndex:1]];

        else if ([view isEqualToString:@"Toggle"])
            [newArray addObject:[%c(FalconTogglePageViewController) new]];

        else {
            [newArray addObject:[arg1 objectAtIndex:2]];
            cameraEnabled = YES;
        }
    }

	return %orig(newArray, arg2, arg3);
}
%end

%hook SBFLockScreenDateView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}
%end

%hook SBDashBoardPageControl
- (BOOL)isCameraPageEnabled {
    return cameraEnabled;
}
%end

%hook SBLockScreenManager
- (void)_setUILocked:(BOOL)arg1 {
    %orig;

    if (arg1)
        unlockedLS = NO;

    else
        unlockedLS = YES;

    NSMutableDictionary *copyPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathLS] ? [NSMutableDictionary dictionaryWithContentsOfFile:filePathLS] : [NSMutableDictionary dictionary];
    
    if (![copyPrefs objectForKey:@"hasShowFirstLaunchMessage"] && !arg1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:@"Thank you for installing Falcon!" message:@"Your purchase is very much appreciated. You can configure options from the Settings app, and if you need any support at all feel free to email me from the Preferences pane." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            #pragma clang diagnostic pop

            [copyPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"hasShowFirstLaunchMessage"];
            [copyPrefs writeToFile:filePathLS atomically:YES];
        });
    }
}
%end

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathLS];
    enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
    lockTogglesLS = [prefs objectForKey:@"lockToggles"] ? [[prefs objectForKey:@"lockToggles"] boolValue] : NO;
}

static void respring() {
    NSSet *action = [NSSet setWithObject:[%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:4 targetURL:nil]];
    [[%c(FBSSystemService) sharedService] sendActions:action withResult:nil];
}

%ctor {
    loadPrefs();

    if (enabled) {
        %init;
    }

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tweaksbylogan.falcon/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, CFSTR("com.tweaksbylogan.falcon/respring"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}