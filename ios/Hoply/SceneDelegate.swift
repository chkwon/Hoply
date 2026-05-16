import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let root = DocumentListViewController()
        let navigationController = UINavigationController(rootViewController: root)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        if let urlContext = connectionOptions.urlContexts.first {
            root.openInboundDocument(at: urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard
            let navigationController = window?.rootViewController as? UINavigationController,
            let root = navigationController.viewControllers.first as? DocumentListViewController,
            let url = URLContexts.first?.url
        else { return }
        root.openInboundDocument(at: url)
    }
}
