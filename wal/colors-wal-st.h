const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#01090C", /* black   */
  [1] = "#289805", /* red     */
  [2] = "#4EA70B", /* green   */
  [3] = "#62D107", /* yellow  */
  [4] = "#78FA01", /* blue    */
  [5] = "#9FA109", /* magenta */
  [6] = "#8CFE00", /* cyan    */
  [7] = "#cbf478", /* white   */

  /* 8 bright colors */
  [8]  = "#8eaa54",  /* black   */
  [9]  = "#289805",  /* red     */
  [10] = "#4EA70B", /* green   */
  [11] = "#62D107", /* yellow  */
  [12] = "#78FA01", /* blue    */
  [13] = "#9FA109", /* magenta */
  [14] = "#8CFE00", /* cyan    */
  [15] = "#cbf478", /* white   */

  /* special colors */
  [256] = "#01090C", /* background */
  [257] = "#cbf478", /* foreground */
  [258] = "#cbf478",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
