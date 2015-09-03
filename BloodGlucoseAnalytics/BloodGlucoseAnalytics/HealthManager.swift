//
//  HealthManager.swift
//Based off this tutorial http://www.raywenderlich.com/86336/ios-8-healthkit-swift-getting-started

import HealthKit
import Foundation

class HealthManager {
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
//        let healthKitTypesToRead = Set(arrayLiteral:[
//            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
//            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType),
//            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
//            //Added blood glucose permissions
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose),
//            HKObjectType.workoutType()
//            ])
        
        let healthKitTypesToRead = NSSet(array: [
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            //Added blood glucose permissions
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose),
            HKObjectType.workoutType()
        ])
        
        // 2. Set the types you want to write to HK Store
//        let healthKitTypesToWrite = Set(arrayLiteral:[
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
//            HKQuantityType.workoutType()
//            ])
        
        let healthKitTypesToWrite = NSSet(array: [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKQuantityType.workoutType()
        ])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        //fix for this at: http://blog.appliedinformaticsinc.com/how-to-grant-readwrite-access-to-apples-healthkit/
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite as Set, readTypes: healthKitTypesToRead as Set) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
}