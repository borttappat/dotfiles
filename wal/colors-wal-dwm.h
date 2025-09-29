static const char norm_fg[] = "#e6e7e7";
static const char norm_bg[] = "#0a0a0a";
static const char norm_border[] = "#a1a1a1";

static const char sel_fg[] = "#e6e7e7";
static const char sel_bg[] = "#8D8D8D";
static const char sel_border[] = "#e6e7e7";

static const char urg_fg[] = "#e6e7e7";
static const char urg_bg[] = "#7E7E81";
static const char urg_border[] = "#7E7E81";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
