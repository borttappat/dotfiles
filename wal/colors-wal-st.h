const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0a0a0a", /* black   */
  [1] = "#7E7E81", /* red     */
  [2] = "#8D8D8D", /* green   */
  [3] = "#9E9FA1", /* yellow  */
  [4] = "#AFB0B1", /* blue    */
  [5] = "#BEC0C1", /* magenta */
  [6] = "#CDCECF", /* cyan    */
  [7] = "#e6e7e7", /* white   */

  /* 8 bright colors */
  [8]  = "#a1a1a1",  /* black   */
  [9]  = "#7E7E81",  /* red     */
  [10] = "#8D8D8D", /* green   */
  [11] = "#9E9FA1", /* yellow  */
  [12] = "#AFB0B1", /* blue    */
  [13] = "#BEC0C1", /* magenta */
  [14] = "#CDCECF", /* cyan    */
  [15] = "#e6e7e7", /* white   */

  /* special colors */
  [256] = "#0a0a0a", /* background */
  [257] = "#e6e7e7", /* foreground */
  [258] = "#e6e7e7",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
