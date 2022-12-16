//
//  WorkModel.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/13.
//

import Foundation
import FirebaseFirestore

class WorkService {
    let db: Firestore = Firestore.firestore()
    var works = [Work]()
    
    static let sharedInstance: WorkService = WorkService()
    
    private func populateFromDB() async throws {
        let snapshot = try await db.collection("tasks").getDocuments()
        for work in snapshot.documents {
//            let documentId = work.documentID
            var data = work.data()
            data["id"] = work.documentID
            
        }
    }
}
