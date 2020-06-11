PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

local heart = love.graphics.newImage("assets/heart.png")

local HEART_POSX = 30
local HEART_POSY = 30
local HEART_OFFSETX = 30
local HEART_OFFSETY = 30

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.score = 0
    self.spawnTimer = 0
    self.randomSpawnTime = math.random(2, 4)
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:enter(params)
    self = params
end

function PlayState:update(dt)
    if love.keyboard.wasPressed("p") then
        gStateMachine:change("pause", self)
    end


    self.spawnTimer = self.spawnTimer + dt

    if self.spawnTimer > self.randomSpawnTime then
        local y = math.max(-PIPE_HEIGHT + 10,
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        table.insert(self.pipePairs, PipePair(y))

        self.randomSpawnTime = math.random(2, 4)
        self.spawnTimer = 0
    end

    for k, pair in pairs(self.pipePairs) do
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds["score"]:play()
            end
        end

        pair:update(dt)
    end

    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    self.bird:update(dt)

    print(self.bird.lives)

    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                if not self.bird.immunity then
                    self.bird.immunity = not self.bird.immunity
                    self.bird.lives = self.bird.lives - 1
                    sounds["explosion"]:play()
                    sounds["hurt"]:play()
                end

                if self.bird.lives == 0 then
                    gStateMachine:change("score", {
                        score = self.score
                    })
                end
            end
        end
    end

    if self.bird.y > VIRTUAL_HEIGHT - 15 or self.bird.y < 0 then
        sounds["explosion"]:play()
        sounds["hurt"]:play()

        gStateMachine:change("score", {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print("Score: " .. tostring(self.score), 8, 8)

    for i=1,self.bird.lives do
        love.graphics.draw(heart, VIRTUAL_WIDTH - heart:getWidth() - 8 - i * HEART_OFFSETX, 8)
    end

    self.bird:render()
end
