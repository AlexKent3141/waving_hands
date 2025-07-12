package waving_hands

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
  Surrender,
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

  // This encoding uses upper-case to indicate a two-handed gesture.
  gestures: string,

  one_time_use: bool
}

dispel_magic            :: Spell{ Spell_Type.Dispel_Magic, "Cdpw", false }
summon_elemental        :: Spell{ Spell_Type.Summon_Elemental, "Cswws", false }
magic_mirror            :: Spell{ Spell_Type.Magic_Mirror, "CW", false }
lightning_bolt          :: Spell{ Spell_Type.Lightning_Bolt, "dffdd", false }
cure_heavy_wounds       :: Spell{ Spell_Type.Cure_Heavy_Wounds, "dfpw", false }
cure_light_wounds       :: Spell{ Spell_Type.Cure_Light_Wounds, "dfw", false }
amnesia                 :: Spell{ Spell_Type.Amnesia, "dpp", false }
confusion               :: Spell{ Spell_Type.Confusion, "dsf", false }
disease                 :: Spell{ Spell_Type.Disease, "dsfffc", false }
blindness               :: Spell{ Spell_Type.Blindness, "dwffD", false }
delayed_effect          :: Spell{ Spell_Type.Delayed_Effect, "dwsssp", false }
raise_dead              :: Spell{ Spell_Type.Raise_Dead, "dwwfwC", false }
poison                  :: Spell{ Spell_Type.Poison, "dwwfwd", false }
paralysis               :: Spell{ Spell_Type.Paralysis, "fff", false }
summon_troll            :: Spell{ Spell_Type.Summon_Troll, "fpsfw", false }
fireball                :: Spell{ Spell_Type.Fireball, "fssdd", false }
shield                  :: Spell{ Spell_Type.Shield, "p", false }
remove_enchantment      :: Spell{ Spell_Type.Remove_Enchantment, "pdwp", false }
invisibility            :: Spell{ Spell_Type.Invisibility, "ppWS", false }
charm_monster           :: Spell{ Spell_Type.Charm_Monster, "psdd", false }
charm_person            :: Spell{ Spell_Type.Charm_Person, "psdf", false }
summon_ogre             :: Spell{ Spell_Type.Summon_Ogre, "psfw", false }
finger_of_death         :: Spell{ Spell_Type.Finger_Of_Death, "pwpfsssd", false }
haste                   :: Spell{ Spell_Type.Haste, "pwpwwC", false }
missile                 :: Spell{ Spell_Type.Missile, "sd", false }
summon_goblin           :: Spell{ Spell_Type.Summon_Goblin, "sfw", false }
anti_spell              :: Spell{ Spell_Type.Anti_Spell, "spf", false }
permanency              :: Spell{ Spell_Type.Permanency, "spfpsdw", false }
time_stop               :: Spell{ Spell_Type.Time_Stop, "sppC", false }
resist_cold             :: Spell{ Spell_Type.Resist_Cold, "ssfp", false }
fear                    :: Spell{ Spell_Type.Fear, "swd", false }
fire_storm              :: Spell{ Spell_Type.Fire_Storm, "swwC", false }
lightning_bolt_one_time :: Spell{ Spell_Type.Lightning_Bolt_One_Time, "wddC", true }
cause_light_wounds      :: Spell{ Spell_Type.Cause_Light_Wounds, "wfp", false }
summon_giant            :: Spell{ Spell_Type.Summon_Giant, "wfpsfw", false }
cause_heavy_wounds      :: Spell{ Spell_Type.Cause_Heavy_Wounds,"wpfd", false }
counter_spell1          :: Spell{ Spell_Type.Counter_Spell1, "wpp", false }
ice_storm               :: Spell{ Spell_Type.Ice_Storm, "wssC", false }
resist_heat             :: Spell{ Spell_Type.Resist_Heat, "wwfp", false }
protection_from_evil    :: Spell{ Spell_Type.Protection_From_Evil, "wwp", false }
counter_spell2          :: Spell{ Spell_Type.Counter_Spell2, "wws", false }
