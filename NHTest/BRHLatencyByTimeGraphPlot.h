// BRHLatencyByTimeGraphAveragePlot.h
// NHTest
//
// Copyright (C) 2015 Brad Howes. All rights reserved.

#import "CorePlot-CocoaTouch.h"

@class BRHLatencyByTimeGraph;
@class BRHRecordingInfo;
@class BRHRunDataNotificationInfo;

@interface BRHLatencyByTimeGraphPlot : NSObject <CPTPlotDataSource>

@property (strong, nonatomic) BRHLatencyByTimeGraph* graph;
@property (strong, nonatomic) CPTScatterPlot *plot;
@property (strong, nonatomic) BRHRecordingInfo *recordingInfo;
@property (copy, nonatomic) NSString *sampleValueKey;

- (instancetype)initFor:(BRHLatencyByTimeGraph *)graph;

- (NSRange)getUpdateRangeFrom:(BRHRunDataNotificationInfo *)info;

- (void)update:(BRHRunDataNotificationInfo *)notification;

- (CPTScatterPlot *)makePlot;

- (NSArray *)dataSource;

@end
