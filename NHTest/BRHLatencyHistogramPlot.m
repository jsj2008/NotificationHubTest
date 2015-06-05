// BRHCountBars.m
// NHTest
//
// Copyright (C) 2015 Brad Howes. All rights reserved.

#import "BRHBinFormatter.h"
#import "BRHLatencyHistogramPlot.h"
#import "BRHHistogram.h"
#import "BRHLogger.h"
#import "BRHRunData.h"

static NSString* const kHistogramPlot = @"Histogram";
static void* kKVOContext = &kKVOContext;

@interface BRHLatencyHistogramPlot () <CPTPlotDataSource, CPTBarPlotDelegate>

@property (strong, nonatomic) BRHHistogram *dataSource;
@property (strong, nonatomic) CPTPlotSpaceAnnotation *annotation;
@property (assign, nonatomic) NSUInteger annotationIndex;

- (void)makePlot;
- (void)update:(NSNotification *)notification;
- (void)updateBounds;

@end

@implementation BRHLatencyHistogramPlot

- (void)initialize:(BRHHistogram *)dataSource
{
    if (self.annotation != nil) {
        [self.hostedGraph.plotAreaFrame.plotArea removeAnnotation:self.annotation];
        self.annotation = nil;
    }

    if (self.dataSource) {
        [self.dataSource removeObserver:self forKeyPath:@"lastBin"];
    }

    self.dataSource = dataSource;

    if (! self.hostedGraph) {
        [self makePlot];
    }
    else {
        [self redraw];
    }

    [self.dataSource addObserver:self forKeyPath:@"lastBin" options:NSKeyValueObservingOptionNew context:kKVOContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:BRHRunDataNewDataNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kKVOContext) {
        if ([keyPath isEqualToString:@"lastBin"] && self.dataSource.maxCount.integerValue == 0) {
            [self updateBounds];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)makePlot
{
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    self.hostedGraph = graph;
    // [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    graph.paddingTop = 0.0f;
    graph.paddingLeft = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.paddingRight = 0.0f;
    
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius = 0.0f;

    graph.plotAreaFrame.paddingTop = 10.0;
    graph.plotAreaFrame.paddingLeft = 30.0;
    graph.plotAreaFrame.paddingBottom = 35.0;
    graph.plotAreaFrame.paddingRight = 10.0;

    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 0.75;
    axisLineStyle.lineColor = [CPTColor colorWithGenericGray:0.45];

    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineWidth = 0.75;
    gridLineStyle.lineColor = [CPTColor colorWithGenericGray:0.25];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineWidth = 0.75;
    tickLineStyle.lineColor = [CPTColor colorWithGenericGray:0.45];

    CPTMutableTextStyle *labelStyle = [CPTMutableTextStyle textStyle];
    labelStyle.color = [CPTColor colorWithGenericGray:0.75];
    labelStyle.fontSize = 12.0f;

    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor colorWithGenericGray:0.75];
    titleStyle.fontSize = 11.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.identifier = kHistogramPlot;
    plotSpace.allowsUserInteraction = NO;

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

    // X Axis
    //
    CPTXYAxis *x = axisSet.xAxis;
    x.titleTextStyle = titleStyle;
    x.title = @"Histogram (1s bin)";
    x.titleOffset = 18.0;

    x.axisLineStyle = nil;

    x.labelTextStyle = labelStyle;
    x.labelOffset = -4.0;

    x.tickDirection = CPTSignNegative;
    x.majorTickLineStyle = tickLineStyle;
    x.majorTickLength = 5.0;
    x.majorIntervalLength = CPTDecimalFromInt(5);

    x.minorTickLineStyle = tickLineStyle;
    x.minorTickLength = 3.0;
    x.minorTicksPerInterval = 4;

    // Y Axis
    //
    CPTXYAxis *y = axisSet.yAxis;
    y.titleTextStyle = nil;
    y.title = nil;

    y.axisLineStyle = nil;

    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = labelStyle;
    y.labelOffset = 16.0;
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMaximumFractionDigits:3];
    y.labelFormatter = formatter;

    y.tickDirection = CPTSignNegative;
    y.majorTickLineStyle = nil;
    y.majorTickLength = 0;
    y.preferredNumberOfMajorTicks = 5;

    y.minorTickLineStyle = nil;

    y.majorGridLineStyle = gridLineStyle;
    y.minorGridLineStyle = nil;

    CPTBarPlot *plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor cyanColor] horizontalBars:NO];
    //plot.barWidth = CPTDecimalFromFloat(0.7);
    plot.identifier = kHistogramPlot;
    plot.dataSource = self;
    plot.delegate = self;
    [graph addPlot:plot toPlotSpace:plotSpace];

    [self updateBounds];

#if 0
    for (int z = 0; z < 13; ++z)
        [self.dataSource addValue:0.5];

    [self.dataSource addValue:1];
    [self.dataSource addValue:1];
    [self.dataSource addValue:1];

    [self.dataSource addValue:2];
    [self.dataSource addValue:2];
    [self.dataSource addValue:2];
    [self.dataSource addValue:2];
    [self.dataSource addValue:2];

    [self.dataSource addValue:28];
    [self.dataSource addValue:29];
    [self.dataSource addValue:30];
    [self.dataSource addValue:30];
    [self.dataSource addValue:31];
    [self.dataSource addValue:32];
    [self.dataSource addValue:33];
    [self.dataSource addValue:34];
    [self.dataSource addValue:35];

    // [plotSpace scaleToFitPlots: graph.allPlots];
    [self updateBounds];
#endif
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateBounds];
}

- (void)redraw
{
    [self.hostedGraph.allPlots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        [obj setDataNeedsReloading];
    }];
    [self updateBounds];
}

- (void)renderPDF:(CGContextRef)pdfContext
{
    CPTLayer *graph = self.hostedGraph;
    CGRect mediaBox = CPTRectMake(0, 0, graph.bounds.size.width, graph.bounds.size.height);
    CGContextBeginPage(pdfContext, &mediaBox);
    [graph layoutAndRenderInContext:pdfContext];
    CGContextEndPage(pdfContext);
}

- (void)updateBounds
{
    NSUInteger lastBin = self.dataSource.lastBin;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.hostedGraph.defaultPlotSpace;
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(-1) length:CPTDecimalFromInteger(lastBin + 1)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(-1) length:CPTDecimalFromInteger(lastBin + 1)];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.hostedGraph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.labelFormatter = [BRHBinFormatter binFormatterWithLastBin:lastBin];
    x.visibleRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(lastBin + 1)];
    CPTXYAxis *y = axisSet.xAxis;
    y.gridLinesRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromInteger(-1) length:CPTDecimalFromInteger(lastBin + 1)];

    NSUInteger max = floor((MAX(self.dataSource.maxCount.integerValue, 5) + 4) / 5) * 5;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(max)];
}

- (void)update:(NSNotification *)notification
{
    NSUInteger bin = [notification.userInfo[@"bin"] unsignedIntegerValue];
    [self.hostedGraph.allPlots[0] reloadDataInIndexRange:NSMakeRange(bin, 1)];

    if (self.annotation != nil && self.annotationIndex == bin) {
        CPTTextLayer *textLayer = (CPTTextLayer *)self.annotation.contentLayer;
        NSUInteger count = [self.dataSource binAtIndex:bin].unsignedIntegerValue;
        textLayer.text = [NSString stringWithFormat:@"%ld", (unsigned long)count];
    }
    
    [self updateBounds];
}

#pragma mark Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.dataSource.lastBin + 1;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = [NSDecimalNumber zero];

    switch (fieldEnum) {
        case CPTBarPlotFieldBarLocation:
            num = [NSNumber numberWithUnsignedInteger:index];
            break;

        case CPTBarPlotFieldBarTip:
            num = [self.dataSource binAtIndex:index];
            break;
                
        default:
            break;
    }
    
    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    return NO;
}

#pragma mark -
#pragma mark Plot Delegate Methods

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    if (self.annotation != nil) {
        [self.hostedGraph.plotAreaFrame.plotArea removeAnnotation:self.annotation];
        self.annotation = nil;
        if (index == self.annotationIndex) {
            return;
        }
    }
    
    self.annotationIndex = index;
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%ld", (long)[[self.dataSource binAtIndex:index] integerValue]] style:hitAnnotationTextStyle];
    NSNumber *x = [NSNumber numberWithInteger:index];
    NSNumber *y = [NSNumber numberWithInteger:0];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    self.annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    self.annotation.contentLayer = textLayer;
    self.annotation.displacement = CGPointMake(-0.5, 10.0);
    
    [self.hostedGraph.plotAreaFrame.plotArea addAnnotation:self.annotation];
}

@end