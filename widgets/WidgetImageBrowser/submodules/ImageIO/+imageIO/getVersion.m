function [ version, major, minor ] = getVersion()
%GETVERSION Return the current version of the toolbox

major = 0;
minor = 9;
version = [num2str(major), '.' num2str(minor)];

end

