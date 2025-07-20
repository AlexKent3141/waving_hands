package waving_hands

import "core:unicode"

Spell_Type :: enum {
  Dispel_Magic,
  Summon_Elemental,
  Magic_Mirror,
  Lightning_Bolt,
  Cure_Heavy_Wounds,
  Cure_Light_Wounds,
  Amnesia,
  Confusion,
  Disease,
  Blindness,
  Delayed_Effect,
  Raise_Dead,
  Poison,
  Paralysis,
  Summon_Troll,
  Fireball,
  Shield,
  Remove_Enchantment,
  Invisibility,
  Charm_Monster,
  Charm_Person,
  Summon_Ogre,
  Finger_Of_Death,
  Haste,
  Missile,
  Summon_Goblin,
  Anti_Spell,
  Permanency,
  Time_Stop,
  Resist_Cold,
  Fear,
  Fire_Storm,
  Lightning_Bolt_One_Time,
  Cause_Light_Wounds,
  Summon_Giant,
  Cause_Heavy_Wounds,
  Counter_Spell1,
  Ice_Storm,
  Resist_Heat,
  Protection_From_Evil,
  Counter_Spell2
}

Spell :: struct {
  type: Spell_Type,
  gestures: []Gesture_Type,
  two_handed: []bool,
  one_time: bool
}

spell_create :: proc(type: Spell_Type, gesture_str: string, one_time: bool) -> Spell {
  spell := Spell{}
  spell.type = type
  spell.one_time = one_time

  spell.gestures = make([]Gesture_Type, len(gesture_str))
  spell.two_handed = make([]bool, len(gesture_str))

  for c, i in gesture_str {
    two_handed := unicode.is_upper(c)
    lower := unicode.to_lower(c)
    gesture: Gesture_Type
    switch lower {
    case 'f': gesture = Gesture_Type.Wiggled_Fingers
    case 'p': gesture = Gesture_Type.Proferred_Palm
    case 's': gesture = Gesture_Type.Snap
    case 'w': gesture = Gesture_Type.Wave
    case 'd': gesture = Gesture_Type.Digit_Pointing
    case 'c': gesture = Gesture_Type.Clap
    case: panic("Spell contains unsupported gesture")
    }

    spell.gestures[i] = gesture
    spell.two_handed[i] = two_handed
  }

  return spell
}

dispel_magic            := spell_create(Spell_Type.Dispel_Magic, "Cdpw", false)
summon_elemental        := spell_create(Spell_Type.Summon_Elemental, "Cswws", false)
magic_mirror            := spell_create(Spell_Type.Magic_Mirror, "CW", false)
lightning_bolt          := spell_create(Spell_Type.Lightning_Bolt, "dffdd", false)
cure_heavy_wounds       := spell_create(Spell_Type.Cure_Heavy_Wounds, "dfpw", false)
cure_light_wounds       := spell_create(Spell_Type.Cure_Light_Wounds, "dfw", false)
amnesia                 := spell_create(Spell_Type.Amnesia, "dpp", false)
confusion               := spell_create(Spell_Type.Confusion, "dsf", false)
disease                 := spell_create(Spell_Type.Disease, "dsfffc", false)
blindness               := spell_create(Spell_Type.Blindness, "dwffD", false)
delayed_effect          := spell_create(Spell_Type.Delayed_Effect, "dwsssp", false)
raise_dead              := spell_create(Spell_Type.Raise_Dead, "dwwfwC", false)
poison                  := spell_create(Spell_Type.Poison, "dwwfwd", false)
paralysis               := spell_create(Spell_Type.Paralysis, "fff", false)
summon_troll            := spell_create(Spell_Type.Summon_Troll, "fpsfw", false)
fireball                := spell_create(Spell_Type.Fireball, "fssdd", false)
shield                  := spell_create(Spell_Type.Shield, "p", false)
remove_enchantment      := spell_create(Spell_Type.Remove_Enchantment, "pdwp", false)
invisibility            := spell_create(Spell_Type.Invisibility, "ppWS", false)
charm_monster           := spell_create(Spell_Type.Charm_Monster, "psdd", false)
charm_person            := spell_create(Spell_Type.Charm_Person, "psdf", false)
summon_ogre             := spell_create(Spell_Type.Summon_Ogre, "psfw", false)
finger_of_death         := spell_create(Spell_Type.Finger_Of_Death, "pwpfsssd", false)
haste                   := spell_create(Spell_Type.Haste, "pwpwwC", false)
missile                 := spell_create(Spell_Type.Missile, "sd", false)
summon_goblin           := spell_create(Spell_Type.Summon_Goblin, "sfw", false)
anti_spell              := spell_create(Spell_Type.Anti_Spell, "spf", false)
permanency              := spell_create(Spell_Type.Permanency, "spfpsdw", false)
time_stop               := spell_create(Spell_Type.Time_Stop, "sppC", false)
resist_cold             := spell_create(Spell_Type.Resist_Cold, "ssfp", false)
fear                    := spell_create(Spell_Type.Fear, "swd", false)
fire_storm              := spell_create(Spell_Type.Fire_Storm, "swwC", false)
lightning_bolt_one_time := spell_create(Spell_Type.Lightning_Bolt_One_Time, "wddC", true)
cause_light_wounds      := spell_create(Spell_Type.Cause_Light_Wounds, "wfp", false)
summon_giant            := spell_create(Spell_Type.Summon_Giant, "wfpsfw", false)
cause_heavy_wounds      := spell_create(Spell_Type.Cause_Heavy_Wounds,"wpfd", false)
counter_spell1          := spell_create(Spell_Type.Counter_Spell1, "wpp", false)
ice_storm               := spell_create(Spell_Type.Ice_Storm, "wssC", false)
resist_heat             := spell_create(Spell_Type.Resist_Heat, "wwfp", false)
protection_from_evil    := spell_create(Spell_Type.Protection_From_Evil, "wwp", false)
counter_spell2          := spell_create(Spell_Type.Counter_Spell2, "wws", false)

all_spells := make([dynamic]Spell)

@(init)
init_all_spells :: proc() {
  append(&all_spells, dispel_magic)
  append(&all_spells, summon_elemental)
  append(&all_spells, magic_mirror)
  append(&all_spells, lightning_bolt)
  append(&all_spells, cure_heavy_wounds)
  append(&all_spells, cure_light_wounds)
  append(&all_spells, amnesia)
  append(&all_spells, confusion)
  append(&all_spells, disease)
  append(&all_spells, blindness)
  append(&all_spells, delayed_effect)
  append(&all_spells, raise_dead)
  append(&all_spells, poison)
  append(&all_spells, paralysis)
  append(&all_spells, summon_troll)
  append(&all_spells, fireball)
  append(&all_spells, shield)
  append(&all_spells, remove_enchantment)
  append(&all_spells, invisibility)
  append(&all_spells, charm_monster)
  append(&all_spells, charm_person)
  append(&all_spells, summon_ogre)
  append(&all_spells, finger_of_death)
  append(&all_spells, haste)
  append(&all_spells, missile)
  append(&all_spells, summon_goblin)
  append(&all_spells, anti_spell)
  append(&all_spells, permanency)
  append(&all_spells, time_stop)
  append(&all_spells, resist_cold)
  append(&all_spells, fear)
  append(&all_spells, fire_storm)
  append(&all_spells, lightning_bolt_one_time)
  append(&all_spells, cause_light_wounds)
  append(&all_spells, summon_giant)
  append(&all_spells, cause_heavy_wounds)
  append(&all_spells, counter_spell1)
  append(&all_spells, ice_storm)
  append(&all_spells, resist_heat)
  append(&all_spells, protection_from_evil)
  append(&all_spells, counter_spell2)

  assert(len(all_spells) == len(Spell_Type))
}

@(fini)
cleanup_all_spells :: proc() {
  delete(all_spells)
}
