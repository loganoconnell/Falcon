// NC
SBNotificationCenterViewController *falconNCPageVC;
UIView *NCmainView;
FalconNCSearchHeader *searchHeaderNC;
UIProgressView *progressViewNC;
WKWebView *webViewNC;
UIToolbar *bottomToolbarNC;
UIBarButtonItem *backNC;
UIBarButtonItem *forwardNC;
UIBarButtonItem *shareNC;
UIBarButtonItem *homeNC;
NSTimer *progressViewTimerNC;

UIView *toggleMainView;
UIButton *respringButtonNC;
UIButton *powerOffButtonNC;
UIButton *safeModeButtonNC;
UIButton *rebootButtonNC;
UISlider *brightnessSliderNC;
UISlider *volumeSliderNC;

UIView *notesMainView;
FalconNCNotesSearchHeader *searchHeaderNCNotes;
UITableView *notesTableViewNC;

BOOL unlockedNC;
static BOOL hasEnteredPages = NO;