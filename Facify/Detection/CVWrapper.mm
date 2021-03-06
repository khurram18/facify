//
//  CVWrapper.m
//  Facify
//
//  Created by Khurram on 21/03/2018.
//  Copyright © 2018 Khurram. All rights reserved.
//

#import "CVWrapper.h"
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgproc.hpp>
#import <vector>

@implementation CVWrapper {
    dispatch_queue_t _dispatch_queue;
    cv::CascadeClassifier _classifier;
}
- (instancetype)init {
    if (self = [super init]) {
        _dispatch_queue = dispatch_queue_create("com.bitsparlour.Facify.detectionQueue", DISPATCH_QUEUE_SERIAL);
        NSString* name = @"haarcascade_frontalface_alt_tree";
        NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
        if (!_classifier.load(path.UTF8String)) {
            NSLog(@"Error loading cascade");
        }
    }
    return self;
}
- (void)detectFaces:(CVImageBufferRef)pixelBuffer; {

    CIImage* ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
    CGAffineTransform transform = [ciImage imageTransformForCGOrientation:kCGImagePropertyOrientationRight];
    ciImage = [ciImage imageByApplyingTransform:transform];
    CIContext* context = [[CIContext alloc] init];
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:ciImage.extent];
    UIImage* image = [UIImage imageWithCGImage:imageRef];
    cv::Mat mat = [self cvMatFromUIImage:image];
    
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    std::vector<cv::Rect> faces;
    std::vector<int> levels;
    std::vector<double> weights;
    _classifier.detectMultiScale(gray, faces, levels, weights, 1.1, 3, 0, cv::Size(), cv::Size(), true);
    NSMutableArray<NSValue*>* array = [[NSMutableArray alloc] initWithCapacity:faces.size()];
    const size_t size = faces.size();
    for (int i = 0; i < size; ++i) {
        // If confidence is greater than 2.0
        if (weights[i] > 2.0) {
            cv::Rect rect = faces[i];
            cv::rectangle(mat, rect, cv::Scalar( 255, 0, 255 ));
            [array addObject:[NSValue valueWithCGRect:CGRectMake(rect.x, rect.y, rect.width, rect.height)]];
        }
    }
    if (_completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _completionBlock(array, image.size);
        });
    }
    CGImageRelease(imageRef);
}
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
@end
