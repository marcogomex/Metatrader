//+------------------------------------------------------------------+
//|                                                RightTriangle.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <SpatialReasoning\CoordinatePoint.mqh>
#include <SpatialReasoning\UnitConversion.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct RightTriangle
  {
public:
   CoordinatePoint   A;
   CoordinatePoint   B;
   CoordinatePoint   C;

   void Set(RightTriangle &t)
     {
      this.Set(t.A,t.C);
     }
     
   void Set(CoordinatePoint &a,CoordinatePoint &c)
     {
      this.A.Set(a);
      this.C.Set(c);
      this.B.X.Set(this.A.X.Get()+this.GetWidth());
      this.B.Y.Set(this.A.Y.Get()+this.GetHeight());
     }

   void RightTriangle()
     {
     }

   void RightTriangle(CoordinatePoint &a,CoordinatePoint &c)
     {
      this.Set(a,c);
     }

   double GetWidth()
     {
      return this.C.X.Get() - this.A.X.Get();
     }

   double GetHeight()
     {
      return this.C.Y.Get() - this.A.Y.Get();
     }

   double GetTangent()
     {
      return this.GetHeight()/this.GetWidth();
     }

   double GetRadians()
     {
      return UnitConversion::TangentToRadians(this.GetTangent());
     }

   double GetDegrees()
     {
      return UnitConversion::TangentToDegrees(this.GetTangent());
     }

   double GetHypotenuseLength()
     {
      return MathSqrt(MathPow(this.GetHeight(),2) + MathPow(this.GetWidth(),2));
     }
  };
//+------------------------------------------------------------------+
