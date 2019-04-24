#import <UIKit/UIKit.h>
@import DTCoreText;

typedef enum CallBackType {
    
    CallBackTypeLink = 1,
    CallBackTypeImage = 2,
    CallBackTypeVideo = 3
    
} CallBackType;

typedef void(^Handler)(CallBackType, NSURL *);

@protocol ReloadNewsDelegate

- (void)reloadCell;

@end

@interface HTMLCell : UITableViewCell <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>

@property (weak, nonatomic) IBOutlet DTAttributedTextView *attributedTextView;
@property Handler callBackHandler;
@property id <ReloadNewsDelegate> delegate;
@property NSArray *tags;
@property NSString *css;

- (CGFloat)requiredRowHeight;
- (void)setupWith:(NSString *)content;
@end
