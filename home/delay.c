#include "../constants.h"
#include "delay.h"
#include "vblank.h"
#if defined(__EMSCRIPTEN__)
#include <emscripten.h>
#endif

void DelayFrame(void){
    //  Wait for one frame
    VBlank();
    gb.display.WY = gb.gb_reg.WY;
    gb.display.window_clear = 0;
    gb_finish_frame();
#if defined(__EMSCRIPTEN__)
    emscripten_sleep(16);
#endif
}

void DelayFrames(uint8_t count) {
    do {
        //  Wait for one frame
        DelayFrame();
    } while(--count > 0);
}
