Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- these variables are for keeping track of our velocity on both
    -- X and Y axis, since the ball can move in 2 dimensions
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

--[[
    places the ball in the middle of the screen, with an initial
    random velocity on both axes
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

--[[
    simply applies velocity to position, scaled by delta time
]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Ball:collides(collider)
    -- first check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > collider.x + collider.width or collider.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > collider.y + collider.height or collider.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end