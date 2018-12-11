//
//  DetailViewController.swift
//  BusanMap02
//
//  Created by D7702_10 on 2018. 12. 4..
//  Copyright © 2018년 김종현. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
class DetailViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet var lblAddr: UILabel!
    @IBOutlet var lbldetailAddr: UILabel!
    @IBOutlet var lblCapcity: UILabel!
    
    var selectedForDetail: BusanData?
    
    var test: String?
    var dLat: Double?
    var dLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      let title = selectedForDetail?.title
      let open = selectedForDetail?.openTime
      let type = selectedForDetail?.type
        print("title = \(title)")
        
        
        lblAddr.text = title
        lbldetailAddr.text = open
        lblCapcity.text = type
        
    }
    
    @IBAction func navi(_ sender: Any) {
        
        let title = selectedForDetail?.subtitle
        dLat = selectedForDetail?.lat
        dLong = selectedForDetail?.long
        
        let latitude:CLLocationDegrees = dLat!
        let longitude:CLLocationDegrees = dLong!
        
        let addressDictionary = [String(kABPersonAddressStreetKey) : "fuck"]
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(title!)"
        mapItem.openInMaps(launchOptions: launchOptions)
        
    }
    
    
}
