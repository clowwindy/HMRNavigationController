//
// Created by clowwindy on 8/9/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "HMRRightPanGestureRecognizer.h"
#import "HMRNavigationController.h"

#define BG_FACTOR 0.3
#define SHADOW_FACTOR 2
#define BG_ALPHA 0.8
#define SHADOW_WIDTH 5

// 左右划触发的最小距离
#define TRIGGER_PAN_LIMIT 15
// 上下滑取消左右划，的最小距离
#define TRIGGER_CANCEL_PAN_LIMIT 50

@implementation HMRNavigationController {
    HMRRightPanGestureRecognizer *recognizer;
    CGRect viewControllerOriginalFrame;
    NSMutableArray *bgImageStack;
    UIImageView *bgImageView;
    UIImageView *shadowImageView;
    BOOL panTriggered;
    BOOL enabled;
    NSTimer *timer;
}


NSUInteger DeviceSystemMajorVersion();

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        enabled = YES;
        panTriggered = NO;
        recognizer = [[HMRRightPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        recognizer.delegate = self;
        bgImageStack = [[NSMutableArray alloc] initWithCapacity:8];
        bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SHADOW_WIDTH, self.view.bounds.size.height)];
        shadowImageView.contentMode = UIViewContentModeScaleToFill;
        shadowImageView.image = [UIImage imageNamed:@"Navigation_Shadow"];
        [self.view insertSubview:shadowImageView atIndex:0];
        [self.view insertSubview:bgImageView atIndex:0];
        [self.view addGestureRecognizer:recognizer];
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count == 1) {
        return NO;
    }
    return YES;
}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
////    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
////        UIPanGestureRecognizer *otherPanGestureGecognizer = (UIPanGestureRecognizer *)otherGestureRecognizer;
//////        if (fabsf([otherPanGestureGecognizer translationInView:self.view].y) > TRIGGER_PAN_LIMIT) {
////            return YES;
////            NSLog(@"require to fail by other gesture");
//////        }
////    }
//    return NO;
//}

- (UIImage *)snapshot:(UIViewController *)viewController fast:(BOOL)fast {
    CGFloat scale = 1.0f;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [UIScreen mainScreen].scale;
    }
    UIImage *viewImage;
    UIGraphicsBeginImageContextWithOptions(bgImageView.frame.size, YES, scale);
    if ((DeviceSystemMajorVersion() >= 7) && fast) {
        [viewController.view drawViewHierarchyInRect:self.view.window.bounds afterScreenUpdates:NO];
    } else {
        CGContextRef c = UIGraphicsGetCurrentContext();
//        if (DeviceSystemMajorVersion() < 7) {
//            CGContextConcatCTM(c, CGAffineTransformMakeTranslation(0, [UIApplication sharedApplication].statusBarFrame.size.height));
//        }
        [viewController.view.layer renderInContext:c];
    }
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return viewImage;
}

- (void)rebuildScreenshots {
    [bgImageStack removeAllObjects];
    for (UIViewController *viewController in self.viewControllers) {
        [bgImageStack addObject:[self snapshot:viewController fast:NO]];  // fast mode doesn't work at this time
    }
    [bgImageStack removeLastObject];
    [bgImageView setImage:bgImageStack.lastObject];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIImage *viewImage = [self snapshot:self.topViewController fast:YES];
    [bgImageStack addObject:viewImage];
    [bgImageView setImage:viewImage];
    [super pushViewController:viewController animated:animated];
    if (animated) {
        enabled = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(enable) userInfo:nil repeats:NO];
    }
}
                          
- (void)enable {
    enabled = YES;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    if (viewController) {
        [bgImageStack removeLastObject];
        bgImageView.image = [bgImageStack lastObject];
    }
    return viewController;
}

- (void)popViewControllerWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options{
//    [HMRKernel executeCommand:@"tutorial/record pan_back"]; // TODO
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        CGRect newFrame = viewControllerOriginalFrame;
        newFrame.origin.x += 320;
        self.topViewController.view.frame = newFrame;
        CGRect bgFrame = bgImageView.frame;
        bgFrame.origin.x = 0;
        bgImageView.frame = bgFrame;
        bgImageView.alpha = 1;
        CGRect shadowFrame = shadowImageView.frame;
        shadowFrame.origin.x = 320 - SHADOW_WIDTH;
        shadowImageView.frame = shadowFrame;
        shadowImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self popViewControllerAnimated:NO];
    }];
}

- (void)resetTopViewControllerWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options{
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.topViewController.view.frame = viewControllerOriginalFrame;
        CGRect bgFrame = bgImageView.frame;
        bgFrame.origin.x = -320 * BG_FACTOR;
        bgImageView.frame = bgFrame;
        bgImageView.alpha = BG_ALPHA;
        CGRect shadowFrame = shadowImageView.frame;
        shadowFrame.origin.x = 0 - SHADOW_WIDTH;
        shadowImageView.alpha = 1;
        shadowImageView.frame = shadowFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer1 {
    if (!enabled) {
        return;
    }
    UIViewController *viewController = self.topViewController;
    UIView *view = viewController.view;
    if (self.viewControllers.count == 1) {
        return;
    }
    
    CGPoint p = [recognizer translationInView:self.view];
    if (p.x < 0) {
        p.x = 0;
    } else if (p.x > 320) {
        p.x = 320;
    }
    if (p.x >= TRIGGER_PAN_LIMIT && p.x <= 320 - TRIGGER_PAN_LIMIT) {
        panTriggered = YES;
        CGRect newFrame = view.frame;
        if (newFrame.origin.x == 0) {
            viewControllerOriginalFrame = view.frame;
        }
        newFrame = viewControllerOriginalFrame;
        newFrame.origin.x += p.x;
        view.frame = newFrame;
        CGRect bgFrame = bgImageView.frame;
        bgFrame.origin.x = p.x * BG_FACTOR - 320 * BG_FACTOR;
        bgImageView.frame = bgFrame;
        bgImageView.alpha = p.x  * (1 - BG_ALPHA) / 320.0f + BG_ALPHA;
        CGRect shadowFrame = shadowImageView.frame;
        shadowFrame.origin.x = p.x - SHADOW_WIDTH;
        shadowImageView.alpha = (320.0f - p.x) / 320.0f * SHADOW_FACTOR; // start fading when x > 160
        shadowImageView.frame = shadowFrame;
    }
    if ((!panTriggered) && (p.y >= TRIGGER_CANCEL_PAN_LIMIT || p.y <= -TRIGGER_CANCEL_PAN_LIMIT)) {
        recognizer.enabled = NO;
        recognizer.enabled = YES;
//        recognizer.state = UIGestureRecognizerStateFailed;
        NSLog(@"cancel go back gesture");
        return;
    }
    if (panTriggered && recognizer.state == UIGestureRecognizerStateEnded) {
        panTriggered = NO;
        CGFloat v = [recognizer velocityInView:self.view].x;
        if (v == 0) v = 0.001;
        CGFloat x = p.x;
        // condition: v > 0 and v * v / (2 * a) > 0.5 * (s - x)
        // t ~= (s - x) / v * 2
        CGFloat sign = v > 0? 1: -1;
        BOOL condition = (sign * (v * v) / (2 * 100) > 0.5 * 320 - x);
        if (condition) {
            CGFloat t = sign * (320 - x) / v * 2;
            if (t > 0.5) {
                t = 0.5;
            } else if (t < 0.1) {
                t = 0.1;
            }
            [self popViewControllerWithDuration:t options:UIViewAnimationOptionCurveEaseOut];
        } else {
            CGFloat t = sign * x / v * 2;
            if (t > 0.5) {
                t = 0.5;
            } else if (t < 0.1) {
                t = 0.1;
            }
            [self resetTopViewControllerWithDuration:t options:UIViewAnimationOptionCurveEaseOut];
        }
        
    }
    
}


@end