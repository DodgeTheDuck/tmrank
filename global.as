
namespace Colours {

    const vec4 TIME_NEUTRAL = vec4(0.7, 0.7, 0.7, 1);
    const vec4 TIME_GOOD = vec4(0.497, 0.770, 0.116, 1);
    const vec4 TIME_BAD = vec4(0.830, 0.066, 0.066, 1);
    const vec4 WHITE = vec4(1, 1, 1, 1);

    vec4 Alpha(vec4 colour, float alpha) {
        colour.w = alpha;
        return colour;
    }

}

namespace Formatters {
    string FloatToString(float speed, uint precision) {
        return Text::Format("%." + precision + "f", speed);
    }
    string FloatDeltaToString(float a, float b, uint precision) {
        if(a > b) {
            return "+" + FloatToString(a - b, precision);
        } else if(b > a) {
            return "-" + FloatToString(b - a, precision);
        } else {
            return FloatToString(0.0, precision);
        }
    }
}