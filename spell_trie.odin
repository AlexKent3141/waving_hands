package waving_hands

import "base:runtime"
import "core:testing"
import "core:fmt"
import "core:slice"

Spell_Trie_Node :: struct {
  previous_gesture: Maybe(Gesture_Type),
  spell: Maybe(Spell),
  next: [len(Gesture_Type)]^Spell_Trie_Node
}

Spell_Trie :: struct {
  root: ^Spell_Trie_Node,
  nodes: [dynamic]Spell_Trie_Node
}

spell_trie_init :: proc(spells: ^Spell_Trie) {
  spells^.nodes = make([dynamic]Spell_Trie_Node)
  append(&spells^.nodes, Spell_Trie_Node{ nil, nil, {} })
  spells^.root = &spells^.nodes[0]
}

spell_trie_destroy :: proc(spells: ^Spell_Trie) {
  if spells^.nodes != nil do delete(spells^.nodes)
}

spell_trie_insert :: proc(spells: ^Spell_Trie, spell: Spell) {
  node := spells^.root
  for gesture in spell.gestures {
    if node^.next[gesture] == nil {
      append(&spells^.nodes, Spell_Trie_Node{ gesture, nil, {} })
      node^.next[gesture] = &spells^.nodes[len(spells^.nodes) - 1]
    }

    node = node^.next[gesture]
  }

  // We should not have any single-handed spells finishing at the same time.
  assert(node^.spell == nil)

  node^.spell = spell
}

spell_trie_next :: proc(current: ^Spell_Trie_Node, gesture: Gesture_Type) -> (next: ^Spell_Trie_Node, found: bool) {
  if current.next[gesture] == nil do return nil, false
  return current.next[gesture], true
}

@(test)
spell_trie_test :: proc(t: ^testing.T) {
  spells: Spell_Trie
  spell_trie_init(&spells)
  defer spell_trie_destroy(&spells)

  spell_trie_insert(&spells, cause_light_wounds)
  spell_trie_insert(&spells, summon_giant)

  // `cause_light_wounds` flowing into `summon_giant`.
  node := spells.root
  found := true
  node, found = spell_trie_next(node, Gesture_Type.Wave)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_trie_next(node, Gesture_Type.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_trie_next(node, Gesture_Type.Proferred_Palm)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Cause_Light_Wounds)

  node, found = spell_trie_next(node, Gesture_Type.Snap)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_trie_next(node, Gesture_Type.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_trie_next(node, Gesture_Type.Wave)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Summon_Giant)
}
