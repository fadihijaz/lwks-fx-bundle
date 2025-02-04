// @Maintainer jwrl
// @Released 2023-01-23
// @Author jwrl
// @Created 2023-01-23

/**
 This effect provides a simple means of smoothing the movement of a credit roll or crawl.
 It does this by applying a small amount of directional blur to the title.  It then blends
 the result with the background video.

 To use it, add this effect after your roll or crawl and disconnect the input to any title
 effect used.  Select whether you're smoothing a roll or crawl then adjust the smoothing
 to give the best looking result.

 NOTE:  This effect is only suitable for use with Lightworks version 2023 and higher.
        Masking is not provided.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect CrawlRollFix.fx
//
// Version history:
//
// Built 2023-01-23 jwrl.
//-----------------------------------------------------------------------------------------//

#include "_utils.fx"

DeclareLightworksEffect ("Crawl and roll fix", "Mix", "Blend Effects", "Directionally blurs a roll or crawl to smooth its motion", CanSize);

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

DeclareInputs (Fg, Bg);

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

DeclareIntParam (SetTechnique, "Title mode", kNoGroup, 0, "Roll|Crawl");

DeclareFloatParam (Smoothing, "Smoothing", "Blur settings", kNoFlags, 0.2, 0.0, 1.0);

DeclareFloatParam (_OutputAspectRatio);

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#define STRENGTH  0.00125

float _gaussian[] = { 0.2255859375, 0.193359375, 0.120849609375, 0.0537109375, 0.01611328125, 0.0029296875, 0.000244140625 };

//-----------------------------------------------------------------------------------------//
// Functions
//-----------------------------------------------------------------------------------------//

float4 mirror2D (sampler S, float2 xy)
{
   float2 uv = (0.5 - abs (abs (frac (xy / 2.0)) - 0.5.xx)) * 2.0;

   return tex2D (S, uv);
}

//-----------------------------------------------------------------------------------------//
// Code
//-----------------------------------------------------------------------------------------//

// technique SmoothRoll

DeclarePass (Roll)
{ return ReadPixel (Fg, uv1); }

DeclareEntryPoint (SmoothRoll)
{
   float4 Bgnd = ReadPixel (Bg, uv2);

   if (IsOutOfBounds (uv1)) return Bgnd;

   float4 Fgnd = mirror2D (Roll, uv3) * _gaussian [0];

   float2 xy1 = float2 (0.0, Smoothing * _OutputAspectRatio * STRENGTH);
   float2 xy2 = uv3 + xy1;

   Fgnd += mirror2D (Roll, xy2) * _gaussian [1]; xy2 += xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [2]; xy2 += xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [3]; xy2 += xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [4]; xy2 += xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [5]; xy2 += xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [6];

   xy2 = uv3 - xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [1]; xy2 -= xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [2]; xy2 -= xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [3]; xy2 -= xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [4]; xy2 -= xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [5]; xy2 -= xy1;
   Fgnd += mirror2D (Roll, xy2) * _gaussian [6];

   Fgnd.a = pow (Fgnd.a, 0.5);

   return lerp (Bgnd, Fgnd, Fgnd.a);
}


// technique SmoothCrawl

DeclarePass (Crawl)
{ return ReadPixel (Fg, uv1); }

DeclareEntryPoint (SmoothCrawl)
{
   float4 Bgnd = ReadPixel (Bg, uv2);

   if (IsOutOfBounds (uv1)) return Bgnd;

   float4 Fgnd = mirror2D (Crawl, uv3) * _gaussian [0];

   float2 xy1 = float2 (Smoothing * STRENGTH, 0.0);
   float2 xy2 = uv3 + xy1;

   Fgnd += mirror2D (Crawl, xy2) * _gaussian [1]; xy2 += xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [2]; xy2 += xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [3]; xy2 += xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [4]; xy2 += xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [5]; xy2 += xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [6];

   xy2 = uv3 - xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [1]; xy2 -= xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [2]; xy2 -= xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [3]; xy2 -= xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [4]; xy2 -= xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [5]; xy2 -= xy1;
   Fgnd += mirror2D (Crawl, xy2) * _gaussian [6];

   Fgnd.a = pow (Fgnd.a, 0.5);

   return lerp (Bgnd, Fgnd, Fgnd.a);
}

