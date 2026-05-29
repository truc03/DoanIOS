//
//  User.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/28.
//

import Foundation

class User {
    private var _uid: String
    private var _username: String
    private var _email: String
    private var _role: Bool
    
    init(uid: String, username: String, email: String, role: Bool) {
        self._uid = uid
        self._username = username
        self._email = email
        self._role = role
    }
    
    public var uid: String {
        get {
            return _uid
        }
        set {
            _uid = newValue
        }
    }
    
    public var username: String {
        get {
            return _username
        }
        set {
            _username = newValue
        }
    }
    
    public var email: String {
        get {
            return _email
        }
        set {
            _email = newValue
        }
    }
    
    public var role: Bool {
        get {
            return _role
        }
        set {
            _role = newValue
        }
    }
}
