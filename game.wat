;;
;; WASM-4: https://wasm4.org/docs
(import "env" "memory" (memory 1))
;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                                                                           │
;; │ Drawing Functions                                                         │
;; │                                                                           │
;; └───────────────────────────────────────────────────────────────────────────┘
(; Copies pixels to the framebuffer. ;)
(import "env" "blit" (func $blit (param i32 i32 i32 i32 i32 i32)))

(; Copies a subregion within a larger sprite atlas to the framebuffer. ;)
(import "env" "blitSub" (func $blitSub (param i32 i32 i32 i32 i32 i32 i32 i32 i32)))

(; Draws a line between two points. ;)
(import "env" "line" (func $line (param i32 i32 i32 i32)))

(; Draws a horizontal line. ;)
(import "env" "hline" (func $hline (param i32 i32 i32)))

(; Draws a vertical line. ;)
(import "env" "vline" (func $vline (param i32 i32 i32)))

(; Draws an oval (or circle). ;)
(import "env" "oval" (func $oval (param i32 i32 i32 i32)))

(; Draws a rectangle. ;)
(import "env" "rect" (func $rect (param i32 i32 i32 i32)))

(; Draws text using the built-in system font. ;)
(import "env" "text" (func $text (param i32 i32 i32)))

;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                                                                           │
;; │ Sound Functions                                                           │
;; │                                                                           │
;; └───────────────────────────────────────────────────────────────────────────┘
(; Plays a sound tone. ;)
(import "env" "tone" (func $tone (param i32 i32 i32 i32)))

;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                                                                           │
;; │ Storage Functions                                                         │
;; │                                                                           │
;; └───────────────────────────────────────────────────────────────────────────┘
(; Reads up to "size" bytes from persistent storage into the pointer "dest". ;)
(import "env" "diskr" (func $diskr (param i32 i32)))

(; Writes up to "size" bytes from the pointer "src" into persistent storage. ;)
(import "env" "diskw" (func $diskw (param i32 i32)))

(; Prints a message to the debug console. ;)
(import "env" "trace" (func $trace (param i32)))

(; Prints a message to the debug console. ;)
(import "env" "tracef" (func $tracef (param i32 i32)))


;; ┌───────────────────────────────────────────────────────────────────────────┐
;; │                                                                           │
;; │ Memory Addresses                                                          │
;; │                                                                           │
;; └───────────────────────────────────────────────────────────────────────────┘

(global $PALETTE0 i32 (i32.const 0x04))
(global $PALETTE1 i32 (i32.const 0x08))
(global $PALETTE2 i32 (i32.const 0x0c))
(global $PALETTE3 i32 (i32.const 0x10))
(global $DRAW_COLORS i32 (i32.const 0x14))
(global $GAMEPAD1 i32 (i32.const 0x16))
(global $GAMEPAD2 i32 (i32.const 0x17))
(global $GAMEPAD3 i32 (i32.const 0x18))
(global $GAMEPAD4 i32 (i32.const 0x19))
(global $MOUSE_X i32 (i32.const 0x1a))
(global $MOUSE_Y i32 (i32.const 0x1c))
(global $MOUSE_BUTTONS i32 (i32.const 0x1e))
(global $SYSTEM_FLAGS i32 (i32.const 0x1f))
(global $NETPLAY i32 (i32.const 0x20))
(global $FRAMEBUFFER i32 (i32.const 0xa0))

(global $BUTTON_1 i32 (i32.const 1))
(global $BUTTON_2 i32 (i32.const 2))
(global $BUTTON_LEFT i32 (i32.const 16))
(global $BUTTON_RIGHT i32 (i32.const 32))
(global $BUTTON_UP i32 (i32.const 64))
(global $BUTTON_DOWN i32 (i32.const 128))

(global $MOUSE_LEFT i32 (i32.const 1))
(global $MOUSE_RIGHT i32 (i32.const 2))
(global $MOUSE_MIDDLE i32 (i32.const 4))

(global $SYSTEM_PRESERVE_FRAMEBUFFER i32 (i32.const 1))
(global $SYSTEM_HIDE_GAMEPAD_OVERLAY i32 (i32.const 2))


(global $BLIT_2BPP i32 (i32.const 1))
(global $BLIT_1BPP i32 (i32.const 0))
(global $BLIT_FLIP_X i32 (i32.const 2))
(global $BLIT_FLIP_Y i32 (i32.const 4))
(global $BLIT_ROTATE i32 (i32.const 8))


(global $TONE_PULSE1 i32 (i32.const 0))
(global $TONE_PULSE2 i32 (i32.const 1))
(global $TONE_TRIANGLE i32 (i32.const 2))
(global $TONE_NOISE i32 (i32.const 3))
(global $TONE_MODE1 i32 (i32.const 0))
(global $TONE_MODE2 i32 (i32.const 4))
(global $TONE_MODE3 i32 (i32.const 8))
(global $TONE_MODE4 i32 (i32.const 12))
(global $TONE_PAN_LEFT i32 (i32.const 16))
(global $TONE_PAN_RIGHT i32 (i32.const 32))

;; smiley
(data (i32.const 0x19a0) "\c3\81\24\24\00\24\99\c3")

(data (i32.const 0x19a8) "Hello world!\00")

;; Functions

(func (export "start")
(call $updatePos (i32.const 76) (i32.const 76))
(i32.store (global.get $PALETTE0) (i32.const 0xffffff))
(i32.store (global.get $PALETTE1) (i32.const 0x000000))
(i32.store (global.get $PALETTE3) (i32.const 0xff0000))
)

(func (export "update")
(local $gamepad i32)


;; uint8_t gamepad = *GAMEPAD1;
(local.set $gamepad (i32.load8_u (global.get $GAMEPAD1)))

;; if (gamepad & BUTTON_1) {
;;     *DRAW_COLORS = 4;
;; }

(call $shoot (local.get $gamepad))
(call $getInput (local.get $gamepad))
(i32.store16 (global.get $DRAW_COLORS) (i32.const 2))
;; blit(smiley, 76, 76, 8, 8, BLIT_1BPP);
(call $blit (i32.const 0x19a0) (call $getPlayerX) (call $getPlayerY) (i32.const 8) (i32.const 8) (global.get $BLIT_1BPP))

(call $cornerHandling)
)

;; region: Movement

(global $playerPos i32 (i32.const 0x3000))
(global $playerVelocity i32 (i32.const 0x3008))
(global $acceleration f32 (f32.const 0.5))
(global $friction f32 (f32.const 0.95))

(func $reverseDirection (param $velocityMem i32)
(call $tone (i32.const 262) (i32.const 5) (i32.const 50) (global.get $TONE_TRIANGLE))

local.get $velocityMem
(f32.mul (f32.load (local.get $velocityMem)) (f32.const -1))
f32.store
)

(func $cornerHandling 
(if (i32.gt_s (call $getPlayerX) (i32.const 158))
(then 

  call $getPlayerMemX
  i32.const -10
  i32.store
))

(if (i32.lt_s (call $getPlayerX) (i32.const -10))
(then
  call $getPlayerMemX
  i32.const 158
  i32.store
))

(if (i32.gt_s (call $getPlayerY) (i32.const 152))
(then
  call $getVelMemY
  call $reverseDirection

  call $getPlayerMemY
  i32.const 152
  i32.store
))

(if (i32.lt_s (call $getPlayerY) (i32.const 0)) 

(then
  call $getVelMemY
  call $reverseDirection
  
  call $getPlayerMemY
  i32.const 0
  i32.store
))
)

(func $updateVel (param $x f32) (param $y f32)
global.get $playerVelocity
local.get $x
f32.store

global.get $playerVelocity
i32.const 0x04
i32.add
local.get $y
f32.store
)

(func $getVelMemX (result i32)
global.get $playerVelocity
return
)

(func $getVelMemY (result i32)
global.get $playerVelocity
i32.const 0x04
i32.add
return
)

(func $getVelX (result f32)
call $getVelMemX
f32.load
return
)

(func $getVelY (result f32)
call $getVelMemY
f32.load
return
)

(func $getPlayerMemX (result i32)
global.get $playerPos
return
)

(func $getPlayerX (result i32)
call $getPlayerMemX
i32.load
return
)

(func $getPlayerMemY (result i32)
global.get $playerPos
i32.const 0x04
i32.add
return
)

(func $getPlayerY (result i32)
call $getPlayerMemY
i32.load
return
)

(func $updatePos (param $x i32) (param $y i32) 

global.get $playerPos
local.get $x
i32.store

global.get $playerPos
i32.const 0x04
i32.add
local.get $y
i32.store
)

(func $getInput (param $input i32)
;; X param:
;; Right input:
(i32.shr_u (i32.and (local.get $input) (global.get $BUTTON_RIGHT)) (i32.const 5))

;; Left input:
(i32.shr_u (i32.and (local.get $input) (global.get $BUTTON_LEFT)) (i32.const 4))
;; Sub them together:
i32.sub
f32.convert_i32_s
global.get $acceleration
f32.mul

;; X-value:
call $getVelX
f32.add
global.get $friction
f32.mul

;; Y param:
;; Down:
(i32.shr_u (i32.and (local.get $input) (global.get $BUTTON_DOWN)) (i32.const 7))

;; Up:
(i32.shr_u (i32.and (local.get $input) (global.get $BUTTON_UP)) (i32.const 6))
i32.sub
f32.convert_i32_s
global.get $acceleration
f32.mul

call $getVelY
f32.add
global.get $friction
f32.mul

call $updateVel


(i32.add (i32.trunc_f32_s (call $getVelX)) (call $getPlayerX))
(i32.add (i32.trunc_f32_s (call $getVelY)) (call $getPlayerY))
call $updatePos
)
;; endregion

;; region: Shooting

;; Each bullet is 3 bytes: 1 byte for X pos, 1 byte for Y pos, 1 byte for "state" (i.e., alive? Dead? Enemy bullet? Player bullet?)
;; The bullets "array" currently doesn't have a set cap, but the first entry indicates length.
(global $bullets i32 (i32.const 0x5000))

(func $createBullet (param $state i32) (param $x i32) (param $y i32)
  (local $bulletIdx i32)
  ;; Bullets Len += 1
  (i32.add (global.get $bullets) (i32.const 1))
  (i32.store (global.get $bullets))

  (local.set $bulletIdx (i32.mul (global.get $bullets) (i32.const 3)))

)

(func $shoot (param $input i32)
  (local $idx i32)
  (local $bulletLen i32)

  (if (i32.and (local.get $input) (global.get $BUTTON_1))
  (then
    (call $createBullet (i32.const 0) (i32.const 0) (i32.const 0))
  ))

  (i32.store16 (global.get $DRAW_COLORS) (i32.const 4))
  (local.set $bulletLen (i32.load (local.get $bulletLen)))
  (local.set $idx (i32.const 0))
  (block $bullet_loop_end
    (loop $bullet_loop
      (br_if $bullet_loop_end (i32.ge_u (local.get $idx) (local.get $bulletLen)))
      (local.set $idx (i32.add (local.get $idx) (i32.const 1)))
      (br $bullet_loop)
    )
  )
)

;; endregion