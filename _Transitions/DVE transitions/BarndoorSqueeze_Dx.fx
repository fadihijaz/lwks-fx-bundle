// @Maintainer jwrl
// @Released 2023-01-31
// @Author jwrl
// @Created 2023-01-31

/**
 This is based on the barn door split effect, modified to squeeze or expand the divided
 section of the frame.

 NOTE:  This effect is only suitable for use with Lightworks version 2023 and higher.
        Unlike LW transitions there is no mask, because I cannot see a reason for it.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect BarndoorSqueeze_Dx.fx
//
// Version history:
//
// Built 2023-01-31 jwrl.
//-----------------------------------------------------------------------------------------//

#include "_utils.fx"

DeclareLightworksEffect ("Barn door squeeze", "Mix", "DVE transitions", "A barn door effect that squeezes the outgoing video to the edges of frame to reveal the incoming video", CanSize);

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

DeclareInputs (Fg, Bg);

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

DeclareIntParam (SetTechnique, "Transition", kNoGroup, 0, "Squeeze horizontal|Expand horizontal|Squeeze vertical|Expand vertical");

DeclareFloatParamAnimated (Amount, "Progress", kNoGroup, kNoFlags, 1.0, 0.0, 1.0);

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#ifdef WINDOWS
#define PROFILE ps_3_0
#endif

#define BLACK float2(0.0, 1.0).xxxy

//-----------------------------------------------------------------------------------------//
// Code
//-----------------------------------------------------------------------------------------//

// Technique squeeze horizontally

DeclarePass (Outgoing_H)
{ return IsOutOfBounds (uv1) ? BLACK : tex2D (Fg, uv1); }

DeclarePass (Bg_H)
{ return ReadPixel (Bg, uv2); }

DeclareEntryPoint (SqueezeH)
{
   float negAmt = 1.0 - Amount;
   float posAmt = (1.0 + Amount) / 2.0;

   float2 xy1 = float2 ((uv3.x - Amount) / negAmt, uv3.y);
   float2 xy2 = float2 (uv3.x / negAmt, uv3.y);

   negAmt /= 2.0;

   return (uv3.x > posAmt) ? tex2D (Outgoing_H, xy1) :
          (uv3.x < negAmt) ? tex2D (Outgoing_H, xy2) : tex2D (Bg_H, uv3);
}

//-----------------------------------------------------------------------------------------//

// Technique expand horizontally

DeclarePass (Fg_H)
{ return ReadPixel (Fg, uv1); }

DeclarePass (Incoming_H)
{ return IsOutOfBounds (uv2) ? BLACK : tex2D (Bg, uv2); }

DeclareEntryPoint (ExpandH)
{
   float negAmt = Amount / 2.0;
   float posAmt = 1.0 - negAmt;

   float2 xy1 = float2 ((uv3.x + Amount - 1.0) / Amount, uv3.y);
   float2 xy2 = float2 (uv3.x / Amount, uv3.y);

   return (uv3.x > posAmt) ? tex2D (Incoming_H, xy1) :
          (uv3.x < negAmt) ? tex2D (Incoming_H, xy2) : ReadPixel (Fg_H, uv3);
}

//-----------------------------------------------------------------------------------------//

// Technique squeeze vertically

DeclarePass (Outgoing_V)
{ return IsOutOfBounds (uv1) ? BLACK : tex2D (Fg, uv1); }

DeclarePass (Bg_V)
{ return ReadPixel (Bg, uv2); }

DeclareEntryPoint (SqueezeV)
{
   float negAmt = 1.0 - Amount;
   float posAmt = (1.0 + Amount) / 2.0;

   float2 xy1 = float2 (uv3.x, (uv3.y - Amount) / negAmt);
   float2 xy2 = float2 (uv3.x, uv3.y / negAmt);

   negAmt /= 2.0;

   return (uv3.y > posAmt) ? tex2D (Outgoing_V, xy1) :
          (uv3.y < negAmt) ? tex2D (Outgoing_V, xy2) : ReadPixel (Bg_V, uv3);
}

//-----------------------------------------------------------------------------------------//

// Technique expand vertically

DeclarePass (Fg_V)
{ return ReadPixel (Fg, uv1); }

DeclarePass (Incoming_V)
{ return IsOutOfBounds (uv2) ? BLACK : tex2D (Bg, uv2); }

DeclareEntryPoint (ExpandV)
{
   float negAmt = Amount / 2.0;
   float posAmt = 1.0 - negAmt;

   float2 xy1 = float2 (uv3.x, (uv3.y + Amount - 1.0) / Amount);
   float2 xy2 = float2 (uv3.x, uv3.y / Amount);

   return (uv3.y > posAmt) ? tex2D (Incoming_V, xy1)
        : (uv3.y < negAmt) ? tex2D (Incoming_V, xy2) : ReadPixel (Fg_V, uv3);
}

