// @Maintainer jwrl
// @Released 2023-01-26
// @Author jwrl
// @Created 2023-01-26

/**
 This simple effect turns the alpha channel of a clip fully on, making it opaque.  There
 are two modes available - the first simply turns the alpha on, the second adds a flat
 background colour where previously the clip was transparent.  The default colour used
 is black, and the image can be unpremultiplied in this mode if desired.

 A means of boosting alpha before processing to support clips such as Lightworks titles
 has also been included.  This only functions when the background is being replaced.

 NOTE:  This effect is only suitable for use with Lightworks version 2023 and higher.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect AlphaOpq.fx
//
// Version history:
//
// Built 2023-01-26 jwrl
//-----------------------------------------------------------------------------------------//

#include "_utils.fx"

DeclareLightworksEffect ("Alpha opaque", "Key", "Key Extras", "Makes a transparent image or title completely opaque", CanSize);

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

DeclareInput (Inp);

DeclareMask;

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

DeclareIntParam (OpacityMode, "Opacity mode", kNoGroup, 0, "Make opaque|Blend with colour");
DeclareIntParam (KeyMode, "Type of alpha channel", kNoGroup, 0, "Standard|Premultiplied|Lightworks title effects");

DeclareColourParam (Colour, "Background colour", kNoGroup, kNoFlags, 0.0, 0.0, 0.0);

//-----------------------------------------------------------------------------------------//
// Code
//-----------------------------------------------------------------------------------------//

DeclareEntryPoint (AlphaOpq)
{
   float4 Fgd = ReadPixel (Inp, uv1);

   if (!OpacityMode) return lerp (kTransparentBlack, float4 (Fgd.rgb, 1.0), tex2D (Mask, uv1));

   if (KeyMode == 2) Fgd.a = pow (Fgd.a, 0.5);
   if (KeyMode > 0) Fgd.rgb /= Fgd.a;

   Fgd = float4 (lerp (Colour.rgb, Fgd.rgb, Fgd.a), 1.0);

   return lerp (Colour, Fgd, tex2D (Mask, uv1).x);
}

