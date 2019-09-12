import Vapor

extension Future {
    func returnOkayStatus() throws -> Future<Status> {
        return map(to: Status.self) { _ in
            return Status(status: "Success")
        }
    }
}
