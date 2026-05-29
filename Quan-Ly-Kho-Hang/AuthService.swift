//
//  AuthService.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/28.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import OSLog

class AuthService {
    // Doc du lieu tren Firestore va Firebase
    public func readUsersServices(completion: @escaping ([User]) -> Void) {
        // Tao ket noi tang Firestore
        let db = Firestore.firestore()
        
        // Doc du lieu trong tang Firestore
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                os_log("\(error.localizedDescription)")
            }
            else {
                // Luu tru du lieu sau khi doc du lieu
                var getAllUsers: [User] = []
                
                // Lay du lieu goc trong tang Firestore va Firebase
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                // Duyet tung du lieu
                for document in documents {
                    // Lay 1 du lieu goc User
                    let data = document.data()
                    
                    // Lay du lieu goc cua User
                    let uid = data["uid"] as? String ?? ""
                    let username = data["username"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let role = data["role"] as? Bool ?? false
                        
                    // Tao va them User vao mang getAllUsers
                    let user = User(uid: uid, username: username, email: email, role: role)
                    getAllUsers.append(user)
                }
                
                // Tat ca du lieu load xong va chuyen vao completion
                completion(getAllUsers)
            }
        }
    }
    
    // Them nguoi dung len Firebase va Firestore
    public func createAccountService(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Tao ket noi tang Firestore
        let db = Firestore.firestore()
        
        // Tao doi tuong nguoi dung
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                os_log("\(error.localizedDescription)")
            }
            else {
                // Lay uid sau khi tao xong nguoi dung
                guard let uid = result?.user.uid else {
                    completion(false)
                    return
                }
                
                // Them du lieu vao tang Firestore
                db.collection("users").document(uid).setData(["email": email, "role": false, "username": username]) { error in
                    // Kiem tra loi khi them nguoi dung
                    if let error = error {
                        os_log("\(error.localizedDescription)")
                        completion(false)
                    }
                    else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    // Kiem tra dang nhap nguoi dung
    public func loginAccount(username: String, password: String, completion: @escaping (Bool) -> Void) {
        // Tao ket noi tang Firestore
        let db = Firestore.firestore()
        
        // Doc du lieu users bang cach tim kiem cot username
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                os_log("\(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Lay du lieu dau tien trong users
            guard let document = snapshot?.documents.first else {
                completion(false)
                return
            }
            
            // Lay du lieu goc cua user dau tien duoc duyet
            let data = document.data()
            
            // Lay email trong Firebase va dich nguoc thanh String trong Firebase
            let email = data["email"] as? String ?? ""
            
            // Goi API Firebase Auth va kiem tra bang email va mat khau
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    os_log("\(error.localizedDescription)")
                    completion(false)
                }
                else {
                    completion(true)
                }
            }
        }
    }
    
    // Kiem tra quyen truy cap Login
    public func checkRoleAccount(username: String, completion: @escaping (Bool) -> Void) {
        // Doc du lieu tat ca nguoi dung
        readUsersServices(completion: { users in
            // Lay role nguoi dung
            var check = false
            
            for user in users {
                if user.username == username {
                    check = user.role
                    break
                }
            }
            
            // Neu check = false -> User, neu check = true -> Admin
            completion(check)
        })
    }
    
    // Kiem tra email
    public func checkEmail(email: String, completion: @escaping (Bool) -> Void) {
        // Tao ket noi tang Firestore
        let db = Firestore.firestore()
        
        // Tim kiem va so sanh cot email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                os_log("\(error.localizedDescription)")
                completion(false)
                return
            }
            else {
                // Lay du lieu trong tang Firestore
                guard let document = snapshot?.documents else {
                    completion(false)
                    return
                }
                
                // Tra ve true neu khong rong
                completion(!document.isEmpty)
            }
        }
    }
    
    // Gui email
    public func sendEmail(email: String) {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if let error = error {
                os_log("\(error.localizedDescription)")
                return
            }
        }
    }
    
    // Kiem tra email da duoc xac thuc
    public func clickedEmail(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error = error {
                os_log("\(error.localizedDescription)")
                return
            }
            
            if Auth.auth().currentUser?.isEmailVerified == true {
                completion(true)
            }
            else {
                completion(false)
            }
        })
    }
}
