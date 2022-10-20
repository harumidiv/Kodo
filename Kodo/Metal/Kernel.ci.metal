//
//  Kernel.ci.metal
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/20.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>

extern "C" {
    namespace coreimage {
        float4 hardbeatFilter(sample_t image)
        {
            return image;
        }
    }
}
