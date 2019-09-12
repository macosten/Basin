import Vapor

extension Future {
    func returnOkay() throws -> Future<HTTPResponse> {
        return map(to: HTTPResponse.self) { _ in
            return HTTPResponse(status: .ok)
        }
    }
}
