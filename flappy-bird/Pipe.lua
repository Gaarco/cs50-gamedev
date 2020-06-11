Pipe = Class{}

local PIPE_IMG = love.graphics.newImage("assets/pipe.png")

PIPE_SPEED = 60

PIPE_WIDTH = 70
PIPE_HEIGHT = 288

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH
    self.y = y

    self.width = PIPE_IMG:getWidth()
    self.height = PIPE_IMG:getHeight()

    self.orientation = orientation
end

function Pipe:update(dt)

end

function Pipe:render()
    love.graphics.draw(PIPE_IMG, self.x,
       (self.orientation == "top" and self.y + PIPE_HEIGHT or self.y),
       0, 1, self.orientation == "top" and -1 or 1)
end
