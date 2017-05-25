//
//  YPPresentaionController.m
//  transitionDemo
//
//  Created by Guoyin Lee on 24/05/2017.
//  Copyright © 2017 yiplee. All rights reserved.
//

#import "YPPresentaionDemoController.h"
#import "YPTestController.h"

@interface YPPresentationController : UIPresentationController

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation YPPresentationController

- (void) presentationTransitionWillBegin
{
    self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.45];
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDimmingView:)];
    [self.dimmingView addGestureRecognizer:tapGesture];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 1;
    } completion:nil];
}

- (void) presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void) dismissalTransitionWillBegin
{
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void) dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect) frameOfPresentedViewInContainerView
{
    UIViewController *presented = self.presentedViewController;
    CGSize size = [presented preferredContentSize];
    CGRect frame = self.containerView.bounds;
    CGRect temp = CGRectZero;
//    CGRectDivide(frame, &temp, &frame, 40, CGRectMaxYEdge);
    CGRectDivide(frame, &frame, &temp, size.height, CGRectMaxYEdge);
    NSLog(@"%@ get content size : %@ frame : %@",NSStringFromSelector(_cmd),NSStringFromCGSize(size),NSStringFromCGRect(frame));
    return frame;
}

- (void) containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    
//    NSLog(@"layout subviews");
//    
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

- (void) preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
//    if (container == self.presentedViewController &&
//        !self.presentedViewController.isBeingPresented &&
//        !self.presentedViewController.isBeingDismissed) {
//        NSLog(@"child content preferred contentSize did change");
//        CGRect frame = [self frameOfPresentedViewInContainerView];
//        [UIView animateWithDuration:0.3 animations:^{
//            self.presentedView.frame = frame;
//        }];
//    }
}

#pragma mark - tap action

- (void) tapOnDimmingView:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    UIView *presentedView = self.presentedViewController.view;
    
    if (!CGRectContainsPoint(presentedView.frame, location)) {
        [self.presentedViewController dismissViewControllerAnimated:YES
                                                         completion:nil];
    }
}

@end

#pragma mark - animator

@interface YPPresentationAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter=isPresenting) BOOL presenting;

@end

@implementation YPPresentationAnimator

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    YPPresentaionDemoController *demo = nil;
    if (self.isPresenting) {
        demo = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    } else {
        demo = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    UIView *animatedView = demo.view;
    
    CGRect targetFrame = [demo.presentationController frameOfPresentedViewInContainerView];
    
    if (self.presenting) {
        CGRect beginFrame = targetFrame;
        beginFrame.origin.y = CGRectGetMaxY(containerView.bounds);
        animatedView.frame = beginFrame;
        [containerView addSubview:animatedView];
    } else {
        targetFrame.origin.y = CGRectGetMaxY(containerView.bounds);
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         animatedView.frame = targetFrame;
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end

@interface YPNavigationAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@end

@implementation YPNavigationAnimator

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [transitionContext isAnimated] ? 0.3 : 0;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    BOOL isPush = self.operation == UINavigationControllerOperationPush;
    CGFloat layoutWidth = CGRectGetWidth(containerView.bounds);
    
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *parentController = from.navigationController;
    CGRect containerTargetFrame = [parentController.presentationController frameOfPresentedViewInContainerView];
    CGRect targetFrame = containerView.bounds;
    targetFrame.size = containerTargetFrame.size;
    
    CGRect fromBeginFrame,fromEndFrame;
    CGRect toBeginFrame,toEndFrame;
    
    if (isPush) {
        fromBeginFrame = containerView.bounds;
        fromEndFrame = targetFrame;
        toBeginFrame = CGRectOffset(fromBeginFrame, layoutWidth, 0);
        toEndFrame = fromEndFrame;
    } else {
        fromBeginFrame = containerView.bounds;
        toBeginFrame = fromBeginFrame;
        toEndFrame = targetFrame;
        fromEndFrame = CGRectOffset(toEndFrame, layoutWidth, 0);
    }
    
    NSLog(@"container view bounds : %@",NSStringFromCGRect(containerView.bounds));
    NSLog(@"from %@ -> %@",NSStringFromCGRect(fromBeginFrame),NSStringFromCGRect(fromEndFrame));
    NSLog(@"to %@ -> %@",NSStringFromCGRect(toBeginFrame),NSStringFromCGRect(toEndFrame));
    
    from.view.frame = fromBeginFrame;
    to.view.frame = toBeginFrame;
    
    if (isPush) {
        [containerView addSubview:to.view];
    } else {
        [containerView insertSubview:to.view belowSubview:from.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         from.view.frame = fromEndFrame;
                         to.view.frame = toEndFrame;
                         parentController.presentationController.presentedView.frame = containerTargetFrame;
                     } completion:^(BOOL finished) {
//                         from.view.frame = fromBeginFrame;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end

@interface YPPresentaionDemoController ()<UIViewControllerTransitioningDelegate,UINavigationControllerDelegate>

@end

@implementation YPPresentaionDemoController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        YPTestController *test = [self createNewTestController];
        self.viewControllers = @[test];
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.clipsToBounds = YES;
    self.interactivePopGestureRecognizer.enabled = NO;
    self.delegate = self;
}

#pragma mark - action

- (YPTestController *) createNewTestController
{
    CGFloat height = 300 + arc4random_uniform(300);
    YPTestController *test = [[YPTestController alloc] initWithLayoutHeight:height];
    UIBarButtonItem *route = [[UIBarButtonItem alloc] initWithTitle:@"ROUTE"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(showNewTestPage:)];
    test.navigationItem.rightBarButtonItem = route;
    return test;
}

- (void) showNewTestPage:(id)sender
{
    YPTestController *test = [self createNewTestController];
    [self pushViewController:test animated:YES];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    YPPresentationAnimator *animator = [YPPresentationAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed
{
    YPPresentationAnimator *animator = [YPPresentationAnimator new];
    animator.presenting = NO;
    return animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    YPPresentationController *presentation =
    [[YPPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return presentation;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.preferredContentSize = [viewController preferredContentSize];
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    YPNavigationAnimator *animator = [YPNavigationAnimator new];
    animator.operation = operation;
    return animator;
}

@end
