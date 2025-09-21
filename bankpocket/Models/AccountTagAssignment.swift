import Foundation
import SwiftData

@Model
final class AccountTagAssignment {
    @Attribute(.unique) var id: UUID
    var account: BankAccount
    var tag: Tag
    var createdAt: Date

    init(account: BankAccount, tag: Tag) {
        self.id = UUID()
        self.account = account
        self.tag = tag
        self.createdAt = Date()
        account.tagAssignments.append(self)
        tag.tagAssignments.append(self)
    }
}
