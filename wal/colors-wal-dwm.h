static const char norm_fg[] = "#e5e8ed";
static const char norm_bg[] = "#0C0F14";
static const char norm_border[] = "#a0a2a5";

static const char sel_fg[] = "#e5e8ed";
static const char sel_bg[] = "#9FADC0";
static const char sel_border[] = "#e5e8ed";

static const char urg_fg[] = "#e5e8ed";
static const char urg_bg[] = "#929FB0";
static const char urg_border[] = "#929FB0";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
