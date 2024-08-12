# attax
a successor to [ExpandedAttackLib](https://github.com/Idunno1/ExpandedAttackLib) for [Kristal](https://github.com/KristalTeam/Kristal) that actually works
# THIS WILL ONLY WORK WITH THE LATEST COMMIT OF KRISTAL

## new item variables
* attack_bolt_count: nil by default. automatically 1 for weapons and 0 for other item types. set to override it.
* attack_bolt_speed: nil by default. automatically 8 for weapons and 0 for other item types as all equipment bolt speeds are summed.
* attack_bolt_offset: 0 by default. adds an offset to where bolts spawn.
* attack_bolt_acceleration: nil by default. adds an acceleration to bolts. jank as fuck with more than 1 bolt
* attack_multibolt_offset_scale: nil by default. the scale as of which bolts are offset from each other if there are more than 1. integers (mainly 1 and 2) are recommended as they perfectly align with bolts in other lanes

## new item callbacks
* onAttackBoltHit(attack, bolt, close)
  * attack: the attack box object
  * bolt: the bolt object
  * points: how close the bolt was from the target

## other shit
* score calculations are more lenient, ideally i'd make a position to frame thing but magic numbers'll do for now
