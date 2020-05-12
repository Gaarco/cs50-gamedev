Class = require "class"
push = require "push"

require "Paddle"
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
    runs once when the game starts, used to initialize the game status
]]
function love.load()
    love.window.setTitle("Pong")
    
    math.randomseed(os.time())

    love.graphics.setDefaultFilter("nearest", "nearest")

    smallFont = love.graphics.newFont("font.ttf", 8)
    mediumFont = love.graphics.newFont("font.ttf", 16)
    largeFont = love.graphics.newFont("font.ttf", 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ["hit_paddle"] = love.audio.newSource("audio/hit_paddle.wav", "static"),
        ["hit_wall"] = love.audio.newSource("audio/hit_wall.wav", "static"),
        ["score"] = love.audio.newSource("audio/score.wav", "static")
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    servingPlayer = 0

    winningPlayer = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5 ,20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- game state variable used to transition between different parts of the game
    -- (beginning, menus, main game, high score list, etc...)
    -- we will use this to determine behavior during render and update
    gameState = "start"
end

--[[
    runs when a keypress event is fired, i.e. when you press a key
]]
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "play"
        elseif gameState == "serve" then
            gameState = "play"
        else
            servingPlayer = 0
            winningPlayer = 0
            player1Score = 0
            player2Score = 0
            ball:reset()
            gameState = "start"
        end
    end
end

--[[
    runs every frame, with "dt" which is the delta time since the last frame
    provided by LOVE2D
]]
function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown("w") then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown("up") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == "serve" then
        ball.dx = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        elseif servingPlayer == 2 then
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == "play" then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds["hit_paddle"]:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds["hit_paddle"]:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds["hit_wall"]:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds["hit_wall"]:play()
        end

        -- if we reach the left or the right edge of the screen,
        -- we go back to start and update the score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            if player2Score == 10 then
                winningPlayer = 2
                gameState = "done"
            else
                ball:reset()
                gameState = "serve"
            end

            sounds["score"]:play()
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1

            if player1Score == 10 then
                winningPlayer = 1
                gameState = "done"
            else
                ball:reset()
                gameState = "serve"
            end

            sounds["score"]:play()
        end

        ball:update(dt)
    end
    
    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply("start")

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

    if gameState == "start" then
        love.graphics.printf(
            "Hello Start State!",
            0,
            30,
            VIRTUAL_WIDTH,
            "center"
        )
    elseif gameState == "done" then
        love.graphics.setFont(mediumFont)
        love.graphics.printf(
            "Player " .. winningPlayer .. " wins!",
            0,
            10,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(smallFont)
    elseif gameState == "serve" then
        love.graphics.setFont(mediumFont)
        love.graphics.printf(
            "Serving player: Player " .. servingPlayer,
            0,
            10,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(smallFont)
        love.graphics.printf(
            "Hello Serve State!",
            0,
            30,
            VIRTUAL_WIDTH,
            "center"
        )
    elseif gameState == "play" then
        love.graphics.printf(
            "Hello Play State!",
            0,
            30,
            VIRTUAL_WIDTH,
            "center"
        )
    end

    love.graphics.setFont(largeFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- render first paddle (left side)
    player1:render()
    -- render second paddle (right side)
    player2:render()
    -- render ball
    ball:render()

    -- display fps for debugging
    displayFPS()

    push:apply("end")
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 2)
end

function love.resize(width ,height)
    push:resize(width, height)
end