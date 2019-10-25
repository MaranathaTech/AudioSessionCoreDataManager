//
//  AudioSessionCoreDataManager.swift
//
//  Created by Ernie Lail on 10/24/19.
//  Copyright © 2019 Development. All rights reserved.
//

import UIKit
import CoreData

class AudioSessionCoreDataManager: NSObject {
    
    //set up singleton
    static let shared = AudioSessionCoreDataManager()
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var currentSession: NSManagedObject?
    var currentRecording: NSManagedObject?
    var highestDBItemIndex:Int = 0
    var sessions:[NSManagedObject] = []
    
    //everytime a new item is added to current sessions recordings, check for highest decible
    var currentSessionsRecordings:[NSManagedObject] = [] {
        didSet {
            if currentSessionsRecordings.count > 1 {
                highestDBItemIndex = 0
                var count = 0
                for rec in currentSessionsRecordings {
                    let prevVal = currentSessionsRecordings[highestDBItemIndex].value(forKey: "highest_decible") as! Float
                    let latestVal = rec.value(forKey: "highest_decible") as! Float
                    if  prevVal <= latestVal  {
                        highestDBItemIndex = count
                    }
                    count += 1
                }
            }
        }
    }
    
    override init() {
        super.init()
        self.getSessions()
    }
    
    func getSessions(){
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions")
        do{
            let results = try context.fetch(request)
            self.sessions = results as! [NSManagedObject]
        }
        catch{
            print("Unable to feth results from CoreData Context!")
        }
    }
    
    func newSession(sessionName:String){
        let context = appDel.persistentContainer.viewContext
        let sessionDate = Date()
        let sessionEntity = NSEntityDescription.entity(forEntityName: "Sessions", in: context)
        self.currentSession = NSManagedObject(entity: sessionEntity!, insertInto: context)
        self.currentSession?.setValue(sessionName, forKey: "name")
        self.currentSession?.setValue(sessionDate, forKey: "date")
        do {
            try  context.save()
        }
        catch let error as NSError {
            print(error)
        }
        self.getSessions()
    }
    
    func newRecording(sessionName:String, location:String, fileName:String, decible:Float){
        let context = appDel.persistentContainer.viewContext
        let recordDate = Date()
        let recordEntity = NSEntityDescription.entity(forEntityName: "Recordings", in: context)
        self.currentRecording = NSManagedObject(entity: recordEntity!, insertInto: context)
        self.currentRecording?.setValue(sessionName, forKey: "session_name")
        self.currentRecording?.setValue(location, forKey: "location")
        self.currentRecording?.setValue(recordDate, forKey: "date")
        self.currentRecording?.setValue(fileName, forKey: "audio_file_name")
        self.currentRecording?.setValue(decible, forKey: "highest_decible")
        self.currentSessionsRecordings.append(self.currentRecording!)
        do {
            try  context.save()
            print("Created New Recording")
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    func loadSessionsRecordings(sessionName:String){
        self.currentSessionsRecordings = []
        print(sessionName)
        let context = appDel.persistentContainer.viewContext
        let predicate = NSPredicate(format: "session_name == %@", sessionName)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Recordings")
        request.predicate = predicate
        
        do{
            let results = try context.fetch(request)
            print("Loaded Sessions Recordings")
            print(results)
            self.currentSessionsRecordings = results as! [NSManagedObject]
        }
        catch{
            
        }
    }
    
    func deleteSession(session:NSManagedObject){
        print("deleting session -> \"\(session.value(forKey: "name"))\"")
        let tempName = session.value(forKey: "name") as! String
        let context = appDel.persistentContainer.viewContext
        do{
            context.delete(session)
            try context.save()
            deleteAllRecordings(sessionName:tempName)
        }
        catch{
            print("Failed to delete session")
        }
        self.getSessions()
    }
    
    private func deleteAllRecordings(sessionName:String){
        print("Deleting All Recordings for \"\(sessionName)\"")
        let context = appDel.persistentContainer.viewContext
        let predicate = NSPredicate(format: "session_name == %@", sessionName)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Recordings")
        request.predicate = predicate
        do{
            let results = try context.fetch(request)
            for data in results{
                context.delete(data as! NSManagedObject)
                try context.save()
            }
        }
        catch{
            print("Unable to save CoreData Context!")
        }
    }
    
    func deleteRecording(recordingName:String, sessionName:String){
        let context = appDel.persistentContainer.viewContext
        let locPredicate = NSPredicate(format: "location == %@", recordingName)
        let sessPredicate = NSPredicate(format: "session_name = %@", sessionName)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [sessPredicate, locPredicate])
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Recordings")
        request.predicate = predicate
        do{
            let results = try context.fetch(request)
            for data in results{
                context.delete(data as! NSManagedObject)
                try context.save()
            }
        }
        catch{
            print("Unable to save CoreData Context!")
        }
    }
    
    
    
}
