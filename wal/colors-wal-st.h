const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0C0F14", /* black   */
  [1] = "#929FB0", /* red     */
  [2] = "#9FADC0", /* green   */
  [3] = "#B0B9CA", /* yellow  */
  [4] = "#BBC3D3", /* blue    */
  [5] = "#C6CDDB", /* magenta */
  [6] = "#D2D8E6", /* cyan    */
  [7] = "#e5e8ed", /* white   */

  /* 8 bright colors */
  [8]  = "#a0a2a5",  /* black   */
  [9]  = "#929FB0",  /* red     */
  [10] = "#9FADC0", /* green   */
  [11] = "#B0B9CA", /* yellow  */
  [12] = "#BBC3D3", /* blue    */
  [13] = "#C6CDDB", /* magenta */
  [14] = "#D2D8E6", /* cyan    */
  [15] = "#e5e8ed", /* white   */

  /* special colors */
  [256] = "#0C0F14", /* background */
  [257] = "#e5e8ed", /* foreground */
  [258] = "#e5e8ed",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
