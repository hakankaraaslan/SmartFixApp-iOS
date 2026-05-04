//
//  Encodable.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 3.05.2026.
//

import Foundation

extension Encodable {

    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: Any]
        else {
            return [:]
        }

        return dictionary
    }
}

extension Decodable {

    static func fromDictionary(_ dictionary: [String: Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let object = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }

        return object
    }
}
