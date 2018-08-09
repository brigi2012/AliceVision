// This file is part of the AliceVision project.
// Copyright (c) 2017 AliceVision contributors.
// This Source Code Form is subject to the terms of the Mozilla Public License,
// v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

#pragma once

// mn MATRIX ADDRESSING: mxy = x*n+y (x-row,y-col), (m-number of rows, n-number of columns)

#include <math_constants.h>

#define DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES

namespace aliceVision {
namespace depthMap {

inline static __device__ float3 M3x3mulV3(float* M3x3, const float3& V)
{
#if 0
    return make_float3(M3x3[0] * V.x + M3x3[3] * V.y + M3x3[6] * V.z, M3x3[1] * V.x + M3x3[4] * V.y + M3x3[7] * V.z,
                       M3x3[2] * V.x + M3x3[5] * V.y + M3x3[8] * V.z);
#else
    return make_float3(
        fmaf( M3x3[0], V.x, fmaf( M3x3[3], V.y, M3x3[6] * V.z ) ),
        fmaf( M3x3[1], V.x, fmaf( M3x3[4], V.y, M3x3[7] * V.z ) ),
        fmaf( M3x3[2], V.x, fmaf( M3x3[5], V.y, M3x3[8] * V.z ) ) );
#endif
}

inline static __device__ float3 M3x3mulV2(float* M3x3, const float2& V)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    return make_float3(M3x3[0] * V.x + M3x3[3] * V.y + M3x3[6], M3x3[1] * V.x + M3x3[4] * V.y + M3x3[7],
                       M3x3[2] * V.x + M3x3[5] * V.y + M3x3[8]);
#else
    return make_float3(
        fmaf( M3x3[0], V.x, fmaf( M3x3[3], V.y, M3x3[6] ) ),
        fmaf( M3x3[1], V.x, fmaf( M3x3[4], V.y, M3x3[7] ) ),
        fmaf( M3x3[2], V.x, fmaf( M3x3[5], V.y, M3x3[8] ) ) );
#endif
}

inline static __device__ float3 M3x4mulV3(float* M3x4, const float3& V)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    return make_float3(M3x4[0] * V.x + M3x4[3] * V.y + M3x4[6] * V.z + M3x4[9],
                       M3x4[1] * V.x + M3x4[4] * V.y + M3x4[7] * V.z + M3x4[10],
                       M3x4[2] * V.x + M3x4[5] * V.y + M3x4[8] * V.z + M3x4[11]);
#else
    return make_float3(
        fmaf( M3x4[0], V.x, fmaf( M3x4[3], V.y, fmaf( M3x4[6], V.z, M3x4[9] ) ) ),
        fmaf( M3x4[1], V.x, fmaf( M3x4[4], V.y, fmaf( M3x4[7], V.z, M3x4[10] ) ) ),
        fmaf( M3x4[2], V.x, fmaf( M3x4[5], V.y, fmaf( M3x4[8], V.z, M3x4[11] ) ) ) );
#endif
}

inline static __device__ float2 V2M3x3mulV2(float* M3x3, float2& V)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    float d = M3x3[2] * V.x + M3x3[5] * V.y + M3x3[8];
    return make_float2((M3x3[0] * V.x + M3x3[3] * V.y + M3x3[6]) / d, (M3x3[1] * V.x + M3x3[4] * V.y + M3x3[7]) / d);
#else
    const float d = 1.0f / fmaf( M3x3[2], V.x, fmaf( M3x3[5], V.y, M3x3[8] ) );
    return make_float2(
        fmaf( M3x3[0], V.x, fmaf( M3x3[3], V.y, M3x3[6] ) ) * d,
        fmaf( M3x3[1], V.x, fmaf( M3x3[4], V.y, M3x3[7] ) ) * d );
#endif
}

inline static __device__ float2 project3DPoint(float* M3x4, const float3& V)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    float3 p = M3x4mulV3(M3x4, V);
    return make_float2(p.x / p.z, p.y / p.z);
#else
    // Rounds differently
    const float3 p = M3x4mulV3(M3x4, V);
    const float  z = 1.0f / p.z;
    return make_float2( p.x * z, p.y * z );
#endif
}

#if 0
__device__ void M3x3mulM3x3(float* O3x3, float* A3x3, float* B3x3);

__device__ void M3x3minusM3x3(float* O3x3, float* A3x3, float* B3x3);

__device__ void M3x3transpose(float* O3x3, float* A3x3);
#endif

inline static __device__ uchar4 float4_to_uchar4(const float4& a)
{
    return make_uchar4((unsigned char)a.x, (unsigned char)a.y, (unsigned char)a.z, (unsigned char)a.w);
}

inline static __device__ float4 uchar4_to_float4(const uchar4& a)
{
    return make_float4((float)a.x, (float)a.y, (float)a.z, (float)a.w);
}

inline static __device__ float4 operator*(const float4& a, const float& d)
{
    return make_float4(a.x * d, a.y * d, a.z * d, a.w * d);
}

inline static __device__ float4 operator+(const float4& a, const float4& d)
{
    return make_float4(a.x + d.x, a.y + d.y, a.z + d.z, a.w + d.w);
}

inline static __device__ float4 operator*(const float& d, const float4& a)
{
    return make_float4(a.x * d, a.y * d, a.z * d, a.w * d);
}

inline static __device__ float3 operator*(const float3& a, const float& d)
{
    return make_float3(a.x * d, a.y * d, a.z * d);
}

inline static __device__ float3 operator/(const float3& a, const float& d)
{
    return make_float3(a.x / d, a.y / d, a.z / d);
}

inline static __device__ float3 operator+(const float3& a, const float3& b)
{
    return make_float3(a.x + b.x, a.y + b.y, a.z + b.z);
}

inline static __device__ float3 operator-(const float3& a, const float3& b)
{
    return make_float3(a.x - b.x, a.y - b.y, a.z - b.z);
}

inline static __device__ int2 operator+(const int2& a, const int2& b)
{
    return make_int2(a.x + b.x, a.y + b.y);
}

inline static __device__ float2 operator*(const float2& a, const float& d)
{
    return make_float2(a.x * d, a.y * d);
}

inline static __device__ float2 operator/(const float2& a, const float& d)
{
    return make_float2(a.x / d, a.y / d);
}

inline static __device__ float2 operator+(const float2& a, const float2& b)
{
    return make_float2(a.x + b.x, a.y + b.y);
}

inline static __device__ float2 operator-(const float2& a, const float2& b)
{
    return make_float2(a.x - b.x, a.y - b.y);
}

inline static __device__ float dot(const float3& a, const float3& b)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    return a.x * b.x + a.y * b.y + a.z * b.z;
#else
    return fmaf( a.x, b.x, fmaf( a.y, b.y, a.z * b.z ) );
#endif
}

inline static __device__ float dot(const float2& a, const float2& b )
{
#if 0
    return a.x * b.x + a.y * b.y;
#else
    return fmaf( a.x, b.x, a.y * b.y );
#endif
}

inline static __device__ float size(const float3& a)
{
    return sqrtf(a.x * a.x + a.y * a.y + a.z * a.z);
}

inline static __device__ float size(const float2& a)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    return sqrtf(a.x * a.x + a.y * a.y);
#else
    return hypotf( a.x, a.y );
#endif
}

inline static __device__ float dist(const float3& a, const float3& b)
{
    float3 ab = a - b;
    return size(ab);
}

inline static __device__ float dist(const float2& a, const float2& b)
{
    float2 ab;
    ab.x = a.x - b.x;
    ab.y = a.y - b.y;
    return size(ab);
}

inline static __device__ float3 cross(const float3& a, const float3& b)
{
    return make_float3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

inline static __device__ void normalize(float3& a)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    float d = sqrtf(dot(a, a));
    a.x /= d;
    a.y /= d;
    a.z /= d;
#else
    const float d = rsqrtf(dot(a, a));
    a.x *= d;
    a.y *= d;
    a.z *= d;
#endif
}

inline __device__ void normalize(float2& a)
{
#ifdef DEVICE_MATRIX_CUH_NO_ROUNDING_DIFFERENCES
    float d = sqrtf(dot(a, a));
    a.x /= d;
    a.y /= d;
#else
    const float d = rhypotf( a.x, a.y );
    a.x *= d;
    a.y *= d;
#endif
}

#if 0
__device__ void outerMultiply(float* O3x3, const float3& a, const float3& b);
#endif

inline __device__ float3 linePlaneIntersect(const float3& linePoint, const float3& lineVect, const float3& planePoint,
                                     const float3& planeNormal)
{
    float k = (dot(planePoint, planeNormal) - dot(planeNormal, linePoint)) / dot(planeNormal, lineVect);
    return linePoint + lineVect * k;
}


inline __device__ float orientedPointPlaneDistanceNormalizedNormal(const float3& point, const float3& planePoint,
                                                            const float3& planeNormalNormalized)
{
    return (dot(point, planeNormalNormalized) - dot(planePoint, planeNormalNormalized));
}


#if 0
__device__ float3 closestPointOnPlaneToPoint(const float3& point, const float3& planePoint,
                                             const float3& planeNormalNormalized);
#endif

inline __device__ float3 closestPointToLine3D(const float3& point, const float3& linePoint, const float3& lineVectNormalized)
{
    return linePoint + lineVectNormalized * dot(lineVectNormalized, point - linePoint);
}

inline __device__ float pointLineDistance3D(const float3& point, const float3& linePoint, const float3& lineVectNormalized)
{
    return size(cross(lineVectNormalized, linePoint - point));
}

#if 0
// v1,v2 dot not have to be normalized
__device__ float angleBetwV1andV2(const float3& iV1, const float3& iV2);
#endif

inline __device__ float angleBetwABandAC(const float3& A, const float3& B, const float3& C)
{
    float3 V1, V2;
    V1 = B - A;
    V2 = C - A;
    normalize(V1);
    normalize(V2);

    float a = acosf(V1.x * V2.x + V1.y * V2.y + V1.z * V2.z);
    a = isinf(a) ? 0.0f : a;

    return fabsf(a) / (CUDART_PI_F / 180.0f);
}


/**
 * f(x)=min + (max-min) * \frac{1}{1 + e^{10 * (x - mid) / width}}
 */
inline static __device__ float sigmoid(float zeroVal, float endVal, float sigwidth, float sigMid, float xval)
{
    return zeroVal + (endVal - zeroVal) * (1.0f / (1.0f + expf(10.0f * ((xval - sigMid) / sigwidth))));
}

inline static __device__ float sigmoid2(float zeroVal, float endVal, float sigwidth, float sigMid, float xval)
{
    return zeroVal + (endVal - zeroVal) * (1.0f / (1.0f + expf(10.0f * ((sigMid - xval) / sigwidth))));
}

inline __device__ float3 lineLineIntersect(float* k, float* l, float3* lli1, float3* lli2, float3& p1, float3& p2, float3& p3,
                                    float3& p4)
{
    /*
    %  [pa, pb, mua, mub] = LineLineIntersect(p1,p2,p3,p4)
    %
    %   Calculates the line segment pa_pb that is the shortest route
    %   between two lines p1_p2 and p3_p4. Calculates also the values of
    %   mua and mub where
    %        pa = p1 + mua (p2 - p1)
    %        pb = p3 + mub (p4 - p3)
    %
    %   Returns a MATLAB error if no solution exists.
    %
    %   This a simple conversion to MATLAB of the C code posted by Paul
    %   Bourke at
    %   http://astronomy.swin.edu.au/~pbourke/geometry/lineline3d/. The
    %   author of this all too imperfect translation is Cristian Dima
    %   (csd@cmu.edu)
    */

    float d1343, d4321, d1321, d4343, d2121, denom, numer, p13[3], p43[3], p21[3], pa[3], pb[3], muab[2];

    p13[0] = p1.x - p3.x;
    p13[1] = p1.y - p3.y;
    p13[2] = p1.z - p3.z;

    p43[0] = p4.x - p3.x;
    p43[1] = p4.y - p3.y;
    p43[2] = p4.z - p3.z;

    /*
    if ((abs(p43[0])  < eps) & ...
        (abs(p43[1])  < eps) & ...
        (abs(p43[2])  < eps))
      error('Could not compute LineLineIntersect!');
    end
    */

    p21[0] = p2.x - p1.x;
    p21[1] = p2.y - p1.y;
    p21[2] = p2.z - p1.z;

    /*
    if ((abs(p21[0])  < eps) & ...
        (abs(p21[1])  < eps) & ...
        (abs(p21[2])  < eps))
      error('Could not compute LineLineIntersect!');
    end
    */

    d1343 = p13[0] * p43[0] + p13[1] * p43[1] + p13[2] * p43[2];
    d4321 = p43[0] * p21[0] + p43[1] * p21[1] + p43[2] * p21[2];
    d1321 = p13[0] * p21[0] + p13[1] * p21[1] + p13[2] * p21[2];
    d4343 = p43[0] * p43[0] + p43[1] * p43[1] + p43[2] * p43[2];
    d2121 = p21[0] * p21[0] + p21[1] * p21[1] + p21[2] * p21[2];

    denom = d2121 * d4343 - d4321 * d4321;

    /*
    if (abs(denom) < eps)
      error('Could not compute LineLineIntersect!');
    end
     */

    numer = d1343 * d4321 - d1321 * d4343;

    muab[0] = numer / denom;
    muab[1] = (d1343 + d4321 * muab[0]) / d4343;

    pa[0] = p1.x + muab[0] * p21[0];
    pa[1] = p1.y + muab[0] * p21[1];
    pa[2] = p1.z + muab[0] * p21[2];

    pb[0] = p3.x + muab[1] * p43[0];
    pb[1] = p3.y + muab[1] * p43[1];
    pb[2] = p3.z + muab[1] * p43[2];

    float3 S;
    S.x = (pa[0] + pb[0]) / 2.0;
    S.y = (pa[1] + pb[1]) / 2.0;
    S.z = (pa[2] + pb[2]) / 2.0;

    *k = muab[0];
    *l = muab[1];

    lli1->x = pa[0];
    lli1->y = pa[1];
    lli1->z = pa[2];

    lli2->x = pb[0];
    lli2->y = pb[1];
    lli2->z = pb[2];

    return S;
}

} // namespace depthMap
} // namespace aliceVision
