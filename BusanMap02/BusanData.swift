//
//  BusanData.swift
//  BusanMap02
//
//  Created by 정인교 on 30/10/2018.
//  Copyright © 2018 정인교. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class BusanData: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var openTime: String?
    var type: String?
    var toiletName: String?
    var lat: Double?
    var long: Double?
   
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, openTime: String, type: String, toiletName: String, lat: Double, long: Double) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.toiletName = toiletName
        self.openTime = openTime
        self.type = type
        self.lat = lat
        self.long = long        
    }
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(kABPersonAddressStreetKey) : subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(title!) \(subtitle!)"
        
        return mapItem
    }
}
