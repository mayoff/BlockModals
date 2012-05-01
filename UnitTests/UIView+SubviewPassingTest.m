/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "UIView+SubviewPassingTest.h"

@implementation UIView (SubviewPassingTest)

- (UIView *)subviewPassingTest:(BOOL (^)(UIView *))test {
    for (UIView *subview in self.subviews) {
        if (test(subview)) {
            return subview;
        }
        UIView *subsubview = [subview subviewPassingTest:test];
        if (subsubview) {
            return subsubview;
        }
    }
    return nil;
}

- (UIButton *)descendantButtonWithTitleText:(NSString *)text {
    return (UIButton *)[self subviewPassingTest:^BOOL(UIView *view) {
        return [view isKindOfClass:[UIButton class]] && [[(UIButton *)view titleLabel].text isEqualToString:text];
    }];
}

@end
