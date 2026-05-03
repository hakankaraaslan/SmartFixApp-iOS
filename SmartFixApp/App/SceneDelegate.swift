//
//  SceneDelegate.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 4.03.2026.
//

import UIKit
// UIKit, iOS uygulamalarında kullanıcı arayüzü oluşturmak için kullanılan ana framework'tür.
// ViewController, NavigationController ve pencere yönetimi gibi bileşenler burada bulunur.

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // SceneDelegate, uygulamanın pencere (window) ve sahne (scene) yaşam döngüsünü yönetir.
    // iOS 13 ve sonrası sürümlerde uygulama arayüzü bu sınıf üzerinden başlatılır.

    var window: UIWindow?
    // window, uygulamanın ekranda gösterilen ana penceresini temsil eder.
    // Tüm ViewController yapısı bu pencere içinde gösterilir.


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Uygulama arayüzü ilk oluşturulurken çalışan metottur.
        // Burada uygulamanın ana penceresi (window) oluşturulur ve ilk ekran belirlenir.
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if AuthService.shared.currentUserId != nil,
           let role = SessionManager.shared.role {

            if SessionManager.shared.isAddressCompleted {
                window.rootViewController = HomeRouter.makeHome(for: role)
            } else if let uid = SessionManager.shared.uid {
                let vc = AddAddressViewController(uid: uid, userRole: role)
                window.rootViewController = UINavigationController(rootViewController: vc)
            } else {
                window.rootViewController = UINavigationController(rootViewController: LoginViewController())
            }

        } else {
            window.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }

        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene sistem tarafından kapatıldığında çalışır.
        // Bu noktada sahneye ait kaynaklar serbest bırakılabilir.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Scene aktif hale geldiğinde çalışır.
        // Daha önce durdurulan işlemler burada tekrar başlatılabilir.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Scene aktif durumdan pasif duruma geçerken çalışır.
        // Örneğin bir telefon araması geldiğinde bu durum oluşabilir.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Uygulama arka plandan tekrar ön plana gelirken çalışır.
        // Arka planda yapılan değişiklikler burada geri alınabilir.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Uygulama arka plana geçtiğinde çalışır.
        // Veri kaydetme ve gerekli durum bilgilerini saklama işlemleri burada yapılabilir.
    }


}
