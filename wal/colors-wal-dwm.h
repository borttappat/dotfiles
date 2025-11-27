static const char norm_fg[] = "#b7c6d7";
static const char norm_bg[] = "#101116";
static const char norm_border[] = "#808a96";

static const char sel_fg[] = "#b7c6d7";
static const char sel_bg[] = "#6E899E";
static const char sel_border[] = "#b7c6d7";

static const char urg_fg[] = "#b7c6d7";
static const char urg_bg[] = "#637B92";
static const char urg_border[] = "#637B92";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
