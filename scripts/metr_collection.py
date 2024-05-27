#============================================================= parsers
def parse_util():
    UTIL_REP_FILE = './tmp/result/utilization.txt'

    slice = 0
    bram  = 0
    dsp   = 0
    
    f = open(UTIL_REP_FILE, 'r')
    s = f.readline()
    while s:
        if (s[0] == '|'):
            s = s.split()

            # Slice used
            if (s[1]== 'Slice' and s[2] == '|'):
                slice += int(s[3])

            # BRAM used
            elif (s[1]== 'RAMB36/FIFO*'):
                bram += int(s[3])
            elif (s[1]== 'RAMB18'):
                bram += int(s[3])/2

            # DSP used
            elif (s[1]== 'DSPs'):
                dsp += int(s[3])

        s = f.readline()
    f.close()
    return (slice, bram, dsp)

def parse_timing():
    TIMING_REP_FILE = './tmp/result/timing.txt'

    WNS = 0
    TNS = 0
    
    f = open(TIMING_REP_FILE, 'r')
    s = f.readline()
    while s:
        if (s == '| Design Timing Summary\n'):
            for i in range(6):
                s = f.readline()
            s = s.split()
            WNS = float(s[0])
            TNS = float(s[1])
            break
        s = f.readline()
    f.close()
    return (WNS, TNS)
#============================================================= parsers : end

#============================================================= calc
def calc_area(slice, bram, dsp):
    return slice + 92.2 * bram + 45.5 * dsp

def calc_fmax(WNS, _):
    PERIOD = 4
    return 1/(PERIOD-WNS)*1000
#============================================================= calc : end

#============================================================= printer
def result_form(utilization, timings, area, fmax):
    separator = '\n========================================================\n'
    table_sep = '\n|--------------|--------------|\n'
    table_head1 = '|' + '|'.join(['Area'  .rjust(14), 
                                  'Fmax, MHz'.rjust(14)]) + '|'

    result  = separator
    result += '\nMetrics:\n\n'
    result += 'WNS:\t'    + format(timings[0], '.3f').rjust(12) + '\n'
    result += 'TNS:\t'    + format(timings[1], '.3f').rjust(12) + '\n'
    result += 'Slices:\t' + format(utilization[0], '.3f').rjust(12) + '\n'
    result += 'BRAMs:\t'  + format(utilization[1], '.3f').rjust(12) + '\n'
    result += 'DSPs:\t'   + format(utilization[2], '.3f').rjust(12) + '\n'

    result += table_sep + table_head1 + table_sep
    temp = (format(area, '.3f').rjust(14),  
            format(fmax, '.3f').rjust(14))
    result += '|'+'|'.join(temp)+'|' + table_sep + separator

    return result
#============================================================= printer : end

#============================================================= main
utilization = parse_util()
timings     = parse_timing()

area = calc_area(*utilization)
fmax = calc_fmax(*timings)

result = result_form(utilization, timings, area, fmax)

print(result)

RESULT_FILE = './tmp/result/result.txt'
f = open(RESULT_FILE, 'w')
f.write(result)
f.close()
#============================================================= main : end
