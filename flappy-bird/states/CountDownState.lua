CountDownState = Class{__includes = BaseState}

COUNTDOWN_TIME = 0.75

function CountDownState:init()
    self.count = 3
    self.timer = 0
end

function CountDownState:enter(params)
    self.playState = params
end

function CountDownState:update(dt)
    self.timer = self.timer + dt

    if self.timer > COUNTDOWN_TIME then
        self.timer = self.timer % COUNTDOWN_TIME
        self.count = self.count - 1

        if self.count == 0 then
            if not self.playState then
                gStateMachine:change("play")
            else
                paused = false
                gStateMachine.current = self.playState
            end
        end
    end
end

function CountDownState:render()
    if self.playState then self.playState:render() end
    love.graphics.setFont(largeFont)
    love.graphics.printf(tostring(self.count), 0, 120, VIRTUAL_WIDTH, "center")
end
