# playmiss-2600
A coding challenge to combine player and missile graphics

Here's the story.

It's December 2022, OpenAI has opened a beta of ChatGPT to the public.
One of the fun activities is to ask ChatGPT to generate code. In many
cases, it does, and sometimes the code even works.

Playing along, I asked it to generate a Hello World for Atari 2600.
It outpout something that mostly looked like 6502 assembly for 2600,
but that was hilariously meaningless. Literally like someone copy-pasting
snippets of code without understanding what they do.

I [posted](https://www.linkedin.com/posts/jbqueru_atari2600-activity-7009700359426252800-dYTR/) about my experience on LinkedIn along with some code snippets,
and a coworker noticed an ominous comment that ChatGPT had generated:
"Set the player/missile graphics pointers".

The 2600 has player/missile size (NUSIZn), player/missile color (COLUPn),
but there's no such think as missile graphics or player/missile graphics.
Also, that exact sentence doesn't show up on Google, which does suggest
that ChatGPT really made it up.

The challenge was on, I made it a mission to create a Hello World where
that specific comment would make sense. This is the result.

The basic idea here is to use the missile as a 9th pixel to the right
of the player graphics, to use those 9 pixels as the support for a
scroller, and to have pointers to the relevant graphics.

There you have it, a piece of code created specifically to be able
to use an improbable AI-generated comment.

For posterity, here's what ChatGPT had generated. We can't let such a
monument of nonsensical code go to waste.

```
; Set up the screen
ldx #$00
stx WSYNC
stx VSYNC
stx VBLANK
stx TIM64T

; Set the color registers
ldx #$0f
stx COLUBK
stx COLUPF

; Set the playfield registers
ldx #$3f
stx PF0
ldx #$00
stx PF1
stx PF2

; Set the player/missile registers
ldx #$00
stx ENAM0
stx ENABL
stx RESMP0
stx RESBL

; Set the audio registers
ldx #$80
stx AUDC0
ldx #$ff
stx AUDC1
ldx #$00
stx AUDC2
ldx #$00
stx AUDC3
ldx #$00
stx AUDC4
ldx #$00
stx AUDC5

; Set the starting address for the display list
ldx #$00
ldy #$20
sty WSYNC
sty VSYNC
sty VBLANK
sty TIM64T

; Set up the display list
.displayList
    .byte $70, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
    .byte $71, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
.endDisplayList

; Set up the player/missile graphics data
.playerData
    .byte $00, $00, $00, $00, $00, $00, $00, $00
.endPlayerData

; Set up the playfield graphics data
.playfieldData
    .byte "Hello, World!"
.endPlayfieldData

; Set the display list pointer
ldx #displayList>>8
ldy #displayList
sta WSYNC
sty WSYNC

; Set the player/missile graphics pointers
ldx #playerData>>8
ldy #playerData
sta RESMP0
sty RESMP0

; Set the playfield graphics pointers
ldx #playfieldData>>8
ldy #playfieldData
sta PF0
sty PF0

; Set the audio frequency registers
ldx #$01
stx AUDF0
ldx #$01
stx AUDF1
ldx #$01
stx AUDF2
ldx #$01
stx AUDF3

; Enable audio
ldx #$08
stx AUDCTL

; Main loop
.loop
    jmp loop
```
