    //
    //  BLEManager.swift
    //  demoFrame
    //
    //  Created by Treel on 10/12/21.
    //

import Foundation
import CoreBluetooth
import CoreLocation
import UserNotifications
import CryptoSwift

public protocol EventCallbackListener{
    func didBLEStateUpdate(status : CBManagerState?)
    func onTpmsDataReceive(vehicleConfiguration : VehicleConfiguration)
    func showAlertNotification(alertNotification : AlertNotification)
    
}

public class BLEManager: NSObject {
    
    static let sharedManager = BLEManager()
    var treelTags = [DetectedTreelTag]()
    var sensorDetectedData : [SensorDetectionEventDataModel] = []
    public static var addOnEventCallbackListenerDelegate: EventCallbackListener?
    fileprivate var timer : Timer? = nil
    fileprivate var syncBLEDataTimer2Min : Timer? = nil
   
    var isBLEDetected = false
    
    lazy fileprivate var locationManager:CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true // uncomment if background location On
        locationManager.pausesLocationUpdatesAutomatically = false
        return locationManager
    }()
    
    fileprivate var bluetoothManager : CBCentralManager? = nil
    
    var vehicleConfigurations: [VehicleConfiguration]?
    fileprivate var beaconsIdentiferCount = 0
    
    private override init() {
        super.init()
        
        locationManager.requestAlwaysAuthorization()
        self.updateVehicleConfigurations()
        NotificationCenter.default.addObserver(self, selector: #selector(notifyLoadBLEData(notification:)), name: .loadBLEData, object: nil)
        
        switch CLLocationManager.authorizationStatus() {
            case  .denied, .restricted: break
                
            case .notDetermined:
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
                    self.locationManager.requestWhenInUseAuthorization()
                })
            default:
                
                break
        }
        
        updateBeaconsFinder()
    }
    
        ///// SaveScannedDataStored
    @objc func notifyLoadBLEData(notification: NSNotification) {
        if (sensorDetectedData.count) > 0{
            syncBLEDataTimer2Min = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(self.scanBLEDataFor2MinAction), userInfo: nil, repeats: true)
        }else{
            TreelTagScan.shared?.isBLEDetected = false
        }
    }
    
    @objc func scanBLEDataFor2MinAction() {
        if (TreelTagScan.shared?.sensorDetectedData.count)! > 0{
                //remove which vehicle those tag are not reponding since last 10 min


                //MARK: Checking BLE and iBeacon Connectivity
            
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        break;
//
                    case .authorizedAlways, .authorizedWhenInUse: break;
//
                
                    @unknown default:
                        break;
                }
            }
        }else{
            syncBLEDataTimer2Min?.invalidate()
            TreelTagScan.shared?.isBLEDetected = false
        }
    }
    
    func updateBeaconsFinder() {
        for region in locationManager.rangedRegions {
            locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
            locationManager.stopMonitoring(for: region)
        }
        findBeaconsWithUUID("ffffffff-ffff-ffff-ffff-ffffffffffe0")
    }
    
    func findBeaconsWithUUID(_ uuid: String) {
            //beaconsIdentiferCount += 1
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, identifier: "Treel iBeacon Identifier)")
        region.notifyEntryStateOnDisplay = true
        locationManager.startMonitoring(for: region)
        locationManager.startRangingBeacons(in: region)
        locationManager.startUpdatingLocation()
    }
    
        //MARK: Live data from TPMS Tags
    func updateVehicleConfigurations() {
        
        vehicleConfigurations = DBHelper.DBHelperShared.fetchVehiclesConfigurationData()
        
        if !treelTags.isEmpty {
          
            treelTags.removeAll()
        }
        for configuration in vehicleConfigurations! {
            
            if let sensorDetectionEvent = DBHelper.DBHelperShared.getSensorDetectionEvent(macAddress: configuration.macAddress!) {
                let tag = DetectedTreelTag()
                
                if (isSensorDataWithinLastGivenMinutes(lastAlertTimeStamp: sensorDetectionEvent.sensorDetectionTimestamp, minutes: 2)) {
                    let sensorData = sensorDetectionEvent.sensorData.split(separator: ",")
                    tag.pressure = String(sensorData[0])
                    tag.temperature = String(sensorData[1])
                    tag.battery = String(sensorData[2])
                    tag.macID = (sensorDetectionEvent.macAddress)!
                    tag.vinNumber = configuration.vinNumber!
                    let dateString = GlobalConstants.getTimeIntervalFromDate(dateString: sensorDetectionEvent.sensorDetectionTimestamp!, dateFormate: GlobalConstants.yyyyMMddHHmmss)
                    tag.time = dateString
                    tag.dateTime = sensorDetectionEvent.sensorDetectionTimestamp!
                    tag.isLive = false
                    if let index = treelTags.index(where: {$0.macID == configuration.macAddress!}) {
                        treelTags[index] = tag
                    }else{
                        treelTags.append(tag)
                    }
                }
                
            }
            
        }
        self.updateConnectedvehicleVehicleConfigurations(with: false)
    }
        //MARK: Display Previous Server Data
    func updateConnectedvehicleVehicleConfigurations(with config: Bool) {
        let vehicleConfigurations = DBHelper.DBHelperShared.fetchVehiclesConfigurationData()
        
        if !treelTags.isEmpty {
          
            treelTags.removeAll()
        }
        
        for configuration in vehicleConfigurations {
            
            if let sensorDetectionEvent = DBHelper.DBHelperShared.getSensorDetectionEvent(macAddress: configuration.macAddress!) {
                let tag = DetectedTreelTag()
                
                let sensorData = sensorDetectionEvent.sensorData.split(separator: ",")
//                print("TREEL sensorData:-\(sensorDetectionEvent.sensorData) :\( configuration.macAddress) :\( configuration.tyrePosition)")
                tag.pressure = String(sensorData[0])
                tag.temperature = String(sensorData[1])
                tag.battery = String(sensorData[2])
                tag.macID = (configuration.macAddress)!
                
                print("tag.pressure\(tag.pressure)")
                print("tag.temperature \(tag.temperature )")
                print("tag.battery\(tag.battery)")
                print("tag.macID\(tag.macID)")
                
                
                tag.vinNumber = configuration.vinNumber!
                let dateString = GlobalConstants.getTimeIntervalFromDate(dateString: sensorDetectionEvent.sensorDetectionTimestamp!, dateFormate: GlobalConstants.yyyyMMddHHmmss)
                tag.time = dateString
                tag.dateTime = sensorDetectionEvent.sensorDetectionTimestamp!
                tag.isLive = false
                
                if let index = treelTags.index(where: {$0.macID == configuration.macAddress!}) {
                    treelTags[index] = tag
                    
                }else{
                    treelTags.append(tag)
                }
            }
        }
        
    }
    
    private func isSensorDataWithinLastGivenMinutes(lastAlertTimeStamp: String, minutes : Int)-> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalConstants.yyyyMMddHHmmss
        guard let fromTime = dateFormatter.date(from: lastAlertTimeStamp) else {
            dateFormatter.dateFormat = GlobalConstants.yyyyMMddHHmmss
            guard let fromTime1 = dateFormatter.date(from: lastAlertTimeStamp) else {
                return false
            }
            let toTime = Date()
            let difference = Calendar.current.dateComponents([.second], from: fromTime1, to: toTime)
            
            return difference.second! <= (minutes * 60)
        }
        
        let toTime = Date()
        
        let difference = Calendar.current.dateComponents([.second], from: fromTime, to: toTime)
        
        return difference.second! <= (minutes * 60)
    }
    
        //Helper Functions
    func findBLE(_ needFind: Bool) {
        if needFind {
            bluetoothManager = CBCentralManager(delegate: self, queue: nil)
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(BLEManager.updateBLE), userInfo: nil, repeats: true)
            updateBLE()
        } else {
            timer!.invalidate()
            timer = nil
            bluetoothManager = nil
        }
    }
    
    @objc func updateBLE() {
        var serviceUUIDs = [CBUUID]()
        serviceUUIDs.append(CBUUID.init(string: "ffe0"))
        bluetoothManager?.scanForPeripherals(withServices: serviceUUIDs, options: nil)
        
    }
    
    func stopScanning() {
        
    }
    
    func checkIfTagConfigured(tagMacId: String)-> VehicleConfiguration? {
        
        if let index = vehicleConfigurations?.index(where: {$0.macAddress == tagMacId}) {
            return vehicleConfigurations?[index]
        }
        return nil
    }
    
    func checkIfiBeaconTagConfigured(iBeaconLastThreeByteMacID: String)-> VehicleConfiguration? {
        print("iBeaconLastThreeByteMacID\(iBeaconLastThreeByteMacID)")
        if let index = vehicleConfigurations?.index(where: {($0.macAddress?.hasSuffix(iBeaconLastThreeByteMacID))! }) {
            return vehicleConfigurations?[index]
        }
        return nil
    }
    
    private func decrypt(encryptedData: Data, macID: Data) -> Data? {
        let key = "#@Trl2018-lespl$"
        let keyData = key.data(using: .utf8)!
        
        do {
            
            let iv = AES.randomIV(AES.blockSize)
            let aes = try AES(key: (keyData.bytes), blockMode: CBC(iv: iv))
//            let aes = try AES(key: (keyData.bytes), blockMode: .ECB) // aes128
            let decryptedData = try aes.decrypt(encryptedData.bytes)
            return Data(decryptedData)
        } catch {
            print(error)
        }
        return nil
    }
    
    func fillParsedData(advertisementData: [String : Any], tag: DetectedTreelTag) {
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            
            if(manufacturerData.count >= 22) {
                
                let macIDRange:Range<Int> = 0..<6
                let temperatureRange:Range<Int> = 1..<3
                let pressureRange:Range<Int> = 3..<5
                let batteryRange:Range<Int> = 5..<6
                let measurementPayloadRange:Range<Int> = 6..<22
                
                let macID = manufacturerData.subdata(in: macIDRange)
                
                let measurementPayloadData = manufacturerData.subdata(in: measurementPayloadRange)
                
                if let decryptedData = decrypt(encryptedData: measurementPayloadData, macID: macID) {
                    
                        //Return when decrypted data is invalid
                    if decryptedData.count < 16 {
                        let macIdd = macID.hexEncodedString()
                        print("****** Tag scanned Data : \(macIdd)")
                        return
                    }
                    
                    var temperature = decryptedData.subdata(in: temperatureRange)
                    temperature = getLsbMsbData(data: temperature)
                    
                    var pressure = decryptedData.subdata(in: pressureRange)
                    pressure = getLsbMsbData(data: pressure)
                    let battery = decryptedData.subdata(in: batteryRange)
                    
                    tag.macID = macID.hexEncodedString()
                    tag.temperature = calculateTemperature(hexString: (temperature.hexEncodedString()))
                    tag.pressure = calculatePressure(hexString:(pressure.hexEncodedString()))
                    tag.battery = calculateCounter(hexString: (battery.hexEncodedString()))
                    let dateString = GlobalConstants.getTimeIntervalFromDate(dateString: BLEManager.sharedManager.getTodayString(), dateFormate: GlobalConstants.yyyyMMddHHmmss)
                    tag.time = dateString
                    tag.dateTime = BLEManager.sharedManager.getTodayString()
                    tag.isLive = true
                }
            }
        }
    }
    
    private func getLsbMsbData(data: Data) -> Data {
        let tempLsb = data.subdata(in: 1..<2)
        let tempMsb = data.subdata(in: 0..<1)
        var lsbMsb = Data()
        lsbMsb.append(tempLsb)
        lsbMsb.append(tempMsb)
        return lsbMsb
    }
    
    
    private func calculatePressure(hexString: String) -> String {
        if let value = UInt16(hexString, radix: 16) {
            return String(value/100)
        } else {
            return "N/A"
        }
    }
    
    private func calculateTemperature(hexString: String) -> String {
        if let value = UInt16(hexString, radix: 16) {
            var temperature: Int
            if value <= 32768 {
                temperature = Int(value/100)
            } else {
                temperature = -(Int((value - 32768)/100))
            }
            return String(temperature)
            
        } else {
            return "N/A"
        }
    }
    
    
    private func calculateCounter(hexString: String) -> String {
        return String(describing: UInt16(hexString, radix: 16)!)
        
    }
       
}

extension Data {
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        
        let hexDigits = Array("0123456789ABCDEF".utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    
}

extension BLEManager : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons {
            
            print("Beacon detected: \(beacon.major)")
            
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("Beacon monitoring..")
        self.findBLE(true)
        
    }
}

extension String {
    
    public static let PSI_U = "PSI"
    public static let BAR_U = "BAR"
    public static let KPA_U = "KPA"
    public static let F_U = "F"
    public static let C_U = "C"
    
    public static let PRESS_UNIT = "W_PRESS_UNIT"
    public static let TEMP_UNIT = "W_TEMP_UNIT"
    
    
    public static let OVR_RANGE = 65356
    public static let MAL_FUNC_PRESS = 216
    public static let MAL_FUNC_TEMP = 125
    
    public static let x_AccessTokenForTodaysEx = "x_AccessTokenForTodaysEx"
    
}

extension BLEManager : CBCentralManagerDelegate {
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager ) {
        
        print("central.state\(central.state)")
        BLEManager.addOnEventCallbackListenerDelegate?.didBLEStateUpdate(status: central.state)
    }
    
    
    @available(iOS 9.1.0, *)
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let tag = DetectedTreelTag()
        let vehicleConfiguration: VehicleConfiguration?
        fillParsedData(advertisementData: advertisementData, tag: tag)
        if(tag.macID == "") {
            print("tag nil")
            return
        }
        print("BLE Detected : \(tag.macID)")
        if let configuration = self.checkIfTagConfigured(tagMacId: tag.macID) {
            vehicleConfiguration = configuration
            
        } else {
            return
        }
        
        if let index = treelTags.firstIndex(where: {$0.macID == tag.macID}) {
            treelTags[index] = tag
        } else {
            treelTags.append(tag)
        }
        
        DispatchQueue.main.async {
            
            
            let sensorDetection = SensorDetectionModel(macAddress: vehicleConfiguration?.macAddress!, pressure: tag.pressure, temperature: tag.temperature, battery: tag.battery, position: vehicleConfiguration?.tyrePosition)
            let vehicleConfig = VehicleConfiguration()
            vehicleConfig.tireReading = sensorDetection
            vehicleConfig.vinNumber = vehicleConfiguration?.vinNumber!
            vehicleConfig.macAddress = vehicleConfiguration?.macAddress!
            vehicleConfig.tyrePosition = vehicleConfiguration?.tyrePosition!
            
            BLEManager.addOnEventCallbackListenerDelegate?.onTpmsDataReceive(vehicleConfiguration: vehicleConfig)
            self.showAlertIfRequired(configuration: vehicleConfiguration!, tag: tag)
        }
        
    }
    
    private func showAlertIfRequired(configuration: VehicleConfiguration, tag: DetectedTreelTag) {
        
            //               Check is it valid frame(may be it is Malware data)
        if Int(tag.temperature) ?? 0 < 0 || Int(tag.temperature) ?? 0 > GlobalConstants.MAL_FUNC_TEMP {
            return
        }
        if Int(tag.pressure) ?? 0 < 0 || Int(tag.pressure) ?? 0 > GlobalConstants.MAL_FUNC_PRESS {
            return
        }
       
        let sensorData = "\(tag.pressure),\(tag.temperature),\(tag.battery)"
        print("sensorData\(sensorData)")
        DBHelper.DBHelperShared.saveSensorLastDetectionEvent(macAddress: configuration.macAddress!, vinNumber: configuration.vinNumber! , sensorData: sensorData,  timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE, tyrePosition: configuration.tyrePosition!)
        
        DBHelper.DBHelperShared.SaveTpmsDataHistory(macAddress: configuration.macAddress!, vinNumber: configuration.vinNumber!, tyrePosition: configuration.tyrePosition!, pressure: Int(tag.pressure)!, temperature: Int(tag.temperature)!, battery: Int(tag.battery)!, timeStamp: getTodayString())
        
        
        if TreelTagScan.shared?.isBLEDetected == false {
            TreelTagScan.shared?.isBLEDetected = true
            NotificationCenter.default.post(name: .loadBLEData,object: nil)
        }
            /////////
            //MARK: Local Alert generate
        if(Int(tag.pressure)! < configuration.lowPressureSetPoint!) {
            isAlertTimeout(macAddress: tag.macID, alertType: AlertType.LOW_PRESSURE) {
                self.showAlert(alertType: AlertType.LOW_PRESSURE, configuration: configuration, tireValue: tag.pressure)
                
            }
        } else if(Int(tag.pressure)! > configuration.highPressureSetPoint!) {
            isAlertTimeout(macAddress: tag.macID, alertType: AlertType.HIGH_PRESSURE) {
                self.showAlert(alertType: AlertType.HIGH_PRESSURE, configuration: configuration, tireValue: tag.pressure)
            }
        }
        
        if(Int(tag.temperature)! > configuration.highTemperatureSetPoint!) {
            isAlertTimeout(macAddress: tag.macID, alertType: AlertType.HIGH_TEMPERATURE) {
                self.showAlert(alertType: AlertType.HIGH_TEMPERATURE, configuration: configuration, tireValue: tag.temperature)
            }
        }
    }
    
    private func isAlertTimeout(macAddress: String, alertType: AlertType, completion: @escaping () -> Void) {
        var lastAlertDetectionTimestamp: String?
        switch alertType {
            case AlertType.LOW_PRESSURE:
                lastAlertDetectionTimestamp = DBHelper.DBHelperShared.getLastLowPressureAlertDetectionEvent(macAddress: macAddress)
                if let timeStamp = lastAlertDetectionTimestamp {
                    if (isTimeoutHappendWithMinutes(lastAlertTimeStamp: timeStamp, minutes: 3)) {
                        DBHelper.DBHelperShared.saveLowPressureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                        completion()
                    }
                }else{
                    DBHelper.DBHelperShared.saveLowPressureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                    completion()
                }
                break
            case AlertType.HIGH_PRESSURE:
                lastAlertDetectionTimestamp = DBHelper.DBHelperShared.getLastHighPressureAlertDetectionEvent(macAddress: macAddress)
                
                if let timeStamp = lastAlertDetectionTimestamp {
                    if (isTimeoutHappendWithMinutes(lastAlertTimeStamp: timeStamp, minutes: 3)) {
                        DBHelper.DBHelperShared.saveHighPressureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                        completion()
                    }
                }else{
                    DBHelper.DBHelperShared.saveHighPressureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                    completion()
                }
                break
            case AlertType.HIGH_TEMPERATURE:
                lastAlertDetectionTimestamp = DBHelper.DBHelperShared.getLastHighTemperatureAlertDetectionEvent(mac_address: macAddress)
                
                if let timeStamp = lastAlertDetectionTimestamp {
                    if (isTimeoutHappendWithMinutes(lastAlertTimeStamp: timeStamp, minutes: 3)) {
                        DBHelper.DBHelperShared.saveHighTemperatureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                        completion()
                    }
                }else{
                    DBHelper.DBHelperShared.saveHighTemperatureAlertDetectionEvent(macAddress: macAddress, timeStamp: getTodayString(), dataType: GlobalConstants.DT_BLE)
                    completion()
                }
                break
            default:
                print("Ignore Alert")
        }
        
        
        
    }
    
    func getTodayDateTimeStringFormate() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = "\(components.year ?? 0)"
        var month = "\(components.month ?? 0)"
        var day = "\(components.day ?? 0)"
        var hour = "\(components.hour ?? 0)"
        var minute = "\(components.minute ?? 0)"
        var second = "\(components.second ?? 0)"
        
        if components.month! < 10 {
            month = "0\(components.month!)"
        }
        if components.day! < 10 {
            day = "0\(components.day!)"
        }
        if components.hour! < 10 {
            hour = "0\(components.hour!)"
        }
        if components.minute! < 10 {
            minute = "0\(components.minute!)"
        }
        if components.second! < 10 {
            second = "0\(components.second!)"
        }
        
        
        let today_string = String(year) + "-" + String(month) + "-" + String(day) + " " + String(hour)  + ":" + String(minute) + ":" +  String(second)
        
        return today_string
        
    }
    func isTimeoutHappendWithMinutes(lastAlertTimeStamp: String, minutes : Int)-> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalConstants.yyyyMMddHHmmss
        let fromTime = dateFormatter.date(from: lastAlertTimeStamp)
        
        let now = getTodayDateTimeStringFormate()
        let toTime = dateFormatter.date(from: now)
        
        let difference = Calendar.current.dateComponents([.second], from: fromTime!, to: toTime!)
        
        
        return difference.second! < (minutes * 60)
    }
    
    
    func getTodayString() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "IST") as TimeZone?
        dateFormatter.dateFormat = GlobalConstants.yyyyMMddHHmmss
        let strDate = dateFormatter.string(from: date)
        return "\(strDate)"
    }
    
    func getTodayLocalDateString() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = GlobalConstants.yyyyMMddHHmmss
        let strDate = dateFormatter.string(from: date)
        return "\(strDate)"
    }
    
    
        //Function to get current date and time
    func getTodayLocalString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = "\(components.year ?? 0)"
        var month = "\(components.month ?? 0)"
        var day = "\(components.day ?? 0)"
        var hour = "\(components.hour ?? 0)"
        var minute = "\(components.minute ?? 0)"
        var second = "\(components.second ?? 0)"
        
        if components.month! < 10 {
            month = "0\(components.month!)"
        }
        if components.day! < 10 {
            day = "0\(components.day!)"
        }
        if components.hour! < 10 {
            hour = "0\(components.hour!)"
        }
        if components.minute! < 10 {
            minute = "0\(components.minute!)"
        }
        if components.second! < 10 {
            second = "0\(components.second!)"
        }
        
        
        let today_string = String(year) + "-" + String(month) + "-" + String(day) + " " + String(hour)  + ":" + String(minute) + ":" +  String(second)
        
        return today_string
        
    }
    
    
    private func showAlert(alertType: AlertType, configuration: VehicleConfiguration, tireValue: String) {
        if let vehicle = DBHelper.DBHelperShared.fetchVehicleDetails(vinNumber: configuration.vinNumber!){
            var notificationID = 0
            let vehicleType = vehicle.vehicleType
            let vinNumber = vehicle.vinNumber!
            let tirePosition = configuration.tyrePosition!
            var vehicleTirePosition: String?
            if(vehicleType != "Bike") {
                switch tirePosition {
                    case "1A":
                        vehicleTirePosition = "Front Left"
                    case "1B":
                        vehicleTirePosition = "Front Right"
                    case "2A":
                        vehicleTirePosition = "Rear Left"
                    case "2B":
                        vehicleTirePosition = "Rear Right"
                    default:
                        vehicleTirePosition = "Stepney"
                }
            } else {
                switch tirePosition {
                    case "1A":
                        vehicleTirePosition = "Front"
                    case "2A":
                        vehicleTirePosition = "Rear"
                    default:
                        vehicleTirePosition = "Front"
                }
            }
            
            var alertLabel: String?
            var alertMsg: String?
            var alert: Int = 0 //@K
            
            let pressUnit = getUnit(key: .PRESS_UNIT)
            let tempUnit = getUnit(key: .TEMP_UNIT)
            
            var tireValueInt: Int = 0
            if tireValue != "" {
                if let value = Float(tireValue) {
                    tireValueInt = Int(value)
                }
            }
            
            
            switch alertType {
                case AlertType.LOW_PRESSURE:
                        //Generating a unique notification identifier which will be used to replace the existing notification for the same tyre's same type of notification. This will prevent from generating duplicate notifications
                    notificationID = configuration.configId! * 100 + 1 * 10
                    alertLabel = "Low Pressure Alert! - \(Float().getUnitValueForAlert(key: pressUnit, value: Float(tireValueInt)))"
                    alertMsg = """
                                       \(String(describing: vehicleTirePosition!)) Tyre.
                                       Please refill air at the nearest gas station.
                                       Save on precious fuel!
                                       """
                    alert = 1  //@K
                    break
                case AlertType.HIGH_PRESSURE:
                        //Generating a unique notification identifier which will be used to replace the existing notification for the same tyre's same type of notification. This will prevent from generating duplicate notifications
                    notificationID = configuration.configId! * 100 + 2 * 10
                    alertLabel = "High Pressure Alert! - \(Float().getUnitValueForAlert(key: pressUnit, value: Float(tireValueInt))) "
                    alertMsg = """
                                       \(String(describing: vehicleTirePosition!)) Tyre.
                                       Please slow down or stop your vehicle and avoid a tyre burst!
                                       """
                    alert = 2 //@K
                    break
                case AlertType.HIGH_TEMPERATURE:
                        //Generating a unique notification identifier which will be used to replace the existing notification for the same tyre's same type of notification. This will prevent from generating duplicate notifications
                    notificationID = configuration.configId! * 100 + 3 * 10
                    alertLabel = "Ahoy! High Temperature Alert! - \(Float().getUnitValueForAlert(key: tempUnit, value: Float(tireValueInt)))"
                    alertMsg = """
                                       \(String(describing: vehicleTirePosition!)) Tyre.
                                       Your tyres are overheated.
                                       Take a break, cool down and avoid a tyre burst!
                                       """
                    break
                    
                default:
                    alertLabel = "Ahoy! High Temperature Alert! - \(Float().getUnitValueForAlert(key: tempUnit, value: Float(tireValueInt)))"
                    alertMsg = """
                                       \(String(describing: vehicleTirePosition!)) Tyre.
                                       Your tyres are overheated.
                                       Take a break, cool down and avoid a tyre burst!
                                       """
                    
            }
            
                //Saving Alert to Database
            
            let today = getTodayLocalDateString()
            let titleName = "\(vinNumber) : \(String(describing: alertLabel!))"
            let titleNameForDB = "\(alertLabel!)"
            
            let message = """
                                      \(titleNameForDB)
                                      \(String(describing: alertMsg!))
                                      """
            
            DBHelper.DBHelperShared.saveAlerts(vinNumber: vinNumber, macAddress: configuration.macAddress, alertType: String(describing: alertType), alertMessage: message, timeStamp: today, tyrePosition: configuration.tyrePosition, isViewed: 0)

            let alertNotification = AlertNotification()
    
            alertNotification.alertMsg = alertMsg
            alertNotification.vinNumber = vinNumber
            alertNotification.titleName = titleName
            alertNotification.notificationID = notificationID
            
            
            BLEManager.addOnEventCallbackListenerDelegate?.showAlertNotification(alertNotification: alertNotification)
                //Fire notification for alert

            
            
        }else{
            return
        }
        
    }
    
    func getUnit(key: String) -> String {
        if UserDefaults.standard.value(forKey: key) != nil{
            let unit = UserDefaults.standard.value(forKey: key) as! String
            return unit
        }else{
            if key == .PRESS_UNIT{
                return .PSI_U
            }else{
                return .C_U
            }
        }
    }
    
}

enum AlertType : Int {
    case LOW_PRESSURE
    case HIGH_PRESSURE
    case HIGH_TEMPERATURE
    case ROTATION_ALERT
    case REMINDER_ALERT
    case CUSTOM_PUSH
}


