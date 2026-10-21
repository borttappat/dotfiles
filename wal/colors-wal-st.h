const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#101116", /* black   */
  [1] = "#637B92", /* red     */
  [2] = "#6E899E", /* green   */
  [3] = "#7694AC", /* yellow  */
  [4] = "#7E9FC1", /* blue    */
  [5] = "#819EBC", /* magenta */
  [6] = "#85A9BE", /* cyan    */
  [7] = "#b7c6d7", /* white   */

  /* 8 bright colors */
  [8]  = "#808a96",  /* black   */
  [9]  = "#637B92",  /* red     */
  [10] = "#6E899E", /* green   */
  [11] = "#7694AC", /* yellow  */
  [12] = "#7E9FC1", /* blue    */
  [13] = "#819EBC", /* magenta */
  [14] = "#85A9BE", /* cyan    */
  [15] = "#b7c6d7", /* white   */

  /* special colors */
  [256] = "#101116", /* background */
  [257] = "#b7c6d7", /* foreground */
  [258] = "#b7c6d7",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
