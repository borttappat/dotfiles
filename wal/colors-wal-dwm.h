static const char norm_fg[] = "#efe3e1";
static const char norm_bg[] = "#040404";
static const char norm_border[] = "#a79e9d";

static const char sel_fg[] = "#efe3e1";
static const char sel_bg[] = "#E74E74";
static const char sel_border[] = "#efe3e1";

static const char urg_fg[] = "#efe3e1";
static const char urg_bg[] = "#E62759";
static const char urg_border[] = "#E62759";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
