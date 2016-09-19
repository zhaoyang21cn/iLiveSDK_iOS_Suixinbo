precision mediump float;
uniform sampler2D SamplerY;
uniform sampler2D SamplerU;
uniform sampler2D SamplerV;

uniform sampler2D SamplerA;

varying highp vec2 coordinate;

varying mediump vec2 v_position;

uniform  vec2 boundsCoordX;
uniform  vec2 boundsCoordY;

uniform float layerBoundsWidth;

uniform mat2 textureRotateMatrix;

uniform mat2 textureBoundsMatrix;

uniform mat2 textureScaleMatrix;

uniform int drawType;

uniform int displayType;

uniform int yuvType;//0 is i420, 1 is nv12

const vec3 delyuv = vec3(-0.0/255.0,-128.0/255.0,-128.0/255.0);

//const vec2 del2 = vec2(-1,-0.5);
//const vec2 del1 = vec2(0.5,1);

const vec3 matYUVRGB1 = vec3(1.0,0.0,1.402);
const vec3 matYUVRGB2 = vec3(1.0,-0.344,-0.714);
const vec3 matYUVRGB3 = vec3(1.0,1.772,0.0);

void main()
{
    if((v_position.x + 1.0) > layerBoundsWidth &&
       (1.0 -v_position.x) > layerBoundsWidth &&
       (v_position.y + 1.0) > layerBoundsWidth &&
       (1.0 - v_position.y) > layerBoundsWidth)
    {
        if (drawType == 1)
        {
            gl_FragColor = vec4(0,0,0, 1);
        }
        else
        {
                if (displayType == 0)//draw texture
                {
                    vec3 CurResult;
                    
                    highp vec3 yuv;
                    
                    if (yuvType == 0)
                    {
                        yuv.x = texture2D(SamplerY, coordinate).r;
                        yuv.y = texture2D(SamplerU, coordinate).r;
                        yuv.z = texture2D(SamplerV, coordinate).r;
                    }
                    else
                    {
                        yuv.x = texture2D(SamplerY, coordinate).r;
                        yuv.y = texture2D(SamplerU, coordinate).r;
                        yuv.z = texture2D(SamplerU, coordinate).a;
                    }
                    
                    yuv += delyuv;
                    
                    CurResult.x = dot(yuv,matYUVRGB1);
                    CurResult.y = dot(yuv,matYUVRGB2);
                    CurResult.z = dot(yuv,matYUVRGB3);
                    
                    
                    gl_FragColor = vec4(CurResult.rgb, 1);
                }
                else if (displayType == 2)//draw loading
                {
                    vec3 CurResult;
                    if (coordinate.x < textureBoundsMatrix[0][0] ||
                        coordinate.x > textureBoundsMatrix[0][1] ||
                        coordinate.y < textureBoundsMatrix[1][0] ||
                        coordinate.y > textureBoundsMatrix[1][1])
                    {
                        gl_FragColor = vec4(0,0,0,0.4);
                    }
                    else
                    {
                        vec2 newCoordinate = coordinate - vec2(textureBoundsMatrix[0][0],textureBoundsMatrix[1][0]);
                        //translation to (0,0) first
                        vec2 tmpCoordinate = newCoordinate * textureScaleMatrix;
                        //scale to full coordinate
                        vec2 textureCoordinate = (tmpCoordinate-vec2(0.5,0.5)) * textureRotateMatrix+vec2(0.5,0.5);
                        //rotate
                        if (textureCoordinate.x < 0.0 ||
                            textureCoordinate.x > 1.0 ||
                            textureCoordinate.y < 0.0 ||
                            textureCoordinate.y > 1.0)
                        {
                            gl_FragColor = vec4(0,0,0,0.4);
                        }
                        else
                        {
                            CurResult.rgb = texture2D(SamplerA, textureCoordinate).rgb;
                            
                            gl_FragColor = vec4(CurResult.rgb,0.4);
                        }
                    }
                }
                else//draw gaussion
                {
                    vec3 CurResult;
                    CurResult.rgb = texture2D(SamplerY, coordinate).rgb;
                    gl_FragColor = vec4(CurResult.rgb, 1);
                }
                
            }
    }
    else
    {
        gl_FragColor = vec4(1,1,1,1);
    }
}
