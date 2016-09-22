#if kSupportADTransition
#import <UIKit/UIKit.h>

#import "ADFlipTransition.h"

@interface UIViewController (ADTransition)



@property (nonatomic, strong) ADTransition *presentedTransition;

@property (nonatomic, strong) ADTransition *presentingTransition;

- (ADTransition *)presentedTransition;

- (void)setPresentedTransition:(ADTransition *)presentedTransition;

- (ADTransition *)presentingTransition;

- (void)setPresentingTransition:(ADTransition *)presentingTransition;

- (ADTransition *)getPresentingTransition;


@end
#endif