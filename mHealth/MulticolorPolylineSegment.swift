//
//  MulticolorPolylineSegment.swift
//  MoonRunner
//
//  Created by Spitfire on 28.02.17.
//  Copyright © 2017 Zedenem. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MulticolorPolylineSegment: MKPolyline {
    var color: UIColor?
    
    private class func allSpeeds(forLocations locations: [Location]) ->
        (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
            // Make Array of all speeds. Find slowest and fastest
            var speeds = [Double]()
            var minSpeed = DBL_MAX
            var maxSpeed = 0.0
            
            for i in 1..<locations.count {
                let l1 = locations[i-1]
                let l2 = locations[i]
                
                let cl1 = CLLocation(latitude: l1.latitude.doubleValue, longitude: l1.longitude.doubleValue)
                let cl2 = CLLocation(latitude: l2.latitude.doubleValue, longitude: l2.longitude.doubleValue)
                
                let distance = cl2.distance(from: cl1)
                let time = l2.timestamp.timeIntervalSince(l1.timestamp)
                let speed = distance/time
                
                minSpeed = min(minSpeed, speed)
                maxSpeed = max(maxSpeed, speed)
                
                speeds.append(speed)
            }
            
            return (speeds, minSpeed, maxSpeed)
    }
    
    private class func allSpeeds(forFirebaseRun FirebaseRun: FirebaseRun) ->
        (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
            // Make Array of all speeds. Find slowest and fastest
            var speeds = [Double]()
            var minSpeed = DBL_MAX
            var maxSpeed = 0.0
            
            for i in 1...FirebaseRun.latitudes.count-1{
                let loc1: Int = i-1
                let loc2: Int = i
                
                let lat1 = FirebaseRun.latitudes[loc1]
                let lat2 = FirebaseRun.latitudes[loc2]
                let long1 = FirebaseRun.longitudes[loc1]
                let long2 = FirebaseRun.longitudes[loc2]
                
                let cl1 = CLLocation(latitude: lat1, longitude: long1)
                let cl2 = CLLocation(latitude: lat2, longitude: long2)
                
                let distance = cl2.distance(from: cl1)
                let time = Util.timeInterval(from: FirebaseRun.timestamps[loc1], to: FirebaseRun.timestamps[loc2])
                
                let speed = distance/time
                
                minSpeed = min(minSpeed, speed)
                maxSpeed = max(maxSpeed, speed)
                speeds.append(speed)
            }
            return (speeds, minSpeed, maxSpeed)
    }
    
    
    class func colorSegments(forLocations locations: [Location]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()
        
        // RGB for Red (slowest)
        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
        
        // RGB for Yellow (middle)
        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
        
        // RGB for Green (fastest)
        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
        
        let (speeds, minSpeed, maxSpeed) = allSpeeds(forLocations: locations)
        
        var totalSpeeds = 0.0
        for speed in speeds{
            totalSpeeds+=speed
        }
        let meanSpeed = totalSpeeds/Double(speeds.count)
        
        for i in 1..<locations.count {
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            var coords = [CLLocationCoordinate2D]()
            
            coords.append(CLLocationCoordinate2D(latitude: l1.latitude.doubleValue, longitude: l1.longitude.doubleValue))
            coords.append(CLLocationCoordinate2D(latitude: l2.latitude.doubleValue, longitude: l2.longitude.doubleValue))
            
            let speed = speeds[i-1]
            var color = UIColor.black
            
            if speed < (meanSpeed-(meanSpeed*0.1)) { // Between Red & Yellow
                let ratio = (speed - (meanSpeed-(meanSpeed*0.1))) / (meanSpeed - minSpeed)
                let r = CGFloat(red.r + ratio * (yellow.r - red.r))
                let g = CGFloat(red.g + ratio * (yellow.g - red.g))
                let b = CGFloat(red.b + ratio * (yellow.b - red.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            else { // Between Yellow & Green
                var ratio = ((speed) - meanSpeed) / (maxSpeed - meanSpeed)
                if ratio > 1{
                    ratio=1
                }
                let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
                let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
                let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }

            
            let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
            segment.color = color
            colorSegments.append(segment)
        }
        
        return colorSegments
    }
    
    class func colorSegments(forLocations FirebaseRun: FirebaseRun) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()
        
        // RGB for Red (slowest)
        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
        
        // RGB for Yellow (middle)
        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
        
        // RGB for Green (fastest)
        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
        
        let (speeds, minSpeed, maxSpeed) = allSpeeds(forFirebaseRun: FirebaseRun)
        
        var totalSpeeds = 0.0
        for speed in speeds{
            totalSpeeds+=speed
        }
        let meanSpeed = totalSpeeds/Double(speeds.count)
        
        for i in 1...FirebaseRun.latitudes.count-1{
            let lat1 = FirebaseRun.latitudes[i-1]
            let lat2 = FirebaseRun.latitudes[i]
            let long1 = FirebaseRun.longitudes[i-1]
            let long2 = FirebaseRun.longitudes[i]
            
            
            var coords = [CLLocationCoordinate2D]()
            
            coords.append(CLLocationCoordinate2D(latitude: lat1, longitude: long1))
            coords.append(CLLocationCoordinate2D(latitude: lat2, longitude: long2))
                let speed = speeds[i-1]
                var color = UIColor.darkGray
                
                if speed < (meanSpeed-(meanSpeed*0.1)) { // Between Red & Yellow
                    let ratio = (speed - (meanSpeed-(meanSpeed*0.1))) / (meanSpeed - minSpeed)
                    let r = CGFloat(red.r + ratio * (yellow.r - red.r))
                    let g = CGFloat(red.g + ratio * (yellow.g - red.g))
                    let b = CGFloat(red.b + ratio * (yellow.b - red.b))
                    color = UIColor(red: r, green: g, blue: b, alpha: 1)
                }
                else { // Between Yellow & Green
                    var ratio = ((speed) - meanSpeed) / (maxSpeed - meanSpeed)
                    if ratio > 1{
                        ratio=1
                    }
                    let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
                    let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
                    let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
                    color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
            segment.color = color
            colorSegments.append(segment)
        }
        return colorSegments
    }
}
