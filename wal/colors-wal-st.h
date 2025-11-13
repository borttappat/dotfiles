const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0d0d0d", /* black   */
  [1] = "#585858", /* red     */
  [2] = "#676767", /* green   */
  [3] = "#787878", /* yellow  */
  [4] = "#878787", /* blue    */
  [5] = "#989898", /* magenta */
  [6] = "#A7A7A7", /* cyan    */
  [7] = "#d2d2d2", /* white   */

  /* 8 bright colors */
  [8]  = "#939393",  /* black   */
  [9]  = "#585858",  /* red     */
  [10] = "#676767", /* green   */
  [11] = "#787878", /* yellow  */
  [12] = "#878787", /* blue    */
  [13] = "#989898", /* magenta */
  [14] = "#A7A7A7", /* cyan    */
  [15] = "#d2d2d2", /* white   */

  /* special colors */
  [256] = "#0d0d0d", /* background */
  [257] = "#d2d2d2", /* foreground */
  [258] = "#d2d2d2",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
