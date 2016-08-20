#!/usr/bin/python3
#
# Name: Educational Assembler (easm)
#
# Projekt: EPU
#
# Autor: Markus Schneider
#
# Erstellungsdatum: 30.07.2016
#
# Version: 1.1
#
# Beschreibung: Assemblersprache in Maschinenbefehle umwandeln
#

import argparse
import re
from bitstring import BitArray


labels = dict()
final = list()
jumpcondition = {
    "EQ":         "0b0000",
    "NEQ":        "0b0001",
    "AGB":        "0b0010",
    "ALB":        "0b0011",
    "AGEB":       "0b0100",
    "ALEB":       "0b0101",
    "PARITY":     "0b0110",
    "NOPARITY":   "0b0111",
    "CARRY":      "0b1000",
    "NOCARRY":    "0b1001",
    "OF":         "0b1010",
    "NOOF":       "0b1011",
    "ZERO":       "0b1100",
    "NOTZERO":    "0b1101",
}

opcodebits = [
    "0b00000",  # OPCODE_NOP
    "0b00001",  # OPCODE_ADD
    "0b00010",  # OPCODE_SUB
    "0b00011",  # OPCODE_AND
    "0b00100",  # OPCODE_OR
    "0b00101",  # OPCODE_XOR
    "0b00110",  # OPCODE_NOT
    "0b00111",  # OPCODE_LOAD
    "0b01000",  # OPCODE_MOV
    "0b01001",  # OPCODE_READ
    "0b01010",  # OPCODE_WRITE
    "0b01011",  # OPCODE_SHL
    "0b01100",  # OPCODE_SHR
    "0b01101",  # OPCODE_CMP
    "0b01110",  # OPCODE_JMP
    "0b01111",  # OPCODE_JC
    "0b10000",  # OPCODE_MUL
    "0b10001",  # OPCODE_DIV
    "0b10010",  # OPCODE_MOD
    "0b10011",  # OPCODE_PUSH
    "0b10100",  # OPCODE_POP
    "0b10101",  # OPCODE_CALL
    "0b10110",  # OPCODE_RET
    "0b10111",  # OPCODE_INT
    "0b11000",  # OPCODE_TEST
    # "0b11001",  # UNUSED
    # "0b11010",  # UNUSED
    # "0b11011",  # UNUSED
    # "0b11100",  # UNUSED
    # "0b11101",  # UNUSED
    # "0b11110",  # UNUSED
    # "0b11111",  # UNUSED
]


def I(args, line, parameter, sel, showerrors):
    """sel=0 => LSB; sel=1 => MSB"""
    bitargs = BitArray("0x00")

    try:
        I = args.split(",", 2)[int(parameter) - 1].replace(" ", "")
    except:
        I = args.replace(" ", "")
    if I.startswith("0x"):  # HEXADECIMAL
        # Check length and if neccessary correct it
        if len(I) > 6:
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Immediate can be only 2 Bytes(4 hex characters) long")
            return bitargs
        else:
            # Fill unused space with 0's
            I = I[0:2] + I[2:].rjust(4, '0')

        # Check syntax
        if not re.fullmatch("[0-9a-fA-F]+", I[2:]):
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Immediate is not an hex number")
            return bitargs

        # Set the immediate
        bitargs = BitArray("0x" + I[2+2*sel:4+2*sel])
        return bitargs

    elif I.startswith("0b"):  # BINARY
        # Check length and if neccessary correct it
        if len(I) > 18:
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " + "Immediate" +
                      " can be only 2 Bytes(16 binary characters) long")
            return bitargs
        else:
            # Fill unused space with 0's
            I = I[0:2] + I[2:].rjust(16, '0')

        # Check syntax
        if not re.fullmatch("[01]+", I[2:]):
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Immediate is not a binary number")
                return bitargs

        # Set the immediate
        bitargs = BitArray("0b" + I[2+8*sel:10+8*sel])
        return bitargs
    elif I.startswith("0d"):  # DECIMAL
        # Check syntax
        if not re.fullmatch("[0-9]+", I[2:]):
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Immediate is not a decimal number")
            return bitargs

        # Check length and if neccessary correct it
        if int(I[2:]) > 65535:
            if showerrors:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Immediate can be only 2 Bytes(max: 0d65535) long")
            return bitargs
        else:
            # Fill unused space with 0's
            I = I[0:2] + I[2:].rjust(5, '0')

        # Set the immediate
        tmp = BitArray("0x" + hex(int(I[2:])))
        bitargs = BitArray("0x" + tmp.hex.
                           rjust(4, '0')[0+2*sel:2+2*sel].rjust(2, '0'))
        return bitargs
    else:
        if showerrors:
            print("(line " + str(line).rjust(3, " ") + ") " +
                  "Immediate syntax error")

    return bitargs


def R(args, line, sel):
    bitargs = BitArray(length=0)

    try:
        R = args.split(",", 2)[int(sel)].replace(" ", "")
    except:
        R = args.replace(" ", "")
    if not R.startswith("r"):
        print("(line " + str(line).rjust(3, " ") + ") " +
              "No register given when expected for parameter " +
              str(int(sel+1)) + ". Defaulting to r0")
        return BitArray("0b0000")
    else:
        if int(R[1:]) >= int(16):
            print("(line " + str(line).rjust(3, " ") + ") " +
                  "Register r" + str(R[1:]) + " does not exist. Defaulting " +
                  "to r0")
            return BitArray("0b0000")
        R = "0x" + hex(int(R[1:]))
        bitargs.append(R)

    return bitargs


def RR(args, line):
    bitargs = BitArray(length=0)

    bitargs.append(R(args, line, 0))
    bitargs.append(R(args, line, 1))

    return bitargs


class FORM_VOID:
    def __init__(self, opcode, flag):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)

    def retLength(self):
        return 1

    def retData(self, args, line):
        self.data = BitArray(length=8)
        if self.opcode in opcodebits:
            self.data[0:5] = BitArray(self.opcode)
        else:
            print("[DEBUG] Given opcode is not listed: " + self.opcode)
            return "X\"00\","

        if self.flag:
            self.data[5] = BitArray("0b1")
        else:
            self.data[5] = BitArray("0b0")

        self.data[6:8] = BitArray("0b00")

        return "X\"" + self.data.hex + "\","


class FORM_RI:
    def __init__(self, opcode, flag):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)
        self.count = 0

    def retLength(self):
        return 4

    def retData(self, args, line):
        if self.count == 0:
            self.data = BitArray(length=8)
            if self.opcode in opcodebits:
                self.data[0:5] = BitArray(self.opcode)
            else:
                print("[DEBUG] Given opcode is not listed: " + self.opcode)
                return "X\"00\","

            if self.flag:
                self.data[5] = BitArray("0b1")
            else:
                self.data[5] = BitArray("0b0")

            self.data[6:8] = BitArray("0b11")

            self.count = self.count + 1
        elif self.count == 1:
            self.data = BitArray(length=0)
            self.data.append(R(args, line, 0))
            self.data.append(BitArray("0b0000"))

            self.count = self.count + 1
        elif self.count == 2:
            self.data = BitArray(length=0)
            self.data.append(I(args, line, 2, 0, True))

            self.count = self.count + 1
        elif self.count == 3:
            self.data = BitArray(length=0)
            self.data.append(I(args, line, 2, 1, False))

            self.count = 0

        return "X\"" + self.data.hex + "\","


class FORM_RR:
    def __init__(self, opcode, flag, rD=None, rA=None):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)
        self.count = 0
        self.rD = rD
        self.rA = rA

    def retLength(self):
        return 2

    def retData(self, args, line):
        if self.count == 0:
            self.data = BitArray(length=8)
            if self.opcode in opcodebits:
                self.data[0:5] = BitArray(self.opcode)
            else:
                print("[DEBUG] Given opcode is not listed: " + self.opcode)
                return "X\"00\","

            if self.flag:
                self.data[5] = BitArray("0b1")
            else:
                self.data[5] = BitArray("0b0")

            self.data[6:8] = BitArray("0b01")

            self.count = self.count + 1
        elif self.count == 1:
            self.data = BitArray(length=0)
            if self.rD is None and self.rA is None:
                self.data.append(RR(args, line))

            elif self.rD is None and self.rA is not None:
                self.data.append(R(args, line, 0))
                self.data.append(BitArray(self.rA))

            elif self.rD is not None and self.rA is None:
                self.data.append(BitArray(self.rD))
                self.data.append(R(args, line, 0))

            elif self.rD is not None and self.rA is not None:
                self.data.append(BitArray(self.rD))
                self.data.append(BitArray(self.rA))

            self.count = 0

        return "X\"" + self.data.hex + "\","


class FORM_IRR:
    def __init__(self, opcode, flag, rA=None, rB=None):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)
        self.count = 0
        self.rA = rA
        self.rB = rB
        self.rCount = 0

        if self.rA is None and self.rB is None:
            self.parameter = 3
        elif self.rA is None and self.rB is not None:
            self.parameter = 2
        elif self.rA is not None and self.rB is None:
            self.parameter = 2
        elif self.rA is not None and self.rB is not None:
            self.parameter = 1

    def retLength(self):
        return 4

    def retData(self, args, line):
        if self.count == 0:
            self.data = BitArray(length=8)
            if self.opcode in opcodebits:
                self.data[0:5] = BitArray(self.opcode)
            else:
                print("[DEBUG] Given opcode is not listed: " + self.opcode)
                return "X\"00\","

            if self.flag:
                self.data[5] = BitArray("0b1")
            else:
                self.data[5] = BitArray("0b0")

            self.data[6:8] = BitArray("0b11")

            self.count = self.count + 1
        elif self.count == 1:
            self.data = BitArray(length=0)

            # Get highest 4 bits of immediate
            self.data.append(BitArray("0x" +
                             I(args, line, self.parameter, 0, True).hex[1]))

            if self.rA is None:
                self.data.append(R(args, line, 0))
                self.rCount = 1
            else:
                self.data.append(BitArray(self.rA))
                self.rCount = 0

            self.count = self.count + 1
            # Check argument length
            parametercount = len(list(args.split(",")))
            if not parametercount == self.parameter:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Parameter list not valid based on length\n" +
                      "           " +
                      "Expected " + str(self.parameter) + " parameters, " +
                      str(parametercount) + " were given.")
                return "X\"" + self.data.hex + "\","

        elif self.count == 2:
            self.data = BitArray(length=0)
            if self.rB is None:
                self.data.append(R(args, line, self.rCount))
            else:
                self.data.append(BitArray(self.rB))

            # Get second-highest 4 bits of immediate
            self.data.append(BitArray("0x" +
                             I(args, line, self.parameter, 0, True).hex[0]))

            self.count = self.count + 1
        elif self.count == 3:
            self.data = BitArray(length=0)
            # Get low 8 bits of immediate
            self.data.append(I(args, line, self.parameter, 1, True))

            self.count = 0

        return "X\"" + self.data.hex + "\","


class FORM_RRI:
    def __init__(self, opcode, flag, rD=None, rA=None):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)
        self.count = 0
        self.showerrors = True
        self.rD = rD
        self.rA = rA
        self.rCount = 0

    def retLength(self):
        return 4

    def retData(self, args, line):
        if self.count == 0:
            self.data = BitArray(length=8)
            if self.opcode in opcodebits:
                self.data[0:5] = BitArray(self.opcode)
            else:
                print("[DEBUG] Given opcode is not listed: " + self.opcode)
                return "X\"00\","

            if self.flag:
                self.data[5] = BitArray("0b1")
            else:
                self.data[5] = BitArray("0b0")

            self.data[6:8] = BitArray("0b11")

            self.count = self.count + 1
        elif self.count == 1:
            self.data = BitArray(length=0)
            if self.rD is None and self.rA is None:
                self.data.append(RR(args, line))

                self.rCount = 2
            elif self.rD is None and self.rA is not None:
                self.data.append(R(args, line, 0))
                self.data.append(BitArray(self.rA))

                self.rCount = 1
            elif self.rD is not None and self.rA is None:
                self.data.append(BitArray(self.rD))
                self.data.append(R(args, line, 0))

                self.rCount = 1
            elif self.rD is not None and self.rA is not None:
                self.data.append(BitArray(self.rD))
                self.data.append(BitArray(self.rA))

                self.rCount = 0

            self.count = self.count + 1

            # Check argument length
            parametercount = len(list(args.split(",")))
            if not parametercount == self.rCount + 1:
                self.showerrors = False  # Do not show more errors
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Parameter list not valid based on length\n" +
                      "           " +
                      "Expected " + str(self.rCount + 1) + " parameters, " +
                      str(parametercount) + " were given.")
                return "X\"" + self.data.hex + "\","

        elif self.count == 2:
            self.data = BitArray(length=0)
            self.data.append(I(args, line, 3, 0, self.showerrors))

            self.count = self.count + 1
        elif self.count == 3:
            self.data = BitArray(length=0)
            self.data.append(I(args, line, 3, 1, False))

            self.count = 0

        return "X\"" + self.data.hex + "\","


class FORM_RRR:
    def __init__(self, opcode, flag, rD=None, rA=None):
        self.opcode = str(opcode)
        self.flag = bool(flag)
        self.data = BitArray(length=8)
        self.count = 0
        self.rD = rD
        self.rA = rA
        self.rCount = 0

    def retLength(self):
        return 3

    def retData(self, args, line):
        if self.count == 0:
            self.data = BitArray(length=8)
            if self.opcode in opcodebits:
                self.data[0:5] = BitArray(self.opcode)

            if self.flag:
                self.data[5] = BitArray("0b1")
            else:
                self.data[5] = BitArray("0b0")

            self.data[6:8] = BitArray("0b10")

            self.count = self.count + 1
        elif self.count == 1:
            self.data = BitArray(length=0)
            if self.rD is None and self.rA is None:
                self.data.append(RR(args, line))

                self.rCount = 2
            elif self.rD is None and self.rA is not None:
                self.data.append(R(args, line, 0))
                self.data.append(BitArray(self.rA))

                self.rCount = 1
            elif self.rD is not None and self.rA is None:
                self.data.append(BitArray(self.rD))
                self.data.append(R(args, line, 0))

                self.rCount = 1
            elif self.rD is not None and self.rA is not None:
                self.data.append(BitArray(self.rD))
                self.data.append(BitArray(self.rA))

                self.rCount = 0

            self.count = self.count + 1

            # Check argument length
            parametercount = len(list(args.split(",")))
            if not parametercount == self.rCount + 1:
                print("(line " + str(line).rjust(3, " ") + ") " +
                      "Parameter list not valid based on length\n" +
                      "           " +
                      "Expected " + str(self.rCount + 1) + " parameters, " +
                      str(parametercount) + " were given.")
                return "X\"" + self.data.hex + "\","

        elif self.count == 2:
            self.data = BitArray(length=0)
            self.data.append(R(args, line, self.rCount))
            self.data.append(BitArray("0b0000"))

            self.count = 0

        return "X\"" + self.data.hex + "\","

opcode = {
    # NOP
    "nop":     FORM_VOID("0b00000", False),

    # ADD
    "add":     FORM_RRR("0b00001", False),
    "add.u":   FORM_RRR("0b00001", False),
    "add.s":   FORM_RRR("0b00001", True),
    "addi":    FORM_RRI("0b00001", False),
    "addi.u":  FORM_RRI("0b00001", False),
    "addi.s":  FORM_RRI("0b00001", True),

    # SUB
    "sub":     FORM_RRR("0b00010", False),
    "sub.u":   FORM_RRR("0b00010", False),
    "sub.s":   FORM_RRR("0b00010", True),
    "subi":    FORM_RRI("0b00010", False),
    "subi.u":  FORM_RRI("0b00010", False),
    "subi.s":  FORM_RRI("0b00010", True),

    # AND
    "and":     FORM_RRR("0b00011", False),

    # OR
    "or":      FORM_RRR("0b00100", False),

    # XOR
    "xor":     FORM_RRR("0b00101", False),

    # NOT
    "not":     FORM_RR("0b00110", False),

    # LOAD
    "load":    FORM_RI("0b00111", False),

    # MOV
    "mov":     FORM_RR("0b01000", False),

    # READ
    "read.l":  FORM_RRI("0b01001", False),
    "read.h":  FORM_RRI("0b01001", True),

    # WRITE
    "write.l": FORM_IRR("0b01010", False),
    "write.h": FORM_IRR("0b01010", True),

    # SHL
    "thl":     FORM_RRR("0b01011", False),
    "shl.r":   FORM_RRR("0b01011", False),
    "shl.i":   FORM_RRI("0b01011", False),

    # SHR
    "shr":     FORM_RRR("0b01100", False),
    "shr.r":   FORM_RRR("0b01100", False),
    "shr.i":   FORM_RRI("0b01100", False),

    # CMP
    "cmp":     FORM_RRR("0b01101", False, "0b1110"),
    "cmp.u":   FORM_RRR("0b01101", False, "0b1110"),
    "cmp.s":   FORM_RRR("0b01101", True, "0b1110"),

    # JMP
    "jmp":     FORM_RR("0b01110", False, "0b0000"),
    "jmp.r":   FORM_RR("0b01110", False, "0b0000"),
    "jmp.o":   FORM_RRI("0b01110", False, "0b0000", "0b0000"),
    "jmp.i":   FORM_RRI("0b01110", True, "0b0000", "0b0000"),

    # JE
    "je":      FORM_RRR("0b01111", False, jumpcondition["EQ"], "0b1110"),
    "je.r":    FORM_RRR("0b01111", False, jumpcondition["EQ"], "0b1110"),
    "je.o":    FORM_RRI("0b01111", False, jumpcondition["EQ"], "0b1110"),
    "je.i":    FORM_RRI("0b01111", True, jumpcondition["EQ"], "0b1110"),

    # JNE
    "jne":     FORM_RRR("0b01111", False, jumpcondition["NEQ"], "0b1110"),
    "jne.r":   FORM_RRR("0b01111", False, jumpcondition["NEQ"], "0b1110"),
    "jne.o":   FORM_RRI("0b01111", False, jumpcondition["NEQ"], "0b1110"),
    "jne.i":   FORM_RRI("0b01111", True, jumpcondition["NEQ"], "0b1110"),

    # JG
    "jg":      FORM_RRR("0b01111", False, jumpcondition["AGB"], "0b1110"),
    "jg.r":    FORM_RRR("0b01111", False, jumpcondition["AGB"], "0b1110"),
    "jg.o":    FORM_RRI("0b01111", False, jumpcondition["AGB"], "0b1110"),
    "jg.i":    FORM_RRI("0b01111", True, jumpcondition["AGB"], "0b1110"),

    # JL
    "jl":      FORM_RRR("0b01111", False, jumpcondition["ALB"], "0b1110"),
    "jl.r":    FORM_RRR("0b01111", False, jumpcondition["ALB"], "0b1110"),
    "jl.o":    FORM_RRI("0b01111", False, jumpcondition["ALB"], "0b1110"),
    "jl.i":    FORM_RRI("0b01111", True, jumpcondition["ALB"], "0b1110"),

    # JGE
    "jge":     FORM_RRR("0b01111", False, jumpcondition["AGEB"], "0b1110"),
    "jge.r":   FORM_RRR("0b01111", False, jumpcondition["AGEB"], "0b1110"),
    "jge.o":   FORM_RRI("0b01111", False, jumpcondition["AGEB"], "0b1110"),
    "jge.i":   FORM_RRI("0b01111", True, jumpcondition["AGEB"], "0b1110"),

    # JLE
    "jle":     FORM_RRR("0b01111", False, jumpcondition["ALEB"], "0b1110"),
    "jle.r":   FORM_RRR("0b01111", False, jumpcondition["ALEB"], "0b1110"),
    "jle.o":   FORM_RRI("0b01111", False, jumpcondition["ALEB"], "0b1110"),
    "jle.i":   FORM_RRI("0b01111", True, jumpcondition["ALEB"], "0b1110"),

    # JP
    "jp":      FORM_RRR("0b01111", False, jumpcondition["PARITY"], "0b1110"),
    "jp.r":    FORM_RRR("0b01111", False, jumpcondition["PARITY"], "0b1110"),
    "jp.o":    FORM_RRI("0b01111", False, jumpcondition["PARITY"], "0b1110"),
    "jp.i":    FORM_RRI("0b01111", True, jumpcondition["PARITY"], "0b1110"),

    # JNP
    "jnp":     FORM_RRR("0b01111", False, jumpcondition["NOPARITY"], "0b1110"),
    "jnp.r":   FORM_RRR("0b01111", False, jumpcondition["NOPARITY"], "0b1110"),
    "jnp.o":   FORM_RRI("0b01111", False, jumpcondition["NOPARITY"], "0b1110"),
    "jnp.i":   FORM_RRI("0b01111", True, jumpcondition["NOPARITY"], "0b1110"),

    # JC
    "jc":      FORM_RRR("0b01111", False, jumpcondition["CARRY"], "0b1110"),
    "jc.r":    FORM_RRR("0b01111", False, jumpcondition["CARRY"], "0b1110"),
    "jc.o":    FORM_RRI("0b01111", False, jumpcondition["CARRY"], "0b1110"),
    "jc.i":    FORM_RRI("0b01111", True, jumpcondition["CARRY"], "0b1110"),

    # JNC
    "jnc":     FORM_RRR("0b01111", False, jumpcondition["NOCARRY"], "0b1110"),
    "jnc.r":   FORM_RRR("0b01111", False, jumpcondition["NOCARRY"], "0b1110"),
    "jnc.o":   FORM_RRI("0b01111", False, jumpcondition["NOCARRY"], "0b1110"),
    "jnc.i":   FORM_RRI("0b01111", True, jumpcondition["NOCARRY"], "0b1110"),

    # JO
    "jo":      FORM_RRR("0b01111", False, jumpcondition["OF"], "0b1110"),
    "jo.r":    FORM_RRR("0b01111", False, jumpcondition["OF"], "0b1110"),
    "jo.o":    FORM_RRI("0b01111", False, jumpcondition["OF"], "0b1110"),
    "jo.i":    FORM_RRI("0b01111", True, jumpcondition["OF"], "0b1110"),

    # JNO
    "jno":     FORM_RRR("0b01111", False, jumpcondition["NOOF"], "0b1110"),
    "jno.r":   FORM_RRR("0b01111", False, jumpcondition["NOOF"], "0b1110"),
    "jno.o":   FORM_RRI("0b01111", False, jumpcondition["NOOF"], "0b1110"),
    "jno.i":   FORM_RRI("0b01111", True, jumpcondition["NOOF"], "0b1110"),

    # JZ
    "jz":      FORM_RRR("0b01111", False, jumpcondition["ZERO"], "0b1110"),
    "jz.r":    FORM_RRR("0b01111", False, jumpcondition["ZERO"], "0b1110"),
    "jz.o":    FORM_RRI("0b01111", False, jumpcondition["ZERO"], "0b1110"),
    "jz.i":    FORM_RRI("0b01111", True, jumpcondition["ZERO"], "0b1110"),

    # JNZ
    "jnz":     FORM_RRR("0b01111", False, jumpcondition["NOTZERO"], "0b1110"),
    "jnz.r":   FORM_RRR("0b01111", False, jumpcondition["NOTZERO"], "0b1110"),
    "jnz.o":   FORM_RRI("0b01111", False, jumpcondition["NOTZERO"], "0b1110"),
    "jnz.i":   FORM_RRI("0b01111", True, jumpcondition["NOTZERO"], "0b1110"),

    # MUL
    "mul":     FORM_RRR("0b10000", False),

    # PUSH
    "push":    FORM_RR("0b10011", False, "0b0000"),

    # POP
    "pop":     FORM_RR("0b10100", False, None, "0b0000"),

    # CALL
    "call":    FORM_RR("0b10001", False, "0b0000"),
    "call.r":  FORM_RR("0b10001", False, "0b0000"),
    "call.o":  FORM_RRI("0b10001", False, "0b0000", "0b0000"),
    "call.i":  FORM_RRI("0b10001", True, "0b0000", "0b0000"),

    # RET
    "ret":     FORM_VOID("0b10010", False),

    # INT
    "int":     FORM_RRI("0b10111", False, "0b1111", "0b0000"),

    # TEST
    "test":    FORM_RR("0b11000", False, "0b1110"),
}


def main():
    # Command line argument setup
    parser = argparse.ArgumentParser(description="Assemble .easm files into\
                                                  .bin binaries for use with\
                                                  the EPU")
    parser.add_argument("infile", metavar="<asm file>",
                        help="Assembler file")
    parser.add_argument("-o", "--out", metavar="<bin file>",
                        help="Output binary file")
    parser.add_argument("-t", "--template", metavar="<template file>",
                        help="Include predefined template")
    parser.add_argument("-s", "--size", metavar="N",
                        help="Size of RAM in N bytes")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Show section addresses")

    args = parser.parse_args()
    afile = str(args.infile)
    ofile = args.out
    if args.size is not None:
        size = int(args.size)
    else:
        size = None
    if args.template is not None:
        tfile = str(args.template)
    else:
        tfile = None

    content = list()
    # Read the input file
    with open(afile) as f:
        for line in f:
            content.append(line.strip())

    # Remove tabs from input file
    for item in range(len(content)):
        content[item] = " ".join(content[item].split())

    # Copy content now for line numbers
    global lines
    lines = content

    # Read the template if given
    if tfile is not None:
        with open(tfile) as f:
            count = 0
            for line in f:
                content.insert(count, line.strip())
                count = count + 1

        # Remove tabs from template file
        for item in range(len(content)):
            content[item] = " ".join(content[item].split())

    # Remove empty lines
    content = list(filter(None, content))

    # Remove line comments
    content = [s for s in content if not s.strip().startswith("#")]

    # Check mnemonic and remove unknown elements
    tmp = list()
    for item in range(len(content)):
        if ":" not in content[item]:
            if content[item].split(" ", 1)[0] not in opcode:
                print("(line " + str(lines.index(content[item]) + 1)
                      .rjust(3, " ") + ") Unknown instruction")
            else:
                tmp.append(content[item])
        else:
            tmp.append(content[item])
    content = tmp

    # Get labels and remove them from the content list
    tmp = list()
    count = 0
    for item in range(len(content)):
        if ":" in content[item]:
            if content[item].split(":", 1)[0] not in labels:
                labels.update({content[item].split(":", 1)[0]: count})
            else:
                print("(line " + str(lines.index(content[item]) + 1)
                      .rjust(3, " ") + ") Label \"" + content[item] + "\"" +
                      "already exists")
            continue
        tmp.append(content[item])
        count = count + opcode[content[item].split(" ", 1)[0]].retLength()
    content = tmp

    # Translate labels to addresses for line numbers
    for item in range(len(lines)):
        if "$" in lines[item]:
            l = lines[item].split("$", 2)[1:]
            for label in l:
                # Remove comment at the end of the line
                label = label.split("#", 1)[0]
                if label in labels:
                    lines[item] = lines[item].replace(
                        "$" + str(label), str(hex(labels[label])))

    # Check ram size
    ramsize = 0
    for item in content:
        if not (item.startswith(".") or item.startswith("#")):
            ramsize += opcode[item.split(" ", 1)[0]].retLength()
    if size is None:
        size = ramsize
    if ramsize > size:
        print("Ram too small for instructions")
        print("Needed RAM size: " + str(ramsize))
        print(" Given RAM size: " + str(size))
        return

    # Setup final list
    final = ["X\"00\","] * size

    # Translate directives and remove them from the content list
    tmp = list()
    for item in content:
        if item.startswith(".data"):
            index = int(item.split(" ", 2)[1], 16)
            if index >= size:
                print("RAM too small for .data entry: " + str(item))
                return
            final[index] = "X\"" + str(item.split(" ", 2)[2][2:]) + "\"",
            + " -- " + str(item)
            continue
        tmp.append(item)
    content = tmp

    # Translate assembler commands
    count = 0
    for item in range(len(content)):
        if ":" in content[item]:
            continue

        # Translate labels to addresses
        if "$" in content[item]:
            l = content[item].split("$", 2)[1:]
            for label in l:
                label = label.split("#", 1)[0]
                if label in labels:
                    content[item] = content[item].replace("$" + str(label),
                                                          hex(labels[label]))

        # Translate commands based on mnemonic
        length = opcode[content[item].split(" ", 1)[0]].retLength()
        offset = 0
        while length != 0:
            try:
                # Try space split(works for all instructions with parameters)
                final[count] = opcode[content[item].split(" ", 1)[0]]\
                                     .retData(content[item].split(" ", 1)[1]
                                              .split("#", 1)[0],
                                              lines.index(content[item]) + 1)
            except:
                # Otherwise don't do the space split
                final[count] = opcode[content[item].split(" ", 1)[0]]\
                                     .retData(content[item].split("#", 1)[0],
                                              lines.index(content[item]) + 1)

            if length == opcode[content[item].split(" ", 1)[0]].retLength():
                final[count] += " -- 0x" + str(hex(count))[2:].rjust(4, '0') +\
                               ": " + str(content[item])

            length = length - 1
            offset = offset + 1
            count = count + 1

    # Remove comma from last line
    final[-1] = final[-1].replace(",", " ")

    # Print debug information
    if args.verbose:
        print("Section addresses".center(33, "="))
        for item in labels:
            if item.startswith("_"):
                print("Section: {0:8} Address: 0x{1}"
                      .format(str(item), str(labels[item]).rjust(4, '0')))

    if ofile is None:
        print("\n")
        print("\n".join(final))
    else:
        with open(ofile, "w") as f:
            for item in final:
                f.write("%s\n" % item)

    return

if __name__ == "__main__":
    main()
