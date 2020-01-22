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

    private var authentication = Auth0.authentication()

    @objc
    static func resume(_ url: URL, options: [A0URLOptionsKey: Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }

    @objc
    func showLogin(withScope scope: String, connection: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        let webAuth = Auth0.webAuth()

        if let connection = connection {
            _ = webAuth.connection(connection)
        }

        webAuth
            .scope(scope)
            .audience("https://" + clientInfo.domain + "/api/v2/")
            .start {
                switch $0 {
                case .failure(let error):
                    callback(wrapError(error), nil)
                case .success(let credentials):
                    callback(nil, credentials)
                }
        }
    }

    @objc
    func userInfo(accessToken: String, callback: @escaping (Error?, UserInfo?) -> ()) {
        self.authentication.userInfo(withAccessToken: accessToken).start {
            switch $0 {
            case .success(let profile):
                callback(nil, profile)
            case .failure(let error):
                callback(wrapError(error), nil)
            }
        }
    }

    @objc
    func login(withUsernameOrEmail username: String, password: String, realm: String, audience: String? = nil, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        _ = self.authentication.logging(enabled: true)
        self.authentication.login(usernameOrEmail: username, password: password, realm: realm, audience: audience, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(wrapError(error), nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

    @objc
    func signUp(withEmail email: String, username: String?, password: String, connection: String, userMetadata: [String: Any]?, scope: String, parameters: [String: Any], callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.signUp(email: email, username: username, password: password, connection: connection, userMetadata: userMetadata, scope: scope, parameters: parameters).start {
            switch $0 {
            case .failure(let error):
                callback(wrapError(error), nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

    @objc
    func renew(withRefreshToken refreshToken: String, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.renew(withRefreshToken: refreshToken, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(wrapError(error), nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }

   @objc
    func userProfile(withAccessToken accessToken: String, userId: String, callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
            .users(token: accessToken)
            .get(userId, fields: [], include: true)
            .start {
                switch $0 {
                case .success(let user):
                    callback(nil, user)
                    break
                case .failure(let error):
                    callback(wrapError(error), nil)
                    break
                }
        }
    }

    @objc
    func patchProfile(withAccessToken accessToken: String, userId: String, metaData: [String: Any], callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
            .users(token: accessToken)
            .patch(userId, userMetadata: metaData)
            .start {
                switch $0 {
                case .success(let user):
                    callback(nil, user)
                case .failure(let error):
                    callback(wrapError(error), nil)
                }
        }
    }

    @objc
    func linkUserAccount(withAccessToken accessToken: String, userId: String, otherAccountToken: String, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
            .users(token: accessToken)
            .link(userId, withOtherUserToken: otherAccountToken)
            .start {
                switch $0 {
                case .success(let payload):
                    callback(nil, payload)
                case .failure(let error):
                    callback(wrapError(error), nil)
                }
        }
    }

    @objc
    func unlinkUserAccount(withAccessToken accessToken: String, userId: String, identity: Identity, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
            .users(token: accessToken)
            .unlink(identityId: identity.identifier, provider: identity.provider, fromUserId: userId)
            .start {
                switch $0 {
                case .success(let payload):
                    callback(nil, payload)
                case .failure(let error):
                    callback(wrapError(error), nil)
                }
        }
    }

    @objc
    func logOutUser(callback: @escaping(Bool) -> Void){
        Auth0
            .webAuth()
            .clearSession(federated:false){
                callback($0)
            }
    }

}

func wrapError(_ error: Error?) -> NSError? {
    guard let error = error else { return nil }
    let nsError = error as NSError
    let cleanUserInfo: [String: Any] = [NSLocalizedDescriptionKey: error.localizedDescription]
    return NSError(domain: nsError.domain, code: nsError.code, userInfo: cleanUserInfo)
}

func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
    guard
        let path = bundle.path(forResource: "Auth0", ofType: "plist"),
        let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
    }

    guard
        let clientId = values["ClientId"] as? String,
        let domain = values["Domain"] as? String
        else {
            print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
            print("File currently has the following entries: \(values)")
            return nil
    }
    return (clientId: clientId, domain: domain)
}
