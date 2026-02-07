import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var phoneNumber: String?
    var profileImageURL: String?
    var householdID: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        phoneNumber: String? = nil,
        profileImageURL: String? = nil,
        householdID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.householdID = householdID
    }
}
