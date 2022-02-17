    //
    //  GlobalConstants.swift
    //  demoFrame
    //
    //  Created by Treel on 10/12/21.
    //

import Foundation
public struct GlobalConstants {
    
    public static let ALERT_TONE = "ALERT_TONE"
    public static let yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    public static let MAL_FUNC_TEMP = 125
    public static let MAL_FUNC_PRESS = 216
    static let DT_BLE = "BLE"
    
    static let yyyyMMdd = "yyyy-MM-dd"
    
    static let PSI_U = "PSI"
    static let BAR_U = "BAR"
    static let KPA_U = "KPA"
    static let F_U = "F"
    static let C_U = "C"
    
    
    
    public static let OVR_RANGE = 65356
    
    
    public static let x_AccessTokenForTodaysEx = "x_AccessTokenForTodaysEx"
    
    
    
    public static func getTimeIntervalFromDate(dateString: String, dateFormate: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormate
        dateFormatter.timeZone = NSTimeZone(name: "IST") as TimeZone?
        
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let currentDate = Date()
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: currentDate)
        
        if differenceOfDate.year! > 0 {
            if differenceOfDate.year! > 1 {
                return "\(differenceOfDate.year ?? 0) Yr's ago";
            }
            return "\(differenceOfDate.year ?? 0) Yr ago";
        }
        if differenceOfDate.month! > 0 {
            if differenceOfDate.month! > 1 {
                return "\(differenceOfDate.month ?? 0) Month's ago";
            }
            return "\(differenceOfDate.month ?? 0) Month ago";
        }
        if differenceOfDate.day! > 0 {
            if differenceOfDate.day! > 1 {
                return "\(differenceOfDate.day ?? 0) Day's ago";
            }
            return "\(differenceOfDate.day ?? 0) Day ago";
        }
        if differenceOfDate.hour! > 0 {
            if differenceOfDate.hour! > 1 {
                return "\(differenceOfDate.hour ?? 0) Hr's ago";
            }
            return "\(differenceOfDate.hour ?? 0) Hr ago";
        }
        if differenceOfDate.minute! > 0 {
            if differenceOfDate.minute! > 1 {
                return "\(differenceOfDate.minute ?? 0) Min's ago";
            }
            return "\(differenceOfDate.minute!) Min ago"
        }
        if differenceOfDate.second! > 0 {
            if differenceOfDate.second! > 1 {
                return "\(differenceOfDate.second ?? 0) Sec's ago";
            }
            return "\(differenceOfDate.second!) Sec ago"
        }
        
        if differenceOfDate.year! == 0 && differenceOfDate.month! == 0 && differenceOfDate.day! == 0 && differenceOfDate.hour! == 0 && differenceOfDate.minute! == 0 && differenceOfDate.second! == 0 {
            return "LIVE"
        }
        
        return ""
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
    
    
    func getTodayString() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "IST") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strDate = dateFormatter.string(from: date)
        return "\(strDate)"
    }
    
}

