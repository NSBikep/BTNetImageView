//
//  BTURLResponse.h
//  BTThread
//
//  Created by 王 浩宇 on 13-6-5.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>



@class BTURLRequestOperation;
@protocol BTURLResponse <NSObject>

@required


//成功之后的处理
- (NSError *)urlOperation:(BTURLRequestOperation *)op successResponse:(NSURLResponse *)response data:(id)data;

@optional


//- (NSError *)urlOperation:(BTURLRequestOperation *)op successResponse:(NSURLResponse *)response data:(id)data;



@end
