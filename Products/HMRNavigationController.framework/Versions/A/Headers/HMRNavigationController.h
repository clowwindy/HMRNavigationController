//
// Created by clowwindy on 8/9/13.
//
//


#import <Foundation/Foundation.h>


@interface HMRNavigationController : UINavigationController <UIGestureRecognizerDelegate>

- (void)popViewControllerWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;
- (void)resetTopViewControllerWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;
- (void)rebuildScreenshots;

@end