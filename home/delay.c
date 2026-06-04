#include "../constants.h"
#include "delay.h"
#include "vblank.h"
#if defined(__EMSCRIPTEN__)
#include <emscripten.h>

#define GBC_FRAME_MS ((1000.0 * 70224.0) / 4194304.0)

static double sNextBrowserFrameMs;
#endif

void DelayFrame(void){
    //  Wait for one frame
    VBlank();
    gb.display.WY = gb.gb_reg.WY;
    gb.display.window_clear = 0;
    gb_finish_frame();
#if defined(__EMSCRIPTEN__)
    double now = emscripten_get_now();

    if (sNextBrowserFrameMs <= 0.0 || now > sNextBrowserFrameMs + (GBC_FRAME_MS * 4.0)) {
        sNextBrowserFrameMs = now + GBC_FRAME_MS;
    }

    int sleepMs = (int)(sNextBrowserFrameMs - now + 0.5);
    if (sleepMs > 0) {
        emscripten_sleep(sleepMs);
    }

    sNextBrowserFrameMs += GBC_FRAME_MS;
#endif
}

void DelayFrames(uint8_t count) {
    do {
        //  Wait for one frame
        DelayFrame();
    } while(--count > 0);
}
