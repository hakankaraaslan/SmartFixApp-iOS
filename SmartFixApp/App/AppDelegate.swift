//
//  AppDelegate.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 4.03.2026.
//

import UIKit
import FirebaseCore
// UIKit iOS uygulamalarında kullanıcı arayüzü oluşturmak için kullanılan temel framework'tür.
// ViewController, Button, Navigation gibi temel UI bileşenleri bu framework içinde yer alır.

@main
// @main uygulamanın giriş noktasıdır.
// Uygulama çalıştırıldığında ilk olarak bu sınıf devreye girer.
class AppDelegate: UIResponder, UIApplicationDelegate {
    // AppDelegate uygulamanın yaşam döngüsünü yöneten sınıftır.
    // Uygulama açılma, kapanma, arka plana geçme gibi olaylar burada takip edilir.



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Uygulama ilk açıldığında çalışan metottur.
        // Genel ayarlar, servis başlatma işlemleri veya başlangıç yapılandırmaları burada yapılır.
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle
    // Scene yaşam döngüsü, uygulamanın pencere ve sahne yönetimini kontrol eder.
    // Özellikle çoklu pencere desteği olan yapılarda kullanılır.

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Yeni bir scene oturumu oluşturulurken bu metot çağrılır.
        // Hangi scene yapılandırmasının kullanılacağı burada belirlenir.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Kullanılmayan scene oturumları silindiğinde bu metot çalışır.
        // Artık ihtiyaç duyulmayan kaynakları burada temizlemek mümkündür.
    }


}

