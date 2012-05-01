/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertViewTests.h"
#import "BlockAlertView.h"

@implementation BlockAlertViewTests

- (void)testInitWithTitleMessage {
    static NSString *const kTitle = @"test title";
    static NSString *const kMessage = @"test message";
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:kTitle message:kMessage];
    STAssertNotNil(alert, @"-[BlockAlertView initWithTitle:message:] returns an object");
    STAssertTrue([alert isKindOfClass:[UIAlertView class]], @"-[BlockAlertView initWithTitle:message:] returns a subclass of UIAlertView");
    STAssertEqualObjects(alert.title, kTitle, @"-[BlockAlertView initWithTitle:message:] sets title correctly");
    STAssertEqualObjects(alert.message, kMessage, @"-[BlockAlertView initWithTitle:message:] sets message correctly");
    STAssertNil(alert.delegate, @"-[BlockAlertView initWithTitle:message:] sets delegate to nil");
    STAssertEquals(alert.numberOfButtons, 0, @"-[BlockAlertView initWithTitle:message:] sets numberOfButtons to zero");
}

@end
