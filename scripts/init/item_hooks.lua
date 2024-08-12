Utils.hook(Item, "init", function(orig, self)
    orig(self)
    self.attack_bolt_count = nil
    self.attack_bolt_speed = nil
    self.attack_bolt_offset = 0
    self.attack_bolt_acceleration = nil

    self.attack_multibolt_offset_scale = nil
end)

Utils.hook(Item, "getAttackBoltCount", function(orig, self)
    return self.attack_bolt_count
end)

Utils.hook(Item, "getAttackBoltSpeed", function(orig, self)
    return self.attack_bolt_speed
end)

Utils.hook(Item, "getAttackBoltOffset", function(orig, self)
    return self.attack_bolt_offset
end)

Utils.hook(Item, "getAttackBoltAcceleration", function(orig, self)
    return self.attack_bolt_acceleration
end)

Utils.hook(Item, "getAttackMultiboltOffsetScale", function(orig, self)
    return self.attack_multibolt_offset_scale
end)

Utils.hook(Item, "onAttackBoltHit", function(orig, self, attack, bolt, close) end)