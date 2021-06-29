from sys import argv
from collections import defaultdict
import os

if __name__ == "__main__":

    d = defaultdict(list)

    with open(argv[1], "r") as in_f:
        for line in in_f:
            fields = line.strip().split()
            # skip comments
            if line.startswith("#"):
                continue
            # skip non exon lines
            t = fields[2]
            if t != "exon":
                continue
            c = fields[0].replace(">", "").split()[0]
            a = fields[3]
            o = fields[4]
            if int(a) > int(o):
                tmp = a
                a = o
                o = tmp
            d[c].append((a, o))

    os.makedirs("exlocs")

    for key in d:
        with open(f"exlocs/{key}_exLocs", "w") as out:
            for loc in d[key]:
                out.write(f"0\t0\t{loc[0]}\t{loc[1]}\t0\t0\t0\t0\t0\n")
