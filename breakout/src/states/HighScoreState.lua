HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
  self.highScores = params.highScores
end

function HighScoreState:update(dt)
  if love.keyboard.wasPressed("escape") then
    gSounds["wall-hit"]:play()

    gStateMachine:change("start", {
      highScores = self.highScores
    })
  end
end

function HighScoreState:render()
  
end
