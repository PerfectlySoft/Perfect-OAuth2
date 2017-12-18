//
//  Vk.swift
//  OAuth2
//
//  Created by Alif on 15/12/2017.
//  Perfect Authentication / Auth Providers
//  Inspired by Turnstile (Edward Jiang)
//
//  Created by Saroar Khandoker on 2017-12-15
//
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import Foundation
import PerfectHTTP
import PerfectSession

/// Vk configuration singleton
public struct VkConfig {

    /// AppID obtained from registering app with Vk (Also known as Client ID)
    public static var appid = ""

    /// Secret associated with AppID (also known as Client Secret)
    //ss7O6Aw2jIDK4nZw5YFx
    public static var secret = ""

    /// Where should Vk redirect to after Authorization
    //http://localhost:8181/auth/response/vk
    public static var endpointAfterAuth = ""

    /// Where should the app redirect to after Authorization & Token Exchange
    //http://localhost:8181
    public static var redirectAfterAuth = ""

    public init(){}
}

/**
 Vk allows you to authenticate against Vk for login purposes.
 */

public class Vk: OAuth2 {
    /**
     Create a Vk object. Uses the Client ID and Client Secret from the
     Vk Developers Console.
     https://oauth.vk.com/authorize?client_id=1&redirect_uri=http://examp
     */
    public init(clientID: String, clientSecret: String) {
        let tokenURL = ""
        let authorizationURL = ""

        super.init(clientID: clientID, clientSecret: clientSecret, authorizationURL: authorizationURL, tokenURL: tokenURL)
    }

    private var appAccessToken: String {
        return clientID + "%7C" + clientSecret
    }

    /// After exchanging token, this function retrieves user information from Vk
    public func getUserData(_ accessToken: String) -> [String: Any] {

        let url = "https://api.vk.com/method/getProfiles?&access_token=\(accessToken)"

        let request = makeRequest(.get, url)

        let response = request["response"] as? [Any]

        guard let data = response?.last as? [String: Any] else {
            print("empty response")
            return ["error": "empty vk data"]
        }

        guard
            let id = data["uid"],
            let first_name = data["first_name"],
            let last_name = data["last_name"]
        else {
            print("empty data")
            return ["error": "empty vk data"]
        }

        var out = [String: Any]()

        out["userid"] = "\(id)"
        out["first_name"] = first_name as? String
        out["last_name"] = last_name as? String
        out["photo_200"] = digIntoDictionary(mineFor: ["url"], data: data) as? String ?? ""

        print("out", out)
        return out
    }

    /// Vk-specific exchange function
    public func exchange(request: HTTPRequest, state: String) throws -> OAuth2Token {
        return try exchange(request: request, state: state, redirectURL: VkConfig.endpointAfterAuth)
    }

    /// Vk-specific login link
    public func getLoginLink(state: String, request: HTTPRequest, scopes: [String] = []) -> String {
        return getLoginLink(redirectURL: VkConfig.endpointAfterAuth, state: state, scopes: scopes)
    }


    /// Route handler for managing the response from the OAuth provider
    /// Route definition would be in the form
    /// ["method":"get", "uri":"/auth/response/vk", "handler":Vk.authResponse]
    public static func authResponse(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let vk = Vk(clientID: VkConfig.appid, clientSecret: VkConfig.secret)

            do {
                guard let state = request.session?.data["csrf"] else {
                    throw OAuth2Error(code: .unsupportedResponseType)
                }

                let t = try vk.exchange(request: request, state: state as! String)

                request.session?.data["accessToken"] = t.accessToken
                request.session?.data["refreshToken"] = t.refreshToken

                let userdata = vk.getUserData(t.accessToken)

                request.session?.data["loginType"] = "vk"

                if let i = userdata["userid"] {
                    request.session?.userid = i as! String
                }
                if let i = userdata["first_name"] {
                    request.session?.data["firstName"] = i as! String
                }
                if let i = userdata["last_name"] {
                    request.session?.data["lastName"] = i as! String
                }
                if let i = userdata["picture"] {
                    request.session?.data["picture"] = i as! String
                }

            } catch {
                print(error)
            }
            response.redirect(path: VkConfig.redirectAfterAuth, sessionid: (request.session?.token)!)
        }
    }

    /// Route handler for managing the sending of the user to the OAuth provider for approval/login
    /// Route definition would be in the form
    /// ["method":"get", "uri":"/to/vk", "handler":Vk.sendToProvider]
	public static func sendToProvider(request: HTTPRequest, response: HTTPResponse) {
		// Add secure state token to session
		// We expect to get this back from the auth
		let vk = Vk(clientID: VkConfig.appid, clientSecret: VkConfig.secret)
		response.redirect(path: vk.getLoginLink(state: request.session?.data["csrf"] as! String, request: request))
    }
}
