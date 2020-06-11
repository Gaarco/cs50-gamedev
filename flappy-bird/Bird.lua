Bird = Class{}

local GRAVITY = 20
local MAX_FALL_SPEED = 1200
local JUMP_VELOCITY = -5
local FLICKERING_DURATION = 2

local flickeringTimer = 0

function Bird:init()
    self.image = love.graphics.newImage("assets/bird.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.immunity = false
    self.draw = true
    self.lives = 3

    self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
    self.y = (VIRTUAL_HEIGHT / 2) - (self.height / 2)

    self.dy = 0
end

function Bird:collides(pipe)
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + pipe.width then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + pipe.height then
            return true
        end
    end
    return false
end

function Bird:update(dt)
    self.dy = math.min(self.dy + GRAVITY * dt, MAX_FALL_SPEED * dt)

    if love.keyboard.wasPressed("space") then
        self.dy = JUMP_VELOCITY
        sounds["jump"]:play()
    end

    if self.immunity then
        flickeringTimer = flickeringTimer + dt
        if flickeringTimer < FLICKERING_DURATION then
            self.draw = not self.draw
        else
            flickeringTimer = 0
            self.immunity = not self.immunity
            self.draw = true
        end
    end

    self.y = self.y + self.dy
end

function Bird:render()
    if self.draw then
        love.graphics.draw(self.image, self.x, self.y)
    end
end
