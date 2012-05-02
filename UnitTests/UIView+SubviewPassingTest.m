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

- (UIControl *)descendantControlWithTitle:(NSString *)title {
    return (UIControl *)[self subviewPassingTest:^BOOL(UIView *view) {
        id object = view;
        if (![object isKindOfClass:[UIControl class]])
            return NO;
        if ([object respondsToSelector:@selector(titleLabel)] && [[object titleLabel] respondsToSelector:@selector(text)] && [[object titleLabel].text isEqualToString:title])
            return YES;
        if ([object respondsToSelector:@selector(title)] && [[object title] isEqualToString:title])
            return YES;
        return NO;
    }];
}

@end
