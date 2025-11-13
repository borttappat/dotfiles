static const char norm_fg[] = "#d2d2d2";
static const char norm_bg[] = "#0d0d0d";
static const char norm_border[] = "#939393";

static const char sel_fg[] = "#d2d2d2";
static const char sel_bg[] = "#676767";
static const char sel_border[] = "#d2d2d2";

static const char urg_fg[] = "#d2d2d2";
static const char urg_bg[] = "#585858";
static const char urg_border[] = "#585858";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
