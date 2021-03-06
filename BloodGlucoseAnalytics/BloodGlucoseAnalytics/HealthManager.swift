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
    
    func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
    {
        var error:NSError?
        var age:Int?
        
        // 1. Request birthday and calculate age
        if let birthDay = healthKitStore.dateOfBirthWithError(&error)
        {
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let differenceComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: birthDay, toDate: today, options: NSCalendarOptions(0) )
            age = differenceComponents.year
        }
        if error != nil {
            println("Error reading Birthday: \(error)")
        }
        
        // 2. Read biological sex
        var biologicalSex:HKBiologicalSexObject? = healthKitStore.biologicalSexWithError(&error);
        if error != nil {
            println("Error reading Biological Sex: \(error)")
        }
        // 3. Read blood type
        var bloodType:HKBloodTypeObject? = healthKitStore.bloodTypeWithError(&error);
        if error != nil {
            println("Error reading Blood Type: \(error)")
        }
        
        // 4. Return the information read in a tuple
        return (age, biologicalSex, bloodType)
    }
    
    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
        
        // 1. Build the Predicate
        let past = NSDate.distantPast() as! NSDate
        let now   = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion(nil,error)
                    return;
                }
                
                // Get the first sample
                let mostRecentSample = results.first as? HKQuantitySample
                
                // Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func saveBMISample(bmi:Double, date:NSDate ) {
        
        // 1. Create a BMI Sample
        let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
        let bmiSample = HKQuantitySample(type: bmiType, quantity: bmiQuantity, startDate: date, endDate: date)
        
        // 2. Save the sample in the store
        healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                println("Error saving BMI sample: \(error.localizedDescription)")
            } else {
                println("BMI sample saved successfully!")
            }
        })
    }
}