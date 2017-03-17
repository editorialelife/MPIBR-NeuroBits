function [ xmlAsString ] = struct2xml( s, file )
%STRUCT2XML Convert a MATLAB structure into a xml file 
% Converts a Matlab structure into an xml object. If the file argument is
% provided, the function will write the xml on file. Otherwise, it will
% return the xml object represented as a char array
%
% USAGE:
% [ ] = struct2xml( s, file )
% xmlAsText = struct2xml(s)
%
% A structure containing:
% s.XMLname.Attributes.attrib1 = "Some value";
% s.XMLname.Element.Text = "Some text";
% s.XMLname.DifferentElement{1}.Attributes.attrib2 = "2";
% s.XMLname.DifferentElement{1}.Text = "Some more text";
% s.XMLname.DifferentElement{2}.Attributes.attrib3 = "2";
% s.XMLname.DifferentElement{2}.Attributes.attrib4 = "1";
% s.XMLname.DifferentElement{2}.Text = "Even more text";
%
% Will produce:
% <XMLname attrib1="Some value">
%   <Element>Some text</Element>
%   <DifferentElement attrib2="2">Some more text</Element>
%   <DifferentElement attrib3="2" attrib4="1">Even more text</DifferentElement>
% </XMLname>
%
% Written by W. Falkena, ASTI, TUDelft, 27-08-2010
%
% Modified by Stefano Masneri, 17.03.2017
    
    if nargin > 2 || nargin == 0 || (nargin == 1 && nargout ~= 1)
        help struct2xml
        return
    end
    
    if ~isstruct(s)
        help struct2xml
        return
    end
    
    if nargin > 1
      if (isempty(strfind(file,'.xml')))
          file = [file '.xml'];
      end
    end
    
    if (length(fieldnames(s)) > 1)
        error(['Error processing the structure:' sprintf('\n') 'There should be a single field in the main structure.']);
    end
    xmlname = fieldnames(s);
    xmlname = xmlname{1};
    
    %create xml structure
    docNode = com.mathworks.xml.XMLUtils.createDocument(xmlname);
    
    %process the rootnode   
    docRootNode = docNode.getDocumentElement;
        
    %append childs
    parseStruct(s.(xmlname),docNode,docRootNode,[inputname(1) '.' xmlname '.']);
    
    %save xml file
    if nargin > 1
      xmlwrite(file,docNode);
    else
      xmlAsString = docNode;
    end
end

% ----- Subfunction parseStruct -----
function [] = parseStruct(s,docNode,curNode,pName)
    
    fnames = fieldnames(s);
    for i = 1:length(fnames)
        curfield = fnames{i};
        
        if (strcmp(curfield,'Attributes'))
            %Attribute data
            if (isstruct(s.(curfield)))
                attr_names = fieldnames(s.Attributes);
                for a = 1:length(attr_names)
                    cur_attr = attr_names{a};
                    [cur_str,succes] = val2str(s.Attributes.(cur_attr));
                    if (succes)
                        curNode.setAttribute(cur_attr,cur_str);
                    else
                        disp(['Warning. The text in ' pName curfield '.' cur_attr ' could not be processed.']);
                    end
                end
            else
                disp(['Warning. The attributes in ' pName curfield ' could not be processed.']);
                disp(['The correct syntax is: ' pName curfield '.attribute_name = ''Some text''.']);
            end
        elseif (strcmp(curfield,'Text'))
            %Text data
            [txt,succes] = val2str(s.Text);
            if (succes)
                curNode.appendChild(docNode.createTextNode(txt));
            else
                disp(['Warning. The text in ' pName curfield ' could not be processed.']);
            end
        else
            %Sub-element
            if (isstruct(s.(curfield)))
                %single element
                curElement = docNode.createElement(curfield);
                curNode.appendChild(curElement);
                parseStruct(s.(curfield),docNode,curElement,[pName curfield '.'])
            elseif (iscell(s.(curfield)))
                %multiple elements
                for c = 1:length(s.(curfield))
                    curElement = docNode.createElement(curfield);
                    curNode.appendChild(curElement);
                    if (isstruct(s.(curfield){c}))
                        parseStruct(s.(curfield){c},docNode,curElement,[pName curfield '{' num2str(c) '}.'])
                    else
                        disp(['Warning. The cell ' pName curfield '{' num2str(c) '} could not be processed, since it contains no structure.']);
                    end
                end
            else
                %eventhough the fieldname is not text, the field could
                %contain text. Create a new element and use this text
                curElement = docNode.createElement(curfield);
                curNode.appendChild(curElement);
                [txt,succes] = val2str(s.(curfield));
                if (succes)
                    curElement.appendChild(docNode.createTextNode(txt));
                else
                    disp(['Warning. The text in ' pName curfield ' could not be processed.']);
                end
            end
        end
    end
end

% ----- Subfunction val2str -----
function [str,succes] = val2str(val)
    
    succes = true;
    str = [];
    
    if (isempty(val))
        %do nothing
    elseif (ischar(val))
        for i = 1:size(val,1) %multiline string
            str = [str regexprep(val(i,:),'[ ]*', ' ') sprintf('\n')];
        end
        str = str(1:end-1); %skip last enter
    elseif (isnumeric(val))
        tmp = num2str(val);
        for i = 1:size(tmp,1) %multiline string
            str = [str regexprep(tmp(i,:),'[ ]*', ' ') sprintf('\n')];
        end
        str = str(1:end-1); %skip last enter
    else
        succes = false;        
    end
end