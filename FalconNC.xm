#import "Falcon.h"
#import "FalconNC.h"

NSBundle *templateBundleNC = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FalconPrefs.bundle/IconTemplate.bundle"];
FSSwitchPanel *switchPanelNC = [FSSwitchPanel sharedPanel];
NSArray *NCenabledViews;
NSMutableDictionary *prefsNC;
NSMutableArray *notesNC;

NSString *filePathNC = @"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist";

NSInteger mainIndex;
NSInteger toggleIndex;
NSInteger notesIndex;

BOOL lockTogglesNC;

static void NCloadRequestFromString(NSString *string) {
    if (![NSURL URLWithString:string].scheme) {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if ([string containsString:@"."] && string.length - [string rangeOfString:@"."].location - 1 > 1 && ![string containsString:@" "])
            string = [@"http://" stringByAppendingString:string];
        
        else
            string = [NSString stringWithFormat:@"https://google.com/search?q=%@", [string stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    }
    
    [webViewNC loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
}

static void reloadDataNC() {
    prefsNC = [NSMutableDictionary dictionaryWithContentsOfFile:filePathNC] ? [NSMutableDictionary dictionaryWithContentsOfFile:filePathNC] : [NSMutableDictionary dictionary];
    NCenabledViews = [prefsNC objectForKey:@"NCenabledViews"] ? [[prefsNC objectForKey:@"NCenabledViews"] copy] : [NSArray arrayWithObjects:@"Today", @"Main", nil];
    notesNC = [prefsNC objectForKey:@"notes"] ? [[prefsNC objectForKey:@"notes"] mutableCopy] : [NSMutableArray array];
}

// Falcon NC Search Bar
%subclass FalconNCSearchHeader : SPUISearchHeader
- (id)init {
    self = %orig;

    SPUITextField *searchField = [self searchField];
    searchField.textColor = [UIColor whiteColor];
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Google" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.45]}];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LSDidUnlock:) name:@"FalconLSDidUnlock" object:nil];

    return self;
}

%new
- (void)keyboardWillHide {
    [self showCancelButton:NO animated:YES];
}

%new
- (void)LSDidUnlock:(NSNotification *)arg1 {
    unlockedNC = [[arg1 object] boolValue];
}

- (void)cancelButtonClicked:(id)arg1 {
    [self showCancelButton:NO animated:YES];
    [[self searchField] resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(SPUITextField *)arg1 {
    NCloadRequestFromString(arg1.text);
    [arg1 resignFirstResponder];
    [self showCancelButton:NO animated:YES];

    return YES;
}

- (BOOL)isOnDarkBackground {
    return YES;
}
%end

%hook SBPagedScrollView
- (void)_bs_willBeginScrolling {
    %orig;

    [[searchHeaderNC searchField] resignFirstResponder];
    [[searchHeaderNCNotes searchField] resignFirstResponder];
}

- (void)setVisiblePageRange:(NSRange)arg1 {
    %orig;

    if (arg1.location == toggleIndex && [self.superview isKindOfClass:[%c(SBSearchEtceteraLayoutView) class]]) {
        brightnessSliderNC.value = [UIScreen mainScreen].brightness;
        volumeSliderNC.value = [[%c(SBMediaController) sharedInstance] volume];

        if (!unlockedNC && lockTogglesNC) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LAContext *context = [%c(LAContext) new];
                NSError *error = nil;

                if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Validate your fingerprint to unlock the Notification Center toggles."
                    reply:^(BOOL success, NSError *error) {
                        if (success) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                unlockedNC = YES;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"FalconNCDidUnlock" object:[NSNumber numberWithBool:unlockedNC]];
                            }];
                        }

                        else {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self scrollToPageAtIndex:mainIndex animated:NO];      
                            }];
                        }
                    }];
                }
            });
        }
    }

    else if (arg1.location == notesIndex) {
        reloadDataNC();
        [notesTableViewNC reloadData];
    }
}

- (void)layoutSubviews {
    reloadDataNC();

    %orig;

	if (!hasEnteredPages && [self.superview isKindOfClass:[%c(SBSearchEtceteraLayoutView) class]]) {
        NCmainView = [[UIView alloc] initWithFrame:self.frame];

    	searchHeaderNC = [%c(FalconNCSearchHeader) new];
    	searchHeaderNC.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36);
    	searchHeaderNC.tintColor = [UIColor whiteColor];
    	[searchHeaderNC enableDictationIfRequired];
    	[NCmainView addSubview:searchHeaderNC];

    	SPUIHeaderBlurView *headerBlurNC = [%c(SPUIHeaderBlurView) new];
    	headerBlurNC.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 152, [UIScreen mainScreen].bounds.size.width - 16, 44);
    	headerBlurNC.layer.cornerRadius = 10;
    	headerBlurNC.clipsToBounds = YES;
    	[NCmainView addSubview:headerBlurNC];

    	bottomToolbarNC = [[UIToolbar alloc] initWithFrame:headerBlurNC.frame];
        backNC = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack:)];
        forwardNC = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward:)];
        shareNC = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
        homeNC = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(home:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        [bottomToolbarNC setItems:[NSArray arrayWithObjects:backNC, spacer, forwardNC, spacer, shareNC, spacer, refresh, spacer, homeNC, nil]];
        [bottomToolbarNC setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
     	[bottomToolbarNC setBackgroundColor:[UIColor clearColor]];
     	bottomToolbarNC.tintColor = [UIColor whiteColor];
     	bottomToolbarNC.clipsToBounds = YES;
        [NCmainView addSubview:bottomToolbarNC];

        UIView *shareButtonView = [shareNC valueForKey:@"_view"];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareButtonLongPress:)];
        [shareButtonView addGestureRecognizer:longPress];

        webViewNC = [[WKWebView alloc] initWithFrame:CGRectMake(8, 56, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 230) configuration:[WKWebViewConfiguration new]];
        webViewNC.backgroundColor = [UIColor clearColor];
        webViewNC.opaque = NO;
        webViewNC.layer.cornerRadius = 10;
        webViewNC.clipsToBounds = YES;
        [webViewNC scrollView].keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        FalconNCDelegate *delegate = [FalconNCDelegate new];
        webViewNC.navigationDelegate = delegate;
        webViewNC.UIDelegate = delegate;
        [NCmainView addSubview:webViewNC];

        [delegate updateWebView];
        [webViewNC _setPageZoomFactor:1];

       	progressViewNC = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressViewNC.frame = CGRectMake(18, 40, [UIScreen mainScreen].bounds.size.width - 36, 2);
        progressViewNC.progress = 0;
        progressViewNC.progressTintColor = [UIColor whiteColor];
        progressViewNC.trackTintColor = [UIColor clearColor];
        [NCmainView addSubview:progressViewNC];

        toggleMainView = [[UIView alloc] initWithFrame:self.frame];

        SPUIHeaderBlurView *respringBackground = [%c(SPUIHeaderBlurView) new];
        respringBackground.frame = CGRectMake(8, 0, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
        respringBackground.layer.cornerRadius = 10;
        respringBackground.clipsToBounds = YES;
        [toggleMainView addSubview:respringBackground];

        SPUIHeaderBlurView *powerOffBackground = [%c(SPUIHeaderBlurView) new];
        powerOffBackground.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 24) / 2 + 16, 0, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
        powerOffBackground.layer.cornerRadius = 10;
        powerOffBackground.clipsToBounds = YES;
        [toggleMainView addSubview:powerOffBackground];

        SPUIHeaderBlurView *safeModeBackground = [%c(SPUIHeaderBlurView) new];
        safeModeBackground.frame = CGRectMake(8, 52, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
        safeModeBackground.layer.cornerRadius = 10;
        safeModeBackground.clipsToBounds = YES;
        [toggleMainView addSubview:safeModeBackground];

        SPUIHeaderBlurView *rebootBackground = [%c(SPUIHeaderBlurView) new];
        rebootBackground.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 24) / 2 + 16, 52, ([UIScreen mainScreen].bounds.size.width - 24) / 2, 44);
        rebootBackground.layer.cornerRadius = 10;
        rebootBackground.clipsToBounds = YES;
        [toggleMainView addSubview:rebootBackground];

        SPUIHeaderBlurView *brightnessBackground = [%c(SPUIHeaderBlurView) new];
        brightnessBackground.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 204, [UIScreen mainScreen].bounds.size.width - 16, 44);
        brightnessBackground.layer.cornerRadius = 10;
        brightnessBackground.clipsToBounds = YES;
        [toggleMainView addSubview:brightnessBackground];

        SPUIHeaderBlurView *volumeBackground = [%c(SPUIHeaderBlurView) new];
        volumeBackground.frame = CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 152, [UIScreen mainScreen].bounds.size.width - 16, 44);
        volumeBackground.layer.cornerRadius = 10;
        volumeBackground.clipsToBounds = YES;
        [toggleMainView addSubview:volumeBackground];

        SPUIHeaderBlurView *togglesBackground = [%c(SPUIHeaderBlurView) new];
        togglesBackground.frame = CGRectMake(8, 104, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 316);
        togglesBackground.layer.cornerRadius = 10;
        togglesBackground.clipsToBounds = YES;
        [toggleMainView addSubview:togglesBackground];

        respringButtonNC = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        respringButtonNC.frame = respringBackground.frame;
        respringButtonNC.backgroundColor = [UIColor clearColor];
        [respringButtonNC setTitle:@"Respring" forState:UIControlStateNormal];
        [respringButtonNC setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [respringButtonNC setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
        [respringButtonNC setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [respringButtonNC addTarget:self action:@selector(respringButtonNCPressed:) forControlEvents:UIControlEventTouchUpInside];
        [respringButtonNC.titleLabel setFont:[UIFont systemFontOfSize:20]];
        UIImageView *respringButtonNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.respring" usingTemplate:templateBundleNC]];
        respringButtonNCImage.frame = CGRectMake(8, 7, 30, 30);
        [respringButtonNC addSubview:respringButtonNCImage];
        [toggleMainView addSubview:respringButtonNC];

        powerOffButtonNC = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        powerOffButtonNC.frame = powerOffBackground.frame;
        powerOffButtonNC.backgroundColor = [UIColor clearColor];
        [powerOffButtonNC setTitle:@"Power Off" forState:UIControlStateNormal];
        [powerOffButtonNC setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [powerOffButtonNC setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
        [powerOffButtonNC setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [powerOffButtonNC addTarget:self action:@selector(powerOffButtonNCPressed:) forControlEvents:UIControlEventTouchUpInside];
        [powerOffButtonNC.titleLabel setFont:[UIFont systemFontOfSize:20]];
        UIImageView *powerOffButtonNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.rotation" usingTemplate:templateBundleNC]];
        powerOffButtonNCImage.frame = CGRectMake(8, 7, 30, 30);
        [powerOffButtonNC addSubview:powerOffButtonNCImage];
        [toggleMainView addSubview:powerOffButtonNC];

        safeModeButtonNC = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        safeModeButtonNC.frame = safeModeBackground.frame;
        safeModeButtonNC.backgroundColor = [UIColor clearColor];
        [safeModeButtonNC setTitle:@"Safe Mode" forState:UIControlStateNormal];
        [safeModeButtonNC setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [safeModeButtonNC setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
        [safeModeButtonNC setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [safeModeButtonNC addTarget:self action:@selector(safeModeButtonNCPressed:) forControlEvents:UIControlEventTouchUpInside];
        [safeModeButtonNC.titleLabel setFont:[UIFont systemFontOfSize:20]];
        UIImageView *safeModeButtonNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.respring" usingTemplate:templateBundleNC]];
        safeModeButtonNCImage.frame = CGRectMake(8, 7, 30, 30);
        [safeModeButtonNC addSubview:safeModeButtonNCImage];
        [toggleMainView addSubview:safeModeButtonNC];

        rebootButtonNC = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        rebootButtonNC.frame = rebootBackground.frame;
        rebootButtonNC.backgroundColor = [UIColor clearColor];
        [rebootButtonNC setTitle:@"Reboot" forState:UIControlStateNormal];
        [rebootButtonNC setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [rebootButtonNC setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
        [rebootButtonNC setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rebootButtonNC addTarget:self action:@selector(rebootButtonNCPressed:) forControlEvents:UIControlEventTouchUpInside];
        [rebootButtonNC.titleLabel setFont:[UIFont systemFontOfSize:20]];
        UIImageView *rebootButtonNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.rotation" usingTemplate:templateBundleNC]];
        rebootButtonNCImage.frame = CGRectMake(8, 7, 30, 30);
        [rebootButtonNC addSubview:rebootButtonNCImage];
        [toggleMainView addSubview:rebootButtonNC];

        CGFloat widthScale = togglesBackground.frame.size.width / 4;
        CGFloat heightScale = togglesBackground.frame.size.height / 4;

        UIButton *airplaneSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode" usingTemplate:templateBundleNC];
        airplaneSwitch.frame = CGRectMake(0, 0, widthScale, heightScale);
        [togglesBackground addSubview:airplaneSwitch];

        UIButton *autoBrightnessSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness" usingTemplate:templateBundleNC];
        autoBrightnessSwitch.frame = CGRectMake(widthScale, 0, widthScale, heightScale);
        [togglesBackground addSubview:autoBrightnessSwitch];

        UIButton *autoLockSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.autolock" usingTemplate:templateBundleNC];
        autoLockSwitch.frame = CGRectMake(widthScale * 2, 0, widthScale, heightScale);
        [togglesBackground addSubview:autoLockSwitch];

        UIButton *bluetoothSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth" usingTemplate:templateBundleNC];
        bluetoothSwitch.frame = CGRectMake(widthScale * 3, 0, widthScale, heightScale);
        [togglesBackground addSubview:bluetoothSwitch];

        UIButton *dataSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.cellular-data" usingTemplate:templateBundleNC];
        dataSwitch.frame = CGRectMake(0, heightScale, widthScale, heightScale);
        [togglesBackground addSubview:dataSwitch];

        UIButton *doNotDisturbSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb" usingTemplate:templateBundleNC];
        doNotDisturbSwitch.frame = CGRectMake(widthScale, heightScale, widthScale, heightScale);
        [togglesBackground addSubview:doNotDisturbSwitch];

        UIButton *flashlightSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.flashlight" usingTemplate:templateBundleNC];
        flashlightSwitch.frame = CGRectMake(widthScale * 2, heightScale, widthScale, heightScale);
        [togglesBackground addSubview:flashlightSwitch];

        UIButton *hotspotSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.hotspot" usingTemplate:templateBundleNC];
        hotspotSwitch.frame = CGRectMake(widthScale * 3, heightScale, widthScale, heightScale);
        [togglesBackground addSubview:hotspotSwitch];

        UIButton *locationSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.location" usingTemplate:templateBundleNC];
        locationSwitch.frame = CGRectMake(0, heightScale * 2, widthScale, heightScale);
        [togglesBackground addSubview:locationSwitch];

        UIButton *lowPowerSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.low-power" usingTemplate:templateBundleNC];
        lowPowerSwitch.frame = CGRectMake(widthScale, heightScale * 2, widthScale, heightScale);
        [togglesBackground addSubview:lowPowerSwitch];

        UIButton *nightShiftSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.night-shift" usingTemplate:templateBundleNC];
        nightShiftSwitch.frame = CGRectMake(widthScale * 2, heightScale * 2, widthScale, heightScale);
        [togglesBackground addSubview:nightShiftSwitch];

        UIButton *ringerSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundleNC];
        ringerSwitch.frame = CGRectMake(widthScale * 3, heightScale * 2, widthScale, heightScale);
        [togglesBackground addSubview:ringerSwitch];

        UIButton *rotationLockSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.rotation-lock" usingTemplate:templateBundleNC];
        rotationLockSwitch.frame = CGRectMake(0, heightScale * 3, widthScale, heightScale);
        [togglesBackground addSubview:rotationLockSwitch];

        UIButton *vibrationSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.vibration" usingTemplate:templateBundleNC];
        vibrationSwitch.frame = CGRectMake(widthScale, heightScale * 3, widthScale, heightScale);
        [togglesBackground addSubview:vibrationSwitch];

        UIButton *vpnSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.vpn" usingTemplate:templateBundleNC];
        vpnSwitch.frame = CGRectMake(widthScale * 2, heightScale * 3, widthScale, heightScale);
        [togglesBackground addSubview:vpnSwitch];

        UIButton *wifiSwitch = [switchPanelNC buttonForSwitchIdentifier:@"com.a3tweaks.switch.wifi" usingTemplate:templateBundleNC];
        wifiSwitch.frame = CGRectMake(widthScale * 3, heightScale * 3, widthScale, heightScale);
        [togglesBackground addSubview:wifiSwitch];

        brightnessSliderNC = [[UISlider alloc] initWithFrame:CGRectMake(54, [UIScreen mainScreen].bounds.size.height - 204, [UIScreen mainScreen].bounds.size.width - 70, 44)];
        brightnessSliderNC.backgroundColor = [UIColor clearColor];
        brightnessSliderNC.continuous = YES;
        brightnessSliderNC.minimumValue = 0.0;
        brightnessSliderNC.maximumValue = 1.0;
        brightnessSliderNC.value = [UIScreen mainScreen].brightness;
        brightnessSliderNC.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.45];
        brightnessSliderNC.minimumTrackTintColor = [UIColor whiteColor];
        [brightnessSliderNC addTarget:self action:@selector(brightnessSliderNCValueChanged:) forControlEvents:UIControlEventValueChanged];
        [toggleMainView addSubview:brightnessSliderNC];
        UIImageView *brightnessSliderNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness" usingTemplate:templateBundleNC]];
        brightnessSliderNCImage.frame = CGRectMake(8, 7, 30, 30);
        [brightnessBackground addSubview:brightnessSliderNCImage];

        volumeSliderNC = [[UISlider alloc] initWithFrame:CGRectMake(54, [UIScreen mainScreen].bounds.size.height - 152, [UIScreen mainScreen].bounds.size.width - 70, 44)];
        volumeSliderNC.backgroundColor = [UIColor clearColor];
        volumeSliderNC.continuous = YES;
        volumeSliderNC.minimumValue = 0.0;
        volumeSliderNC.maximumValue = 1.0;
        volumeSliderNC.value = [[%c(SBMediaController) sharedInstance] volume];
        volumeSliderNC.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.45];
        volumeSliderNC.minimumTrackTintColor = [UIColor whiteColor];
        [volumeSliderNC addTarget:self action:@selector(volumeSliderNCValueChanged:) forControlEvents:UIControlEventValueChanged];
        [toggleMainView addSubview:volumeSliderNC];
        UIImageView *volumeSliderNCImage = [[UIImageView alloc] initWithImage:[switchPanelNC imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundleNC]];
        volumeSliderNCImage.frame = CGRectMake(8, 7, 30, 30);
        [volumeBackground addSubview:volumeSliderNCImage];

        notesMainView = [[UIView alloc] initWithFrame:self.frame];

        searchHeaderNCNotes = [%c(FalconNCNotesSearchHeader) new];
        searchHeaderNCNotes.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36);
        searchHeaderNCNotes.tintColor = [UIColor whiteColor];
        [searchHeaderNCNotes enableDictationIfRequired];
        [notesMainView addSubview:searchHeaderNCNotes];

        SPUIHeaderBlurView *tableViewBackground = [%c(SPUIHeaderBlurView) new];
        tableViewBackground.frame = CGRectMake(8, 56, [UIScreen mainScreen].bounds.size.width - 16, [UIScreen mainScreen].bounds.size.height - 164);
        tableViewBackground.layer.cornerRadius = 10;
        tableViewBackground.clipsToBounds = YES;
        [notesMainView addSubview:tableViewBackground];

        notesTableViewNC = [[UITableView alloc] initWithFrame:tableViewBackground.frame style:UITableViewStylePlain];
        notesTableViewNC.rowHeight = 44;
        notesTableViewNC.delegate = self;
        notesTableViewNC.dataSource = self;
        notesTableViewNC.layer.cornerRadius = 10;
        notesTableViewNC.clipsToBounds = YES;
        notesTableViewNC.backgroundColor = [UIColor clearColor];
        [notesTableViewNC registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newNCNotesCell"];
        [notesMainView addSubview:notesTableViewNC];

        NSMutableArray *newArray = [NSMutableArray array];

        for (NSString *view in NCenabledViews) {
            if ([view isEqualToString:@"Today"])
                [newArray addObject:[[self pageViews] objectAtIndex:0]];

            else if ([view isEqualToString:@"Notes"]) {
                [newArray addObject:notesMainView];
                notesIndex = [newArray count] - 1;
            }

            else if ([view isEqualToString:@"Search"])
                [newArray addObject:NCmainView];

            else if ([view isEqualToString:@"Main"]) {
                [newArray addObject:[[self pageViews] objectAtIndex:1]];
                mainIndex = [newArray count] - 1;
            }

            else {
                [newArray addObject:toggleMainView];
                toggleIndex = [newArray count] - 1;
            }
        }

        [self setPageViews:newArray];

        hasEnteredPages = YES;
    }
}

%new
- (void)goBack:(id)sender {
    if (webViewNC.canGoBack)
        [webViewNC goBack];
}

%new
- (void)goForward:(id)sender {
    if (webViewNC.canGoForward)
        [webViewNC goForward];
}

%new
- (void)share:(id)sender {
	[falconNCPageVC presentViewController:[[UIActivityViewController alloc] initWithActivityItems:@[webViewNC.URL] applicationActivities:nil] animated:YES completion:nil];
}

%new
- (void)handleShareButtonLongPress:(id)sender {
    if (unlockedNC)
        [[UIApplication sharedApplication] openURL:webViewNC.URL];
}

%new
- (void)refresh:(id)sender {
    [webViewNC reload];
}

%new
- (void)stop:(id)sender {
	[webViewNC stopLoading];
}

%new
- (void)home:(id)sender {
    [searchHeaderNC searchField].text = @"";

    [webViewNC loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [webViewNC _setPageZoomFactor:1];
}

%new
- (void)respringButtonNCPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Respring?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSSet *relaunchAction = [NSSet setWithObject:[%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:4 targetURL:nil]];
        [[%c(FBSSystemService) sharedService] sendActions:relaunchAction withResult:nil];
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)powerOffButtonNCPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Power Off?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[%c(FBSystemService) sharedInstance] shutdownAndReboot:NO];
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)safeModeButtonNCPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Safe Mode?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        FILE *tmp = fopen("/var/mobile/Library/Preferences/com.saurik.mobilesubstrate.dat", "w");
        fclose(tmp);

        [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)rebootButtonNCPressed:(id)sender {
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reboot?" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[%c(FBSystemService) sharedInstance] shutdownAndReboot:YES];
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)volumeSliderNCValueChanged:(id)sender {
    [[%c(SBMediaController) sharedInstance] setVolume:volumeSliderNC.value];
}

%new
- (void)brightnessSliderNCValueChanged:(id)sender {
    [[%c(SBBrightnessController) sharedBrightnessController] setBrightnessLevel:brightnessSliderNC.value];
}

%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

%new
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return notesNC.count;
}

%new
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newNCNotesCell"];

    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newNCNotesCell"];

    cell.textLabel.text = notesNC[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

%new
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    reloadDataNC();

    [notesNC removeObjectAtIndex:indexPath.row];
    [notesTableViewNC deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [prefsNC setObject:notesNC forKey:@"notes"];
    [prefsNC writeToFile:filePathNC atomically:YES];

    reloadDataNC();
}
%end

%subclass FalconNCNotesSearchHeader : SPUISearchHeader
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
    reloadDataNC();

    [notesNC addObject:arg1.text];
    [prefsNC setObject:notesNC forKey:@"notes"];
    [prefsNC writeToFile:filePathNC atomically:YES];

    reloadDataNC();

    [notesTableViewNC reloadData];
    [searchHeaderNCNotes clearSearchFieldWhyQuery:0 allowZKW:NO];
    [arg1 resignFirstResponder];
    [self showCancelButton:NO animated:YES];

    return YES;
}

- (BOOL)isOnDarkBackground {
    return YES;
}
%end

%hook SBNotificationCenterViewController
- (id)init {
    self = %orig;
    falconNCPageVC = self;
    return self;
}

%new
- (void)refresh:(id)sender {
    [webViewNC reload];
}

%new
- (void)stop:(id)sender {
    [webViewNC stopLoading];
}
%end

%hook SBSearchEtceteraIsolatedViewController
- (void)dismissSearchViewWithReason:(unsigned long long)arg1 {
    %orig;

    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        NCmainView.alpha = 1;
        toggleMainView.alpha = 1;
        notesMainView.alpha = 1;
    } completion:nil];
}

- (void)searchFieldDidFocus {
    %orig;

    NCmainView.alpha = 0;
    toggleMainView.alpha = 0;
    notesMainView.alpha = 0;
}
%end

%hook SBLockScreenManager
- (void)_setUILocked:(BOOL)arg1 {
    %orig;

    if (arg1)
        unlockedNC = NO;

    else
        unlockedNC = YES;
}
%end

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathNC];
    lockTogglesNC = [prefs objectForKey:@"lockToggles"] ? [[prefs objectForKey:@"lockToggles"] boolValue] : NO;
}

%ctor {
    loadPrefs();

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tweaksbylogan.falcon/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}