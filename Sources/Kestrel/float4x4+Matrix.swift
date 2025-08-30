import simd

// All of this is AI generated, I don't know matrix math and I don't care. They seem to work fine, but optimisations are welcome.
public extension float4x4 {
    static func perspective(fovY: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let yScale = 1 / tan(fovY * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        
        return float4x4([
            SIMD4<Float>(xScale, 0, 0, 0),
            SIMD4<Float>(0, yScale, 0, 0),
            SIMD4<Float>(0, 0, farZ / zRange, 1),
            SIMD4<Float>(0, 0, -nearZ * farZ / zRange, 0)
        ])
    }
    
    static func orthographic(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float
    ) -> float4x4 {
        let r_l = right - left
        let t_b = top - bottom
        let f_n = far - near

        return float4x4([
            SIMD4<Float>(2.0 / r_l, 0, 0, 0),
            SIMD4<Float>(0, 2.0 / t_b, 0, 0),
            SIMD4<Float>(0, 0, -2.0 / f_n, 0),
            SIMD4<Float>(-(right + left) / r_l, -(top + bottom) / t_b, -(far + near) / f_n, 1.0)
        ])
    }

    static func translation(x: Float = 0, y: Float = 0, z: Float = 0) -> float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = [x, y, z, 1]
        return matrix
    }
    
    static func rotationX(_ angle: Float) -> float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return float4x4([
            SIMD4<Float>(1,  0,  0, 0),
            SIMD4<Float>(0,  c, -s, 0),
            SIMD4<Float>(0,  s,  c, 0),
            SIMD4<Float>(0,  0,  0, 1)
        ])
    }

    static func rotationY(_ angle: Float) -> float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return float4x4([
            SIMD4<Float>( c, 0, s, 0),
            SIMD4<Float>( 0, 1, 0, 0),
            SIMD4<Float>(-s, 0, c, 0),
            SIMD4<Float>( 0, 0, 0, 1)
        ])
    }
    
    static func rotationZ(_ angle: Float) -> float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return float4x4([
            SIMD4<Float>( c, -s, 0, 0),
            SIMD4<Float>( s,  c, 0, 0),
            SIMD4<Float>( 0,  0, 1, 0),
            SIMD4<Float>( 0,  0, 0, 1)
        ])
    }
    
    static func scale(x: Float = 1, y: Float = 1, z: Float = 1) -> float4x4 {
        return float4x4([
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ])
    }

    init(_ columns: [SIMD4<Float>]) {
        self.init()
        self.columns = (columns[0], columns[1], columns[2], columns[3])
    }
}
