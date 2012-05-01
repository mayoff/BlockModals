/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertView.h"

@implementation BlockAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}

- (BlockAlertViewHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex {
    return nil;
}

- (void)setHandler:(BlockAlertViewHandler)handler forButtonAtIndex:(NSInteger)buttonIndex {
}

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockAlertViewHandler)handler {
    return -1;
}

@end
