Binocles = require("Binocles");

--Test variable
test = 0;

function love.load(arg)
  Binocles();
    -- Watch the FPS
    Binocles:watch("FPS", function() return math.floor(1/love.timer.getDelta()) end);
    -- Watch the test global variable
    Binocles:watch("test",function() return test end);
end


function love.update(dt)
  Binocles:update();
end

function love.draw()
  Binocles:draw();
end

function love.keypressed(key)
  test = test + 1; -- inc test every time a key is pressed
  Binocles:keypressed(key);
end
