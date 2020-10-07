Powerup = Class{}

Powerup.TYPES = {
    ["ATTRACTOR"] = 10,
    ["DOUBLE_BALLS"] = 8
}

function Powerup:init(skin)
    self.width = 16
    self.height = 16

    self.x = math.random(0, VIRTUAL_WIDTH)
    self.y = 0 + self.height / 2

    self.dx = math.random(-400, 400)
    self.dy = math.random(60, 80)

    self.skin = skin
    self.active = true
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:update(dt)
    if self.active == true then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt

        if self.x <= 0 then
            self.x = 0
            self.dx = -self.dx
        end

        if self.x >= VIRTUAL_WIDTH then
            self.x = VIRTUAL_WIDTH
            self.dx = -self.dx
        end

        if self.y >= VIRTUAL_HEIGHT then
            self.active = false
        end
    end
end

function Powerup:render()
    if self.active then
        love.graphics.draw(gTextures["main"], gFrames["powerups"][self.skin],
            self.x, self.y)
    end
end
