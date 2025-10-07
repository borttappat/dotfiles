#!/bin/sh
[ "${TERM:-none}" = "linux" ] && \
    printf '%b' '\e]P0090909
                 \e]P1777777
                 \e]P2888888
                 \e]P3989898
                 \e]P4A8A8A8
                 \e]P5B7B7B7
                 \e]P6C6C6C6
                 \e]P7e2e2e2
                 \e]P89e9e9e
                 \e]P9777777
                 \e]PA888888
                 \e]PB989898
                 \e]PCA8A8A8
                 \e]PDB7B7B7
                 \e]PEC6C6C6
                 \e]PFe2e2e2
                 \ec'
