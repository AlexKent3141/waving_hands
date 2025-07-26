package waving_hands

import "base:runtime"
import "core:testing"
import "core:fmt"
import "core:container/queue"
import "core:container/avl"
import "core:slice"
import "core:strings"
import "core:os"

// I want to create a state machine covering all of the one-handed combinations.
Spell_State_Node :: struct {
  id: int,
  previous_gesture: Maybe(Gesture_Type),
  spell: Maybe(Spell),
  next: [len(Gesture_Type)]Maybe(^Spell_State_Node),

  // These are dynamically allocated to support different sets of spells.
  spell_progress: []int
}

spell_node_copy :: proc(node: Spell_State_Node) -> Spell_State_Node {
  next := Spell_State_Node{}
  next.previous_gesture = nil
  next.spell = nil
  next.spell_progress = make([]int, len(node.spell_progress))
  copy(next.spell_progress, node.spell_progress)
  return next
}

Spell_State_Machine :: struct {
  next_id: int,
  root: ^Spell_State_Node,
  states: avl.Tree(Spell_State_Node)
}

spell_state_machine_init :: proc(spell_state_machine: ^Spell_State_Machine, spells: []Spell) {
  root := Spell_State_Node{ 0, nil, nil, {}, make([]int, len(spells)) }

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
  spell_state_machine^.next_id = 1

  gesture_stack := queue.Queue(Gesture_Type){}
  queue.init(&gesture_stack)
  defer queue.destroy(&gesture_stack)

  spell_state_machine_init_recursive(
    spell_state_machine, spell_state_machine.root, &gesture_stack, spells)
}

// Do we need the whole stack?
spell_state_machine_init_recursive :: proc(
  spell_state_machine: ^Spell_State_Machine,
  spell_state_node: ^Spell_State_Node,
  gesture_stack: ^queue.Queue(Gesture_Type),
  spells: []Spell) {

  next_base := spell_node_copy(spell_state_node^)
  defer delete(next_base.spell_progress)

  // For completed spells, zero their spell_progress ready for the next state.
  for spell in spells {
    num_gestures := len(spell.gestures)
    if next_base.spell_progress[spell.index] == num_gestures {
      next_base.spell_progress[spell.index] = 0
    }
  }

  // Consider all gestures from this point.
  for gesture in all_gestures {
    queue.push_back(gesture_stack, gesture)
    defer queue.pop_back(gesture_stack)

    next := spell_node_copy(next_base)

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
        // We might still have some progress - check how much of the spell prefix is intact.
        num_gestures := queue.len(gesture_stack^)
        num_matches := 0
        spell := spells[spell_index]
        for n in 1..<len(spell.gestures) {
          if num_gestures < n do break
          gestures_so_far := gesture_stack.data[num_gestures - n:num_gestures]
          spell_gestures_prefix := spell.gestures[:n]
          assert(len(gestures_so_far) == len(spell_gestures_prefix))
          if slice.equal(gestures_so_far, spell_gestures_prefix) do num_matches = n
        }

        next.spell_progress[spell_index] = num_matches
      }
    }

    node, inserted, _ := avl.find_or_insert(&spell_state_machine^.states, next)

    // Link the child to the parent.
    spell_state_node^.next[gesture] = &node.value

    if !inserted {
      delete(next.spell_progress)
      continue
    }

    node.value.id = spell_state_machine^.next_id
    spell_state_machine^.next_id += 1

    // We've got a new node to explore.
    spell_state_machine_init_recursive(
      spell_state_machine, &node^.value, gesture_stack, spells)
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

spell_state_machine_serialise :: proc(ssm: ^Spell_State_Machine, builder: ^strings.Builder) {
  it := avl.iterator(&ssm^.states, avl.Direction.Forward)
  node, found := avl.iterator_next(&it)
  for found {
    state_node := node.value

    child_gestures := map[^Spell_State_Node]([dynamic]u8){}
    defer delete(child_gestures)

    for gesture in Gesture_Type {
      child := state_node.next[gesture].?
      assert(child != nil)

      if !(child in child_gestures) {
        child_gestures[child] = make([dynamic]u8)
      }

      append(&child_gestures[child], gesture_to_char[gesture])
    }

    for k, v in child_gestures {
      if state_node.spell != nil {
        s, _ := fmt.enum_value_to_string(state_node.spell.?.type)
        strings.write_string(builder, s)
      }
      else {
        strings.write_int(builder, state_node.id)
      }

      strings.write_rune(builder, ' ')
      if k^.spell != nil {
        s, _ := fmt.enum_value_to_string(k^.spell.?.type)
        strings.write_string(builder, s)
      }
      else {
        strings.write_int(builder, k^.id)
      }
      strings.write_rune(builder, ' ')

      strings.write_string(builder, cast(string)v[:])
      strings.write_rune(builder, '\n')

      delete(v)
    }

    node, found = avl.iterator_next(&it)
  }
}

@(test)
spell_graph_test :: proc(t: ^testing.T) {

  ssm: Spell_State_Machine
  spell_state_machine_init(&ssm, all_spells[:])
  defer spell_state_machine_destroy(&ssm)

  fmt.println("Num states:", avl.len(&ssm.states))
  fmt.println(ssm)

  // Play through White's left hand in the sample game.
  node := ssm.root
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Proferred_Palm].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Resist_Heat) // 1st spell complete.

  node = node^.next[Gesture_Type.Snap].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Snap].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Counter_Spell2) // 2nd spell complete.

  node = node^.next[Gesture_Type.Digit_Pointing].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Missile) // 3rd spell complete.

  node = node^.next[Gesture_Type.Proferred_Palm].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Shield) // 4th spell complete.

  node = node^.next[Gesture_Type.Proferred_Palm].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Shield) // 5th spell complete.

  node = node^.next[Gesture_Type.Clap].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Snap].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wave].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Clap].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Fire_Storm) // 6th spell complete.

  node = node^.next[Gesture_Type.Snap].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Digit_Pointing].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Missile) // 7th spell complete.

  // Hit by an anti-spell which resets the spell history.
  node = ssm.root

  node = node^.next[Gesture_Type.Snap].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Proferred_Palm].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Shield) // 8th spell complete.

  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Anti_Spell) // 9th spell complete.
}

@(test)
spell_graph_repeated_paralysis_test :: proc(t: ^testing.T) {

  ssm: Spell_State_Machine
  spell_state_machine_init(&ssm, all_spells[:])
  defer spell_state_machine_destroy(&ssm)

  fmt.println("Num states:", avl.len(&ssm.states))
  fmt.println(ssm)

  // Repeatedly cast paralysis.
  // Once we've done it the first time, we can keep casting `F` to keep it going.
  node := ssm.root
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell == nil)
  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Paralysis) // 1st paralysis

  node = node^.next[Gesture_Type.Wiggled_Fingers].?
  assert(node != nil)
  assert(node^.spell != nil)
  assert(node^.spell.?.type == Spell_Type.Paralysis) // 2nd paralysis
}

main :: proc() {
  ssm: Spell_State_Machine
  spell_state_machine_init(&ssm, reduced_spells[:])
  defer spell_state_machine_destroy(&ssm)

  builder: strings.Builder
  strings.builder_init(&builder)
  defer strings.builder_destroy(&builder)

  spell_state_machine_serialise(&ssm, &builder)

  os.write_entire_file("edges.txt", builder.buf[:])
}
