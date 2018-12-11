//
//  ViewController.swift
//  BusanMap02
//
//  Created by 정인교 on 26/11/2018.
//  Copyright © 2018 정인교. All rights reserved.
//  XCode 108.1

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    var selected: BusanData?
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    var tn: String?
    var ty: String?
    
    // 1시간 마다 호출위해 타이머 객체 생성
    var timer = Timer()
    var currentTime: String?
    
    
    
    
    // 광복동, 초량동
    let addrs:[String:[String]] = [
        "노인종합복지관" : ["양정2동 중앙대로 993", "35.178463", "129.074502", "부산광역시 연제구청", "개방화장실"],
        "동명초등학교" : ["연산동 쌍미천로44번길 17", "35.178289", "129.091026", "부산광역시 연제구청", "개방화장실"],
        "이사벨중학교" : ["거제1동 교대로 3", "35.194962", "129.078271", "부산광역시 연제구청", "개방화장실"],
        "부산교육대학교" : ["연제구 교대로 24", "35.196127", "129.075091", "부산광역시 연제구청", "개방화장실"],
        "거학초등학교" : ["거제1동 교대로24번길 36", "35.197352", "129.076942", "부산광역시 연제구청", "개방화장실"],
        "교대부속초등학교" : ["거제1동 교대로 24", "35.195200", "129.074485","부산광역시 연제구청","개방화장실" ],
        "거제1동사무소" : ["거제1동 법원북로 88", "35.192242", "129.075658", "부산광역시 연제구청", "개방화장실" ],
        "동래세무서" : ["거제1동 거제천로269번길 16", "35.192927", "129.086886", "부산광역시 연제구청", "개방화장실" ],
        "남문초등학교" : ["거제1동 법원북로 23", "35.194641", "129069604", "부산광역시 연제구청", "개방화장실"],
        "교대지하철" : ["거제1동",  "35.195751", "129.080044", "부산광역시 연제구청","개방화장실"],
        "과정공원" : ["연산동", "35.186041", "129.108388", "부산광역시 연제구청", "공중화장실"],
        "정부기록보존소" : ["거제2동 126", "35.190538","129.052842", "부산광역시 연제구청", "개방화장실"],
        "연제고등학교" : ["연산동 쌍미천로30번길 31", "35.177641", "129.091907", "부산광역시 연제구청", "개방화장실"],
        "창신초등학교" : ["거제2동 종합운동장로12번길 15", "35.192627", "129.065581", "부산광역시 연제구청", "개방화장실"],
        "종합운동장역" : ["거제2동", "35.191169", "129.067864", "부산광역시 연제구청", "개방화장실"],
        "거제2동사무소" : ["거제2동 아시아드대로22번길 19",  "35.187697", "129.070307", "부산광역시 연제구청", "개방화장실"],
        "거제여자중학교" : ["거제2동 금용로 43",  "35.187800", "129.063411", "부산광역시 연제구청", "개방화장실"],
        "지하철거제역" : ["거제2동",  "35.188603", "129.073897", "부산광역시 연제구청", "개방화장실"],
        "국립농산물 품질관리원": ["거제3동 501", "35.187213", "129.073396", "부산광역시 연제구청", "개방화장실"],
        "거제3동사무소": ["거제3동 거제대로 180", "35.184357", "129.071131", "부산광역시 연제구청", "개방화장실"],
        "거성중학교" : ["거제4동 해맞이로 109번길 61", "35.183071", "129.066992", "부산광역시 연제구청", "개방화장실"],
        "계성정보고등학교" : [ "거제4동 해맞이로109번길 47", "35.182716" ,
        "129.067501" ,"부산광역시 연제구청", "개방화장실"],
        "연산동 우체국" : [ "연산6동 2133-54", "35.174048", "129.092543", "부산광역시 연제구청", " 개방화장실"],
    "거제초등학교" : [ "거제4동 해맞이로 39" , "35.178076", "129.066946" ,"부산광역시 연제구청", " 개방화장실"],
    "연신초등학교" : [ "연산동 신금로23번길 30","35.192339","129.093130", "부산광역시 연제구청", " 개방화장실"],
    "연산1동사무소" : [ "연산동 연동로8번길 66" , "35.189989", "129.090425", "부산광역시 연제구청", " 개방화장실"],
    "연서초등학교" : [ "연산동 거제천로270번길 30" , "35.190713", "129.086207", "부산광역시 연제구청", " 개방화장실"]

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산연제구 공중화장실 지도"

        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    
        myMapView.showsUserLocation = true
        myMapView.showsCompass = true
        
        myParse()
        timer = Timer.scheduledTimer(timeInterval: 60*1, target: self, selector: #selector(myParse), userInfo: nil, repeats: true)
        
        // Map
        myMapView.delegate = self
        
        //  초기 맵 region 설정
        zoomToRegion()
        print(item)
        
        for item in items {
            let instname = item["toiletName"]

            print("toiletName = \(String(describing: instname))")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == instname {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    tn = value[3]
                    ty = value[4]
                    dLat = Double(lat!)
                    dLong = Double(long!)
        
                        }
            
            }
            // 파싱 데이터 처리
         
          
            let tOpenTime = item["openTime"]
            let toiletName = item["toiletName"]
            let insname = item["instName"]
            let types = item["type"]
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: insname!, subtitle: toiletName!, openTime: tOpenTime!, type: types!, toiletName: tn!, lat: dLat!, long: dLong!)

            annotations.append(annotation!)
        }
        
        
      
        myMapView.addAnnotations(annotations)

    }
    
    @objc func myParse() {
        // XML Parsing
        let key = "dH7oyxOq53N%2B%2FRde8Bv2BfStdElt4%2BYo8Y2uv0qcVTAEE2JZi3fsxzkkncorSPsCWBb%2Fp4m4l2T6c80hxRzbrA%3D%3D"
        let strURL = "http://opendata.busan.go.kr/openapi/service/PublicToilet/getToiletInfoList?ServiceKey=\(key)&numOfRows=28"
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    
                    // 파싱이 끝난시간 시간 측정
                    let date: Date = Date()
                    let dayTimePeriodFormat = DateFormatter()
                    dayTimePeriodFormat.dateFormat = "YYYY/MM/dd HH시 MM분"
                    currentTime = dayTimePeriodFormat.string(from: date)
                   
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
        
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeToOriginLocation(_ sender: Any) {
        
        let currnetLoc: CLLocation = locationManager.location!
        let location = CLLocationCoordinate2D(latitude: currnetLoc.coordinate.latitude, longitude: currnetLoc.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
    }
    

    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Leave default annotation for user location
        if annotation is MKUserLocation {
            return nil
        }

        let reuseID = "MyPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if annotationView == nil {
            let pin = MKPinAnnotationView(annotation: annotation,
                                       reuseIdentifier: reuseID)
//            pin.image = UIImage(named: "marker-30")
            pin.isEnabled = true
            pin.canShowCallout = true
            
            let castBusanData = annotation as! BusanData
      
            

            let label = UILabel(frame: CGRect(x: -2, y: 12, width: 30, height: 30))
            
//            label.text = annotation.id // set text here
            
            //let castBusanData = annotation as! BusanData
            
            
            pin.addSubview(label)
            annotationView = pin
            
            
        } else {
            annotationView?.annotation = annotation
        }

        let btnR = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btnR
        
        return annotationView
    }
    
    // rightCalloutAccessoryView를 눌렀을때 호출되는 delegate method
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selected = view.annotation as? BusanData
        
        if control == view.rightCalloutAccessoryView {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! DetailViewController
            
            detailVC.selectedForDetail = self.selected
        }
        
    }
    
    // XML Parsing Delegate 메소드
    // XMLParseDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        // tag 이름이 elements이거나 item이면 초기화
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
}
