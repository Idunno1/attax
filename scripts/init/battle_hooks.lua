Utils.hook(Battle, "handleAttackingInput", function(orig, self, key)
    if Input.isConfirm(key) then
        if not self.attack_done and not self.cancel_attack and #self.battle_ui.attack_boxes > 0 then
            local closest
            local closest_attacks = {}

            for _,attack in ipairs(self.battle_ui.attack_boxes) do
                if not attack.attacked then
                    local close = attack:getClose()
                    if not closest then
                        closest = close
                        table.insert(closest_attacks, attack)
                    elseif close == closest then
                        table.insert(closest_attacks, attack)
                    elseif close < closest then
                        closest = close
                        closest_attacks = {attack}
                    end
                end
            end

            if closest and closest < 14.2 and closest > -2 then
                for _,attack in ipairs(closest_attacks) do
                    if attack.bolts and #attack.bolts > 1 then
                        attack:hit()
                    else
                        local points = attack:hit()

                        local action = self:getActionBy(attack.battler, true)
                        action.points = points
    
                        if self:processAction(action) then
                            self:finishAction(action)
                        end
                    end
                end
            end
        end
    end
end)

Utils.hook(Battle, "updateAttacking", function(orig, self)
    if self.cancel_attack then
        self:finishAllActions()
        self:setState("ACTIONSDONE")
        return
    end
    if not self.attack_done then
        if not self.battle_ui.attacking then
            self.battle_ui:beginAttack()
        end

        if #self.attackers == #self.auto_attackers and self.auto_attack_timer < 4 then
            self.auto_attack_timer = self.auto_attack_timer + DTMULT

            if self.auto_attack_timer >= 4 then
                local next_attacker = self.auto_attackers[1]

                local next_action = self:getActionBy(next_attacker, true)
                if next_action then
                    self:beginAction(next_action)
                    self:processAction(next_action)
                end
            end
        end

        local all_done = true
        for _,attack in ipairs(self.battle_ui.attack_boxes) do
            if not attack.attacked and attack.fade_rect.alpha < 1 then
                local close = attack:getClose()
                if close <= -2 then
                    if attack.bolts and #attack.bolts > 1 then
                        attack:miss()
                        all_done = false
                    else
                        local points = attack:miss()

                        local action = self:getActionBy(attack.battler, true)
                        action.points = points
    
                        if self:processAction(action) then
                            self:finishAction(action)
                        end
                    end
                else
                    all_done = false
                end
            end
        end

        if #self.auto_attackers > 0 then
            all_done = false
        end

        if all_done then
            self.attack_done = true
        end
    else
        if self:allActionsDone() then
            self:setState("ACTIONSDONE")
        end
    end
end)