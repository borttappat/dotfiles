static const char norm_fg[] = "#dedede";
static const char norm_bg[] = "#0c0c0c";
static const char norm_border[] = "#9b9b9b";

static const char sel_fg[] = "#dedede";
static const char sel_bg[] = "#84BB05";
static const char sel_border[] = "#dedede";

static const char urg_fg[] = "#dedede";
static const char urg_bg[] = "#6E9B08";
static const char urg_border[] = "#6E9B08";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
