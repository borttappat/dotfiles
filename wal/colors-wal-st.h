const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0b0c15", /* black   */
  [1] = "#4A4D79", /* red     */
  [2] = "#393A82", /* green   */
  [3] = "#505583", /* yellow  */
  [4] = "#475095", /* blue    */
  [5] = "#696D9A", /* magenta */
  [6] = "#9A61B3", /* cyan    */
  [7] = "#a5c0d3", /* white   */

  /* 8 bright colors */
  [8]  = "#738693",  /* black   */
  [9]  = "#4A4D79",  /* red     */
  [10] = "#393A82", /* green   */
  [11] = "#505583", /* yellow  */
  [12] = "#475095", /* blue    */
  [13] = "#696D9A", /* magenta */
  [14] = "#9A61B3", /* cyan    */
  [15] = "#a5c0d3", /* white   */

  /* special colors */
  [256] = "#0b0c15", /* background */
  [257] = "#a5c0d3", /* foreground */
  [258] = "#a5c0d3",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
