import Foundation
import SwiftGodot
import AuthenticationServices

#if os(iOS)
import UIKit

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var onSuccess: ((String, String?, String?) -> Void)?
    var onError: ((String) -> Void)?

    @available(iOS 17.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No valid window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onError?(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let id = credentials.user
            let email = credentials.email
            let name = "\(credentials.fullName?.givenName ?? "") \(credentials.fullName?.familyName ?? "")"
                .trimmingCharacters(in: .whitespaces)
            UserDefaults.standard.set(id, forKey: "id")
            onSuccess?(id, email, name)
        default:
            onError?("Received unknown credential type")
        }
    }
}
#endif

#initSwiftExtension(
    cdecl: "swift_entry_point",
    types: [MyLibrary.self]
)

@Godot
class MyLibrary: RefCounted {
    #if os(iOS)
    private var signInDelegate: AppleSignInDelegate?
    #endif
    
    #signal("Output", arguments: ["output": String.self])
    let signal = SignalWith1Argument<String>("Output")
    
    #signal("Signout", arguments: ["signout": String.self])
    let signalTwo = SignalWith1Argument<String>("Signout")
    
    let center = NotificationCenter.default
    let name = ASAuthorizationAppleIDProvider.credentialRevokedNotification
    
    @Callable
    func signIn() {
        #if os(iOS)
        signInDelegate = AppleSignInDelegate()
        
        signInDelegate?.onSuccess = { [weak self] id, email, name in
            guard let self = self else { return }
            let output = "\(id) \(email ?? "") \(name ?? "")"
            emit(signal: self.signal, output)
        }
        
        signInDelegate?.onError = { [weak self] error in
            guard let self = self else { return }
            emit(signal: self.signal, "Error: \(error)")
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = signInDelegate
        controller.presentationContextProvider = signInDelegate
        controller.performRequests()
        #else
        emit(signal: self.signal, "Apple sign in is not supported on this platform")
        #endif
    }
    
    @Callable
    func checkForChange() {
        #if os(iOS)
        center.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            emit(signal: self.signalTwo, "Sign out and redirect user to login screen")
        }
        #endif
    }
    
    @Callable
    func checkUserAlreadyLoggedIn() {
        #if os(iOS)
        guard let id = UserDefaults.standard.string(forKey: "id") else {
            emit(signal: self.signal, "show login screen")
            return
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: id) { [weak self] credentialState, error in
            guard let self = self else { return }
            switch credentialState {
            case .authorized:
                emit(signal: self.signal, "User is already authorized")
            case .revoked:
                emit(signal: self.signal, "Sign user out and remove cache and navigate to login screen")
            case .notFound:
                emit(signal: self.signal, "show login screen")
            @unknown default:
                emit(signal: self.signal, "Unknown credential state")
            }
        }
        #else
        emit(signal: self.signal, "Apple sign in is not supported on this platform")
        #endif
    }
}
