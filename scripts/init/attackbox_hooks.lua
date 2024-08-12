Utils.hook(AttackBox, "init", function(orig, self, battler, offset, index, x, y)
    offset = offset + self:getBoltOffset(battler)

    orig(self, battler, offset, index, x, y)

    self.speed = self:getBoltSpeed(self.battler)
    self.acceleration = self:getBoltAcceleration(self.battler)
    
    if self.acceleration > 0 then
        self.bolt.physics.friction = -self.acceleration
        self.bolt.physics.speed_x = -self.speed
    else
        self.bolt.physics.speed_x = -self.speed
    end
end)

Utils.hook(AttackBox, "getBoltSpeed", function(orig, self, battler)
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
end)

Utils.hook(AttackBox, "getBoltAcceleration", function(orig, self, battler)
    local acceleration = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        acceleration = acceleration + (equip:getAttackBoltAcceleration() or 0)
    end
    return math.max(acceleration, 0)
end)

Utils.hook(AttackBox, "getBoltOffset", function(orig, self, battler)
    local offset = 0
    for _,equip in ipairs(battler.chara:getEquipment()) do
        offset = offset + (equip:getAttackBoltOffset() or 0)
    end
    return offset
end)

Utils.hook(AttackBox, "getClose", function(orig, self)
    return (self.bolt.x - self.bolt_target - 2) / self.speed
end)

Utils.hook(AttackBox, "hit", function(orig, self)
    local points = math.abs(self:getClose())

    self.bolt:resetPhysics()

    self.bolt:burst()
    self.bolt.layer = 1
    self.bolt:setPosition(self.bolt:getRelativePos(0, 0, self.parent))
    self.bolt:setParent(self.parent)

    local score
    if points <= 0.35 then
        self.bolt:setColor(COLORS.yellow)
        self.bolt.burst_speed = 0.2
        score = 150
    elseif points <= 1.2 then
        score = 120
    elseif points <= 2.6 then
        score = 110
    else
        self.bolt:setColor(self.battler.chara:getDamageColor())
        score = 100 - (points * 2)
    end

    for _,equip in ipairs(self.battler.chara:getEquipment()) do
        equip:onAttackBoltHit(self, self.bolt, points)
    end

    self.attacked = true
    
    return score
end)

Utils.hook(AttackBox, "update", function(orig, self)
    if self.removing or Game.battle.cancel_attack then
        self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, 0.08 * DTMULT)
    end

    if not self.attacked then
        self.afterimage_timer = self.afterimage_timer + DTMULT/2
        while math.floor(self.afterimage_timer) > self.afterimage_count do
            self.afterimage_count = self.afterimage_count + 1
            local afterimg = AttackBar(self.bolt.x, 0, 6, 38)
            afterimg.layer = 3
            afterimg.alpha = 0.4
            afterimg:fadeOutSpeedAndRemove()
            self:addChild(afterimg)
        end
    end

    if not Game.battle.cancel_attack and Input.pressed("confirm") then
        self.flash = 1
    else
        self.flash = Utils.approach(self.flash, 0, DTMULT/5)
    end

    AttackBox.__super.update(self)
end)

Utils.hook(AttackBox, "draw", function(orig, self)
    local target_color = {self.battler.chara:getAttackBarColor()}
    local box_color = {self.battler.chara:getAttackBoxColor()}

    if self.flash > 0 then
        box_color = Utils.lerp(box_color, COLORS.white, self.flash)
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

    AttackBox.__super.draw(self)
end)