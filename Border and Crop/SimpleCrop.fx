// @Maintainer jwrl
// @Released 2023-01-22
// @Author jwrl
// @Released 2023-01-2

/**
 This is a quick simple cropping tool.  You can also use it to blend images without
 using a blend effect.  It provides a simple border and can be automatically cropped
 to the edges of the background.  If the foreground is smaller than the crop area
 the overflow is filled with the border colour.  With its extended alpha support you
 can also use it to crop and overlay two images with alpha channels over another
 background using an external blend effect.

 Previously the "sense" of the effect could have been swapped so that background
 became foreground and vice versa.  With the ability to cycle inputs built in to
 Lightworks there's little point in doing that, and it has been dropped.

 NOTE:  This effect is only suitable for use with Lightworks version 2023 and higher.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect SimpleCrop.fx
//
// Version history:
//
// Built 2023-01-22 jwrl.
//-----------------------------------------------------------------------------------------//

#include "_utils.fx"

DeclareLightworksEffect ("Simple crop", "DVE", "Border and crop", "A simple crop tool with blend", kNoFlags);

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

DeclareInputs (Fg, Bg);

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

DeclareFloatParam (CropLeft, "Top left", kNoGroup, "SpecifiesPointX", 0.1, 0.0, 1.0);
DeclareFloatParam (CropTop, "Top left", kNoGroup, "SpecifiesPointY", 0.9, 0.0, 1.0);
DeclareFloatParam (CropRight, "Bottom right", kNoGroup, "SpecifiesPointX", 0.9, 0.0, 1.0);
DeclareFloatParam (CropBottom, "Bottom right", kNoGroup, "SpecifiesPointY", 0.1, 0.0, 1.0);

DeclareIntParam (AlphaMode, "Alpha channel output", kNoGroup, 3, "Ignore alpha|Background only|Cropped foreground|Combined alpha|Overlaid alpha");

DeclareFloatParam (Border, "Thickness", "Border", kNoFlags, 0.1, 0.0, 1.0);

DeclareColourParam (Colour, "Colour", "Border", kNoFlags, 1.0, 1.0, 1.0, 1.0);

DeclareBoolParam (CropToBgd, "Crop foreground to background", kNoGroup, false);

DeclareFloatParam (_OutputAspectRatio);

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#ifdef WINDOWS
#define PROFILE ps_3_0
#endif

#define jSaturate(n)    min(max (n, 0.0), 1.0)

#define BLACK float2(0.0, 1.0).xxxy

//-----------------------------------------------------------------------------------------//
// Code
//-----------------------------------------------------------------------------------------//

DeclarePass (Fgd)
{ return IsOutOfBounds (uv1) ? BLACK : tex2D (Fg, uv1); }

DeclareEntryPoint (SimpleCrop)
{
   if (CropToBgd && IsOutOfBounds (uv2)) return kTransparentBlack;

   float2 brdrEdge = (Border * 0.05).xx;

   brdrEdge.y *= _OutputAspectRatio;

   float2 cropTL = float2 (CropLeft, 1.0 - CropTop);
   float2 cropBR = float2 (CropRight, 1.0 - CropBottom);
   float2 bordTL = jSaturate (cropTL - brdrEdge);
   float2 bordBR = jSaturate (cropBR + brdrEdge);

   float4 Fgnd = tex2D (Fgd, uv3);
   float4 Bgnd = ReadPixel (Bg, uv2);

   if (all (uv3 > bordTL) && all (uv3 < bordBR)) { Bgnd = Colour; }
   else if (AlphaMode == 4) Bgnd.a = 0.0;

   if (any (uv3 < cropTL) || any (uv3 > cropBR)) { Fgnd = kTransparentBlack; }

   float alpha = (AlphaMode == 0) ? 1.0
               : (AlphaMode == 1) ? Bgnd.a
               : (AlphaMode == 2) ? Fgnd.a : max (Bgnd.a, Fgnd.a);

   return float4 (lerp (Bgnd, Fgnd, Fgnd.a).rgb, alpha);
}

