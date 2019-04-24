#import "DTTableTextAttachment.h"

NSString *const kDTTableTextAttachmentWebViewDidFinishLoading = @"p_kWebViewDidFinishLoading";

@implementation DTTableTextAttachment {
    DTHTMLElement *p_element;
    NSDictionary *p_options;
    UIWebView *p_webView;
    UIScrollView *p_scrollView;
}

- (id)initWithElement:(DTHTMLElement *)element options:(NSDictionary *)options {
    self = [super initWithElement:element options:options];
    p_element = element;
    p_options = options;
    return self;
}

- (void)process {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _html = [[NSString alloc] initWithFormat:@"<html><head><style> table, img { max-width: %fpx; border-collapse: collapse; } th, td { text-align: left; font-size: 16; } body { max-width: %fpx; word-wrap: break-word; background-color: rgb(233, 233, 233);}</style></head><body>%@</body></html>", screenWidth - 10, screenWidth - 10, p_element.debugDescription];
}

- (UIView *)view {
    if (p_scrollView) {
        return p_scrollView;
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 10, 10)];
    scrollView.showsVerticalScrollIndicator = NO;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:scrollView.frame];
    p_webView = webView;
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.delegate = self;
    [webView loadHTMLString:_html baseURL:nil];
    [scrollView addSubview:webView];
    p_scrollView = scrollView;
    return scrollView;
}

- (NSString *)stringByEncodingAsHTML {
    return @"here we go";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    CGFloat height = [result floatValue];
    _originalSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 10, height + 3);
    _displaySize = _originalSize;
    webView.frame = CGRectMake(0, 0, webView.scrollView.contentSize.width, _originalSize.height);
    [p_scrollView setContentSize:webView.frame.size];
    webView.scrollView.contentInset = UIEdgeInsetsMake(-7, 0, 0, 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:kDTTableTextAttachmentWebViewDidFinishLoading object:nil];
}

@end
