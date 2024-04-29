//
//  UIView+frame.h
//  GoldenCare
//
//  Created by 박정우 on 2014. 3. 26..
//  Copyright (c) 2014년 skplanet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)

#pragma mark - Set Frame

@property (nonatomic) CGPoint	frameOrigin;
@property (nonatomic) CGSize	frameSize;

@property (nonatomic) CGFloat	frameX;
@property (nonatomic) CGFloat	frameY;

@property (nonatomic) CGFloat	frameRight;
@property (nonatomic) CGFloat	frameBottom;

@property (nonatomic) CGFloat	frameWidth;
@property (nonatomic) CGFloat	frameHeight;

@property (nonatomic) CGFloat	centerX;
@property (nonatomic) CGFloat	centerY;

@end
