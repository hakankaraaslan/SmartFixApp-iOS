//
//  UserRole.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 5.03.2026.
//


// Foundation Swift'in temel veri tiplerini ve altyapı araçlarını sağlayan framework'tür.
// String, Date, Array gibi temel veri yapıları bu framework ile birlikte kullanılır.
import Foundation

enum UserRole: String {
    // UserRole uygulamada kullanıcı tiplerini temsil eden bir enum (enumeration) yapısıdır.
    // Enum kullanarak belirli ve sınırlı seçenekleri güvenli bir şekilde tanımlayabiliriz.
    // ': String' ifadesi her rolün bir String değeri ile temsil edilmesini sağlar.
    case customer
    // customer uygulamayı hizmet almak için kullanan normal kullanıcıyı temsil eder.
    case technician
    // technician tamir hizmeti sunan servis sağlayıcı kullanıcıyı temsil eder.
}
