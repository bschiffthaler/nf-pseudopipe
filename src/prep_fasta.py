from sys import argv
import os

class FASTAFile(object):
    """docstring for FASTAFile"""

    def __init__(self, path):
        super(FASTAFile, self).__init__()
        self.path = path
        self.linebuffer = ""
        self.eof = False

        self.__open__()

    def __open__(self):
        self.handle = open(self.path, "r")

    def __iter__(self):
        return self

    def __next__(self):
        if self.eof:
            raise StopIteration

        cur_id = self.handle.readline().strip() if not self.linebuffer else self.linebuffer
        cur_id = cur_id.replace(">", "").split()[0]
        cur_seq = ""

        while True:
            line = self.handle.readline()
            # Eof
            if not line:
                self.eof = True
                break
            # Next record
            if line.startswith(">"):
                self.linebuffer = line.strip()
                break
            line = line.strip()
            # Empty line
            if not line:
                continue
            cur_seq += line

        return (cur_id, cur_seq)


if __name__ == "__main__":

    fasta = FASTAFile(argv[1])

    os.makedirs("split_out")

    for name, seq in fasta:
        print(f"Reading {name}")
        ostr = f"split_out/{name}.fa"
        with open(ostr, "w") as out:
            out.write(">")
            out.write(name)
            out.write("\n")
            out.write(seq)
            out.write("\n")
