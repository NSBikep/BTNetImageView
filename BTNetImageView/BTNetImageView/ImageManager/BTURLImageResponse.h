//
//  BTURLImageResponse.h
//  BTThread
//
//  Created by 王 浩宇 on 13-6-5.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTURLResponse.h"



@interface BTURLImageResponse : NSObject <BTURLResponse>{
    UIImage *_image;
}


@property (nonatomic,retain)UIImage   *image;

@end
