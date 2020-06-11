ScoreState = Class{__includes = BaseState}

local first = love.graphics.newImage("assets/medal-1.png")
local second = love.graphics.newImage("assets/medal-2.png")
local third = love.graphics.newImage("assets/medal-3.png")

function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("countdown")
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf("Oof! You lost!", 0, 64, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(mediumFont)
    love.graphics.printf("Score: " .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, "center")

    if self.score > 30 then
        love.graphics.draw(first, VIRTUAL_WIDTH / 2 - first:getWidth() / 2, 110)
    elseif self.score > 20 then
        love.graphics.draw(second, VIRTUAL_WIDTH / 2 - second:getWidth() / 2, 110)
    else
        love.graphics.draw(third, VIRTUAL_WIDTH / 2 - third:getWidth() / 2, 110)
    end
    love.graphics.printf("Press Enter to Play Again", 0, 220, VIRTUAL_WIDTH, "center")
end
