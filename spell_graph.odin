package waving_hands

import "base:runtime"
import "core:testing"
import "core:fmt"
import "core:container/queue"
import "core:container/avl"
import "core:slice"

// I want to create a state machine covering all of the one-handed combinations.
Spell_State_Node :: struct {
  previous_gesture: Maybe(Gesture),    // The gesture that was made to reach this node.
  spell: Maybe(Spell),                 // The spell we completed (if any).
  spell_progress: []int, // The state this node represents.
  next: [len(Gesture)]Maybe(^Spell_State_Node)    // Links to the next node for each gesture.
}

spell_node_copy :: proc(node: Spell_State_Node, num_spells: int) -> Spell_State_Node {
  next := Spell_State_Node{}
  next.previous_gesture = nil
  next.spell = nil
  next.spell_progress = make([]int, num_spells)
  copy(next.spell_progress, node.spell_progress)
  return next
}

Spell_State_Machine :: struct {
  root: ^Spell_State_Node,
  states: avl.Tree(Spell_State_Node)
}

spell_state_machine_init :: proc(spell_state_machine: ^Spell_State_Machine) {

  spells := []Spell {
    dispel_magic,
    summon_elemental,
    magic_mirror
  }

  root := Spell_State_Node{ nil, nil, make([]int, len(spells)), {} }

  avl.init_cmp(&spell_state_machine^.states, proc(a, b: Spell_State_Node) -> slice.Ordering {
    assert(len(a.spell_progress) == len(b.spell_progress))
    for i in 0..<len(a.spell_progress) {
      p1, p2 := a.spell_progress[i], b.spell_progress[i]
      if p1 < p2 do return slice.Ordering.Less
      if p1 > p2 do return slice.Ordering.Greater
    }
    return slice.Ordering.Equal
  })

  avl.find_or_insert(&spell_state_machine^.states, root)

  spell_state_machine^.root = &avl.first(&spell_state_machine^.states)^.value

  fmt.println(spell_state_machine^)

  gesture_stack := queue.Queue(Gesture){}
  queue.init(&gesture_stack)
  defer queue.destroy(&gesture_stack)

  spell_state_machine_init_recursive(
    spell_state_machine, spell_state_machine.root, &gesture_stack, spells)
}

// Do we need the whole stack?
spell_state_machine_init_recursive :: proc(
  spell_state_machine: ^Spell_State_Machine,
  spell_state_node: ^Spell_State_Node,
  gesture_stack: ^queue.Queue(Gesture),
  spells: []Spell) {

  next_base := spell_node_copy(spell_state_node^, len(spells))
  defer delete(next_base.spell_progress)

  // For completed spells, zero their spell_progress ready for the next state.
  for spell in spells {
    num_gestures := len(spell.gestures)
    if next_base.spell_progress[spell.type] == num_gestures {
      next_base.spell_progress[spell.type] = 0
    }
  }

  // Consider all gestures from this point.
  for gesture in all_gestures {
    next := spell_node_copy(next_base, len(spells))

    // Update all spell progress.
    for spell_index in 0..<len(spells) {
      progress := next.spell_progress[spell_index]
      next_gesture_in_spell := spells[spell_index].gestures[progress]
      if next_gesture_in_spell == gesture {
        next.spell_progress[spell_index] += 1
        if next.spell_progress[spell_index] == len(spells[spell_index].gestures) {
          next.spell = spells[spell_index]
        }
      }
      else {
        next.spell_progress[spell_index] = 0

        // Does this gesture happen to be the first one of this spell?
        first_gesture_in_spell := spells[spell_index].gestures[0]
        if first_gesture_in_spell == gesture {
          next.spell_progress[spell_index] = 1
        }
      }
    }

    // Is this a new state?
    node, inserted, _ := avl.find_or_insert(&spell_state_machine^.states, next)

    // Link to the parent.
    spell_state_node^.next[gesture] = &node.value

    if !inserted {
      // Already explored
      delete(next.spell_progress)
      continue
    }

    queue.push_back(gesture_stack, gesture)
    spell_state_machine_init_recursive(
      spell_state_machine, &node^.value, gesture_stack, spells)
    queue.pop_back(gesture_stack)
  }
}

spell_state_machine_destroy :: proc(ssm: ^Spell_State_Machine) {
  it := avl.iterator(&ssm.states, avl.Direction.Forward)
  node, found := avl.iterator_next(&it)
  for found {
    delete(node.value.spell_progress)
    node, found = avl.iterator_next(&it)
  }

  avl.destroy(&ssm^.states)
}

@(test)
spell_graph_test :: proc(t: ^testing.T) {
  ssm: Spell_State_Machine
  spell_state_machine_init(&ssm)
  defer spell_state_machine_destroy(&ssm)

  fmt.println(ssm)

  // Let's take a look at the nodes we've got.
  it := avl.iterator(&ssm.states, avl.Direction.Forward)
  node, found := avl.iterator_next(&it)
  fmt.println("Found:", found)
  for found {
    fmt.println("Found:", found)
    fmt.println("Node:", node.value)
    node, found = avl.iterator_next(&it)
  }
}
