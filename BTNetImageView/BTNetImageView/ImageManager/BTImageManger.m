//
//  BTImageManger.m
//  BTThread
//
//  Created by 王 浩宇 on 13-6-21.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTImageManger.h"
#import "BTCache.h"
#import "BTURLRequestOperation.h"
#import <objc/runtime.h>

static char kBTImageRequestOperationObjectKey = 1;
static char kBTImageMemoryAndLocalOperationObjectKey = 2;

@interface BTImageManger (runTime)

@property (nonatomic, retain) BTURLRequestOperation *imageRequestOperation;
@property (nonatomic, retain) NSBlockOperation  *imageCacheOperation;

@end

@implementation BTImageManger (runTime)

@dynamic imageRequestOperation;

- (BTURLRequestOperation *)imageRequestOperation {
    return (BTURLRequestOperation *)objc_getAssociatedObject(self, &kBTImageRequestOperationObjectKey);
}

- (void)setImageRequestOperation:(BTURLRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kBTImageRequestOperationObjectKey, imageRequestOperation,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSBlockOperation *)imageCacheOperation{
    return (NSBlockOperation *)objc_getAssociatedObject(self, &kBTImageMemoryAndLocalOperationObjectKey);
}

- (void)setImageCacheOperation:(NSBlockOperation *)imageCacheOperation{
    objc_setAssociatedObject(self, &kBTImageMemoryAndLocalOperationObjectKey, imageCacheOperation,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end





@interface BTImageManger ()

@property (nonatomic,retain)NSURL *requestURL;

@end




@implementation BTImageManger

@synthesize requestURL;

@synthesize isloading,isAutoCancelRequest,origin;


#pragma mark ————————————————————————
#pragma mark class Method

//得到下载的队列
+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *__imageRequestOperationQueue = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^{
        __imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [__imageRequestOperationQueue setMaxConcurrentOperationCount:3];
    });
    
    return __imageRequestOperationQueue;
}

- (void)dealloc{
    self.requestURL = nil;
    [super dealloc];
}

- (void)imageForURL:(NSURL *)url completeBlock:(void (^)(UIImage *image, NSURL *url,BTImageResponseOrigin origin))complete;{
    if([self.requestURL isEqual:url]){
        return;
    }else{
        [self cancelRequest];
        self.requestURL = url;
        self.origin = noImage;
        NSBlockOperation * op = [[BTCache sharedCache] imageForURL:url completionBlock:^(UIImage *image, NSURL *url,BOOL isFromMemory) {
            self.imageCacheOperation = nil;
            if ([self.requestURL isEqual:url]) {
                if (image&&complete) {
                    if(isFromMemory){
                        self.origin = memory;
                    }else{
                        self.origin = local;
                    }
                    complete(image,self.requestURL,self.origin);
                } else {
                    //TODO: request
                    [self sendRequestWithCompleteBlock:complete];
                }
            }
        }];
        self.imageCacheOperation = op;
    }
}

//cancel request
- (void)cancelRequest{
    //去掉从本地读取的request
    //[[BTCache sharedCache] cancelImageForURL:self.requestURL withObject:self];
    if(self.imageCacheOperation){
        NSLog(@"存在");
    }
    [self.imageCacheOperation cancel];
    self.imageCacheOperation = nil;
    //去掉从网络读取的request
    if(self.isAutoCancelRequest){
        BTURLRequestOperation *op = self.imageRequestOperation;
        if(op){
            [op cancel];
            self.imageRequestOperation = nil;
        }
    }
}

- (BOOL)isloading{//是否存在网络的请求
    return self.imageCacheOperation ||self.imageRequestOperation;
}

- (void)sendRequestWithCompleteBlock:(void (^)(UIImage *image ,NSURL *url,BTImageResponseOrigin origin))complete{
    //NSLog(@"发请求");
    NSURL *url = self.requestURL;    
    BTURLRequestOperationCompleteBlock completeBlock = ^(BTURLRequestOperation *op){
        BTURLImageResponse *response = op.urlResponse;
        UIImage *image = response.image;
        NSURL *url = op.request.URL;
        if(url&&image){
            [[BTCache sharedCache] setImage:image forURL:[op.request URL]];
            if(url){
                if([url isEqual:self.requestURL]){
                    self.imageRequestOperation = nil;
                    if(complete&&image){
                        self.origin = net;
                        complete(image,url,net);
                    }
                }
            }
        }
    };
    
    BTURLRequestOperationStartBlock startBlock = ^(BTURLRequestOperation *op){
        //NSLog(@"开始请求 op =  %@",op);
    };
    
    
    BTURLRequestOperation *operation = [[BTURLRequestOperation alloc] initWithURL:url start:startBlock cancel:nil complete:completeBlock failed:nil];
    operation.urlResponse = [[[BTURLImageResponse alloc] init] autorelease];
    [operation setQueuePriority:NSOperationQueuePriorityNormal];
    self.imageRequestOperation = operation;
    [[[self class] sharedImageRequestOperationQueue] addOperation:operation];
    [operation release];
    
}

@end
