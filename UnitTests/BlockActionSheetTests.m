/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import "BlockActionSheetTests.h"
#import "BlockActionSheet.h"
#import "UIView+SubviewPassingTest.h"
#import "GenericActionSheetDelegate.h"

@implementation BlockActionSheetTests

+ (void)tearDown {
    // Xcode 4.3.2 and earlier sometimes miss output if the test run exits too quickly.  Grumble.
    usleep(100000);
}

#pragma mark - Initializers

- (void)testInitWithTitle {
    static NSString *const kTitle = @"test title";
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:kTitle];
    STAssertNotNil(sheet, @"-[BlockActionSheet initWithTitle:] returns an object");
    STAssertTrue([sheet isKindOfClass:[UIActionSheet class]], @"-[BlockActionSheet initWithTitle:] returns a subclass of UIActionSheet");
    STAssertEqualObjects(sheet.title, kTitle, @"-[BlockActionSheet initWithTitle:] sets title correctly");
    STAssertNil(sheet.delegate, @"-[BlockActionSheet initWithTitle:] sets delegate to nil");
    STAssertEquals(sheet.numberOfButtons, 0, @"-[BlockActionSheet initWithTitle:] sets numberOfButtons to zero");
}

#pragma mark - Delegate

- (void)testSetDelegate {
    BlockActionSheet *sheet = [BlockActionSheet new];
    STAssertEquals((id)nil, (id)sheet.delegate, @"delegate is initially nil");
    id delegate = [NSObject new];
    sheet.delegate = delegate;
    STAssertEquals(delegate, sheet.delegate, @"setDelegate: sets delegate");
    sheet.delegate = nil;
    STAssertEquals((id)nil, (id)sheet.delegate, @"setDelegate: sets delegate to nil");
}

- (void)testDelegateWithNoHandlers {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    NSInteger i = [sheet addButtonWithTitle:@"the button"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate delegateExpectingButtonAtIndex:i];
    sheet.delegate = delegate;
    [self showSheet:sheet thenClickButtonAtIndex:i];
    [self checkDelegate:sheet.delegate];
}

- (void)testDelegateWithUnusedHandlers {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger handlerButtonIndex = [sheet addButtonWithTitle:@"button 0" handler:^{
        clickedHandlerCalled = YES;
    }];
    __block BOOL didDismissHandlerCalled = NO;
    [sheet setButtonAtIndex:handlerButtonIndex phase:BlockActionSheetDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    NSInteger delegateButtonIndex = [sheet addButtonWithTitle:@"button 1"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate delegateExpectingButtonAtIndex:delegateButtonIndex];
    sheet.delegate = delegate;
    [self showSheet:sheet thenClickButtonAtIndex:delegateButtonIndex];
    STAssertFalse(clickedHandlerCalled, @"BlockActionSheet doesn't invoke button 0 handler");
    STAssertFalse(didDismissHandlerCalled, @"BlockActionSheet doesn't invoke button 0 handler");
    [self checkDelegate:sheet.delegate];
}

- (void)testDelegateWithClickedHandler {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger i = [sheet addButtonWithTitle:@"button 0" handler:^{
        clickedHandlerCalled = YES;
    }];
    [sheet addButtonWithTitle:@"button 1"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate delegateExpectingDidDismissButtonAtIndex:i];
    sheet.delegate = delegate;
    [self showSheet:sheet thenClickButtonAtIndex:i];
    STAssertTrue(clickedHandlerCalled, @"BlockActionSheet calls clicked handler");
    [self checkDelegate:sheet.delegate];
}

- (void)testDelegateWithDidDismissHandler {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL didDismissHandlerCalled = NO;
    NSInteger i = [sheet addButtonWithTitle:@"button 0" phase:BlockActionSheetDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    [sheet addButtonWithTitle:@"button 1"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate delegateExpectingClickedButtonAtIndex:i];
    sheet.delegate = delegate;
    [self showSheet:sheet thenClickButtonAtIndex:i];
    STAssertTrue(didDismissHandlerCalled, @"BlockActionSheet calls didDismiss handler");
    [self checkDelegate:sheet.delegate];
}

- (void)testDelegateWithBothHandlers {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    [sheet addButtonWithTitle:@"button 0"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger i = [sheet addButtonWithTitle:@"button 1" handler:^{
        clickedHandlerCalled = YES;
    }];
    __block BOOL didDismissHandlerCalled = NO;
    [sheet setButtonAtIndex:i phase:BlockActionSheetDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate delegateExpectingNoButtonAtIndex:i];
    sheet.delegate = delegate;
    [self showSheet:sheet thenClickButtonAtIndex:i];
    STAssertTrue(clickedHandlerCalled, @"BlockActionSheet calls clicked handler");
    STAssertTrue(didDismissHandlerCalled, @"BlockActionSheet calls didDismiss handler");
    [self checkDelegate:sheet.delegate];
}

- (void)testReplacedDelegateIsCalled {
    // At least as of iOS 4.3 - iOS 5.1, UIActionSheet caches the results of `respondsToSelector:` for all of the delegate messages when the delegate is assigned.  Therefore this test changes out the delegate to make sure that BlockActionSheet propertly forces UIActionSheet to recache those results.
    
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    NSObject *delegate0 = [NSObject new];
    sheet.delegate = (id)delegate0;
    
    NSInteger i = [sheet addButtonWithTitle:@"the button" handler:^{}];
    
    GenericActionSheetDelegate *delegate1 = [GenericActionSheetDelegate delegateExpectingDidDismissButtonAtIndex:i];
    sheet.delegate = delegate1;
    
    [self showSheet:sheet thenClickButtonAtIndex:i];    
    [self checkDelegate:delegate1];
}

#pragma mark - Handlers

- (void)testHandlersAreNilForAddButtonWithTitle {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"addButtonWithTitle: sets nil handler for clicked phase");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"addButtonWithTitle: sets nil handler for didDismiss phase");
}

- (void)testSetClickedHandlerForButtonAtIndex {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    BlockActionSheetHandler handler = ^{ NSLog(@"handler"); };
    [sheet setButtonAtIndex:i phase:BlockActionSheetClickedPhase handler:handler];
    STAssertEquals(handler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler sets clicked handler for button added without handler");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler doesn't set didDismiss handler for button added without handler");
}

- (void)testSetDidDismissHandlerForButtonAtIndex {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    BlockActionSheetHandler handler = ^{ NSLog(@"handler"); };
    [sheet setButtonAtIndex:i phase:BlockActionSheetDidDismissPhase handler:handler];
    STAssertEquals(handler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler sets didDismiss handler for button added without handler");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler doesn't set clicked handler for button added without handler");
}

- (void)testSetBothHandlersForButtonAtIndex {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    BlockActionSheetHandler clickedHandler = ^{ NSLog(@"clicked"); };
    BlockActionSheetHandler didDismissHandler = ^{ NSLog(@"didDismiss"); };
    [sheet setButtonAtIndex:i phase:BlockActionSheetClickedPhase handler:clickedHandler];
    [sheet setButtonAtIndex:i phase:BlockActionSheetDidDismissPhase handler:didDismissHandler];
    STAssertEquals(clickedHandler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler: sets clicked handler");
    STAssertEquals(didDismissHandler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler: sets didDismiss handler");
    
    BlockActionSheetHandler clickedHandler2 = ^{ NSLog(@"clicked 2"); };
    BlockActionSheetHandler didDismissHandler2 = ^{ NSLog(@"didDismiss 2"); };
    
    [sheet setButtonAtIndex:i phase:BlockActionSheetClickedPhase handler:clickedHandler2];
    STAssertEquals(clickedHandler2, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler: replaces clicked handler");
    STAssertEquals(didDismissHandler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler: doesn't modify didDismiss handler");
    
    [sheet setButtonAtIndex:i phase:BlockActionSheetDidDismissPhase handler:didDismissHandler2];
    STAssertEquals(clickedHandler2, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler: doesn't modify clicked handler");
    STAssertEquals(didDismissHandler2, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler: replaces didDismiss handler");
    
    [sheet setButtonAtIndex:i phase:BlockActionSheetClickedPhase handler:nil];
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler: sets clicked handler to nil");
    STAssertEquals(didDismissHandler2, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler: doesn't modify didDismiss handler");
    
    [sheet setButtonAtIndex:i phase:BlockActionSheetDidDismissPhase handler:nil];
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"setButtonAtIndex:phase:handler: doesn't modify clicked handler to nil");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"setButtonAtIndex:phase:handler: sets didDismiss handler to nil");
}

- (void)testAddButtonWithTitleHandler {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    BlockActionSheetHandler handler = ^{ NSLog(@"handler"); };
    NSInteger i = [sheet addButtonWithTitle:title handler:handler];
    STAssertEqualObjects([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertEquals([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], handler, @"addButtonWithTitle:handler: sets clicked handler");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"addButtonWithTitle:handler: doesn't set didDismiss handler");
}

- (void)testAddButtonWithTitleHandlerNil {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    NSInteger i = [sheet addButtonWithTitle:title handler:nil];
    STAssertEquals([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"addButtonWithTitle:handler: sets clicked handler to nil");
}

- (void)testAddButtonWithTitleClickedPhaseHandler {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    BlockActionSheetHandler handler = ^{ NSLog(@"didDismiss handler"); };
    NSInteger i = [sheet addButtonWithTitle:title phase:BlockActionSheetClickedPhase handler:handler];
    STAssertEqualObjects([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:phase:handler: sets title");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"addButtonWithTitle:phase:handler: sets didDismiss handler to nil");
    STAssertEquals(handler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"addButtonWithTitle:phase:handler: sets clicked handler");
}

- (void)testAddButtonWithTitleDidDismissPhaseHandler {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    BlockActionSheetHandler handler = ^{ NSLog(@"didDismiss handler"); };
    NSInteger i = [sheet addButtonWithTitle:title phase:BlockActionSheetDidDismissPhase handler:handler];
    STAssertEqualObjects([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:phase:handler: sets title");
    STAssertNil([sheet buttonHandlerAtIndex:i phase:BlockActionSheetClickedPhase], @"addButtonWithTitle:phase:handler: sets clicked handler to nil");
    STAssertEquals(handler, [sheet buttonHandlerAtIndex:i phase:BlockActionSheetDidDismissPhase], @"addButtonWithTitle:phase:handler: sets didDismiss handler");
}

#pragma mark - Helpers

- (void)checkDelegate:(GenericActionSheetDelegate *)delegate {
    STAssertEqualObjects(delegate.clickedButtonIndexes_expected, delegate.clickedButtonIndexes_actual, @"clickedButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.willDismissWithButtonIndexes_expected, delegate.willDismissWithButtonIndexes_actual, @"willDismissWithButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.didDismissWithButtonIndexes_expected, delegate.didDismissWithButtonIndexes_actual, @"didDismissWithButtonIndexes expected equals actual");
    STAssertEquals(delegate.willPresentActionSheet_expected, delegate.willPresentActionSheet_actual, @"willPresentActionSheet expected equals actual");
    STAssertEquals(delegate.didPresentActionSheet_expected, delegate.didPresentActionSheet_actual, @"didPresentActionSheet expected equals actual");
}

- (void)showSheet:(UIActionSheet *)sheet thenClickButtonAtIndex:(NSInteger)buttonIndex {
    [sheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:buttonIndex]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
}

@end
