package waving_hands

import "core:testing"
import "core:unicode"
import "core:fmt"

Spell_Trie_Node :: struct {
  previous_gesture: Maybe(Gesture), // The gesture that was made to reach this node.
  spell: Maybe(Spell),              // The spell we completed (if any).
  next: []Maybe(Spell_Trie_Node)    // Links to the next node for each gesture.
}

// The root node for the trie.
Spell_Trie :: struct {
  root: Spell_Trie_Node
}

spells_init :: proc(spells: ^Spell_Trie) {
  spells^.root = Spell_Trie_Node{
    nil,
    nil,
    make([]Maybe(Spell_Trie_Node), Gesture.NUM_GESTURES) }
}

spells_insert :: proc(spells: ^Spell_Trie, spell: Spell) {
  node := &spells^.root
  for c in spell.gestures {
    two_handed := unicode.is_upper(c)
    lower := unicode.to_lower(c)
    gesture: Gesture
    switch lower {
    case 'f': gesture = Gesture.Wiggled_Fingers
    case 'p': gesture = Gesture.Proferred_Palm
    case 's': gesture = Gesture.Snap
    case 'w': gesture = Gesture.Wave
    case 'd': gesture = Gesture.Digit_Pointing
    case 'c': gesture = Gesture.Clap
    case: panic("Spell contains unsupported gesture")
    }

    if node^.next[gesture] == nil {
      node^.next[gesture] = Spell_Trie_Node{
        gesture,
        nil,
        make([]Maybe(Spell_Trie_Node), Gesture.NUM_GESTURES) }
    }

    node = &node^.next[gesture].?
  }

  // We should not have any single-handed spells finishing at the same time.
  assert(node^.spell == nil)

  node^.spell = spell
}

@(test)
basic_test :: proc(t: ^testing.T) {
  spells: Spell_Trie
  spells_init(&spells)
  spells_insert(&spells, dispel_magic)
  fmt.println(spells)
}
