//
//  BTURLImageResponse.m
//  BTThread
//
//  Created by 王 浩宇 on 13-6-5.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTURLImageResponse.h"
#import "BTURLRequestOperation.h"
#import "SDWebImageDecoder.h"

@implementation BTURLImageResponse

@synthesize image = _image;


- (void)dealloc{
    self.image = nil;
    [super dealloc];
}




- (NSError *)urlOperation:(BTURLRequestOperation *)op successResponse:(NSURLResponse *)response data:(id)data{
    
    
    NSAssert(![NSThread isMainThread], @"必须是子线程");
    NSAssert([data isKindOfClass:[UIImage class]]||[data isKindOfClass:[NSData class]],@"传递的对象必须是NSData，UIImage对象");
    
    if([data isKindOfClass:[UIImage class]]){
        UIImage *decodeImage = [UIImage decodedImageWithImage:(UIImage *)data];
        self.image =decodeImage;
    }else if ([data isKindOfClass:[NSData class]]){
        //        UIImage *decodeImage = [UIImage decodedImageWithImage:[UIImage imageWithData:data]];
        //        self.image = decodeImage;
        UIImage *image = [UIImage imageWithData:data];
        if(image !=nil){
            UIImage *decodeImage = [UIImage decodedImageWithImage:image];
            self.image = decodeImage;
        }else{
            return [NSError errorWithDomain:@"BTThread.image" code:100 userInfo:nil];
        }
        
    }
    
    return nil;
    
    return nil;
}
@end
