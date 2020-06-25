Push = require "push"
Class = require "class"

require "Bird"
require "Pipe"
require "PipePair"

require "states/StateMachine"
require "states/BaseState"
require "states/TitleScreenState"
require "states/ScoreState"
require "states/PlayState"
require "states/PauseState"
require "states/CountDownState"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage("assets/background.png")
local backgroundScroll = 0

local ground = love.graphics.newImage("assets/ground.png")
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413
local GROUND_LOOPING_POINT = 514

paused = false

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Flappy Bird")

    smallFont = love.graphics.newFont("font.ttf", 8)
    mediumFont = love.graphics.newFont("font.ttf", 16)
    flappyFont = love.graphics.newFont("font.ttf", 32)
    largeFont = love.graphics.newFont("font.ttf", 64)
    love.graphics.setFont(flappyFont)

    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ["title"] = function() return TitleScreenState() end,
        ["countdown"] = function() return CountDownState() end,
        ["play"] = function() return PlayState() end,
        ["score"] = function() return ScoreState() end,
        ["pause"] = function() return PauseState() end,
    }

    sounds = {
        ["jump"] = love.audio.newSource("audio/jump.wav", "static"),
        ["explosion"] = love.audio.newSource("audio/explosion.wav", "static"),
        ["hurt"] = love.audio.newSource("audio/hurt.wav", "static"),
        ["score"] = love.audio.newSource("audio/score.wav", "static"),
        ["music"] = love.audio.newSource("audio/marios_way.mp3", "static"),
    }

    sounds["music"]:setLooping(true)
    sounds["music"]:setVolume(0.5)
    --sounds["music"]:play()

    gStateMachine:change("title")

    -- initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == "escape" then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
      return true
    else
      return false
    end
end

function love.update(dt)
    if not paused then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
            % BACKGROUND_LOOPING_POINT

        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
            % GROUND_LOOPING_POINT
    end
    gStateMachine:update(dt)

    -- reset input table
    love.keyboard.keysPressed = {}
end

function love.draw()
    Push:start()

    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    displayFPS()

    Push:finish()
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), VIRTUAL_HEIGHT - 50, 2)
end
