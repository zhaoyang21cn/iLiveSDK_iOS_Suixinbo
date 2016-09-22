#if kSupportADTransition
#import "UIViewController+ADTransition.h"

#import <objc/runtime.h>

@implementation UIViewController (ADTransition)

#pragma mark - Setters

static NSString *const kPresentedTransitionKey = @"kPresentedTransition";
static NSString *const kPresentingTransitionKey = @"kPresentingTransition";

- (ADTransition *)presentedTransition
{
	return objc_getAssociatedObject(self, (__bridge const void *)kPresentedTransitionKey);
}

- (void)setPresentedTransition:(ADTransition *)presentedTransition
{
	objc_setAssociatedObject(self, (__bridge const void *)kPresentedTransitionKey, presentedTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ADTransition *)presentingTransition
{
	return objc_getAssociatedObject(self, (__bridge const void *)kPresentingTransitionKey);
}

- (void)setPresentingTransition:(ADTransition *)presentingTransition
{
	objc_setAssociatedObject(self, (__bridge const void *)kPresentingTransitionKey, presentingTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ADTransition *)getPresentingTransition
{
	UIViewController *vc = self;
	while (![vc presentingTransition] && [vc parentViewController])
    {
		vc = [vc parentViewController];
	}
	
	return [vc presentingTransition];
}

@end
#endif