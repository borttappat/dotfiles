const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0c0c0c", /* black   */
  [1] = "#6E9B08", /* red     */
  [2] = "#84BB05", /* green   */
  [3] = "#98D902", /* yellow  */
  [4] = "#9DE001", /* blue    */
  [5] = "#929292", /* magenta */
  [6] = "#B3B3B3", /* cyan    */
  [7] = "#dedede", /* white   */

  /* 8 bright colors */
  [8]  = "#9b9b9b",  /* black   */
  [9]  = "#6E9B08",  /* red     */
  [10] = "#84BB05", /* green   */
  [11] = "#98D902", /* yellow  */
  [12] = "#9DE001", /* blue    */
  [13] = "#929292", /* magenta */
  [14] = "#B3B3B3", /* cyan    */
  [15] = "#dedede", /* white   */

  /* special colors */
  [256] = "#0c0c0c", /* background */
  [257] = "#dedede", /* foreground */
  [258] = "#dedede",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
