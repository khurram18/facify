//
//  CVWrapper.h
//  Facify
//
//  Created by Khurram on 21/03/2018.
//  Copyright © 2018 Khurram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef void(^DetectionResult)(NSArray<NSValue*>*);
@interface CVWrapper : NSObject
- (void)detect:(CVImageBufferRef)buffer;
@end
