package waving_hands

import "base:runtime"
import "core:testing"
import "core:fmt"
import "core:slice"

Spell_Trie_Node :: struct {
  previous_gesture: Maybe(Gesture_Type), // The gesture that was made to reach this node.
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
    make([]Maybe(Spell_Trie_Node), len(Gesture_Type)) }
}

spells_insert :: proc(spells: ^Spell_Trie, spell: Spell) {
  node := &spells^.root
  for gesture in spell.gestures {
    if node^.next[gesture] == nil {
      node^.next[gesture] = Spell_Trie_Node{
        gesture,
        nil,
        make([]Maybe(Spell_Trie_Node), len(Gesture_Type)) }
    }

    node = &node^.next[gesture].?
  }

  // We should not have any single-handed spells finishing at the same time.
  assert(node^.spell == nil)

  node^.spell = spell
}

spell_next :: proc(current: Spell_Trie_Node, gesture: Gesture_Type) -> (next: Spell_Trie_Node, found: bool) {
  if current.next[gesture] == nil do return {}, false
  return current.next[gesture].?, true
}

@(test)
spell_trie_test :: proc(t: ^testing.T) {
  spells: Spell_Trie
  spells_init(&spells)

  spells_insert(&spells, cause_light_wounds)
  spells_insert(&spells, summon_giant)

  // `cause_light_wounds` flowing into `summon_giant`.
  node := spells.root
  found := true
  node, found = spell_next(node, Gesture_Type.Wave)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture_Type.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture_Type.Proferred_Palm)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Cause_Light_Wounds)

  node, found = spell_next(node, Gesture_Type.Snap)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture_Type.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture_Type.Wave)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Summon_Giant)
}
