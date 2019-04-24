#import <Foundation/Foundation.h>
@import DTCoreText;

@interface HTMLProcessor : NSObject

@property NSArray *supportedTags;
@property NSString *styles;

- (id)init:(NSString *)html;
- (NSString *)css:(NSString *)color;
- (NSString *)body;

@end
