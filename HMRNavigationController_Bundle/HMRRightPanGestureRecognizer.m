//
//  HMRRightPanGestureRecognizer.m
//  HMRNavigationController
//
//  Created by clowwindy on 13-12-27.
//  Copyright (c) 2013年 zhihu. All rights reserved.
//

#import "HMRRightPanGestureRecognizer.h"

@implementation HMRRightPanGestureRecognizer

- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return YES;
}
@end
