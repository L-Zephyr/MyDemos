// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT








// MARK: - ClassModel Codable
extension ClassModel {
    enum CodingKeys: String, CodingKey {
        case data1 
        case data2 
    }

}

// MARK: - ConcreteType Codable
extension ConcreteType {
    enum CodingKeys: String, CodingKey {
        case key
        case option1_0
        case option2_0
        case option3_0
        case option3_1
        case option3_2
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .option1(let val0):
                try container.encode("option1", forKey: .key)
                try container.encode(val0, forKey: .option1_0)
            case .option2(let val0):
                try container.encode("option2", forKey: .key)
                try container.encode(val0, forKey: .option2_0)
            case .option3(let val0,let val1,let val2):
                try container.encode("option3", forKey: .key)
                try container.encode(val0, forKey: .option3_0)
                try container.encode(val1, forKey: .option3_1)
                try container.encode(val2, forKey: .option3_2)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        switch key {
        case "option1":
            self = .option1(
                try container.decode(String.self, forKey: .option1_0)
            )
        case "option2":
            self = .option2(
                try container.decode(School.self, forKey: .option2_0)
            )
        default:
            self = .option3(
                try container.decode(String.self, forKey: .option3_0)
            ,
                try container.decode(School.self, forKey: .option3_1)
            ,
                try container.decode(Int.self, forKey: .option3_2)
            )
        }
    }
}

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

