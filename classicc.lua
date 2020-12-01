--[[
    classicc

    Copyright (c) 2020, rxi

    This module is free software based on the classic module;
    you can redistribute it and/or modify it under
    the terms of the MIT license. See LICENSE for details.
--]]

local Object = {};
Object.__index = Object;

function Object:new()
end

function Object:extend(name)
  local newClass = {};
  for key,value in pairs(self) do
    if key:find("__") == 1 then
      newClass[key] = value;
    end
    newClass.__index = newClass;
    newClass.super = self;
    setmetatable(newClass,self);
    if name then
      function newClass:__tostring() return name end;
    end
    return newClass;
  end
end

function Object:implement(...)
  for _, newClass in pairs({...}) do
    for key, value in pairs(newClass) do
      if self[key] == nil and type(value) == "function" then
        self[key] = value;
      end
    end
  end
end

function Object:is(Type)
  local mt = getmetatable(self);
  while mt do
    if mt == Type then
      return true;
    end
    mt = getmetatable(mt);
  end
  return false;
end

function Object:__call(...)
  local obj = setmetatable({}, self);
  obj:new(...);
  return obj;
end

return Object;
