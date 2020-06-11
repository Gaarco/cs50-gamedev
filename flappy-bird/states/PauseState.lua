PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
    self.playState = params
    paused = true
end

function PauseState:update(dt)
    if love.keyboard.wasPressed("p") then
        gStateMachine:change("countdown", self.playState)
    end
end

function PauseState:render()
    self.playState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf("Game Paused", 0, 64, VIRTUAL_WIDTH, "center")
end
