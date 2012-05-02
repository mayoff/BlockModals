/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertViewTests.h"
#import "BlockAlertView.h"
#import "UIView+SubviewPassingTest.h"
#import "GenericAlertViewDelegate.h"

@implementation BlockAlertViewTests

+ (void)tearDown {
    // Xcode 4.3.2 and earlier sometimes miss output if the test run exits too quickly.  Grumble.
    usleep(100000);
}

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

- (void)testSetDelegate {
    BlockAlertView *alert = [BlockAlertView new];
    id delegate = [NSObject new];
    alert.delegate = delegate;
    STAssertEquals(delegate, alert.delegate, @"setDelegate: sets delegate");
}

- (void)testSetDelegateToNil {
    BlockAlertView *alert = [BlockAlertView new];
    id delegate = [NSObject new];
    alert.delegate = delegate;
    alert.delegate = nil;
    STAssertEquals((id)nil, (id)alert.delegate, @"setDelegate: sets delegate to nil");
}

- (void)testHandlerIsNilForAddButtonWithTitle {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    STAssertNil([alert buttonHandlerAtIndex:i], @"addButtonWithTitle: sets nil handler");
}

- (void)testSetHandlerForButtonAtIndex {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    BlockAlertViewHandler handler = ^{ NSLog(@"handler"); };
    [alert setHandler:handler forButtonAtIndex:i];
    STAssertEquals(handler, [alert buttonHandlerAtIndex:i], @"setHandler:forButtonAtIndex: sets handler for button added without handler");
}

- (void)testSetHandlerToNilForButtonAtIndex {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button" handler:^{}];
    [alert setHandler:nil forButtonAtIndex:i];
    STAssertNil([alert buttonHandlerAtIndex:i], @"setHandler:forButtonAtIndex: sets handler to nil");
}

- (void)testReplaceHandler {
    BlockAlertView *alert = [BlockAlertView new];
    BlockAlertViewHandler handler0 = ^{ NSLog(@"handler0"); };
    BlockAlertViewHandler handler1 = ^{ NSLog(@"handler1"); };
    NSInteger i = [alert addButtonWithTitle:@"a button" handler:handler0];
    [alert setHandler:handler1 forButtonAtIndex:i];
    STAssertEquals([alert buttonHandlerAtIndex:i], handler1, @"setHandler:forButtonAtIndex: replaces handler");
}

- (void)testAddButtonWithTitleHandler {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    BlockAlertViewHandler handler = ^{ NSLog(@"handler"); };
    NSInteger i = [alert addButtonWithTitle:title handler:handler];
    STAssertEquals([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertEquals([alert buttonHandlerAtIndex:i], handler, @"addButtonWithTitle:handler: sets handler");
}

- (void)testAddButtonWithTitleHandlerNil {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    NSInteger i = [alert addButtonWithTitle:title handler:nil];
    STAssertEquals([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertNil([alert buttonHandlerAtIndex:i], @"addButtonWithTitle:handler: sets handler to nil");
}

- (void)testHandlerCalledForButton0 {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    NSInteger i = [alert addButtonWithTitle:@"button 0" handler:^{
        handler0Called = YES;
    }];
    [alert addButtonWithTitle:@"button 1" handler:^{
        handler1Called = YES;
    }];
    // -[UIAlertView dismissWithClickedButtonIndex:animated:] doesn't send alertView:clickedButtonAtIndex: to the delegate.
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertTrue(handler0Called, @"BlockAlertView invokes handler for button 0");
    STAssertFalse(handler1Called, @"BlockAlertView doesn't invoke handler for button 1");
}

- (void)testHandlerCalledForButton1 {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    [alert addButtonWithTitle:@"button 0" handler:^{
        handler0Called = YES;
    }];
    NSInteger i = [alert addButtonWithTitle:@"button 1" handler:^{
        handler1Called = YES;
    }];
    // -[UIAlertView dismissWithClickedButtonIndex:animated:] doesn't send alertView:clickedButtonAtIndex: to the delegate.
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handler0Called, @"BlockAlertView doesn't invoke handler for button 0");
    STAssertTrue(handler1Called, @"BlockAlertView invokes handler for button 1");
}

- (void)testReplacedHandlerNotCalledForButton {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    NSInteger i = [alert addButtonWithTitle:@"the button" handler:^{
        handler0Called = YES;
    }];
    [alert setHandler:^{
        handler1Called = YES;
    } forButtonAtIndex:i];
    // -[UIAlertView dismissWithClickedButtonIndex:animated:] doesn't send alertView:clickedButtonAtIndex: to the delegate.
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handler0Called, @"BlockAlertView doesn't invoke replaced handler");
    STAssertTrue(handler1Called, @"BlockAlertView invokes replacement handler");
}

- (void)testRemovedHandlerNotCalledForButton {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL handlerCalled = NO;
    NSInteger i = [alert addButtonWithTitle:@"the button" handler:^{
        handlerCalled = YES;
    }];
    [alert setHandler:nil forButtonAtIndex:i];
    // -[UIAlertView dismissWithClickedButtonIndex:animated:] doesn't send alertView:clickedButtonAtIndex: to the delegate.
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handlerCalled, @"BlockAlertView doesn't invoke removed handler");
}

- (void)testDelegateCalledForButtonWithoutHandler {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate new];
    alert.delegate = delegate;
    __block BOOL handlerCalled = NO;
    [alert addButtonWithTitle:@"button 0" handler:^{
        handlerCalled = YES;
    }];
    NSInteger i = [alert addButtonWithTitle:@"button 1"];
    delegate.clickedButtonIndexes_expected = [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
    NSLog(@"button = %@", [alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]]);
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handlerCalled, @"BlockAlertView doesn't invoke button 0 handler");
    [self checkDelegate:delegate];
}

- (void)testDelegateNotCalledForButtonWithHandler {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate new];
    alert.delegate = delegate;
    __block BOOL handlerCalled = NO;
    [alert addButtonWithTitle:@"button 0"];
    NSInteger i = [alert addButtonWithTitle:@"button 1" handler:^{
        handlerCalled = YES;
    }];
    [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertTrue(handlerCalled, @"BlockAlertView invokes button 1 handler");
    [self checkDelegate:delegate];
}

- (void)testDelegateCalledForNonButtonMessages {
    // At least as of iOS 4.3 - iOS 5.1, UIAlertView caches the results of `respondsToSelector:` for all of the delegate messages when the delegate is assigned.  Therefore this test changes out the delegate to make sure that BlockAlertView propertly forces UIAlertView to recache those results.
    
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    NSObject *delegate0 = [[NSObject alloc] init];
    alert.delegate = delegate0;
    
    NSInteger i = [alert addButtonWithTitle:@"the button" handler:^{}];
    
    GenericAlertViewDelegate *delegate1 = [GenericAlertViewDelegate new];
    alert.delegate = delegate1;
    delegate1.willPresentAlertView_expected = YES;
    delegate1.didPresentAlertView_expected = YES;
    delegate1.dismissWithButtonIndexes_expected = [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
    
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
    
    [self checkDelegate:delegate1];
}

#pragma mark - Helpers

- (void)checkDelegate:(GenericAlertViewDelegate *)delegate {
    STAssertEqualObjects(delegate.clickedButtonIndexes_expected, delegate.clickedButtonIndexes_actual, @"clickedButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.dismissWithButtonIndexes_expected, delegate.willDismissWithButtonIndexes_actual, @"willDismissWithButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.dismissWithButtonIndexes_expected, delegate.didDismissWithButtonIndexes_actual, @"didDismissWithButtonIndexes expected equals actual");
    STAssertEquals(delegate.willPresentAlertView_expected, delegate.willPresentAlertView_actual, @"willPresentAlertView expected equals actual");
    STAssertEquals(delegate.didPresentAlertView_expected, delegate.didPresentAlertView_actual, @"didPresentAlertView expected equals actual");
}

@end

