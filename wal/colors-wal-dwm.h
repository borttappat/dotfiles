static const char norm_fg[] = "#a5c0d3";
static const char norm_bg[] = "#0b0c15";
static const char norm_border[] = "#738693";

static const char sel_fg[] = "#a5c0d3";
static const char sel_bg[] = "#393A82";
static const char sel_border[] = "#a5c0d3";

static const char urg_fg[] = "#a5c0d3";
static const char urg_bg[] = "#4A4D79";
static const char urg_border[] = "#4A4D79";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
