// @Maintainer jwrl
// @Released 2023-01-20
// @Author jwrl
// @Released 2023-01-20

/**
 This effect is a flexible vignette with the ability to apply a range of masks using
 the Lightworks mask effect.  The edges of the mask can be bordered with a bicolour
 shaded surround as a percentage of the edge softness.  Drop shadowing of the mask
 is included, and is set as an offset percentage.

 There is a limited 2D DVE function included which will allow the masked video to
 be scaled and positioned.  Since this is applied after the mask is generated it is
 advisable to set the mask up first.

 Because using the mask opacity to fade the foreground will give ugly results when
 a border is used, the master opacity is the best way to fade the effect out.  If
 the mask invert function is used the border colours will swap and the drop shadow
 will appear inside the mask.  To stop this happening you should use the master
 invert function.

 NOTE:  This effect is only suitable for use with Lightworks version 2023 and higher.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect Flexicrop.fx
//
// Version history:
//
// Built 2023-01-20 jwrl.
//-----------------------------------------------------------------------------------------//

#include "_utils.fx"

DeclareLightworksEffect ("Flexible crop", "DVE", "Border and Crop", "A flexible bordered crop with drop shadow based on LW masking", CanSize);

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

DeclareInputs (Fg, Bg);

DeclareMask;

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

DeclareFloatParam (Opacity, "Opacity", kNoGroup, kNoFlags, 1.0, 0.0, 1.0);

DeclareBoolParam (Invert, "Invert effect", kNoGroup, false);

DeclareFloatParam (Scale, "Master size", "DVE", "DisplayAsPercentage", 1.0, 0.0, 10.0);

DeclareFloatParam (SizeX, "Size", "DVE", "SpecifiesPointX|DisplayAsPercentage", 1.0, 0.0, 10.0);
DeclareFloatParam (SizeY, "Size", "DVE", "SpecifiesPointY|DisplayAsPercentage", 1.0, 0.0, 10.0);

DeclareFloatParam (Pos_X, "Position", "DVE", "SpecifiesPointX|DisplayAsPercentage", 0.5, -1.0, 2.0);
DeclareFloatParam (Pos_Y, "Position", "DVE", "SpecifiesPointY|DisplayAsPercentage", 0.5, -1.0, 2.0);

DeclareBoolParam (UseBorder, "Use border", "Border", true);

DeclareFloatParam (bStrength, "Strength", "Border", kNoFlags, 1.0, 0.0, 1.0);

DeclareColourParam (BorderColour_1, "Inner colour", "Border", kNoFlags, 0.2, 0.8, 0.8, 1.0);
DeclareColourParam (BorderColour_2, "Outer colour", "Border", kNoFlags, 0.2, 0.1, 1.0, 1.0);

DeclareBoolParam (UseShadow, "Use drop shadow", "Drop shadow", true);

DeclareFloatParam (sStrength, "Strength", "Drop shadow", kNoFlags, 0.5, 0.0, 1.0);

DeclareFloatParam (ShadowX, "Offset", "Drop shadow", "SpecifiesPointX|DisplayAsPercentage", 0.525, 0.4, 0.6);
DeclareFloatParam (ShadowY, "Offset", "Drop shadow", "SpecifiesPointY|DisplayAsPercentage", 0.475, 0.4, 0.6);

DeclareFloatParam (_OutputAspectRatio);

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#ifdef WINDOWS
#define PROFILE ps_3_0
#endif

#define BLACK float2(0.0,1.0).xxxy

//-----------------------------------------------------------------------------------------//
// Code
//-----------------------------------------------------------------------------------------//

// These first 2 passes are done to optionally invert the inputs to the effect and map
// their coordinates to the master sequence coordinates.

DeclarePass (Fgd)
{ return Invert ? ReadPixel (Bg, uv2) : ReadPixel (Fg, uv1); }

DeclarePass (Bgd)
{ return Invert ? ReadPixel (Fg, uv1) : ReadPixel (Bg, uv2); }

DeclarePass (Dfg)
{
   float4 Fgnd = ReadPixel (Fgd, uv3);          // The only input required is the nominal foreground

   // We now generate the XY coordinates for the drop shadow

   float2 xy1 = uv3 - float2 (ShadowX - 0.5, (0.5 - ShadowY) * _OutputAspectRatio);

   // The raw mask softness data for both the the foreground and the drop shadow is now recovered.

   float Mraw = tex2D (Mask, uv3).x;
   float Sraw = tex2D (Mask, xy1).x;

   // check if we're colouring the border or not and skip if no

   if (UseBorder) {

      // First the raw mask data is scaled to run from 0 to 1.5.  This allows us to generate
      // the three transitions that we require for the border colours.  The first, innerBorder,
      // transitions from 0 to 1 over two thirds of the mask softness, starting at the inner
      // edge.  The next, borderWidth, occupies the middle third of the mask, and outerBorder
      // takes up the final two thirds.

      float outerBorder = 1.5 * Mraw;
      float innerBorder = lerp (1.0, saturate (outerBorder - 0.5), bStrength);
      float borderWidth = lerp (1.0, saturate ((outerBorder * 2.0) - 1.0), bStrength);

      // The transition between the inner and outer colours for the border is now built

      float4 BorderColour = lerp (BorderColour_2, BorderColour_1, borderWidth);

      // The foreground is now blended with the border colours

      Fgnd  = lerp (BorderColour, Fgnd, innerBorder);

      // The two raw masks are adjusted to allow for the percentage border width.

      Mraw = lerp (Mraw, saturate (outerBorder), bStrength);
      Sraw = lerp (Sraw, saturate (1.5 * Sraw), bStrength);
   }

   // If we're using the drop shadow build it in retval, otherwise use transparent black

   float4 retval = UseShadow ? lerp (kTransparentBlack, BLACK, Sraw * sStrength) : kTransparentBlack;

   // Return the masked and bordered foreground over the drop shadow.

   return lerp (retval, Fgnd, Mraw);
}

DeclareEntryPoint (Flexicrop)
{
   // Set up the scaled and positioned coordinates for the masked video

   float2 xy1 = (uv3 - float2 (Pos_X, 1.0 - Pos_Y)) / Scale;

   // We now scale X and Y separately using their own scale factors.

   xy1.x /= SizeX;
   xy1.y /= SizeY;

   // Now we re-centre the coordinates 

   xy1 += 0.5.xx;

   // Recover the scaled and repositioned masked foreground and the background video

   float4 Fgnd = ReadPixel (Dfg, xy1);
   float4 Bgnd = ReadPixel (Bgd, uv3);

   // Mix everything and get out.

   return ((Fgnd - Bgnd) * Fgnd.a * Opacity) + Bgnd;
}

