#import "Falcon.h"
#import "FalconNC.h"

@implementation FalconNCDelegate
- (void)updateWebView {
    backNC.enabled = webViewNC.canGoBack;
    forwardNC.enabled = webViewNC.canGoForward;
    shareNC.enabled = webViewNC.URL ? YES : NO;
    homeNC.enabled = webViewNC.URL ? YES : NO;
    
    NSMutableArray *items = [bottomToolbarNC.items mutableCopy];
    
    if (webViewNC.loading) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView startAnimating];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:falconNCPageVC action:@selector(stop:)];
        [activityIndicatorView addGestureRecognizer:tap];

        [items replaceObjectAtIndex:6 withObject:[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView]];
    }
    
    else
        [items replaceObjectAtIndex:6 withObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:falconNCPageVC action:@selector(refresh:)]];

    ((UIBarButtonItem *)[items objectAtIndex:6]).enabled = webViewNC.URL ? YES : NO;

    [bottomToolbarNC setItems:items animated:NO];
}

- (void)updateProgressView:(id)sender {
    if (progressViewNC.progress == 1) {
        progressViewNC.hidden = YES;
        [progressViewTimerNC invalidate];
    }
     
    else
        [progressViewNC setProgress:webViewNC.estimatedProgress animated:YES];
}

- (void)webView:(id)webView didCommitNavigation:(id)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self updateWebView];

    progressViewNC.progress = 0;
    progressViewNC.hidden = NO;
    progressViewTimerNC = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressView:) userInfo:nil repeats:YES] retain];

}

- (void)webView:(id)webView didStartProvisionalNavigation:(id)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self updateWebView];

    progressViewNC.progress = 0;
    progressViewNC.hidden = NO;
    progressViewTimerNC = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressView:) userInfo:nil repeats:YES] retain];
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

	    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self updateWebView];
    
    if ([error code] != NSURLErrorCancelled) {
    	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
	    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];

	    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)())completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
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

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];

    [falconNCPageVC presentViewController:alertController animated:YES completion:nil];
}
@end