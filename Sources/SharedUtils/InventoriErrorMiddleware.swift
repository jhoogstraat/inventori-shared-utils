import Vapor

/// Structure of `ErrorMiddleware` default response.
internal struct ErrorResponse: Codable {
    /// Always `true` to indicate this is a non-typical JSON response.
    var error: Bool

    /// The reason for the error.
    var reason: String
}

func InventoriErrorMiddleware(environment: Environment) -> ErrorMiddleware {
    return .init({ req, error in

        // variables to determine
        let status: HTTPResponseStatus
        let reason: String
        let headers: HTTPHeaders

        // inspect the error type
        switch error {
        case let abort as AbortError:
            // this is an abort error, we should use its status, reason, and headers
            reason = abort.reason
            status = abort.status
            headers = abort.headers
        case let error as QueryError:
            switch error as QueryError {
                case .notFound:
                reason = "Entity not found"
                status = .notFound
                headers = [:]
            }
        default:
            // if not release mode, and error is debuggable, provide debug info
            // otherwise, deliver a generic 500 to avoid exposing any sensitive error info
            reason = environment.isRelease
                ? "Something went wrong."
                : String(describing: error)
            status = .internalServerError
            headers = [:]
        }
        
        // Report the error to logger.
        req.logger.report(error: error)
        
        // create a Response with appropriate status
        let response = Response(status: status, headers: headers)
        
        // attempt to serialize the error to json
        do {
            let errorResponse = ErrorResponse(error: true, reason: reason)
            response.body = try .init(data: JSONEncoder().encode(errorResponse))
            response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        } catch {
            response.body = .init(string: "Oops: \(error)")
            response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
        }
        return response
    })
}
