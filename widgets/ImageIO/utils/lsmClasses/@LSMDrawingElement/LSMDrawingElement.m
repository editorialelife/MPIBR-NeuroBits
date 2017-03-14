classdef LSMDrawingElement
  %LSMDrawingElement Class representation of a DrawingElement in LSM files
  %   The description of a particular drawing element contains two parts.
  %   The first part is a fixed sized structure with equal fields for all 
  %   drawing elements. The second part is drawing element type specific.
  %
  % AUTHOR: Stefano Masneri
  % Date: 13.3.2017
  
  properties
    % fixed part
    type;                   % 13 – Text (DRAWING_ELEMENT_FLOAT_TEXT)
                            % 14 – Line (DRAWING_ELEMENT_FLOAT_LINE)
                            % 15 – Horizontal or vertical scale bar with displayed length
                            % (DRAWING_ELEMENT_FLOAT_SCALE_BAR).
                            % 16 – Line with two line arrow tip
                            % (DRAWING_ELEMENT_FLOAT_OPEN_ARROW)
                            % 17 – Line with three line arrow tip
                            % (DRAWING_ELEMENT_FLOAT_CLOSED_ARROW)
                            % 18 – Rectangle (DRAWING_ELEMENT_FLOAT_RECTANGLE)
                            % 19 – Ellipse (DRAWING_ELEMENT_FLOAT_ELLIPSE)
                            % 20 – Closed polyline
                            % (DRAWING_ELEMENT_FLOAT_CLOSED_POLYLINE)
                            % 21 – Open polyline
                            % (DRAWING_ELEMENT_FLOAT_OPEN_POLYLINE)
                            % 22 – Closed Bezier spline curve
                            % (DRAWING_ELEMENT_FLOAT_CLOSED_BEZIER)
                            % 23 – Open Bezier spline curve
                            % (DRAWING_ELEMENT_FLOAT_OPEN_BEZIER)
                            % 24 – Circle
                            % (DRAWING_ELEMENT_FLOAT_CIRCLE)
                            % 25 – Rectangle with color palette
                            % (DRAWING_ELEMENT_FLOAT_PALETTE)
                            % 26 – Open polyline with arrow tip
                            % (DRAWING_ELEMENT_FLOAT_POLYLINE_ARROW)
                            % 27 – Open Bezier spline curve with arrow tip
                            % (DRAWING_ELEMENT_FLOAT_BEZIER_WITH_ARROW)
                            % 28 – Two connected lines for angle measurement
                            % (DRAWING_ELEMENT_FLOAT_ANGLE)
                            % 29 – Circle defined by three points on the perimeter
                            % (DRAWING_ELEMENT_FLOAT_CIRCLE_3POINT)
    size;                   % Size of the block for the description of the current drawing element in bytes
    lineWidth;              % Line width used to draw the element in pixels.
    measure;                % The value 0 indicates that no measured characteristics are drawn for the drawing element. The value 1 indicates that the default set of measured characteristics is displayed. If the value is not 0 and not 1 the value contains flags for enabled types of measure values.
                            % The flags are:
                            % 0x00000002 – circumference
                            % 0x00000004 – area
                            % 0x00000008 – radius
                            % 0x00000010 - angle
                            % 0x00000020 – distance x
                            % 0x00000040 – distance y
    additTextStartPointX;   % Horizontal start of additional text in image memory coordinates
    additTextStartPointY;   % Vertical start of additional text in image memory coordinates
    color;
    valid;
    knotWidth;
    catchArea;
    fontHeight;             
    fontWidth;              
    fontEscapement;         
    fontOrientation;        
    fontWeight;
    fontItalic;
    fontUnderline;
    fontStrikeOut;
    fontCharSet;
    fontOutPrecision;
    fontClipPrecision;
    fontQuality;
    fontPitchAndFamily;
    fontFaceName;
    disabled;
    notMoveable;
    % part specific to each drawing element type
    
  end
  
  methods
    function obj = LSMDrawingElement(lsmPtr, byteOrder)
    %LSMDRAWINGELEMENT Constructor
    end
  end
  
end

