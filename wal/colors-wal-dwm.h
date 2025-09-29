static const char norm_fg[] = "#efefef";
static const char norm_bg[] = "#0c0c0c";
static const char norm_border[] = "#a7a7a7";

static const char sel_fg[] = "#efefef";
static const char sel_bg[] = "#E4E4E4";
static const char sel_border[] = "#efefef";

static const char urg_fg[] = "#efefef";
static const char urg_bg[] = "#E2E2E2";
static const char urg_border[] = "#E2E2E2";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
