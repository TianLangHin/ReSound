//
//  SkyboxView.swift
//  ReSound
//
//  Created by Tian Lang Hin on 22/3/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

import SwiftUI
import RealityKit

/// Since our background assets are full images loaded as HDRI assets,
/// the immersive space background is created by making a big sphere
/// and putting the background image as the texture on the inside.
struct SkyboxView: View {
    let resourceName: String

    var body: some View {
        RealityView { content in
            /// The resource is loaded. If it fails, nothing will show.
            guard let resource = try? await TextureResource(named: resourceName) else {
                return
            }

            /// We generate the sphere and place the resource as a texture on it.
            let sphereMesh = MeshResource.generateSphere(radius: 200.0)
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))

            /// We construct the entity and flip it so the texture is on the inside.
            let skyboxEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
            content.add(skyboxEntity)
        }
    }
}

#if DEBUG
#Preview("Skybox") {
    SkyboxView(resourceName: Presets.hearingTests[0].backgroundResourceLink)
}
#endif

