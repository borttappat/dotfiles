const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#1b1e25", /* black   */
  [1] = "#6C869A", /* red     */
  [2] = "#7694AE", /* green   */
  [3] = "#789AB2", /* yellow  */
  [4] = "#7C9FC1", /* blue    */
  [5] = "#819EBB", /* magenta */
  [6] = "#86ABBD", /* cyan    */
  [7] = "#b7c6d7", /* white   */

  /* 8 bright colors */
  [8]  = "#808a96",  /* black   */
  [9]  = "#6C869A",  /* red     */
  [10] = "#7694AE", /* green   */
  [11] = "#789AB2", /* yellow  */
  [12] = "#7C9FC1", /* blue    */
  [13] = "#819EBB", /* magenta */
  [14] = "#86ABBD", /* cyan    */
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
