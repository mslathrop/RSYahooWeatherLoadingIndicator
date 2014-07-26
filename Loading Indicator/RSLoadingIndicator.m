//
//  RSLoadingIndicator.m
//  Sample
//
//  Created by R0CKSTAR on 7/1/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSLoadingIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface RSLoadingIndicator () {
    CGFloat _startAngle; // Start angle of the cycle, never changed
    CGFloat _endAngle; // End angle of the cycle
    CGFloat _startY; // Line start y
    CGFloat _spring; // Current spring
    NSInteger _springDirection; // Sprint direction +/-
    NSInteger _counter; // Counter, used for rotation
    NSInteger _lineWidth; // Counter, used for rotation
    NSTimer *_loadingIndicatorTimer;
}

@end

@implementation RSLoadingIndicator
float Radian2Degree(float radian) {
    return ((radian / M_PI) * 180.0f);
}

float Degree2Radian(float degree) {
    return ((degree / 180.0f) * M_PI);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        
        center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        radius = 10;
        arrowEdgeLength = 10;
        radianceDegree = 30;
        radianceOffset = 0;
        radianceMinLength = 10;
        radianceMaxLength = 30;
        sprintMax = 1;
        rotationSpeed = 1.0f;
        
        _startAngle = -90;
        _endAngle = -90;
        _startY = -(2.0f * M_PI * radius);
        _spring = 0;
        _springDirection = 0;
        _lineWidth = 4;
    }
    
    return self;
}

- (void)didScroll:(float)offset {
    if (_startY == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(startLoading)]) {
            [_delegate startLoading];
        }
        
        _startY = 1;
    } else if (_startY == 1) {
        if (_counter == (NSUIntegerMax - 1)) {
            _counter = 0;
        }
        
        _counter++;
        [self setNeedsDisplay];
    } else {
        _startY += offset;
        float deltaAngle = Radian2Degree(offset / radius);
        _endAngle += deltaAngle;
        
        if (roundf(_startY) >= 0) {
            _endAngle = 270;
            _startY = 0;
        }
        
        [self setNeedsDisplay];
    }
}

- (void)setRadius:(NSInteger)aRadius minLength:(NSInteger)aMinLength maxLength:(NSInteger)aMaxLength lineWidth:(NSInteger)aLineWidth {
    radius = aRadius;
    radianceMinLength = aMinLength;
    radianceMaxLength = aMaxLength;
    _lineWidth = aLineWidth;
}

- (void)startLoading {
    if (!_loadingIndicatorTimer) {
        _loadingIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f / 33.0f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
}

- (void)tick {
    [self didScroll:1000.0f];
}

- (void)stopLoading {
    _endAngle = -90;
    _startY = -(2.0f * M_PI * radius);
    [self setNeedsDisplay];
    
    [_loadingIndicatorTimer invalidate];
    _loadingIndicatorTimer = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(stopLoading)]) {
        [_delegate stopLoading];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    CGContextBeginPath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, _lineWidth);
    
    // draw the center circle
    CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
    CGContextAddArc(ctx, center.x, center.y, radius - 2, startAngle, endAngle, 0);
    CGContextStrokePath(ctx);
    
    // under here is where the sun rays move
    CGContextTranslateCTM(ctx, center.x, center.y);
    
    for (int i = 0; i < (Radian2Degree(M_PI * 2) / radianceDegree); i++) {
        if (i > 0) {
            CGContextRotateCTM(ctx, Degree2Radian(radianceDegree));
        } else {
            CGContextRotateCTM(ctx, Degree2Radian(_counter * rotationSpeed));
        }
        
        if (_springDirection == 0) {
            _spring += 0.01f;
            
            if (_spring >= sprintMax) {
                _springDirection = 1;
            }
        }
        
        if (_springDirection == 1) {
            _spring -= 0.01f;
            
            if (_spring <= 0) {
                _springDirection = 0;
            }
        }
        
        if (i % 2 == 1) {
            CGContextMoveToPoint(ctx, 0, -radius - radianceOffset - radianceMinLength + _spring);
            CGContextAddLineToPoint(ctx, 0, -radius - radianceOffset - radianceMaxLength - _spring);
        } else {
            CGContextMoveToPoint(ctx, 0, -radius - radianceOffset - radianceMinLength - _spring);
            CGContextAddLineToPoint(ctx, 0, -radius - radianceOffset - radianceMaxLength + _spring);
        }
    }
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
}

@end
