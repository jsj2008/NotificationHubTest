// BRHMainController.h
// NHTest
//
// Copyright (C) 2015 Brad Howes. All rights reserved.

#import <UIKit/UIKit.h>

@class BRHDropboxUploader;
@class BRHLatencyHistogramGraph;
@class BRHLatencyByTimeGraph;
@class BRHRecordingInfo;
@class BRHRecordingsViewController;
@class BRHSettingsViewDelegate;
@class BRHRunData;
@class IASKAppSettingsViewController;

@interface BRHMainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *recordingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (strong, nonatomic) IBOutlet BRHLatencyByTimeGraph *latencyPlot;
@property (strong, nonatomic) IBOutlet BRHLatencyHistogramGraph *countBars;
@property (strong, nonatomic) IBOutlet UITextView *logView;
@property (strong, nonatomic) IBOutlet UITextView *eventsView;
@property (strong, nonatomic) IBOutlet UIView *recordingsView;

@property (strong, nonatomic) BRHRecordingsViewController *recordingsViewController;
@property (strong, nonatomic) IASKAppSettingsViewController *settingsViewController;
@property (strong, nonatomic) BRHSettingsViewDelegate *settingsViewDelegate;
@property (strong, nonatomic) BRHDropboxUploader *dropboxUploader;

@property (strong, nonatomic) BRHRecordingInfo *recordingInfo;

- (IBAction)startStop:(id)sender;
- (IBAction)showHideLogView:(id)sender;
- (IBAction)showHideEventsView:(id)sender;
- (IBAction)showHideRecordingsView:(id)sender;
- (IBAction)showSettings:(id)sender;

- (void)start;
- (void)stop;

@end
