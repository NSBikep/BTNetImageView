//
//  BTImageManger.h
//  BTThread
//
//  Created by 王 浩宇 on 13-6-21.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(unsigned short, BTImageResponseOrigin){
    noImage = 0,
    memory  = 1,
    local   = 2,
    net     = 3,
};


@interface BTImageManger : NSObject



@property (nonatomic,assign)BOOL  isloading;
@property (nonatomic,assign)BOOL  isAutoCancelRequest;
@property (nonatomic,assign)BTImageResponseOrigin origin;
- (void)imageForURL:(NSURL *)url completeBlock:(void (^)(UIImage *image, NSURL *url,BTImageResponseOrigin origin))complete;

- (void)cancelRequest;

@end
