const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#100c12", /* black   */
  [1] = "#6A4AA5", /* red     */
  [2] = "#8A7497", /* green   */
  [3] = "#8A5FE2", /* yellow  */
  [4] = "#8F63E7", /* blue    */
  [5] = "#7897AE", /* magenta */
  [6] = "#67CC82", /* cyan    */
  [7] = "#d2cddd", /* white   */

  /* 8 bright colors */
  [8]  = "#938f9a",  /* black   */
  [9]  = "#6A4AA5",  /* red     */
  [10] = "#8A7497", /* green   */
  [11] = "#8A5FE2", /* yellow  */
  [12] = "#8F63E7", /* blue    */
  [13] = "#7897AE", /* magenta */
  [14] = "#67CC82", /* cyan    */
  [15] = "#d2cddd", /* white   */

  /* special colors */
  [256] = "#100c12", /* background */
  [257] = "#d2cddd", /* foreground */
  [258] = "#d2cddd",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
