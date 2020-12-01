-- Author : Tourahi Amine
-- Object   = require "classic"; -- Remove it from here if its erequired in the main.lua
Bonocles = Object:extend("Bonocles");

function Bonocles:new(options)
  self.active = options.active or false;-- if bonocles is active (drawing)
  self.names  = {}; -- keeps the names of teh watched variables
  self.listeners = {}; -- function that run to get the last version of the watched variables
  self.results = {}; -- keeps the results of teh updates of every watched variable
  self.metaInfo = {}; -- contains meta info about what variables are we watching
  self.printer = options.customPrinter or false; -- activate printing to console
  self.palette = {
    "RED"   = {1.0,0.0,0.0,1.0},
    "BLUE"  = {0.0,0.0,1.0,1.0},
    "GREEN" = {0.0,1.0,0.0,1.0},
    "WHITE" = {1.0,1.0,1.0,1.0}
  };

  self.draw_x = options.draw_x or 0; -- x pos of the Bonocles instance (Used in :draw())
  self.draw_y = options.draw_y or 0; -- y pos of the Bonocles instance (Used in :draw())

  self.printColor = options.printColor or self.palette["WHITE"]; -- text color (will be sent to love.graphics.setColor())
  self.debugToggle = options.debugToggle or "0"; -- Toggle (change the satate of self.active)
  self.watchedFiles = options.watchedFiles or {}; -- files to watch
  self.watchedFilesInfo = {}; -- hold the output of love.filesystem.getInfo(file) for every file.
  -- Test to make sure that every given file exists
  for i,file in ipairs(self.watchedFiles) do
    local fileInfo = love.filesystem.getInfo(file,fileInfo);
    assert(fileInfo,file .. ' must not exist or is in the wrong directory.');
    self.watchedFilesInfo[i] = fileInfo;
  end
end

function Bonocles:keypressed(key)
  if self.active and key == self.debugToggle then
    self.active = not self.active; -- Toggle the instance drawing
  end
end

function Bonocles:print(text,justTxt)
  if self.printer and not justTxt then
    print("[Bonocles]: " .. text);
  else
    return "[Bonocles]: " .. text;
  end
end

function Bonocles:watch(name,obj)
  if type(obj) == 'function' then
    self.print("Watching : " .. name);
    table.insert(self.listeners,obj);
    table.insert(self.names,name);
  else
    error("Obj to watch is not a function." ..
          "Hint : wrap the obj in an anonymous function then return the object from it.");
  end
end

function Bonocles:update()
  for key,obj in ipairs(self.listeners) do -- Update Objects
    if type(obj) == 'function'then
      self.results[key] = obj() or 'Error!';
    end
   end
   for i,file in ipairs(self.watchedFiles) do
     local currentFileInfo = love.filesystem.getInfo(file,currentFileInfo);
     if self.watchedFilesInfo[i].modtime ~= currentFileInfo.modtime then
      self.watchedFilesInfo[i] = currentFileInfo;
      love.filesystem.load('main.lua')();
     end
   end
end




return Bonocles;
