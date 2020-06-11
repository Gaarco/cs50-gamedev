Paddle = Class{}

AI_HIGH_SPEED = 130
AI_LOW_SPEED = 75

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

--[[
    simply applies velocity to position, scaled by delta time
]]
function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Paddle:reset(x, y)
    self.x = x
    self.y = y
end

function Paddle:autopilot(ball)
    if ball.dy > 0 then
        if ball.y > self.y + self.height / 2 then
            -- move down with velocity dependent on the ball distance
            self.dy = getSpeed(ball)
        elseif ball.y + ball.size < self.y + self.height / 2 then
            -- move up with velocity dependent on the ball distance
            self.dy = -getSpeed(ball)
        else
            self.dy = 0
        end
    elseif ball.dy < 0 then
        if ball.y > self.y + self.height / 2 then
            -- move down with velocity dependent on the ball distance
            self.dy = getSpeed(ball)
        elseif ball.y + ball.size < self.y + self.height / 2 then
            -- move up with velocity dependent on the ball distance
            self.dy = -getSpeed(ball)
        else
            self.dy = 0
        end
    end
end

function getSpeed(ball)
    if ball.x < VIRTUAL_WIDTH / 2 then
        return AI_LOW_SPEED
    elseif ball.x > VIRTUAL_WIDTH / 2 then
        return AI_HIGH_SPEED
    end
    return 0
end