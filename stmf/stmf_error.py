#!/usr/bin/python

import sys

flag = {
    'failure': 0x1000000000000000,
    'target_failure': 0x2000000000000000,
    'lu_failure': 0x3000000000000000,
    'retry': 0x0080000000000000,
}

reason = {
    'busy': flag['failure'] | flag['retry'],
    'not_found': flag['failure'] | 1 << 32,
    'invalid_arg': flag['failure'] | 2 << 32,
    'lun_taken': flag['failure'] | 3 << 32,
    'aborted': flag['failure'] | 5 << 32,
    'abort_success': flag['failure'] | 6 << 32,
    'alloc_failure': flag['failure'] | 7 << 32,
    'already': flag['failure'] | 8 << 32,
    'timeout': flag['failure'] | 9 << 32,
    'not_supported': flag['failure'] | 10 << 32,
    'bad_state': flag['failure'] | 11 << 32
}

def flags(value):
    return [ f for f, fv in flag.iteritems() if (value & fv) == fv ]

def reasons(value):
    return [ r for r, rv in reason.iteritems() if value == rv ]

if __name__ == '__main__':
    val = int(sys.argv[1])
    print flags(val)
    print reasons(val)
