const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#040404", /* black   */
  [1] = "#E62759", /* red     */
  [2] = "#E74E74", /* green   */
  [3] = "#7F827D", /* yellow  */
  [4] = "#EC6E8C", /* blue    */
  [5] = "#EE9DAC", /* magenta */
  [6] = "#CDB0B2", /* cyan    */
  [7] = "#efe3e1", /* white   */

  /* 8 bright colors */
  [8]  = "#a79e9d",  /* black   */
  [9]  = "#E62759",  /* red     */
  [10] = "#E74E74", /* green   */
  [11] = "#7F827D", /* yellow  */
  [12] = "#EC6E8C", /* blue    */
  [13] = "#EE9DAC", /* magenta */
  [14] = "#CDB0B2", /* cyan    */
  [15] = "#efe3e1", /* white   */

  /* special colors */
  [256] = "#040404", /* background */
  [257] = "#efe3e1", /* foreground */
  [258] = "#efe3e1",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
