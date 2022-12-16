//
//  ClassModel.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import Foundation
import FirebaseFirestore

class Service {
    
    let db: Firestore = Firestore.firestore()
    var loadTable: (() -> Void) = {}
    var courses = [Course]() {
        didSet {
            DispatchQueue.main.async {
                self.loadTable()
            }
        }
    }
    var courseIndex: Int?
    var pastCourses = [Course]() {
        didSet {
            DispatchQueue.main.async {
                self.loadTable()
            }
        }
    }
    var pastCourseIndex: Int?
    
    static let sharedInstance: Service = Service()
    
    
    // helper function for loadCourse & loadPastCourse
    private func load(task: @escaping (() async throws -> Void)) {
        Task.init {
            do {
                try await task()
            } catch {
                print(error)
            }
        }
    }
    
    func loadCourse() {
        load {
            self.courses =  try await self.getAllCourse(collectionId: "courses")
        }
    }
    
    func loadPastCourse() {
        load {
            self.pastCourses = try await self.getAllCourse(collectionId: "past-courses")
        }
    }
    
    // GET All Course from firebase (async)
    private func getAllCourse(collectionId: String) async throws -> [Course] {
        let snapshot = try await db.collection(collectionId).getDocuments()
        
        var courses: [Course] = []
        for document in snapshot.documents {
            let documentId = document.documentID
            let data = document.data()
            courses.append(decodeCourse(id: documentId, data: data))
        }
        return courses
    }
    
    // private helper function for JSON -> Object
    private func decodeCourse(id: String, data: [String : Any]) -> Course {
        let title = (data["title"] as? String)!
        let grade = (data["grade"] as? Int)!
        let courseworks = (data["courseworks"] as? [[String : Any]])!
        var works: [Work] = []
        for work in courseworks {
            works.append(Work(
                title: (work["title"] as? String)!,
                due: (work["due"] as? Timestamp)!.dateValue(),
                isNotify: (work["isNotify"] as? Bool)!,
                notifyId: work["notifyId"] as? String
            ))
        }
        works.sort { $0.due < $1.due }
        return Course(id: id, title: title, courseworks: works, grade: grade)
    }
    
    // private helper function for convert Object -> JSON
    private func encodeWork(work: Work) -> [String : Any] {
        var data = [String : Any]()
        data["title"] = work.title
        data["due"] = work.due
        data["isNotify"] = work.isNotify
        data["notifyId"] = work.notifyId
        return data
    }
    
    private func encodeCourse(course: Course) -> [String : Any] {
        var data = [String : Any]()
        data["title"] = course.title
        data["grade"] = course.grade
        var works: [[String : Any]] = []
        for work in course.courseworks {
            works.append(encodeWork(work: work))
        }
        data["courseworks"] = works
        return data
    }
    
    // get course (from singleton)
    func getCourse() -> Course? {
        return courseIndex == nil ? nil : courses[courseIndex!]
    }
    
    // get past course (from singleton)
    func getPastCourse() -> Course? {
        return pastCourseIndex == nil ? nil : pastCourses[pastCourseIndex!]
    }
    
    /* update course information methods */
    // update a work for course
    func updateWork(workIndex: Int, newWork: Work) {
        let course = courses[courseIndex!]
        let work = course.courseworks[workIndex]
        // copy by value is crucial
        work.title = newWork.title
        work.due = newWork.due
        work.isNotify = newWork.isNotify
        work.notifyId = newWork.notifyId
    }
    
    // add a work for course
    func addWork(newWork: Work) {
        let course = courses[courseIndex!]
        course.courseworks.append(newWork)
    }
    
    // delete a work for course
    func deleteWork(workIndex: Int) {
        let course = courses[courseIndex!]
        course.courseworks.remove(at: workIndex)
    }
    
    // update the title for course
    func updateTitle(title: String) {
        let course = courses[courseIndex!]
        course.title = title
    }
    
    // save modification of course to firestore
    func saveCourseToDB() {
        let course = courses[courseIndex!]
        db.collection("courses").document(course.id).setData(encodeCourse(course: course))
    }
    
    // add new course to firestore
    func addEmptyCourseToDB() {
        let course = Course(id: "", title: "", courseworks: [], grade: 0)
        let id = db.collection("courses").addDocument(data: encodeCourse(course: course)).documentID
        courses.append(Course(
            id: id,
            title: "",
            courseworks: [],
            grade: 0
        ))
        courseIndex = courses.count - 1
    }
    
    // delete a course from database
    func deleteCourse() {
        guard let courseIndex = courseIndex else {
            return
        }
        let course = courses.remove(at: courseIndex)
        if courses.count == 0 {
            self.courseIndex = nil
        } else {
            if courseIndex <= 0 {
                self.courseIndex = 0
            } else {
                self.courseIndex = courseIndex - 1
            }
        }
        db.collection("courses").document(course.id).delete()
    }
    
    // move a course to pastCourse
    func archiveCourse() {
        let course = courses.remove(at: courseIndex!)
        pastCourses.append(course)
        db.collection("courses").document(course.id).delete()
        db.collection("past-courses").addDocument(data: encodeCourse(course: course))
    }
    
    
    /* update past course information methods */
    // delete a past course
    func deletePastCourse() {
        let course = pastCourses.remove(at: pastCourseIndex!)
        db.collection("past-courses").document(course.id).delete()
    }
    
    // put back a past course to course
    func putBackCourse() {
        let course = pastCourses.remove(at: pastCourseIndex!)
        courses.append(course)
        db.collection("past-courses").document(course.id).delete()
        db.collection("courses").addDocument(data: encodeCourse(course: course))
    }
    
}
