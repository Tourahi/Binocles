Binocles = require("Binocles");

--Test variables
test = 0;
local bool = false;
pox = {
  x = 10,
  y = 20
}
function love.load(arg)
  Binocles();
    -- Watch the FPS
    Binocles:watch("FPS", function() return math.floor(1/love.timer.getDelta()) end);
    -- Watch the test global variable
    Binocles:watch("test",function() return test end);
    Binocles:watch("bool",function() return bool end);
end


function love.update(dt)
  Binocles:update();
end

function love.draw()
  Binocles:draw();
end

function love.keypressed(key)
  test = test + 1; -- inc test every time a key is pressed
  bool = not bool; -- change bool variable
  Binocles:keypressed(key);
end
