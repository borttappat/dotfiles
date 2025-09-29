const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0c0c0c", /* black   */
  [1] = "#E2E2E2", /* red     */
  [2] = "#E4E4E4", /* green   */
  [3] = "#E7E7E7", /* yellow  */
  [4] = "#E8E8E8", /* blue    */
  [5] = "#EBEBEB", /* magenta */
  [6] = "#ECECEC", /* cyan    */
  [7] = "#efefef", /* white   */

  /* 8 bright colors */
  [8]  = "#a7a7a7",  /* black   */
  [9]  = "#E2E2E2",  /* red     */
  [10] = "#E4E4E4", /* green   */
  [11] = "#E7E7E7", /* yellow  */
  [12] = "#E8E8E8", /* blue    */
  [13] = "#EBEBEB", /* magenta */
  [14] = "#ECECEC", /* cyan    */
  [15] = "#efefef", /* white   */

  /* special colors */
  [256] = "#0c0c0c", /* background */
  [257] = "#efefef", /* foreground */
  [258] = "#efefef",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
