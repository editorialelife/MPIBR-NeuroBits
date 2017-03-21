function [ version, major, minor ] = getVersion()
%GETVERSION Return the current version of the toolbox

major = 1;
minor = 0;
version = [num2str(major), '.' num2str(minor)];

end

