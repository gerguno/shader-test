#define numOfPoints 30
#define seed (35487457)
#define a (1103515245)
#define c (12345)
#define m (1<<31)

const vec3 fafafa = vec3(0.9804, 0.9804, 0.9804);
const vec3 color69EDAA = vec3(0.4118, 0.9294, 0.6667);
uniform vec2 u_resolution;

float rand(int i) {
    uint ui = uint(i);
    uint ua = uint(a);
    uint uc = uint(c);
    uint useed = uint(seed);
    ui += ua + useed;
    float v = float(ua * ui + uc + useed + useed);
    if (v == 0.) v = 1.;
    return abs(float(ui) / v);
}

float rand(float i) {
    float k = i;
    if (i == 0.) k = 1.;
    int i2 = int(i * 2. / k);
    return (rand(int(i)) + rand(i2)) / 2.0;
}

vec3 hash23(vec2 src) {
    vec3 randV = vec3(rand(src.x), rand(src.y), rand(src.x * src.y + src.x + src.y + 8912.2793));
    randV += dot(randV, randV+vec3(3799.6274,9567.3518,8575.2724));
    return fract(randV);
}

vec2 hash32(vec3 src) {
    vec2 randV = vec2(rand(src.x), rand(src.y)) + vec2(rand(src.z), rand(src.z + 9463.9522));
    randV += dot(randV, randV+vec2(8183.0119,4912.9833));
    return fract(randV);
}

float d(vec2 p0, vec2 p1) {
    return sqrt(pow(p0.x - p1.x, 2.0) + pow(p0.y - p1.y, 2.0));
}

const vec3 colors[1] = vec3[1](
vec3(0.9686, 0.2706, 0.1176)
);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // First part of the shader (from Buffer)
    vec2 uv = ((fragCoord - .5 * iResolution.xy) / iResolution.y);
    vec3 col = vec3(0, 0, 0); // Default background color
    float width = 200.0; 

    // Pixelation effect
    float pixelSize = 1.0; // Adjust this value for more or less pixelation
    vec2 pixelatedCoord = floor(fragCoord / pixelSize) * pixelSize + pixelSize * 0.5;
    
    for(int i = 0; i < numOfPoints; i++) {
        vec2 pointBase = vec2(float(i) + 100000., float(numOfPoints - i) + 539.2171);
        float time = iTime / 5.;
        float t = fract(time);
        vec2 prev = hash32(vec3(pointBase, floor(time)));
        vec2 next = hash32(vec3(pointBase, ceil(time)));
        vec2 point = (prev + ((next - prev) * t)) * iResolution.xy;
        float dist = d(point, pixelatedCoord);
        
        vec3 currentColor = colors[i % 2];
        
        if(dist < width) {
            vec3 blendColor = currentColor * smoothstep(1., 0., dist / width);
            col = blendColor + col; // Additive blending
        }
    
    }
    
    col = clamp(col, 0.0, 1.0); // Ensure the resulting color does not exceed the limits

    // Second part of the shader (from Image)
    vec3 baseColor = col; // This is the color from the first part

    // Define the blend color (#A0A0A0)
    vec3 blendColor = vec3(0.62745, 0.62745, 0.62745); // #A0A0A0

    // Calculate the luminance of the blend color
    float blendLuma = dot(blendColor, vec3(0.299, 0.587, 0.114));

    // Calculate the chroma of the base color
    vec3 baseChroma = baseColor - dot(baseColor, vec3(0.299, 0.587, 0.114));

    // Combine the chroma of the base color with the luminance of the blend color
    vec3 finalColor = baseChroma + blendLuma;

    // Output the final color
    fragColor = vec4(finalColor, 1.0);
}
