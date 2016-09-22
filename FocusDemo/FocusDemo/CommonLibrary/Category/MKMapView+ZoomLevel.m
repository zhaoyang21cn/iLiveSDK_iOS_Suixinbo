//
//  MKMapView+ZoomLevel.m
//  CommonLibrary
//
//  Created by Alexi on 14-11-17.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#if kSupportMKMapViewZoomLevel
#import "MKMapView+ZoomLevel.h"
#import <objc/runtime.h>

@implementation MKMapView (ZoomLevel)


#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

//static NSString *const kMKMapViewZoomLevel = @"kMKMapViewZoomLevel";
//
//- (NSUInteger)zoomLevel
//{
//	return objc_getAssociatedObject(self, (__bridge const void *)kMKMapViewZoomLevel);
//}
//
//- (void)setZoomLevel:(NSUInteger)zoomLevel
//{
//	objc_setAssociatedObject(self, (__bridge const void *)kMKMapViewZoomLevel, kMKMapViewZoomLevel, OBJC_ASSOCIATION_ASSIGN);
//}


#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    return;
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, kMKMapViewMaxZoomLevel);
    
    zoomLevel = MAX(kMKMapViewMinZoomLevel, zoomLevel);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    MKCoordinateRegion regf = [self regionThatFits:region];

    [self setRegion:regf animated:animated];
}

- (void)setZoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [self centerCoordinate];
    [self setCenterCoordinate:center zoomLevel:zoomLevel animated:animated];
}

- (void)setZoomLevel:(NSUInteger)zoomLevel
{
    [self setZoomLevel:zoomLevel animated:YES];
}
@end
#endif