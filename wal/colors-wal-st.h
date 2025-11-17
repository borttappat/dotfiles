const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#1b1e25", /* black   */
  [1] = "#6E8A9F", /* red     */
  [2] = "#7695AE", /* green   */
  [3] = "#7D9FC1", /* yellow  */
  [4] = "#809FBE", /* blue    */
  [5] = "#86AABE", /* magenta */
  [6] = "#92C1BF", /* cyan    */
  [7] = "#b7c6d7", /* white   */

  /* 8 bright colors */
  [8]  = "#808a96",  /* black   */
  [9]  = "#6E8A9F",  /* red     */
  [10] = "#7695AE", /* green   */
  [11] = "#7D9FC1", /* yellow  */
  [12] = "#809FBE", /* blue    */
  [13] = "#86AABE", /* magenta */
  [14] = "#92C1BF", /* cyan    */
  [15] = "#b7c6d7", /* white   */

  /* special colors */
  [256] = "#1b1e25", /* background */
  [257] = "#b7c6d7", /* foreground */
  [258] = "#b7c6d7",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
