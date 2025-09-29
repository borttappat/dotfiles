#!/bin/sh
[ "${TERM:-none}" = "linux" ] && \
    printf '%b' '\e]P00c0c0c
                 \e]P1E2E2E2
                 \e]P2E4E4E4
                 \e]P3E7E7E7
                 \e]P4E8E8E8
                 \e]P5EBEBEB
                 \e]P6ECECEC
                 \e]P7efefef
                 \e]P8a7a7a7
                 \e]P9E2E2E2
                 \e]PAE4E4E4
                 \e]PBE7E7E7
                 \e]PCE8E8E8
                 \e]PDEBEBEB
                 \e]PEECECEC
                 \e]PFefefef
                 \ec'
