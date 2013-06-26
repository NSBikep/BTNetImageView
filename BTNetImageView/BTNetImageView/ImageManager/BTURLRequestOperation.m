//
//  BTURLConnectionOperation.m
//  BTThread
//
//  Created by Gary on 13-5-1.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTURLRequestOperation.h"

@interface BTURLRequestOperation()

///------------------------
/// @name Accessing Streams
///------------------------
//
///**
// The input stream used to read data to be sent during the request.
//
// @discussion This property acts as a proxy to the `HTTPBodyStream` property of `request`.
// */
//@property (nonatomic, retain) NSInputStream *inputStream;
//
///**
// The output stream that is used to write data received until the request is finished.
//
// @discussion By default, data is accumulated into a buffer that is stored into `responseData` upon completion of the request. When `outputStream` is set, the data will not be accumulated into an internal buffer, and as a result, the `responseData` property of the completed request will be `nil`. The output stream will be scheduled in the network thread runloop upon being set.
// */



@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSError *error;





//Neo add

@property (nonatomic,copy)BTURLRequestOperationCancelBlock   cancelBlock;
@property (nonatomic,copy)BTURLRequestOperationStartBlock    startBlock;
@property (nonatomic,copy)BTURLRequestOperationCompleteBlock completeBlock;
@property (nonatomic,copy)BTURLRequestOperationFailedBlock   faildeBlock;


- (void)markOperationFinish;
- (void)concurrentExecution;
- (void)cancelConcurrentExecution;
- (void)closeConnection;
@end

@implementation BTURLRequestOperation


@synthesize urlResponse = _urlResponse;


- (void)dealloc {
    self.completeBlock = nil;
    self.startBlock = nil;
    self.cancelBlock = nil;
    self.faildeBlock = nil;
    self.request = nil;
    self.response = nil;
    self.responseData = nil;
    [self closeConnection];
    self.error = nil;
    [super dealloc];
}

- (void)closeConnection {
    [self.outputStream close];
    self.outputStream = nil;
    self.connection = nil;
}


- (id)initWithURL:(NSURL *)requestURL
            start:(BTURLRequestOperationStartBlock)startBlock
           cancel:(BTURLRequestOperationCancelBlock)cancelBlock
         complete:(BTURLRequestOperationCompleteBlock)completeBlock
          failed:(BTURLRequestOperationFailedBlock)failedBlock{
    self = [super init];
    if(self){
        self.request = [NSURLRequest requestWithURL:requestURL];
        _cancelBlock = [cancelBlock copy];
        _startBlock  = [startBlock copy];
        _completeBlock = [completeBlock copy];
        _faildeBlock = [failedBlock copy];
    }
    return self;
}


//- (id)initWithURL:(NSURL *)requestURL delegate:(id<BTURLRequestDelegate>)delegate{
//    self = [super init];
//    if(self){
//        self.request = [NSMutableURLRequest requestWithURL:requestURL];
//        _delegate = delegate;
//    }
//    return self;
//}
/**
 Subclass should overwrite this method
 */
- (void)concurrentExecution {
    //NSLog(@"发请求");
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (_delegate && [_delegate respondsToSelector:@selector(requestStarted:)]) {
//            [_delegate performSelector:@selector(requestStarted:) withObject:self];
//        }
        if(self.startBlock){
            self.startBlock(self);
        }
    });
    _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    for (NSString *runLoopMode in self.runLoopModes) {
        [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
    }
//    if (_delegate && [_delegate respondsToSelector:@selector(request:didReceiveData:)]) {
//        _receiveDataExternally = YES;
//    }
//TODO: 判断时候需要传递出去进度
    
    
    [self.connection start];
    ////NSLog(@"%@ self.connection start",self);
    
}

/**
 Subclass should overwrite this method
 */
- (void)cancelConcurrentExecution {
    //[super cancelConcurrentExecution];
    NSDictionary *userInfo = nil;
    if ([self.request URL]) {
        userInfo = [NSDictionary dictionaryWithObject:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
    }
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
    
    if (self.connection) {
        [self.connection cancel];
        
        // Manually send this delegate message since `[self.connection cancel]` causes the connection to never send another message to its delegate
        [self performSelector:@selector(connection:didFailWithError:) withObject:self.connection withObject:error];
    }
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate

/*
 in rare cases, for example in the case of an HTTP load where the content type of the load data is multipart/x-mixed-replace, the delegate will receive more than one connection:didReceiveResponse: message. In the event this occurs, delegates should discard all data previously delivered by connection:didReceiveData:, and should be prepared to handle the, potentially different, MIME type reported by the newly reported URL response.
 The only case where this message is not sent to the delegate is when the protocol implementation encounters an error before a response could be created.
 
 */
- (void)connection:(NSURLConnection __unused *)connection didReceiveResponse:(NSURLResponse *)response {
    //long long contentLength = [response expectedContentLength];
    ////NSLog(@"didReceiveResponse >> th:%@-op:%@ contentLength:%f",[NSThread currentThread],self.name,(contentLength/1024/1024.0));
    self.response = response;
    self.outputStream = [NSOutputStream outputStreamToMemory];
    [self.outputStream open];
    
    
    
    
    //这个位置为什么要这么写？难道不会直接跳到fail
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (([httpResponse statusCode]/100) != 2) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:nil];
            [self performSelector:@selector(connection:didFailWithError:) withObject:connection withObject:error];
        }
    }
    //      NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //      NSString *modified = [headers objectForKey:@"Last-Modified"];
    //      if (modified) {
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //
    //        /* avoid problem if the user's locale is incompatible with HTTP-style dates */
    //        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    //
    //        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    //        self.lastModified = [dateFormatter dateFromString:modified];
    //        [dateFormatter release];
    //      }
    //      else {
    //        /* default if last modified date doesn't exist (not an error) */
    //        self.lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    //      }
}

- (void)connection:(NSURLConnection __unused *)connection didReceiveData:(NSData *)data {
    if (_receiveDataExternally) {
        dispatch_async(dispatch_get_main_queue(), ^{
//需要计算进度？
        
        
        });
    } else {
        if ([self.outputStream hasSpaceAvailable]) {
            const uint8_t *dataBuffer = (uint8_t *) [data bytes];
            [self.outputStream write:&dataBuffer[0] maxLength:[data length]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ////NSLog(@"didReceiveData[%@]:%d",self.name, [data length]);
                //TODO:
                //    self.totalBytesRead += [data length];
                //
                //    if (self.downloadProgress) {
                //      self.downloadProgress([data length], self.totalBytesRead, self.response.expectedContentLength);
                //    }
            });
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection {
    self.responseData = [_outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [self closeConnection];
    [self markOperationFinish];
    
    NSError *error =  [_urlResponse urlOperation:self successResponse:self.response data:self.responseData];
    if(error == nil){
        if(self.completeBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completeBlock(self);
            });
        }
    }else{
        self.error = error;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.faildeBlock(self);
        });
    }
    
    
}

- (void)connection:(NSURLConnection __unused *)connection didFailWithError:(NSError *)error {
    self.error = error;
    
    [self closeConnection];
    [self markOperationFinish];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.faildeBlock){
            self.faildeBlock(self);
        }
    });
}
@end
