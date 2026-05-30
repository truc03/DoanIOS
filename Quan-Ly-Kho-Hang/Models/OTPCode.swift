//
//  OTPCode.swift
//  Quan-Ly-Kho-Hang
//
//  Created by vantrong10e1 on 2026/05/30.
//

import Foundation
import FirebaseFirestore

class OTPCode {
    private var _email: String
    private var _otp: Int
    private var _createdAt: Timestamp
    
    init(email: String, otp: Int, createdAt: Timestamp) {
        self._email = email
        self._otp = otp
        self._createdAt = createdAt
    }
    
    public var email: String {
        get {
            return _email
        }
        set {
            _email = newValue
        }
    }
    
    public var otp: Int {
        get {
            return _otp
        }
        set {
            _otp = newValue
        }
    }
    
    public var createdAt: Timestamp {
        get {
            return _createdAt
        }
        set {
            _createdAt = newValue
        }
    }
}

