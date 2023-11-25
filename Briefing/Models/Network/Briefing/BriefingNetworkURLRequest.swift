//
//  BriefingNetworkURLRequest.swift
//  Briefing
//
//  Created by 이전희 on 2023/09/23.
//

import Foundation
import Alamofire

// MARK: - Category Mapping
extension BriefingCategory {
    var keywordType: BriefingNetworkURLRequest.KeywordsType {
        switch self {
        case .social: return .social
        case .science: return .science
        case .global: return .global
        #warning("replace social to economy, can not find economy tpe")
        case .economy: return .social
        case .culture: return .korea
        }
    }
}


// TODO: - POST
public struct BriefingNetworkURLRequest: BFURLRequest {
    var accessToken: String?
    var urlRequest: URLRequest
    var httpMethod: BFHTTPMethod
    var path: Path
    var httpBody: Data?
    var query: [String: String]?
    var timeoutInterval: TimeInterval
    
    init(_accessToken: String?,
         _urlRequest: URLRequest,
         _method: BFHTTPMethod,
         _path: Path,
         _httpBody: Data?,
         _query: [String : String]?,
         _timeoutInterval: TimeInterval) {
        self.accessToken = _accessToken
        self.urlRequest = _urlRequest
        self.httpMethod = _method
        self.path = _path
        self.httpBody = _httpBody
        self.query = _query
        self.timeoutInterval = _timeoutInterval
    }
}

// MARK: - URLRequest Management
extension BriefingNetworkURLRequest {
    enum KeywordsType: String {
        case korea = "KOREA"
        case global = "GLOBAL"
        case social = "SOCIAL"
        case science = "SCIENCE"
    }
    
    enum Path: BFPath {
        case root
        case keywords
        case briefingCard(id: Int)
        case chattings(id: Int?=nil)
        case scrap
        case deleteScrap(id: Int, memberId: Int)
        case fetchScrap(memberId: Int)
        
        var path: String {
            switch self {
            case .root: return ""
            case .keywords: return "briefings/temp"
            case let .briefingCard(id): return "briefings/\(id)"
            case let .chattings(id):
                guard let id = id else { return "chattings" }
                return "chattings/\(id)"
            case .scrap: return "scraps/briefings"
            case let .fetchScrap(memberId): return "scraps/briefings/members/\(memberId)"
            case let .deleteScrap(id, memberId):
                return "scraps/briefings/\(id)/members/\(memberId)"
            }
        }
        
        var available: [BFHTTPMethod] {
            switch self {
            case .root: return [.get]
            case .keywords: return [.get, .post]
            case .briefingCard: return [.get]
            case .chattings: return [.get, .post]
            case .scrap: return [.post]
            case .fetchScrap: return [.get]
            case .deleteScrap: return [.delete]
            }
        }
    }
    
    enum QueryKey: String, BFQueryKey {
        case date
        case type
    }
    
    enum HTTPBodyKey: String, BFHTTPBodyKey {
        case memberId
        case briefingId
    }
}
