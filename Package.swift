import PackageDescription

let package = Package(
    name: "OAuth2",
    targets: [],
    dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/PerfectLib.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 1),
		.Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Session.git", majorVersion: 1)
	]

)
