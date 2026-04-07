//
//  AuthService.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 10.03.2026.
//

import Foundation
// Foundation Swift'in temel veri tiplerini ve altyapı araçlarını sağlayan framework'tür.
// Ağ işlemleri, veri yapıları ve temel uygulama mantığı için kullanılır.

final class AuthService {
    // AuthService uygulamadaki kimlik doğrulama (authentication) işlemlerini yöneten servis sınıfıdır.
    // Login ve register gibi kullanıcı giriş işlemleri burada toplanır.

    static let shared = AuthService()
    // Singleton pattern kullanılır.
    // Böylece uygulama boyunca AuthService'in tek bir instance'ı kullanılır.

    private init() {}
    // private init sayesinde dışarıdan yeni AuthService nesnesi oluşturulamaz.
    // Bu da singleton yapısını korumak için kullanılır.

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Kullanıcının sisteme giriş yapmasını sağlayan fonksiyondur.
        // email ve password parametreleri kullanıcıdan alınan giriş bilgileridir.
        // completion closure'ı ise işlem tamamlandığında sonucu geri döndürmek için kullanılır.

        // MOCK LOGIN (Firebase gelene kadar)
        // Şu anda gerçek bir backend olmadığı için sahte (mock) login işlemi yapılır.

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // asyncAfter belirli bir süre gecikmeli işlem çalıştırmak için kullanılır.
            // Burada gerçek ağ isteği varmış gibi 1 saniyelik gecikme simüle edilir.
            completion(true)
            // completion(true) login işleminin başarılı olduğunu simüle eder.
        }

    }

    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Yeni kullanıcı oluşturma işlemini temsil eden fonksiyondur.
        // Gerçek projede burada Firebase Auth register işlemi yapılacaktır.

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Gerçek backend işlemi varmış gibi gecikme simülasyonu yapılır.
            completion(true)
            // Kullanıcı kaydının başarılı olduğu varsayılır.
        }

    }

}
