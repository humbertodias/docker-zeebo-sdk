#include "AEEModGen.h"
#include "AEEAppGen.h"
#include "AEEDisp.h"
#include "hello.bid"

typedef struct {
    AEEApplet a;
} HelloApp;

static const AECHAR kMessage[] = {
    'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd', ' ',
    'f', 'r', 'o', 'm', ' ', 'Z', 'e', 'e', 'b', 'o', 0
};

static void Hello_Draw(HelloApp *app)
{
    IDisplay *display = app->a.m_pIDisplay;
    AEERect screen;

    IDISPLAY_FillRect(display, NULL, RGB_BLACK);
    IDISPLAY_SetColor(display, CLR_USER_TEXT, RGB_WHITE);
    /* O zeebx só centraliza quando o retângulo da tela vai junto. */
    IDISPLAY_GetClipRect(display, &screen);
    IDISPLAY_DrawText(display,
                      AEE_FONT_BOLD,
                      kMessage,
                      -1,
                      0,
                      0,
                      &screen,
                      IDF_ALIGN_CENTER | IDF_ALIGN_MIDDLE);
    IDISPLAY_Update(display);
}

/* O zeebx encerra o applet quando não há timer nem entrada pendente. */
static void Hello_Tick(void *user)
{
    HelloApp *app = (HelloApp *)user;

    Hello_Draw(app);
    ISHELL_SetTimer(app->a.m_pIShell, 1000, Hello_Tick, app);
}

static boolean Hello_HandleEvent(HelloApp *app, AEEEvent evt, uint16 wParam, uint32 dwParam)
{
    (void)wParam;
    (void)dwParam;

    switch (evt) {
    case EVT_APP_START:
    case EVT_APP_RESUME:
        Hello_Tick(app);
        return TRUE;
    case EVT_APP_STOP:
        ISHELL_CancelTimer(app->a.m_pIShell, Hello_Tick, app);
        return TRUE;
    case EVT_APP_NO_SLEEP:
        return TRUE;
    default:
        return FALSE;
    }
}

static void Hello_Free(IApplet *applet)
{
    (void)applet;
}

int AEEClsCreateInstance(AEECLSID clsId, IShell *shell, IModule *mod, void **ppObj)
{
    if (clsId != AEECLSID_HELLOWORLD)
        return EFAILED;

    if (!AEEApplet_New(sizeof(HelloApp), clsId, shell, mod, (IApplet **)ppObj,
                       (AEEHANDLER)Hello_HandleEvent, (PFNFREEAPPDATA)Hello_Free))
        return EFAILED;

    return AEE_SUCCESS;
}
