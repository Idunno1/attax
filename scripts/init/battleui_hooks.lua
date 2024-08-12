Utils.hook(BattleUI, "beginAttack", function(orig, self)
    local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

    for _,box in ipairs(self.attack_boxes) do
        box:remove()
    end
    self.attack_boxes = {}

    local last_offset = -1
    local offset = 0
    for i = 1, #attack_order do
        offset = offset + last_offset

        local battler = attack_order[i]
        local index = Game.battle:getPartyIndex(battler.chara.id)

        local bolts = 0
        for _,equip in ipairs(battler.chara:getEquipment()) do
            bolts = bolts + (equip:getAttackBoltCount() or 0)
        end
        bolts = math.max(bolts, 1)

        local attack_box
        if bolts == 1 then
            attack_box = AttackBox(battler, 30 + offset, index, 0, 40 + (38 * (index - 1)))
        else
            attack_box = AttackBoxMulti(battler, 30 + offset, index, 0, 40 + (38 * (index - 1)))
        end
        
        attack_box.layer = -10 + (index * 0.01)
        self:addChild(attack_box)
        table.insert(self.attack_boxes, attack_box)

        if i < #attack_order and last_offset ~= 0 then
            last_offset = Utils.pick{0, 10, 15}
        else
            last_offset = Utils.pick{10, 15}
        end
    end

    self.attacking = true
end)