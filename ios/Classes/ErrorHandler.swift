//
//  ErrorHandler.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 22.11.2021.
//

enum ErrorCode: String {
    // SKError
    case unknown = "E_UNKNOWN"
    case clientInvalid = "E_CLIENT_INVALID"
    case paymentCancelled = "E_USER_CANCELLED"
    case paymentInvalid = "E_PAYMENT_INVALID"
    case paymentNotAllowed = "E_PAYMENT_NOT_ALLOWED"
    case storeProductNotAvailable = "E_STORE_PRODUCT_NOT_AVAILABLE"
    case cloudServicePermissionDenied = "E_CLOUD_SERVICE_DENIED"
    case cloudServiceNetworkConnectionFailed = "E_NETWORK_CONNECTION"
    case cloudServiceRevoked = "E_CLOUD_SERVICE_REVOKED"
    case privacyAcknowledgementRequired = "E_PRIVACY_ACKNOWLEDGEMENT_REQUIREd"
    case unauthorizedRequestData = "E_UNAUTHORIZED"
    case invalidOfferIdentifier = "E_INVALID_OFFER"
    case invalidSignature = "E_INVALID_SIGNATURE"
    case missingOfferParams = "E_MISSING_OFFER_PARAMS"
    case invalidOfferPrice = "E_INVALID_OFFER_PARAMS"
    case overlayCancelled = "E_OVERLAY_CANCELLED"
    case overlayInvalidConfiguration = "E_OVERLAY_CONFIGURATION"
    case overlayTimeout = "E_OVERLAY_TIMEOUT"
    case ineligibleForOffer = "E_INELIGIBLE_FOR_OFFER"
    case unsupportedPlatform = "E_UNSUPPORTED_PLATFORM"
    case overlayPresentedInBackgroundScene = "E_OVERLAY_IN_BACKGROUND"
    
    // Custom errors
    case serviceNotReady = "E_SERVICE_NOT_READY"
    case argumentError = "E_MISSING_ARGUMENT"
    case finishTransactionError = "E_FINISH_TRANSACTION"
    case requestAlreadyProcessing = "E_REQUEST_PROCESSING"
    case noSuchInAppPurchase = "E_IN_APP_PURCHASE_MISSING"
}

extension ErrorCode {
    var defaultMessage: String {
        switch self {
        case .unknown:
            return "unknow error"
        case .clientInvalid:
            return "client is not allowed to issue the request"
        case .paymentCancelled:
            return "user cancelled the request"
        case .paymentInvalid:
            return "purchase identifier was invalid"
        case .paymentNotAllowed:
            return "this device is not allowed to make the payment"
        case .storeProductNotAvailable:
            return "product is not available in the current storefront"
        case .cloudServicePermissionDenied:
            return "user has not allowed access to cloud service information"
        case .cloudServiceNetworkConnectionFailed:
            return "the device could not connect to the nework"
        case .cloudServiceRevoked:
            return "user has revoked permission to use this cloud service"
        case .privacyAcknowledgementRequired:
            return "user needs to acknowledge Apple's privacy policy"
        case .unauthorizedRequestData:
            return "app is attempting to use SKPayment's requestData property, but does not have the appropriate entitlement"
        case .invalidOfferIdentifier:
            return "specified subscription offer identifier is not valid"
        case .invalidSignature:
            return "the cryptographic signature provided is not valid"
        case .missingOfferParams:
            return "One or more parameters from SKPaymentDiscount is missing"
        case .invalidOfferPrice:
            return "price of the selected offer is not valid (e.g. lower than the current base subscription price)"
        case .ineligibleForOffer:
            return "user is not eligible for the subscription offer"
        case .argumentError:
            return "needed arguments not provided"
        case .finishTransactionError:
            return "can't finish transaction in .purchasing state"
        case .requestAlreadyProcessing:
            return "previous request is not finished yet"
        case .noSuchInAppPurchase:
            return "in app purchase with provided sku is missing in cache, try to "
        case .serviceNotReady:
            return "swift in app purchases service is not initialized yet, try again later."
        default:
            return ""
        }
    }
    
    static var SKErrorArray: [ErrorCode] {
        return [
            .unknown,
            .clientInvalid,
            .paymentCancelled,
            .paymentInvalid,
            .paymentNotAllowed,
            .storeProductNotAvailable,
            .cloudServicePermissionDenied,
            .cloudServiceNetworkConnectionFailed,
            .cloudServiceRevoked,
            .privacyAcknowledgementRequired,
            .unauthorizedRequestData,
            .invalidOfferIdentifier,
            .invalidSignature,
            .missingOfferParams,
            .invalidOfferPrice,
            .overlayCancelled,
            .overlayInvalidConfiguration,
            .overlayTimeout,
            .ineligibleForOffer,
            .unsupportedPlatform,
            .overlayPresentedInBackgroundScene,
        ]
    }
}

protocol ErrorHandler {
    func buildError(_ code: ErrorCode, _ message: String?, _ details: Any?) -> FlutterError
    func buildSKError(_ error: NSError) -> FlutterError
    func buildStandardError(_ code: ErrorCode) -> FlutterError
    func buildArgumentError(_ message: String) -> FlutterError
    
    func buildSKErrorMap(_ error: NSError, _ debugMessage: String?) -> [String: String?]
    func buildErrorMap(_ code: String, _ message: String, _ debugMessage: String?) -> [String: String?]
}

struct ErrorHandlerImpl: ErrorHandler {
    func buildError(_ code: ErrorCode, _ message: String?, _ details: Any?) -> FlutterError {
        return FlutterError(code: code.rawValue, message: message, details: details)
    }
    
    func buildStandardError(_ code: ErrorCode) -> FlutterError {
        return buildError(code, code.defaultMessage, nil)
    }
    
    func buildArgumentError(_ message: String) -> FlutterError {
        return buildError(ErrorCode.argumentError, message, nil)
    }
    
    func buildSKError(_ error: NSError) -> FlutterError {
        let skError = buildSkError(error.code)
        return FlutterError(code: skError.rawValue, message: skError.defaultMessage, details: nil)
    }
    
    func buildErrorMap(_ code: String, _ message: String, _ debugMessage: String?)  -> [String: String?] {
        return [
            "code": code,
            "message": message,
            "debugMessage" : debugMessage
        ]
    }
    
    func buildSKErrorMap(_ error: NSError, _ debugMessage: String?) -> [String: String?] {
        let skError = buildSkError(error.code)
        return [
            "code": skError.rawValue,
            "debugMessage" : debugMessage,
            "message": skError.defaultMessage
        ]
    }
    
    private func buildSkError(_ code: Int) -> ErrorCode {
        if code >= 0 && code < ErrorCode.SKErrorArray.count {
            return ErrorCode.SKErrorArray[code]
        }
        
        return ErrorCode.SKErrorArray[0]
    }
}
