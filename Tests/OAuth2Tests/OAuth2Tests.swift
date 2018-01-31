import XCTest
@testable import OAuth2

class OAuth2Tests: XCTestCase {



	func testGitHub() {
		let g = GitHub(clientID: "2775e90580918e3d06e7", clientSecret: "e83b53d94ab1d7680ef260c2c17121fd297f2c7e")
		let x = g.getLoginLink(redirectURL: "http://localhost:8181/callback", state: "xxx", scopes: ["repo"])
		print(x)
    }


    static var allTests : [(String, (OAuth2Tests) -> () throws -> Void)] {
        return [
            ("testGitHub", testGitHub),
        ]
    }
}
