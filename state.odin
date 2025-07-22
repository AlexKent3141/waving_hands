#+feature dynamic-literals

package waving_hands

Gesture_Type :: enum {
  Wiggled_Fingers,
  Proferred_Palm,
  Snap,
  Wave,
  Digit_Pointing,
  Clap
}

all_gestures :: []Gesture_Type {
  Gesture_Type.Wiggled_Fingers,
  Gesture_Type.Proferred_Palm,
  Gesture_Type.Snap,
  Gesture_Type.Wave,
  Gesture_Type.Digit_Pointing,
  Gesture_Type.Clap
}

gesture_to_char := map[Gesture_Type]u8 {
  Gesture_Type.Wiggled_Fingers = 'F',
  Gesture_Type.Proferred_Palm = 'P',
  Gesture_Type.Snap = 'S',
  Gesture_Type.Wave = 'W',
  Gesture_Type.Digit_Pointing = 'D',
  Gesture_Type.Clap = 'C'
}
