# Binocles
Debugging Love2D in a simple way.

Binocles is a module based on Monocle https://github.com/kjarvi/monocle.
this module gives the ability to easily :
  1. watch variables and complex expressions
  2. watch files and reload them when they change
  3. Reloads the game after any watched files have been changed.
  4. Custom colors
  5. Add Global variables to the listener from the console.

The setup of a basic main.lua file is as follows:

Note : Make sure to run the game from the console or use --console so you can see the listener output.

```lua

Binocles = require("Binocles");

local test = 0;

function love.load(arg)
  Binocles();
  -- Watch the FPS
  Binocles:watch("FPS", function() return math.floor(1/love.timer.getDelta()) end);
  Binocles:watch("test",function() return test end);

  Binocles:setPosition(10 ,1);
  Binocles:watchFiles( { 'main.lua' } ); -- Add files so the game reloads if they changed.
  Binocles:addColors( { {0.9,0.5,0.2,1.0} } ) -- Add colors to the pallete.
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

```
For Moonscript:
```lua
 export Binocles = assert require "Binocles"
 with love
   .load = () ->
     Binocles!
     Binocles\watch "FPS",() -> return love.timer.getFPS!
```

Options :
* You can send an options array in the constructor : Binocles(options);
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
* if false : will reload only the watched file if it got modified (ctrl-s).
]]--

```

Console Example : !! You can not watch nested tables using the console. !!

![Screenshot from 2021-03-04 22-47-06](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-47-06.png)

* Click "f3" Use "," as a delimiter:

![Screenshot from 2021-03-04 22-48-39](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-48-39.png)

![Screenshot from 2021-03-04 22-48-52](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-04%2022-48-52.png)

* Or you can just give the table name :

![Screenshot from 2021-03-09 09-52-33](https://github.com/maromaroXD/Binocles/blob/master/public/imgs/Screenshot%20from%202021-03-09%2009-52-33.png)
