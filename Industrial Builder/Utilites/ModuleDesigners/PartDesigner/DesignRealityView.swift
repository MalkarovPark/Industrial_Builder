//
//  DesignRealityView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 15.07.2026.
//

import SwiftUI
import RealityKit

public struct DesignRealityView: View
{
    let entity: Entity?
    
    //@State private var previewed_entity: Entity?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var view_size: CGSize = .zero
    @State private var scale: Float = 1
    
    private let factor: Float = 0.5
    private let shift: Float = 200
    private let grid_factor: Float = 0.675
    
    public var body: some View
    {
        GeometryReader
        { geometry in
            RealityView
            { content in
                if let previewed_entity = entity
                {
                    let bounds = previewed_entity.visualBounds(relativeTo: nil)
                    model_size = bounds.extents
                    
                    content.add(previewed_entity)
                }
            }
            //.frame(depth: CGFloat(scale * model_size.x * 1000 + shift * scale))
            .onChange(of: geometry.size)
            { _, new_size in
                view_size = new_size
                update_scale()
            }
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
                {
                    view_size = geometry.size
                    update_scale()
                }
            }
        }
        .background
        {
            InfiniteGridView(scale: CGFloat(scale * grid_factor))
        }
    }
    
    private func update_scale()
    {
        guard let previewed_entity = entity else { return }
        guard model_size != .zero else { return }
        
        let view_width = Float(view_size.width) * 0.001
        let view_height = Float(view_size.height) * 0.001
        
        let min_view_dimension = min(view_width, view_height)
        
        let model_radius = length(model_size) * 0.5
        
        guard model_radius > 0, min_view_dimension > 0
        else { return }
        
        scale = (min_view_dimension / length(model_size)) * factor
        
        previewed_entity.scale = SIMD3<Float>(repeating: scale)
    }
}

public struct InfiniteGridView: View
{
    var cell_size: CGFloat = 20
    var major_step: Int = 10
    
    var scale: CGFloat = 1.0 // Global grid scale
    
    var minor_color = Color.gray.opacity(0.25)
    var major_color = Color.gray.opacity(0.40)
    var axis_color  = Color.gray.opacity(0.60)
    
    var offset: CGSize = .zero
    
    public var body: some View
    {
        GeometryReader
        { geometry in
            Canvas
            { context, size in
                
                let scaled_cell_size = cell_size * scale
                
                guard scaled_cell_size > 1 else { return }
                
                let center_x = size.width  * 0.5 + offset.width
                let center_y = size.height * 0.5 + offset.height
                
                let columns = Int(ceil(size.width / scaled_cell_size)) + 2
                let rows    = Int(ceil(size.height / scaled_cell_size)) + 2
                
                
                for i in -columns...columns
                {
                    let x = center_x + CGFloat(i) * scaled_cell_size
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    
                    let color: Color
                    let width: CGFloat
                    
                    if i == 0
                    {
                        color = axis_color
                        width = 2
                    }
                    else if i % major_step == 0
                    {
                        color = major_color
                        width = 1.5
                    }
                    else
                    {
                        color = minor_color
                        width = 1
                    }
                    
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: width
                    )
                }
                
                
                for i in -rows...rows
                {
                    let y = center_y + CGFloat(i) * scaled_cell_size
                    
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    
                    let color: Color
                    let width: CGFloat
                    
                    if i == 0
                    {
                        color = axis_color
                        width = 2
                    }
                    else if i % major_step == 0
                    {
                        color = major_color
                        width = 1.5
                    }
                    else
                    {
                        color = minor_color
                        width = 1
                    }
                    
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: width
                    )
                }
            }
            //.ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

public struct PortalCardView: View
{
    let entity: Entity?
    
    @State private var previewed_entity: Entity?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var scale: Float = 1
    @State private var portal_entity = Entity()
    
    private let factor: Float = 0.5
    private let shift: Float = 200
    private let grid_factor: Float = 0.675
    
    public var body: some View
    {
        GeometryReader
        { geometry in
            RealityView
            { content in
                if let previewed_entity = entity
                {
                    let bounds = previewed_entity.visualBounds(relativeTo: nil)
                    model_size = bounds.extents
                    
                    let world = make_world(with: previewed_entity)
                    portal_entity = make_portal(world: world)
                    
                    content.add(world)
                    content.add(portal_entity)
                }
            }
            .frame(depth: 2)
            .onChange(of: geometry.size)
            { _, new_size in
                update_scale(with: geometry.size)
                update_portal(with: geometry.size)
            }
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
                {
                    update_scale(with: geometry.size)
                    update_portal(with: geometry.size)
                }
            }
        }
        .background
        {
            InfiniteGridView(scale: CGFloat(scale * grid_factor))
        }
    }
    
    private func update_scale(with size: CGSize = .zero)
    {
        guard let previewed_entity = entity else { return }
        guard model_size != .zero else { return }
        
        let view_width = Float(size.width) * 0.001
        let view_height = Float(size.height) * 0.001
        
        let min_view_dimension = min(view_width, view_height)
        
        let model_radius = length(model_size) * 0.5
        
        guard model_radius > 0, min_view_dimension > 0
        else { return }
        
        scale = (min_view_dimension / length(model_size)) * factor
        
        previewed_entity.scale = SIMD3<Float>(repeating: scale)
    }
    
    private func make_world(with entity: Entity) -> Entity
    {
        let world = Entity()
        world.components[WorldComponent.self] = .init()
        
        let material = UnlitMaterial(color: .white)
        let background = Entity()
        background.components.set(ModelComponent(
            mesh: .generateSphere(radius: 0.8),
            materials: [material]))
        background.scale.x *= -1
        world.addChild(background)
        
        entity.components[PortalCrossingComponent.self] = .init()
        
        world.addChild(entity)
        
        // Center shift
        let bounds = entity.visualBounds(relativeTo: nil)
        let center = bounds.center
        entity.position -= center// * scale
        
        // Light
        let light = DirectionalLight()
        //light.light.intensity = 4000
        //light.light.color = .white
        light.position = [0, 2, 2]
        light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
        world.addChild(light)
        
        return world
    }
    
    private func make_portal(world: Entity) -> Entity
    {
        let portal = Entity()
        portal.components[PortalComponent.self] = .init(target: world)
        
        let portalComponent = PortalComponent(
            target: world,
            clippingMode: .disabled,
            crossingMode: .disabled
        )
        portal.components.set(portalComponent)
        
        return portal
    }
    
    func update_portal(with size: CGSize = .zero)
    {
        portal_entity.components.remove(ModelComponent.self)
        portal_entity.components[ModelComponent.self] = .init(
            mesh: .generatePlane(
                width: Float(size.width / 1370),
                height: Float(size.height / 1370)/*,
                cornerRadius: Float(0.01)*/),
            materials: [PortalMaterial()]
        )
    }
}

#Preview(windowStyle: .automatic)
{
    PartModelView(entity: ModelEntity(
        mesh: .generateBox(width: 0.1, height: 0.2, depth: 0.1)/*mesh: .generateBox(size: Float(0.1)/*, cornerRadius: Float(0.01)*/)*/,
        materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
    )) // 100mm^3
}

#Preview(windowStyle: .automatic)
{
    PortalCardView(entity: ModelEntity(
        mesh: .generateBox(size: Float(0.1), cornerRadius: Float(0.01)),
        materials: [SimpleMaterial(color: .white, isMetallic: false)]
    )) // 100mm^3
}

#Preview(windowStyle: .plain)
{
    PortalView(entity: ModelEntity(
        mesh: .generateBox(size: Float(0.1), cornerRadius: Float(0.01)),
        materials: [SimpleMaterial(color: .white, isMetallic: false)]
    )) // 100mm^3
}

#Preview
{
    @Previewable @State var scale: CGFloat = 1.0
    
    VStack(spacing: 32)
    {
        ZStack
        {
            Rectangle()
                .fill(.white)
            
            InfiniteGridView(scale: scale)
        }
        .frame(width: 256, height: 256)
        
        Slider(value: $scale, in: 0 ... 2)
            .frame(width: 256)
    }
}

public struct PortalView: View
{
    let entity: Entity?
    
    @State private var scene_content: RealityViewContent?
    
    @State private var previewed_entity: Entity?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var portal_entity = Entity()
    @State private var portal_root = Entity()
    
    @State private var portal_geometry_size: CGSize = .zero
    
    private let factor: Float = 0.5
    
    @State private var is_portal = false
    
    public var body: some View
    {
        let view_type = Binding(
            get: { is_portal },
            set:
                { new_value in
                    is_portal = new_value
                    
                    toggle_view(new_value)
                }
        )
        
        GeometryReader
        { geometry in
            RealityView
            { content in
                scene_content = content
                
                build_portal()
                //turn_entity()
            }
            .onChange(of: geometry.size)
            { _, _ in
                if !is_portal { return }
                //portal_geometry_size = geometry.size
                update_portal_entity_scale(with: geometry.size)
                update_portal_size(with: geometry.size)
            }
            .onChange(of: is_portal)
            { _, _ in
                if !is_portal { return }
                //portal_geometry_size = geometry.size
                update_portal_entity_scale(with: geometry.size)
                update_portal_size(with: geometry.size)
            }
            /*.onAppear
            {
                if !is_portal { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
                {
                    portal_geometry_size = geometry.size
                    update_portal_entity_scale(with: portal_geometry_size)
                    update_portal_size(with: portal_geometry_size)
                }
             
            }*/
        }
        .overlay(alignment: .bottomTrailing)
        {
            HStack
            {
                Toggle(isOn: view_type)
                {
                    Text("Portal")
                }
                .frame(width: 128)
            }
            .padding()
            .glassBackgroundEffect()
            .padding()
        }
        /*.ornament(attachmentAnchor: .scene(.bottom))
        {
            HStack
            {
                Toggle(isOn: view_type)
                {
                    Text("Portal")
                }
            }
            .padding()
            .glassBackgroundEffect()
        }*/
    }
    
    private func toggle_view(_ is_portal: Bool)
    {
        if is_portal
        {
            turn_portal()
        }
        else
        {
            turn_entity()
        }
    }
    
    func turn_portal()
    {
        guard let previewed_entity = entity else { return }
        
        model_size = previewed_entity.visualBounds(relativeTo: nil).extents
        
        portal_entity.isEnabled = true
        portal_root.addChild(previewed_entity)
        
        update_portal_entity_scale(with: portal_geometry_size)
    }
    
    func turn_entity()
    {
        guard let previewed_entity = entity, let scene_content else { return }
        
        previewed_entity.scale = .init(repeating: 1)
        portal_entity.isEnabled = false
        scene_content.add(previewed_entity)
    }
    
    private func build_portal()
    {
        guard let previewed_entity = entity, let scene_content else { return }
        
        model_size = previewed_entity.visualBounds(relativeTo: nil).extents
        
        let world = make_world()
        portal_entity.components[PortalComponent.self] = .init(target: world)
        
        let portalComponent = PortalComponent(
            target: world,
            clippingMode: .disabled,
            crossingMode: .disabled
        )
        portal_entity.components.set(portalComponent)
        
        scene_content.add(world)
        scene_content.add(portal_entity)
        
        //portal_root.addChild(previewed_entity)
        update_portal_size(with: CGSize(width: 1280, height: 720))
        turn_entity()
        
        func make_world() -> Entity
        {
            // World
            let world = Entity()
            world.components[WorldComponent.self] = .init()
            
            // Background
            let material = UnlitMaterial(color: .white)
            let background = Entity()
            background.components.set(ModelComponent(
                mesh: .generateSphere(radius: 0.8),
                materials: [material]))
            background.scale.x *= -1
            world.addChild(background)
            
            // Light
            let light = DirectionalLight()
            light.light.intensity = 4000
            light.light.color = .white
            light.position = [0, 2, 2]
            light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
            world.addChild(light)
            
            // Entity
            world.addChild(portal_root)
            
            return world
        }
    }
    
    private func update_portal_entity_scale(with size: CGSize = .zero)
    {
        guard let previewed_entity = entity else { return }
        guard model_size != .zero else { return }
        
        let view_width = Float(size.width) * 0.001
        let view_height = Float(size.height) * 0.001
        
        let min_view_dimension = min(view_width, view_height)
        let model_radius = length(model_size) * 0.5
        
        guard model_radius > 0, min_view_dimension > 0
        else { return }
        
        previewed_entity.scale = SIMD3<Float>(repeating: (min_view_dimension / length(model_size)) * factor)
    }
    
    private func update_portal_size(with size: CGSize = .zero)
    {
        portal_entity.components.remove(ModelComponent.self)
        portal_entity.components[ModelComponent.self] = .init(
            mesh: .generatePlane(
                width: Float(size.width / 1370),
                height: Float(size.height / 1370),
                cornerRadius: Float(0.03)),
            materials: [PortalMaterial()]
        )
    }
}
