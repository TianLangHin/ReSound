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
            if resourceName == "Cafe" {
                await cafeEnvironment(content: content)
            } else if resourceName == "Train" {
                await trainEnvironment(content: content)
            } else if resourceName == "Home" {
                await homeEnvironment(content: content)
            }

            if resourceName.hasSuffix(".exr") || resourceName.hasSuffix(".hdr") {
                if let skybox = await makeSkybox(name: resourceName) {
                    content.add(skybox)
                }
            }
        }
    }

    func homeEnvironment(content: RealityViewContent) async {
        let container = Entity()

        guard let homeEntity = try? await Entity(named: "Home.usdz") else {
            return
        }
        let originalRotation = homeEntity.transform.rotation
        homeEntity.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0]) * originalRotation
        container.addChild(homeEntity)

        if let skybox = await makeSkybox(name: "suburban_garden_4k.exr") {
            container.addChild(skybox)
        }

        let backboard = ModelEntity(
            mesh: .generatePlane(width: 5, depth: 5),
            materials: [UnlitMaterial(color: .black)])
        backboard.position = [0, 0, -2.6]
        backboard.orientation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
        container.addChild(backboard)

        container.addChild(homeEntity)
        content.add(container)
    }

    func trainEnvironment(content: RealityViewContent) async {
        let container = Entity()

        guard let stationEntity = try? await Entity(named: "Station_Resized.usdz") else {
            return
        }
        stationEntity.position = [0, 0, -2]
        container.addChild(stationEntity)

        let trainLights: [Float] = [-30, -20, -10, 0, 10, 20, 30]
        let positions: [(Float, Float, Float)] = [(4, 4, 0)] + trainLights.map { z in (-5, 3, z) }
        for (x, y, z) in positions {
            container.addChild(makeLight(position: .init(x: x, y: y, z: z), intensity: 1000000, attenuation: 500000))
        }
        container.position = CustomTest.Theme.train.offset()
        content.add(container)
    }

    func cafeEnvironment(content: RealityViewContent) async {
        let container = Entity()

        guard let cafeteriaEntity = try? await Entity(named: "Cafe_Resized.usdz") else {
            return
        }
        let originalRotation = cafeteriaEntity.transform.rotation
        cafeteriaEntity.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0]) * originalRotation
        container.addChild(cafeteriaEntity)

        let xPositions: [Float] = [-1.0, 1.0, 3.0]
        let zPositions: [Float] = [-2.0, 0.0, 2.0]
        for x in xPositions {
            for z in zPositions {
                if x == xPositions[1] && z == zPositions[1] {
                    continue
                }
                container.addChild(makeLight(position: .init(x: x, y: 2, z: z), intensity: 20000, attenuation: 5000))
            }
        }

        if let man1 = await makeAnimated(name: "ANIM_SittingMan1.usdz") {
            man1.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0]) * man1.transform.rotation
            man1.scale *= 1.2
            man1.position = [2.3, 0, 3.0]
            container.addChild(man1)
        }

        if let man2 = await makeAnimated(name: "ANIM_SittingMan2.usdz") {
            man2.scale *= 1.2
            man2.position = [2.3, 0, 1.55]
            container.addChild(man2)
        }

        if let woman1 = await makeAnimated(name: "ANIM_SittingWoman1.usdz") {
            woman1.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0]) * woman1.transform.rotation
            woman1.scale *= 1.3
            woman1.position = [2.8, 0, -1.1]
            container.addChild(woman1)
        }

        if let woman2 = await makeAnimated(name: "ANIM_SittingWoman3.usdz") {
            woman2.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0]) * woman2.transform.rotation
            woman2.scale *= 1.3
            woman2.position = [2.75, -0.1, -0.1]
            container.addChild(woman2)
        }

        if let skybox = await makeSkybox(name: "suburban_garden_4k.exr") {
            container.addChild(skybox)
        }

        container.position = CustomTest.Theme.cafe.offset()
        content.add(container)
    }

    func makeAnimated(
        name: String,
        anim: String = "default subtree animation",
        looping: Bool = true
    ) async -> Entity? {
        guard let entity = try? await Entity(named: name) else {
            print("Cannot load animated entity.")
            return nil
        }
        guard let anim = entity
            .components[AnimationLibraryComponent.self]?
            .animations[anim] else {
            print("Cannot load animation.")
            return nil
        }
        let animation = looping ? anim.repeat() : anim
        entity.playAnimation(animation)
        return entity
    }

    func makeSkybox(name: String) async -> ModelEntity? {
        guard let resource = try? await TextureResource(named: name) else {
            print("Cannot load skybox.")
            return nil
        }
        let sphereMesh = MeshResource.generateSphere(radius: 100.0)
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        let skyboxEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        skyboxEntity.scale = .init(x: -1, y: 1, z: 1)
        return skyboxEntity
    }

    func makeLight(position: SIMD3<Float>, intensity: Float, attenuation: Float) -> Entity {
        let lightingEntity = Entity()
        let lightSource = PointLightComponent(color: .white, intensity: intensity, attenuationRadius: attenuation)
        lightingEntity.components.set(lightSource)
        lightingEntity.position = position
        return lightingEntity
    }
}
