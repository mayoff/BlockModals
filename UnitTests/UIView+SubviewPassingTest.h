/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import <UIKit/UIKit.h>

@interface UIView (SubviewPassingTest)

// I return as subview for which `test(subview)` is YES.  I return nil if I have no such subview.
- (UIView *)subviewPassingTest:(BOOL (^)(UIView *))test;

// I return a descendant control that has a title property whose value is equal to `title`, or a `textLabel.text` property whose value is equal to `title`.  I return nil if I have no such descendant.  I need this because in iOS 4.3, UIAlertView and UIActionSheet use a private subclass of `UIControl` that has a `title` property, but in iOS 5.0, they use a private subclass of `UIButton`.
- (UIControl *)descendantControlWithTitle:(NSString *)title;

@end
