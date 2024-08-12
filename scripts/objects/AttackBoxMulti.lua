local AttackBoxMulti, super = Class(Object, "AttackBoxMulti")

function AttackBoxMulti:init(battler, offset, index, x, y)
    super.init(self, x, y)

    self.battler = battler
    self.index = index

    self.count = self:getBoltCount(self.battler)
    self.speed = self:getBoltSpeed(self.battler)
    self.offset = offset + self:getBoltOffset(self.battler)
    self.acceleration = self:getBoltAcceleration(self.battler)
    self.multibolt_offset_scale = self:getMultiboltOffsetScale(self.battler)

    self.head_sprite = Sprite(battler.chara:getHeadIcons().."/head", 21, 19)
    self.head_sprite:setOrigin(0.5)
    self:addChild(self.head_sprite)

    self.press_sprite = Sprite("ui/battle/press", 42, 0)
    self:addChild(self.press_sprite)

    self.fade_rect = Rectangle(0, 0, SCREEN_WIDTH, 300)
    self.fade_rect:setColor(0, 0, 0, 0)
    self.fade_rect.layer = 2
    self:addChild(self.fade_rect)

    self.bolt_target = 80 + 2
    self.bolt_start_x = self.bolt_target + (self.offset * self.speed)

    self.bolts = {}
    self:createBolts()

    self.score = 0

    self.afterimage_timer = 0
    self.afterimage_count = -1

    self.flash_timer = 0

    self.attacked = false
    self.removing = false
end

function AttackBoxMulti:getBoltCount(battler)
    local bolts = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        if equip:getAttackBoltCount() then
            bolts = bolts + equip:getAttackBoltCount()
        else
            if equip.type == "weapon" then
                bolts = bolts + 1
            end
        end
    end
    return math.max(bolts, 1)
end

function AttackBoxMulti:getBoltSpeed(battler)
    local speed = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        if equip:getAttackBoltSpeed() then
            speed = speed + equip:getAttackBoltSpeed()
        else
            if equip.type == "weapon" then
                speed = speed + 8
            end
        end
    end
    if speed == 0 then speed = 8 end
    return math.max(speed, 1)
end

function AttackBoxMulti:getBoltOffset(battler)
    local offset = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        offset = offset + (equip:getAttackBoltOffset() or 0)
    end
    return offset
end

function AttackBoxMulti:getBoltAcceleration(battler)
    local acceleration = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        acceleration = acceleration + (equip:getAttackBoltAcceleration() or 0)
    end
    return math.max(acceleration, 0)
end

function AttackBoxMulti:getMultiboltOffsetScale(battler)
    local multibolt_offset_scale = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        if equip:getAttackMultiboltOffsetScale() then
            multibolt_offset_scale = multibolt_offset_scale + equip:getAttackMultiboltOffsetScale()
        else
            if equip.type == "weapon" then
                multibolt_offset_scale = multibolt_offset_scale + 1
            end
        end
    end
    return math.max(multibolt_offset_scale, 1)
end

function AttackBoxMulti:createBolts()
    for i = 1, self.count do
        local x = self.bolt_start_x + ((40 + (38 * (self.index - 1))) * (i - 1) * self.multibolt_offset_scale)
        local bolt = AttackBar(x, 0, 6, 38)
        if self.acceleration > 0 then
            bolt.physics.friction = -self.acceleration
            bolt.physics.speed_x = -self.speed / i
        else
            bolt.physics.speed_x = -self.speed
        end
        bolt.layer = 1
        self:addChild(bolt)
        table.insert(self.bolts, bolt)
    end
end

function AttackBoxMulti:getClose()
    local bolt = self.bolts[1]
    if bolt then
        return (bolt.x - self.bolt_target - 2) / self.speed
    end
end

function AttackBoxMulti:hit()
    local points = math.abs(self:getClose())

    local bolt = self.bolts[1]

    bolt:resetPhysics()
    bolt:burst()
    bolt:setPosition(bolt:getRelativePos(0, 0, self.parent))
    bolt:setParent(self.parent)
    
    if points <= 0.35 then
        Assets.playSound("victor")
        Assets.playSound("victor", 0.1)
        bolt:setColor(COLORS.yellow)
        bolt.burst_speed = 0.2
        self.score = self.score + math.ceil(150 / self.count)
    elseif points <= 1.2 then
        Assets.playSound("hit")
        Assets.playSound("hit", 0.1)
        self.score = self.score + math.ceil(120 / self.count)
    elseif points <= 2.6 then
        Assets.playSound("hit")
        Assets.playSound("hit", 0.1)
        self.score = self.score + math.ceil(110 / self.count)
    else
        Assets.playSound("hit")
        Assets.playSound("hit", 0.1)
        bolt:setColor(self.battler.chara:getDamageColor())
        self.score = self.score + math.ceil((100 - (points * 2)) / self.count)
    end
    table.remove(self.bolts, 1)

    for _,equip in ipairs(self.battler.chara:getEquipment()) do
        equip:onAttackBoltHit(self, bolt, points)
    end

    if #self.bolts == 0 then
        self.attacked = true
        return Utils.clamp(self.score, 0, 150)
    end
end

function AttackBoxMulti:miss()
    local bolt = self.bolts[1]
    bolt:fadeOutSpeedAndRemove(0.4)

    table.remove(self.bolts, 1)

    if #self.bolts == 0 then
        self.attacked = true
        return Utils.clamp(self.score, 0, 150)
    end
end

function AttackBoxMulti:endAttack()
    self.removing = true
end

function AttackBoxMulti:update()
    if self.removing or Game.battle.cancel_attack then
        self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, 0.08 * DTMULT)
    end

    if not self.attacked then
        self.afterimage_timer = self.afterimage_timer + DTMULT/2
        while math.floor(self.afterimage_timer) > self.afterimage_count do
            self.afterimage_count = self.afterimage_count + 1
            for _,bolt in ipairs(self.bolts) do
                local afterimg = AttackBar(bolt.x, 0, 6, 38)
                afterimg.layer = 3
                afterimg.alpha = 0.4
                afterimg:fadeOutSpeedAndRemove()
                self:addChild(afterimg)
            end
        end
    end

    if not Game.battle.cancel_attack and Input.pressed("confirm") then
        self.flash_timer = 1
    else
        self.flash_timer = Utils.approach(self.flash_timer, 0, DTMULT/5)
    end

    super.update(self)
end

function AttackBoxMulti:draw()
    local target_color = {self.battler.chara:getAttackBarColor()}
    local box_color = {self.battler.chara:getAttackBoxColor()}

    if self.flash_timer > 0 then
        box_color = Utils.lerp(box_color, COLORS.white, self.flash_timer)
    end

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")

    local ch1_offset = Game:getConfig("oldUIPositions")

    Draw.setColor(box_color)
    love.graphics.rectangle("line", 80, ch1_offset and 0 or 1, (15 * self.speed) + 3, ch1_offset and 37 or 36)

    Draw.setColor(target_color)
    love.graphics.rectangle("line", 83, 1, 8, 36)
    Draw.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 84, 2, 6, 34)

    love.graphics.setLineWidth(1)

    super.draw(self)

    if DEBUG_RENDER then
        Draw.setColor(COLORS.white)
        if self.score >= 150 then
            Draw.setColor(COLORS.yellow)
        end
        love.graphics.print(self.score, 10, 0)
    end
end

return AttackBoxMulti