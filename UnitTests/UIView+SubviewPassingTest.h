/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <UIKit/UIKit.h>

@interface UIView (SubviewPassingTest)

// I return as subview for which `test(subview)` is YES.  I return nil if I have no such subview.
- (UIView *)subviewPassingTest:(BOOL (^)(UIView *))test;

// I return a descendant button whose title text is `text`.  I return nil if I have no such descendant button.
- (UIButton *)descendantButtonWithTitleText:(NSString *)text;

@end
