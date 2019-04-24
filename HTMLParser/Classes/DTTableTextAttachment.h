#import <DTCoreText/DTCoreText.h>

extern NSString *const kDTTableTextAttachmentWebViewDidFinishLoading;

@interface DTTableTextAttachment : DTTextAttachment <DTTextAttachmentHTMLPersistence, UIWebViewDelegate>

@property (nonatomic, strong) NSString *someString;
@property (nonatomic, strong) NSString *html;

- (id)initWithElement:(DTHTMLElement *)element options:(NSDictionary *)options;
- (void)process;
- (UIView *)view;

@end
