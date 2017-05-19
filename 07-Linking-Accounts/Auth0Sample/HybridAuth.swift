//
// HybridAuth.swift
// Auth0Sample
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation
import Auth0

@objc class HybridAuth: NSObject {

    private let authentication = Auth0.authentication()

    static func resume(_ url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }

    func showLogin(withScope scope: String, connection: String?, callback: @escaping (Error?, Credentials?) -> ()) {

        let webAuth = Auth0.webAuth()

        if let connection = connection {
            _ = webAuth.connection(connection)
        }

        webAuth
            .scope(scope)
            .start {
                switch $0 {
                case .failure(let error):
                    callback(error, nil)
                case .success(let credentials):
                    callback(nil, credentials)
                }
        }
    }

    func userInfo(accessToken: String, callback: @escaping (Error?, Profile?) -> ()) {
        self.authentication.userInfo(token: accessToken).start {
            switch $0 {
            case .success(let profile):
                callback(nil, profile)
            case .failure(let error):
                callback(error, nil)
            }
        }
    }

    func login(withUsernameOrEmail username: String, password: String, realm: String, audience: String? = nil, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.login(usernameOrEmail: username, password: password, realm: realm, audience: audience, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

    func signUp(withEmail email: String, username: String?, password: String, connection: String, userMetadata: [String: Any]?, scope: String, parameters: [String: Any], callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.signUp(email: email, username: username, password: password, connection: connection, userMetadata: userMetadata, scope: scope, parameters: parameters).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

    func renew(withRefreshToken refreshToken: String, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.renew(withRefreshToken: refreshToken, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

    func userProfile(withIdToken idToken: String, userId: String, callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
            .users(token: idToken)
            .get(userId, fields: [], include: true)
            .start {
                switch $0 {
                case .success(let user):
                    callback(nil, user)
                    break
                case .failure(let error):
                    callback(error, nil)
                    break
                }
        }
    }

    func patchProfile(withIdToken idToken: String, userId: String, metaData: [String: Any], callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
            .users(token: idToken)
            .patch(userId, userMetadata: metaData)
            .start {
                switch $0 {
                case .success(let user):
                    callback(nil, user)
                case .failure(let error):
                    callback(error, nil)
                }
        }
    }

    func linkUserAccount(withIdToken idToken: String, userId: String, otherAccountToken: String, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
            .users(token: idToken)
            .link(userId, withOtherUserToken: otherAccountToken)
            .start {
                switch $0 {
                case .success(let payload):
                    callback(nil, payload)
                case .failure(let error):
                    callback(error, nil)
                }
        }
    }

    func unlinkUserAccount(withIdToken idToken: String, userId: String, identity: Identity, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
            .users(token: idToken)
            .unlink(identityId: identity.identifier, provider: identity.provider, fromUserId: userId)
            .start {
                switch $0 {
                case .success(let payload):
                    callback(nil, payload)
                case .failure(let error):
                    callback(error, nil)
                }
        }
    }
    
}
