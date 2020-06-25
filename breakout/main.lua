require "src/Dependencies"

function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())

    love.window.setTitle("Breakout")

    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gFonts = {
        ["small"] = love.graphics.newFont("fonts/font.ttf", 8),
        ["medium"] = love.graphics.newFont("fonts/font.ttf", 16),
        ["large"] = love.graphics.newFont("fonts/font.ttf", 32)
    }

    love.graphics.setFont(gFonts["small"])

    gTextures = {
        ["background"] = love.graphics.newImage("graphics/background.png"),
        ["main"] = love.graphics.newImage("graphics/main.png"),
        ["arrows"] = love.graphics.newImage("graphics/arrows.png"),
        ["hearts"] = love.graphics.newImage("graphics/hearts.png"),
        ["particle"] = love.graphics.newImage("graphics/particle.png"),
    }

    gSounds = {
        ["paddle-hit"] = love.audio.newSource("sounds/paddle_hit.wav"),
        ["score"] = love.audio.newSource("sounds/score.wav"),
        ["wall-hit"] = love.audio.newSource("sounds/wall_hit.wav"),
        ["confirm"] = love.audio.newSource("sounds/confirm.wav"),
        ["select"] = love.audio.newSource("sounds/select.wav"),
        ["no-select"] = love.audio.newSource("sounds/no_select.wav"),
        ["brick-hit-1"] = love.audio.newSource("sounds/brick_hit_1.wav"),
        ["brick-hit-2"] = love.audio.newSource("sounds/brick_hit_2.wav"),
        ["hurt"] = love.audio.newSource("sounds/hurt.wav"),
        ["victory"] = love.audio.newSource("sounds/victory.wav"),
        ["recover"] = love.audio.newSource("sounds/recover.wav"),
        ["high-score"] = love.audio.newSource("sounds/high_score.wav"),
        ["pause"] = love.audio.newSource("sounds/pause.wav"),

        ["music"] = love.audio.newSource("sounds/music.wav"),
    }

    gStateMachine = StateMachine {
        ["start"] = function() return StartState() end
    }

    gStateMachine:change("start")

    love.keyboard.keysPressed = {}
end

function love.update()
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    Push:apply("start")

    local backgroundWidth = gTextures["background"]:getWidth()
    local backgroundHeight = gTextures["background"]:getHeight()

    love.graphics.draw(gTextures["background"],
        0, 0, 0, -- coordinates 0, 0 and no rotation
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1)
    )

    gStateMachine:render()

    displayFPS()

    Push:apply("stop")
end

function displayFPS()
    love.graphics.setFont(gFonts["small"])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end
