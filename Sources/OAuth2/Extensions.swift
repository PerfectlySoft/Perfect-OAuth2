//
//  Extensions.swift
//  Perfect Authentication / OAuth2
//
//  Created by Jonathan Guthrie on 2016-10-24.
//
//

import PerfectLib
import Foundation

func urlencode(dict: [String: String]) -> String {
	
	let httpBody = dict.map { (key, value) in
		return key + "=" + value
		}
		.joined(separator: "&")
	//		.data(using: .utf8)
	
	return httpBody
	
}

fileprivate extension String {
	func parseHTTPStatus() -> (version: String, code: Int, status: String)? {
		let line = self.trimmingCharacters(in: .whitespaces)
		guard line.lowercased().hasPrefix("http/") else {
			return nil
		}
		var http = line.components(separatedBy: .whitespaces)
		
		// parse the tokens
		let version = http[0].trimmingCharacters(in: .whitespaces)
		let code = Int(http[1]) ?? 0
		http.removeFirst(2)
		let status = http.joined(separator: " ")
		return (version: version, code: code, status: status)
	}
	func parseHeader() -> (key: String, value: String)? {
		guard let range = self.range(of: ":") else { return nil }
		let key = String(self[self.startIndex..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
		let value = String(self[range.upperBound..<self.endIndex]).trimmingCharacters(in: .whitespaces)
		return (key: String(key), value: String(value))
	}
}


/// A lightweight HTTP Response Header Parser
/// transform the header into a dictionary with http status code
class HTTPHeaderParser {
	
	private var _dic: [String:String] = [:]
	private var _version: String? = nil
	private var _code : Int = -1
	private var _status: String? = nil
	
	/// HTTPHeaderParser default constructor
	/// - header: the HTTP response header string
	public init(header: String) {
		
		// parse the header into lines,
		header.components(separatedBy: .newlines)
			// remove all null lines
			.filter{!$0.isEmpty}
			// map each line into the dictionary
			.forEach {
				
				if let (version, code, status) = $0.parseHTTPStatus() {
					_version = version
					_code = code
					_status = status
				} else if let (key, val) = $0.parseHeader() {
					_dic.updateValue(val, forKey: key)
				}
		}
	}
	
	/// HTTP response header information by keywords
	public var variables: [String:String] {
		get { return _dic }
	}
	
	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let code = 200
	public var code: Int {
		get { return _code }
	}
	
	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let status = "OK"
	public var status: String {
		get { return _status ?? "" }
	}
	
	/// The HTTP response code, e.g.,, HTTP/1.1 200 OK -> let version = "HTTP/1.1"
	public var version: String {
		get { return _version ?? "" }
	}
}
