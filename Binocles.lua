local Binocles = {};
local concat = table.concat
Binocles.__index = Bonocles;

local defaultOptions = {
  active = true,
  customPrinter = true,
  debugToggle = 'f1',
  consoleToggle = 'f2',
  colorToggle = 'f3',
  restart = true,
  watchedFiles = {}
};

function Binocles:init(options)
  options = options or defaultOptions;
  self.active = options.active or false;-- if bonocles is active (drawing)
  self.names = {}; -- keeps the names of teh watched variables
  self.listeners = {}; -- function that run to get the last version of the watched variables
  self.results = {}; -- keeps the results of teh updates of every watched variable
  self.printer = options.customPrinter or false; -- activate printing to console
  self.draw_x = options.draw_x or 0; -- x pos of the Bonocles instance (Used in :draw())
  self.draw_y = options.draw_y or 0; -- y pos of the Bonocles instance (Used in :draw())
  self.currentColor = 2;
  self.printColor = options.printColor or {1.0, 1.0, 1.0, 1.0}; -- text color (will be sent to love.graphics.setColor())
  self.debugToggle = options.debugToggle or "0"; -- Toggle (change the satate of self.active)
  self.consoleToggle = options.consoleToggle or "f1";
  self.watchedFiles = options.watchedFiles or {}; -- files to watch
  self.watchedFilesInfo = {}; -- hold the output of love.filesystem.getInfo(file) for every file.
  self.colorToggle = options.colorToggle or "f2";
  self.restart = options.restart or false; -- Restarts the game without relaunching the executable. This cleanly shuts down the main Lua state instance and creates a brand new one.
  self.colorPalette = {
    --[[BLACK]] {0.0, 0.0, 0.0, 1.0},
    --[[WHITE]] {1.0, 1.0, 1.0, 1.0},
    --[[RED]] {1.0, 0.0, 0.0, 1.0},
    --[[BLUE]] {0.0, 0.0, 1.0, 1.0},
    --[[GREEN]] {0.0, 1.0, 0.0, 1.0},
  };
  self.currentColorIndex = 2;
  -- Test to make sure that every given file exists
  for i, file in ipairs(self.watchedFiles) do
    local fileInfo = love.filesystem.getInfo(file, fileInfo);
    assert(fileInfo, file .. ' must not exist or is in the wrong directory.');
    self.watchedFilesInfo[i] = fileInfo;
  end
end

function Binocles:setPosition (x, y)
  self.draw_x = x;
  self.draw_y = y;
end

function array_concat(...)
  local t = {}
  for n = 1, select("#", ...) do
    local arg = select(n, ...)
    if type(arg) == "table" then
      for _, v in ipairs(arg) do
        t[#t + 1] = v
      end
    else
      t[#t + 1] = arg
    end
  end
  return t
end

function Binocles:addColors(tab)
  self.colorPalette = array_concat(tab, self.colorPalette);
end

function Binocles:watchFiles(tab)
  self.watchedFiles = array_concat(tab, self.watchedFiles);
  for i, file in ipairs(self.watchedFiles) do
    local fileInfo = love.filesystem.getInfo(file, fileInfo);
    assert(fileInfo, file .. ' must not exist or is in the wrong directory.');
    self.watchedFilesInfo[i] = fileInfo;
  end
end


function Binocles:keypressed(key)
  if key == self.debugToggle then
    self.active = not self.active; -- Toggle the instance drawing
  elseif key == self.consoleToggle then
    self:console();
  elseif key == self.colorToggle then
    self:changeColor();
  end
end

function Binocles:changeColor()
  local nbrColors = #self.colorPalette;
  self.currentColorIndex = self.currentColorIndex + 1;
  if self.currentColorIndex > nbrColors then
    self.currentColorIndex = 1;
  end
  self.printColor = self.colorPalette[self.currentColorIndex];
end

function Binocles:print(text, IO, option)
  if self.printer and not IO and not option then
    print("[Bonocles]: " .. text);
  elseif self.printer and option then
    print("[Bonocles Options]: " .. text);
  else
    io.write(text);
  end
end

function containsValue(tab, value)
  for _, val in ipairs(tab) do
    if val == value then
      return true;
    end
  end
  return false;
end

function Binocles:watch(name, obj)
  if containsValue(self.names, name) == false then
    if type(obj) == 'function' then
      self:print("Watching : " .. name);
      table.insert(self.listeners, obj);
      table.insert(self.names, name);
    else
      error("Obj to watch is not a function." ..
      "Hint : wrap the obj in an anonymous function then return the object from it.");
    end
  end
end

function Binocles:update()
  for key, obj in ipairs(self.listeners) do -- Update Objects
    if type(obj) == 'function' then
      self.results[key] = obj();
    end
  end
  for i, file in ipairs(self.watchedFiles) do
    local currentFileInfo = love.filesystem.getInfo(file, currentFileInfo);
    if self.watchedFilesInfo[i].modtime ~= currentFileInfo.modtime then
      self.watchedFilesInfo[i] = currentFileInfo;
      self:print("Changed file :"..file);
      if self.restart then
        love.event.quit( "restart" );
      else
        love.filesystem.load(file)();
      end
    end
  end
end

function Binocles.dump(value)
  local _dump; -- recursive func
  _dump = function(value, depth)
    if depth == nil then
      depth = 0;
    end
    local v_t = type(value);
    if v_t == "string" then
      return '"'.. value .. '"\n';
    elseif v_t == "table" then
      depth = depth + 1;
      local lines;
      do
        local _lines = {};
        local _len = 1;
        for k, v in pairs(value) do
          _lines[_len] = (" "):rep(depth * 4) .. "[" .. tostring(k) .. "] = " .. _dump(v, depth);
          _len = _len + 1;
        end
        lines = _lines;
      end
      -- Moonscript Only
      local class_name;
      if value.__call then
        class_name = "<" .. tostring(value.__class.__name) .. ">";
      end
      return tostring(class_name or "") .. "{\n" .. concat(lines) .. (" "):rep((depth - 1) * 4) .. "}\n";
    else
      return tostring(value) .. "\n";
    end
  end
  return _dump(value);
end

function Binocles:draw()
  love.graphics.push('all');
  if self.active then
    love.graphics.setColor(self.printColor);
    local draw_y = self.draw_y;
    local draw_x = self.draw_x;
    for nameIndice, result in ipairs(self.results) do
      love.graphics.print(self.names[nameIndice] .. " : " .. self.dump(result), draw_x, (draw_y + 1) * 15);
      local _, count = self.dump(result):gsub('\n', '\n');

      if count == 1 then
        draw_y = draw_y + 1;
      else
        draw_y = draw_y + count + 2;
      end

    end
  end
  love.graphics.pop();
end

function Binocles:deconstructeGlobal(str)
  if string.find(str, '%.') then
    local global = string.match(str, "(%w+)%.");
    local dot = string.find(str, '.', 1, true)
    local property = string.sub(str, dot + 1);
    return {
      isTable = true,
      global = global,
      property = property
    };
  else
    return {
      isTable = false,
      global = str
    };
  end
end

function Binocles.GlobalHasKey(key)
  return _G[key] ~= nil;
end

function makeTable(str)
  local delim = {","};
  local results = {}
  local toutput = ""
  for _, v in ipairs(delim) do
    str = str:gsub("([%"..v.."]+)", "`%1`")
  end
  for item in str:gmatch("[^`]+") do if item ~= "," then table.insert(results, item) end end
  return results;
end


function Binocles:console()
  self:print("Variable name (Only globals): ");
  local str = io.read("*l");
  local globals = makeTable(str);
  local toutput = "";
  for _, v in ipairs(globals) do
    toutput = toutput .. "'" .. v .. "',"
  end

  print("[" .. toutput .. "]")
  for i, global in ipairs(globals) do
    local deconstructedGlobal = self:deconstructeGlobal(global);
    local displayName = global;
    local varName = deconstructedGlobal.global;
    local Svarname = varName;
    if self.GlobalHasKey(varName) then
      local varName = _G[varName];
      if not deconstructedGlobal.isTable then
        self:watch(displayName, function() return _G[Svarname] end);
      else
        local property = deconstructedGlobal.property;
        self:watch(displayName, function() return varName[tostring(property)] end);
      end
    else
      self:print("Global Does not exist.");
    end
  end

end

local meta = {
  __call = function(self, ...)
    self:init(...);
  end
}

setmetatable(Binocles, meta);

return Binocles;
