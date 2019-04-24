#import "HTMLCell.h"
#import "HTMLProcessor.h"
#import "DTTableTextAttachment.h"

@implementation HTMLCell

#pragma mark - Cell methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableAttachment) name:kDTTableTextAttachmentWebViewDidFinishLoading object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_attributedTextView.frame.size.height == 0) return;
    CGSize size = [self requiredSize];
    _attributedTextView.frame = CGRectMake(0, 0, size.width, size.height);
    _attributedTextView.attributedTextContentView.frame = _attributedTextView.frame;
    [_attributedTextView relayoutText];
}

#pragma mark - Helper methods

- (CGSize)requiredSize {
    return [_attributedTextView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:[UIScreen mainScreen].bounds.size.width];
}

- (CGFloat)requiredRowHeight {
    return [self requiredSize].height;
}

- (void)setupWith:(NSString *)content {
    HTMLProcessor *processor = [[HTMLProcessor alloc] init:content];
    processor.supportedTags = _tags;
    processor.styles = _css;
    NSData *data = [[processor body] dataUsingEncoding:NSUTF8StringEncoding];
    DTCSSStylesheet *css = [[DTCSSStylesheet alloc] initWithStyleBlock:[processor css:nil]];
    NSDictionary *options = @{DTDefaultStyleSheet : css};
    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:nil];
    _attributedTextView.attributedTextContentView.delegate = self;
    _attributedTextView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _attributedTextView.attributedTextContentView.attributedString = attString;
    _attributedTextView.scrollEnabled = false;
}

- (void)reloadTableAttachment {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_attributedTextView relayoutText];
        [_delegate reloadCell];
    });
}

#pragma mark - Actions

- (void)linkPushed:(DTLinkButton *)sender {
    if (_callBackHandler) _callBackHandler(CallBackTypeLink, sender.URL);
}
//TODO: make valid url for video
- (void)imagePushed:(DTLinkButton *)sender {
    if (sender.URL == nil) return;
    if ([sender.URL.absoluteString containsString:@"youtube.com"]) {
        if (_callBackHandler) _callBackHandler(CallBackTypeVideo, sender.URL);
        return;
    }
    if (_callBackHandler) _callBackHandler(CallBackTypeImage, sender.URL);
}

#pragma mark - DTAttributedTextContentViewDelegate
//TODO: center small images
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    if ([attachment isKindOfClass:[DTImageTextAttachment class]]) {
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.url = attachment.contentURL;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.userInteractionEnabled = true;
        imageView.shouldShowProgressiveDownload = true;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:CGRectMake(0, 0, imageView.bounds.size.width, imageView.bounds.size.height)];
        button.URL = attachment.contentURL;
        button.minimumHitSize = CGSizeMake(25, 25);
        button.GUID = attachment.hyperLinkGUID;
        button.tag = 101;
        [button addTarget:self action:@selector(imagePushed:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:button];
        return imageView;
    } else if ([attachment isKindOfClass:[DTTableTextAttachment class]]) {
        DTTableTextAttachment *tableAttachment = (DTTableTextAttachment *)attachment;
        [tableAttachment process];
        UIView *view = tableAttachment.view;
        view.frame = CGRectMake(frame.origin.x, frame.origin.y, view.frame.size.width, view.frame.size.height);
        return view;
    }
    return nil;
}

//TODO: Make link according to design
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:nil];
    if ([attributes objectForKey:DTLinkAttribute]) {
        NSURL *url = [attributes objectForKey:DTLinkAttribute];
        DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
        button.URL = url;
        button.minimumHitSize = CGSizeMake(25, 25);
        button.GUID = [attributes objectForKey:DTGUIDAttribute];
        [button setImage:[attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault] forState:UIControlStateNormal];
        [button setImage:[attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    }
    return nil;
}

#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    if (lazyImageView == nil) return;
    NSURL *url = lazyImageView.url;
    BOOL didUpdate = false;
    for (DTTextAttachment *attach in [_attributedTextView.attributedTextContentView.layoutFrame.textAttachments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contentURL == %@", url]]) {
        if (!CGSizeEqualToSize(attach.originalSize, CGSizeZero)) continue;
        [attach setOriginalSize:size];
        [self displaySize:attach accordingTo:size];
        didUpdate = true;
        DTLinkButton *button = [lazyImageView viewWithTag:101];
        [button setFrame:CGRectMake(0, 0, size.width, size.height)];
    }
    if (didUpdate) {
        [self reloadTableAttachment];
    }
}

- (void)displaySize:(DTTextAttachment *)attach accordingTo:(CGSize) size {
    CGFloat mW = [UIScreen mainScreen].bounds.size.width - 20;
    if (attach.displaySize.width != mW) {
        CGFloat scale = size.height / size.width;
        [attach setDisplaySize:CGSizeMake(mW, mW * scale) withMaxDisplaySize:CGSizeMake(mW, mW * scale)];
    }
}

@end
