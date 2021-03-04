# Binocles
Debugging Love2D in a simple way.

Binocles is a module base on Monocle https://github.com/kjarvi/monocle.
this module give the ability to easily :
  1. watch variables and complex expressions
  2. watch files and reload them when they change
  3. Reloads the game after any watched files have been changed.
  4. Custom colors
  5. Add Global variables to the listener from the console by providing there name.

The setup of a basic main.lua file is as follows:

Note : Make sure to run the game from the console or use --console so you can see the listener output.

```lua
Binocles = require("Binocles");

--Test variables
test = 0;
local bool = false;
pos = {
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

```

Options :

```lua
options.active -- if bonocles is active (drawing)  
options.customPrinter -- activate printing to console
options.draw_x -- x pos of the Bonocles instance (Used in :draw())
options.draw_y  -- y pos of the Bonocles instance (Used in :draw())
options.printColor -- text color (will be sent to love.graphics.setColor())
options.debugToggle -- Toggle (change the satate of self.active)
options.consoleToggle -- Start the interaction with the listener from the console
options.colorToggle -- toggle to change the printing color
options.watchedFiles  -- files to watch

options.restart --[[
* if true :  Restarts the game without relaunching the executable. This cleanly shuts down the main Lua state instance and creates a brand new one.
* if false : will reload only the watched file if he got modified (ctrl-s).
]]--

```

Console Example :

![Screenshot from 2021-03-04 22-47-06](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-47-06.png)

* Click "f3" : 

![Screenshot from 2021-03-04 22-48-39](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-48-39.png)

![Screenshot from 2021-03-04 22-48-52](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-48-52.png)

