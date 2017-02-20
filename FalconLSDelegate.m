#import "Falcon.h"
#import "FalconLS.h"

NSString *filePathLSD = @"/var/mobile/Library/Preferences/com.tweaksbylogan.falcon.plist";

BOOL deleting = NO;

static void reloadDataLSD() {
    prefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathLSD] ? [NSMutableDictionary dictionaryWithContentsOfFile:filePathLSD] : [NSMutableDictionary dictionary];
    LSenabledViews = [prefs objectForKey:@"LSenabledViews"] ? [[prefs objectForKey:@"LSenabledViews"] copy] : [NSArray arrayWithObjects:@"Today", @"Main", @"Camera", nil];
    notes = [prefs objectForKey:@"notes"] ? [[prefs objectForKey:@"notes"] mutableCopy] : [NSMutableArray array];
}

@implementation FalconLSDelegate
- (void)updateWebView {
    backLS.enabled = webViewLS.canGoBack;
    forwardLS.enabled = webViewLS.canGoForward;
    shareLS.enabled = webViewLS.URL ? YES : NO;
    homeLS.enabled = webViewLS.URL ? YES : NO;
    
    NSMutableArray *items = [bottomToolbarLS.items mutableCopy];
    
    if (webViewLS.loading) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView startAnimating];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:falconLSPageVC action:@selector(stop:)];
        [activityIndicatorView addGestureRecognizer:tap];

        [items replaceObjectAtIndex:6 withObject:[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView]];
    }
    
    else
        [items replaceObjectAtIndex:6 withObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:falconLSPageVC action:@selector(refresh:)]];

    ((UIBarButtonItem *)[items objectAtIndex:6]).enabled = webViewLS.URL ? YES : NO;

    [bottomToolbarLS setItems:items animated:NO];
}

- (void)updateProgressView:(id)sender {
    if (progressViewLS.progress == 1) {
        progressViewLS.hidden = YES;
        [progressViewTimerLS invalidate];
    }
     
    else
        [progressViewLS setProgress:webViewLS.estimatedProgress animated:YES];
}

- (void)webView:(id)webView didCommitNavigation:(id)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self updateWebView];

    progressViewLS.progress = 0;
    progressViewLS.hidden = NO;
    progressViewTimerLS = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressView:) userInfo:nil repeats:YES] retain];

}

- (void)webView:(id)webView didStartProvisionalNavigation:(id)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self updateWebView];

    progressViewLS.progress = 0;
    progressViewLS.hidden = NO;
    progressViewTimerLS = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressView:) userInfo:nil repeats:YES] retain];
}

- (void)webView:(id)webView didFinishNavigation:(id)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self updateWebView];
}

- (void)webView:(id)webView didFailNavigation:(id)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self updateWebView];
    
    if ([error code] != NSURLErrorCancelled) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
	    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

	    [falconLSPageVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self updateWebView];
    
    if ([error code] != NSURLErrorCancelled) {
    	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
	    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

	    [falconLSPageVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)())completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];

    [falconLSPageVC presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:prompt preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = defaultText;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(((UITextField *)alertController.textFields.firstObject).text);
    }]];

    [falconLSPageVC presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];

    [falconLSPageVC presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableDictionary *copyPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:filePathLSD] ? [NSMutableDictionary dictionaryWithContentsOfFile:filePathLSD] : [NSMutableDictionary dictionary];
    NSMutableArray *copyNotes = [copyPrefs objectForKey:@"notes"] ? [[copyPrefs objectForKey:@"notes"] mutableCopy] : [NSMutableArray array];
    return (deleting) ? copyNotes.count - 1 : copyNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newNotesCell"];

    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"newNotesCell"];

    cell.textLabel.text = notes[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    reloadDataLSD();
    deleting = YES;

    [notes removeObjectAtIndex:indexPath.row];
    [notesTableViewLS deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [prefs setObject:notes forKey:@"notes"];
    [prefs writeToFile:filePathLSD atomically:YES];
    
    deleting = NO;
    reloadDataLSD();
}
@end