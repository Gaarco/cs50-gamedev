PlayState = Class{__includes = BaseState}

local blocksHit = 14
local powerupActive = false

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.balls = {}
    self.powerups = {}
    table.insert(self.balls, params.ball)

    -- give ball random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed("space") then
            self.paused = false
            gSounds["pause"]:play()
        else
            return
        end
    elseif love.keyboard.wasPressed("space") then
        self.paused = true
        gSounds["pause"]:play()
        return
    end

    self.paddle:update(dt)

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
        print(tostring(k) .. " powerup: " .. tostring(powerup.x) .. " " .. tostring(powerup.y)
            .. " active: " .. tostring(powerup.active))
        if not powerup.active then
            powerupActive = false
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            table.remove(self.powerups, k)
        end
    end

    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds["paddle-hit"]:play()
        end

        if ball.y >= VIRTUAL_HEIGHT then
            self.health = self.health - 1
            gSounds["hurt"]:play()

            if self.health == 0 then
                gStateMachine:change("game-over", {
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level
                })
            else
                
                gStateMachine:change("serve", {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level
                })
            end
        end

        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                -- trigger the brick's hit function, which removes it from play
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                brick:hit()
                blocksHit = blocksHit + 1
                
                -- TODO debug
                print("blocks hit: " .. tostring(blocksHit))
                print("powerup active: " .. tostring(powerupActive))

                if self:checkVictory() then
                    gSounds["victory"]:play()

                    gStateMachine:change("victory", {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1]
                    })
                end


                if ball.x + 2 < brick.x and ball.dx > 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                elseif ball.y < brick.y then
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                ball.dy = ball.dy * 1.03
            end
        end

        for k, brick in pairs(self.bricks) do
            brick.psystem:update(dt)
        end

        if blocksHit >= 15 and not powerupActive then
            table.insert(self.powerups, Powerup(Powerup.TYPES["DOUBLE_BALLS"]))
            powerupActive = true
        end

        if love.keyboard.wasPressed("escape") then
            love.event.quit()
        end
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end

function PlayState:render()
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts["large"])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
    end
end
