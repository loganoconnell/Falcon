@interface SPUIHeaderBlurView : UIVisualEffectView
@end

BOOL darkModeEnabled;
static BOOL hasAddedListener = NO;

%hook SPUIHeaderBlurView
- (void)layoutSubviews {
    %orig;

	if (darkModeEnabled) {
        self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	}

	else {
    	self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	}

	if (!hasAddedListener) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableNotification:) name:@"com.laughingquoll.noctis.enablenotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableNotification:) name:@"com.laughingquoll.noctis.disablenotification" object:nil];

		hasAddedListener = YES;
    }
}

%new
- (void)enableNotification:(NSNotification *)notification {
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
}

%new
- (void)disableNotification:(NSNotification *)notification {
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}
%end

static void settingsChangedprefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	@autoreleasepool {
        NSDictionary *DecorusPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctisprefs.plist"] ?: [NSDictionary dictionary] copy];
        darkModeEnabled = (BOOL)[[DecorusPrefs objectForKey:@"enabled"] ?: @YES boolValue];
        CFPreferencesSetAppValue((CFStringRef)@"LQDDarkModeEnabled", (CFPropertyListRef)[NSNumber numberWithBool:darkModeEnabled], CFSTR("com.laughingquoll.noctis"));
    }
}

%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedprefs, CFSTR("com.laughingquoll.decorusprefs/changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        settingsChangedprefs(NULL, NULL, NULL, NULL, NULL);
    }
}