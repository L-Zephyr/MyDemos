// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





// MARK: - Person Codable
extension Person {
    enum CodingKeys: String, CodingKey {
        case myName = "my_name"
        case boy 
        case married 
        case array 
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        myName = try container.decode(String.self, forKey: .myName)
        if let r = try? container.decode(Bool.self, forKey: .boy) {
            boy = r
        } else if let r = try? container.decode(Int.self, forKey: .boy) {
            boy = (r == 0 ? false : true)
        }
        else {
            let context = DecodingError.Context(codingPath: [CodingKeys.boy], debugDescription: "Expected to decode Bool")
            throw DecodingError.typeMismatch(Bool.self, context) 
        }
        if let r = try? container.decode(Bool.self, forKey: .married) {
            married = r
        } else if let r = try? container.decode(Int.self, forKey: .married) {
            married = (r == 0 ? false : true)
        }
        else {
            married = false
        }
        array = try container.decodeIfPresent([School].self, forKey: .array) ?? []
    }
}

// MARK: - School Codable
extension School {
    enum CodingKeys: String, CodingKey {
        case name 
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
}

