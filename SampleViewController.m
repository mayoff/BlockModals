/*
Created by Rob Mayoff on 5/8/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "SampleViewController.h"

typedef void (^UIActionSheetHandler)(void);

typedef enum {
    UIActionSheetClickedPhase,
    UIActionSheetDidDismissPhase
} UIActionSheetPhase;

@interface UIActionSheet (Blocks)

- (id)initWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler;
- (NSInteger)addButtonWithTitle:(NSString *)title phase:(UIActionSheetPhase)phase handler:(void (^)(void))handler;

@end

@interface SampleViewController () <UIActionSheetDelegate>

@end

#if 0
@implementation SampleViewController

// adapted from https://github.com/keithferns/Programming/blob/23cfe542a901694197f30994fa5fde060cd14e48/miMemo/miMemo/MyMemosViewController.m

- (IBAction)showGoToSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Go To…" delegate:self cancelButtonTitle:@"Stay Here" destructiveButtonTitle:nil otherButtonTitles:@"Folders", @"Appointments", @"Tasks", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1: [self presentFolders]; break;
        case 2: [self presentAppointments]; break;
        case 3: [self presentTasks]; break;
    }
}

@end
#endif

#if 0
@implementation SampleViewController {
    NSInteger _foldersButtonIndex;
    NSInteger _appointmentsButtonIndex;
    NSInteger _tasksButtonIndex;
}

- (IBAction)showGoToSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Go To…" delegate:self cancelButtonTitle:@"Stay Here" destructiveButtonTitle:nil otherButtonTitles:nil];
    _foldersButtonIndex = [sheet addButtonWithTitle:@"Folders"];
    _appointmentsButtonIndex = [sheet addButtonWithTitle:@"Appointments"];
    _tasksButtonIndex = [sheet addButtonWithTitle:@"Tasks"];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == _foldersButtonIndex) {
        [self presentFolders];
    } else if (buttonIndex == _appointmentsButtonIndex) {
        [self presentAppointments];
    } else if (buttonIndex == _tasksButtonIndex) {
        [self presentTasks];
    }
}

@end
#endif

#if 0

@implementation SampleViewController

- (IBAction)showGoToSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Go To…"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Stay Here"];
    [sheet addButtonWithTitle:@"Folders" handler:^{ [self presentFolders]; }];
    [sheet addButtonWithTitle:@"Appointments" handler:^{ [self presentAppointments]; }];
    [sheet addButtonWithTitle:@"Tasks" handler:^{ [self presentTasks]; }];
    [sheet showInView:self.view];
}

@end

#endif

#if 1

@implementation SampleViewController

- (IBAction)showGoToSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Go To…"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Stay Here"];
    [sheet addButtonWithTitle:@"Folders" phase:UIActionSheetDidDismissPhase handler:^{ [self presentFolders]; }];
    [sheet addButtonWithTitle:@"Appointments" phase:UIActionSheetDidDismissPhase handler:^{ [self presentAppointments]; }];
    [sheet addButtonWithTitle:@"Tasks" phase:UIActionSheetDidDismissPhase handler:^{ [self presentTasks]; }];
    [sheet showInView:self.view];
}

@end

#endif

#if 0
@implementation SampleViewController {
    NSSet *_allParticipants;
    NSString *_sender;
    NSSet *_replyRecipients;
}

- (IBAction)showReplySheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Don't Reply"];
    [sheet addButtonWithTitle:@"Reply to All" handler:^{
        _replyRecipients = _allParticipants;
    }];
    [sheet addButtonWithTitle:@"Reply to Sender" handler:^{
        _replyRecipients = [NSSet setWithObject:_sender];
    }];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self presentReplyViewControllerWithRecipients:_replyRecipients];
}

- (void)presentReplyViewControllerWithRecipients:(id)r { }

@end
#endif

#if 0
@implementation SampleViewController {
    NSSet *_allParticipants;
    NSString *_sender;
    NSSet *_replyRecipients;
}

- (IBAction)showReplySheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Don't Reply"];
    [sheet addButtonWithTitle:@"Reply to All" phase:UIActionSheetDidDismissPhase handler:^{
        [self presentReplyViewControllerWithRecipients:_allParticipants];
    }];
    [sheet addButtonWithTitle:@"Reply to Sender" phase:UIActionSheetDidDismissPhase handler:^{
        [self presentReplyViewControllerWithRecipients:[NSSet setWithObject:_sender]];
    }];
    [sheet showInView:self.view];
}

- (void)presentReplyViewControllerWithRecipients:(id)r { }

@end
#endif


