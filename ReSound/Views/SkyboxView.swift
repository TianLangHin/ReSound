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
            if resourceName == "bush_restaurant_4k.exr" {
                guard let cafeteriaEntity = try? await Entity(named: "new cafe.usdz") else {
                    return
                }
                cafeteriaEntity.scale *= 0.01
                cafeteriaEntity.position = [0, -0.3, 0]
                let originalRotation = cafeteriaEntity.transform.rotation
                let newRotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                cafeteriaEntity.transform.rotation = newRotation * originalRotation
                content.add(cafeteriaEntity)

                let size: Float = 2.2
                let increments: [Float] = [-size, 0, size]
                for x in increments {
                    for z in increments {
                        content.add(makeLight(position: .init(x: x, y: 1.5, z: z)))
                    }
                }

                guard let resource = try? await TextureResource(named: "suburban_garden_4k.exr") else {
                    return
                }
                var m = UnlitMaterial()
                m.color = .init(texture: .init(resource))
                let skybox = ModelEntity(mesh: MeshResource.generateSphere(radius: 200), materials: [m])
                skybox.scale = .init(x: -1, y: 1, z : 1)
                content.add(skybox)
                return
            }

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

    func makeLight(position: SIMD3<Float>) -> Entity {
        let lightingEntity = Entity()
        let lightSource = PointLightComponent(color: .white, intensity: 20000, attenuationRadius: 5000)
        lightingEntity.components.set(lightSource)
        lightingEntity.position = position
        return lightingEntity
    }
}
