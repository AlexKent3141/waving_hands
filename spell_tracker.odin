package waving_hands

import "base:runtime"
import "core:testing"
import "core:unicode"
import "core:fmt"
import "core:container/queue"

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
  for gesture in spell.gestures {
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

spell_next :: proc(current: Spell_Trie_Node, gesture: Gesture) -> (next: Spell_Trie_Node, found: bool) {
  if current.next[gesture] == nil do return {}, false
  return current.next[gesture].?, true
}

@(test)
basic_test :: proc(t: ^testing.T) {
  spells: Spell_Trie
  spells_init(&spells)

  spells_insert(&spells, cause_light_wounds)
  spells_insert(&spells, summon_giant)

  // `cause_light_wounds` flowing into `summon_giant`.
  node := spells.root
  found := true
  node, found = spell_next(node, Gesture.Wave)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture.Proferred_Palm)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Cause_Light_Wounds)

  node, found = spell_next(node, Gesture.Snap)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture.Wiggled_Fingers)
  assert(found)
  assert(node.spell == nil)
  node, found = spell_next(node, Gesture.Wave)
  assert(found)
  assert(node.spell.?.type == Spell_Type.Summon_Giant)

  fmt.println(spells)
}

/*
// I want to create a state machine covering all of the one-handed combinations.
Spell_State_Node :: struct {
  previous_gesture: Maybe(Gesture),    // The gesture that was made to reach this node.
  spell: Maybe(Spell),                 // The spell we completed (if any).
  spell_progress: []int // The state this node represents.
}

Spell_State_Machine :: struct {
  root: ^Spell_State_Node,
  states: [dynamic]Spell_State_Node
}

spell_state_machine_init :: proc(spell_state_machine: ^Spell_State_Machine) {

  spells := []Spell {
    dispel_magic,
    summon_elemental
  }

  root := Spell_State_Node{ nil, nil, make([]int, len(spells)) }

  runtime.append_elem(&spell_state_machine^.states, root)

  spell_state_machine^.root = &spell_state_machine^.states[0]

  fmt.println(spell_state_machine^)

  gesture_stack := queue.Queue(u8){}
  queue.init(&gesture_stack)
  defer queue.destroy(&gesture_stack)

  spell_state_machine_init_recursive(spell_state_machine^.root, &gesture_stack, spells)
}

// Do we need the whole stack?
spell_state_machine_init_recursive :: proc(
  spell_state_node: ^Spell_State_Node,
  gesture_stack: ^queue.Queue(u8),
  spells: []Spell) {

  // For completed spells, zero their spell_progress ready for the next state.
  for spell in spells {
    num_gestures := len(spell.gestures)
    if spell_state_node^.spell_progress[spell.type] == num_gestures {
      spell_state_node^.spell_progress[spell.type] = 0
    }
  }

  // Consider all gestures from this point.
  gestures :=  []Gesture { Gesture.Wiggled_Fingers }
  for gesture in gestures {
    next := spell_state_node^

    // Update all spell progress.
  }
}

@(test)
basic_test2 :: proc(t: ^testing.T) {
  ssm: Spell_State_Machine
  spell_state_machine_init(&ssm)
}
*/
