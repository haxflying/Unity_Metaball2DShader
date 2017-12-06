Shader "MZ/MetaBallShader"
{
	Properties
	{
		_MatCap("MatCap Texture",2D) = "black" {}
		_mcFactor("MatCap Factor",Range(0,1)) = 0
		_threshold("Threshold",Range(0,1)) = 1
		_diffuse("Diffuse",color) = (1,1,1,1)
		_specular("Specular", color) = (1,1,1,1)
		_ambient("Ambient",color) = (1,1,1,1)
		_gloss("Gloss", float) = 3
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "LightMode" = "ForwardBase" "Queue" = "Transparent"}
		LOD 100

		Pass
		{
			Cull Off
			ZWrite On
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			
			#include "UnityCG.cginc"
			#define IT 300
			#define EPSILON 0.02
			#define MAX_DIST 200

			struct Metaball
            {
                float  radius;
                float3 position;
                float4 color;
            };

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 wPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			StructuredBuffer<Metaball> _MetaballBuffer;
			sampler2D _MainTex, _MatCap;
			float4 _MainTex_ST;
			fixed4 _diffuse, _specular, _ambient;
			float _gloss, _threshold, _mcFactor;

			float4 _ObjectPos;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float sdf(float3 p)
			{
				
				Metaball metaball;
				half sum = 0;
				for (int i = 0; i < (int)_MetaballBuffer.Length; ++i)
				{
					metaball = _MetaballBuffer[i];
					float len = length(metaball.position - p);
					float stength = metaball.radius / len;
					sum += stength;
				}
				return abs(sum - _threshold);
				
				//return length(p) - 1;
			}	

			//coz the surface is actually a isosurface, so it's grad == it's normal
			float3 getNormal(float3 p)
			{
				return normalize(float3(
					sdf(float3(p.x + EPSILON,p.y,p.z)) - sdf(float3(p.x - EPSILON,p.y,p.z)),
					sdf(float3(p.x,p.y + EPSILON,p.z)) - sdf(float3(p.x,p.y - EPSILON,p.z)),
					sdf(float3(p.x,p.y,p.z + EPSILON)) - sdf(float3(p.x,p.y,p.z - EPSILON))
				));
			}
			
			float3 phongShader(float3 p)
			{
				float3 N = getNormal(p);
				float3 eye = _WorldSpaceCameraPos;
				float3 V = normalize(p - eye);
				float3 L = normalize(_WorldSpaceLightPos0);
				float3 R = normalize(reflect(L,N));
				

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _ambient;
				float3 diffuse = saturate(dot(L, N)) * _diffuse;
				float s = dot(L, N) > 0?1:0;
				float3 specular = pow(max(0.0,dot(R,V)),_gloss) * _specular * s;
				float3 matcap = tex2D(_MatCap, N.xy * 0.5 + 0.5).rgb;
				return lerp(ambient + diffuse + specular, matcap, _mcFactor);			
			}


			float march(float3 o, float3 r, float end)
			{
				float t = 0.0;
				for(int i = 0; i < IT; i++)
				{
					float d = sdf(o + r * t - _ObjectPos);
					if(d < EPSILON)
					{
						return t;
					}
					t += d;

					if(t >= end)
						return end;
				}
				return end;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 ray = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 pos = _WorldSpaceCameraPos;

				fixed4 col = 1;
				float dist = march(pos, ray, MAX_DIST);
				if(dist >= MAX_DIST - EPSILON)
					return fixed4(0,0,0,0);

				pos += dist * ray;
				col = fixed4(phongShader(pos - _ObjectPos),1);
				return col;
			}
			ENDCG
		}
	}
}
