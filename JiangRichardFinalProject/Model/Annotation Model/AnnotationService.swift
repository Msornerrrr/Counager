//
//  AnnotationService.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/7.
//

import Foundation
import FirebaseFirestore

class AnnotationService {
    
    let db: Firestore = Firestore.firestore()
    var loadMap: (() -> Void) = {}
    var annotations = [Annotation]()
    var idList = [String]()
    
    static let sharedInstance: AnnotationService = AnnotationService()
    
    
    func load() {
        Task.init {
            do {
                annotations = try await getAllAnnotations()
                self.loadMap()
            } catch {
                print(error)
            }
        }
    }
    
    func save() {
        // clear documents
        for id in idList {
            db.collection("annotations").document(id).delete()
        }

        // re-populate documents
        for annotation in annotations {
            db.collection("annotations").addDocument(data: [
                "latitude": annotation.latitude,
                "longitude": annotation.longitude
            ])
        }
    }
    
    private func getAllAnnotations() async throws -> [Annotation] {
        let snapshot = try await db.collection("annotations").getDocuments()
        
        var annotations: [Annotation] = []
        for document in snapshot.documents {
            let data = document.data()
            idList.append(document.documentID)
            annotations.append(Annotation(
                title: data["title"] as? String,
                latitude: (data["latitude"] as? NSNumber)!,
                longitude: (data["longitude"] as? NSNumber)!
            ))
        }
        return annotations
    }
}
