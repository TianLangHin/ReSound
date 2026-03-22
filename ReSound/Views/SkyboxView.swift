//
//  SkyboxView.swift
//  ReSound
//
//  Created by Tian Lang Hin on 22/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

struct SkyboxView: View {
    let resourceName: String

    var body: some View {
        RealityView { content in
            guard let resource = try? await TextureResource(named: resourceName) else {
                return
            }

            let sphereMesh = MeshResource.generateSphere(radius: 200.0)
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))

            let skyboxEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
            content.add(skyboxEntity)
        }
    }
}
