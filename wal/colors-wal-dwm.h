static const char norm_fg[] = "#cbf478";
static const char norm_bg[] = "#01090C";
static const char norm_border[] = "#8eaa54";

static const char sel_fg[] = "#cbf478";
static const char sel_bg[] = "#4EA70B";
static const char sel_border[] = "#cbf478";

static const char urg_fg[] = "#cbf478";
static const char urg_bg[] = "#289805";
static const char urg_border[] = "#289805";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
