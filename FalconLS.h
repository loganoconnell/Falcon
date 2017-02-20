//LS
FalconBrowserPageViewController *falconLSPageVC;
FalconLSSearchHeader *searchHeaderLS;
UIProgressView *progressViewLS;
WKWebView *webViewLS;
UIToolbar *bottomToolbarLS;
UIBarButtonItem *backLS;
UIBarButtonItem *forwardLS;
UIBarButtonItem *shareLS;
UIBarButtonItem *homeLS;
NSTimer *progressViewTimerLS;

FalconTogglePageViewController *falconLSTogglePageVC;
UIButton *respringButtonLS;
UIButton *powerOffButtonLS;
UIButton *safeModeButtonLS;
UIButton *rebootButtonLS;
UISlider *brightnessSliderLS;
UISlider *volumeSliderLS;

FalconNotesPageViewController *falconLSNotesPageVC;
FalconNCNotesSearchHeader *searchHeaderLSNotes;
UITableView *notesTableViewLS;

NSMutableDictionary *prefs;
NSMutableArray *notes;
NSArray *LSenabledViews;

BOOL unlockedLS;
static BOOL cameraEnabled = NO;