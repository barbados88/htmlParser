//
//  HTMLProcessor.h
//  UAFootball
//
//  Created by Woxapp on 02.11.17.
//  Copyright © 2017 woxapp. All rights reserved.
//

#import <Foundation/Foundation.h>
@import DTCoreText;

@interface HTMLProcessor : NSObject

@property NSArray *supportedTags;
@property NSString *styles;

- (id)init:(NSString *)html;
- (NSString *)css:(NSString *)color;
- (NSString *)body;

@end
