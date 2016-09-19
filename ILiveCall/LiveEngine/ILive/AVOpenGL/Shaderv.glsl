attribute vec4 position;
attribute mediump vec2 textureCoordinate;
varying mediump vec2 coordinate;
varying mediump vec2 v_position;

uniform mat4 rotateXMatrix;
uniform mat4 rotateYMatrix;
uniform mat4 rotateZMatrix;

uniform float transformValueX;

uniform float transformValueY;

uniform int vertexDrawType;

void main()
{
    vec4 glPosition;
    glPosition.x = dot(position, vec4(1.0,0.0,0.0,transformValueX));
    glPosition.y = dot(position, vec4(0.0,1.0,0.0,transformValueY));
    glPosition.z = dot(position, vec4(0.0,0.0,1.0,0.0));
    glPosition.w = dot(position, vec4(0.0,0.0,0.0,1.0));

    if (vertexDrawType == 1)
    {
        gl_Position = glPosition;//background do not need rotate
    }
    else
    {
        gl_Position = glPosition * rotateXMatrix * rotateYMatrix * rotateZMatrix;
    }
    coordinate = textureCoordinate;
    
    v_position = position.xy;
}

