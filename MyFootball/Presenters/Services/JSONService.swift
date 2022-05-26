//
//  JSONService.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import Foundation


/// Generic call back
typealias DataRequestCallBack<T> = (Result<T, Error>) -> Void
typealias SuccessCallBack<T> = (T) -> Void
typealias ErrorCallBack = (Error) -> Void


/** URL and path of the API */
enum API: String {
    case url = "https://thesportsdb.com/api/v1/json/2/"
    case all_leagues = "all_leagues.php"
    case search_all_teams = "search_all_teams.php?l="
}


/** Service to execute JSON requests */
protocol JSONService {

    /** Fatch data */
    func fetch<T: Decodable>(url: URL?, success: @escaping SuccessCallBack<T>, failure: @escaping ErrorCallBack)
}


/** Main implementation of `JSONService` */
final class JSONServiceImpl: JSONService {

    /** Errors */
    private enum ServiceError: Error {
        case noUrl
        case noData
        case mimeType(type: String)
        case decode(error: Error)
        case unknown(error: Error)
    }

    /// Mime type for json response
    private let jsonMimeType = "application/json"

    /// URL session dependency
    private let sessionManager: URLSession

    /// JSON decoder dependency
    private let decoder: JSONDecoder


    init(
        sessionManager: URLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.sessionManager = sessionManager
        self.decoder = decoder
    }


    func fetch<T: Decodable>(url: URL?, success: @escaping SuccessCallBack<T>, failure: @escaping ErrorCallBack) {
        guard let url = url else {
            failure(ServiceError.noUrl)
            return
        }

        self.fetch(url: url) { (result: Result<T, Error>) in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure(error)
            }
        }
    }


    /** Send the request with session manager to fetch data */
    private func fetch<T: Decodable>(url: URL, _ completion: @escaping DataRequestCallBack<T>) {
        let task = self.sessionManager.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(ServiceError.unknown(error: error!)))
                return
            }

            if let mimeType = response?.mimeType, mimeType != self.jsonMimeType {
                completion(.failure(ServiceError.mimeType(type: mimeType)))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            do {
                let objects = try self.decoder.decode(T.self, from: data)
                completion(.success(objects))
            } catch {
                completion(.failure(ServiceError.decode(error: error)))
            }
        }
        task.resume()
    }
}
