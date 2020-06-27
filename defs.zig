const print = @import("std").debug.print;
const std = @import("std");

const IDENT_SIZE = 16;

pub const Elf64Header = packed struct {
    ident: [IDENT_SIZE]u8,
    file_type: FileType,
    machine: Machine,
    version: u32,
    entry: u64,
    phoff: u64,
    shoff: u64,
    flags: u32,
    header_size: u16,
    phent_size: u16,
    phnum: u16,
    shentsize: u16,
    shnum: u16,
    shstrndx: u16,

    const FileType = packed enum(u16) {
        ET_NONE = 0,
        ET_REL = 1,
        ET_EXEC = 2,
        ET_DYN = 3,
        ET_CORE = 4,
        ET_NUM = 5,
        ET_LOOS = 0xfe00,
        ET_HIOS = 0xfeff,
        ET_LOPROC = 0xff00,
        ET_HIPROC = 0xffff,
    };

    const Machine = packed enum(u16) {
        EM_NONE = 0,
        EM_M32 = 1,
        EM_SPARC = 2,
        EM_386 = 3,
        EM_68K = 4,
        EM_88K = 5,
        EM_IAMCU = 6,
        EM_860 = 7,
        EM_MIPS = 8,
        EM_S370 = 9,
        EM_MIPS_RS3_LE = 10,
        EM_PARISC = 15,
        EM_VPP500 = 17,
        EM_SPARC32PLUS = 18,
        EM_960 = 19,
        EM_PPC = 20,
        EM_PPC64 = 21,
        EM_S390 = 22,
        EM_SPU = 23,
        EM_V800 = 36,
        EM_FR20 = 37,
        EM_RH32 = 38,
        EM_RCE = 39,
        EM_ARM = 40,
        EM_FAKE_ALPHA = 41,
        EM_SH = 42,
        EM_SPARCV9 = 43,
        EM_TRICORE = 44,
        EM_ARC = 45,
        EM_H8_300 = 46,
        EM_H8_300H = 47,
        EM_H8S = 48,
        EM_H8_500 = 49,
        EM_IA_64 = 50,
        EM_MIPS_X = 51,
        EM_COLDFIRE = 52,
        EM_68HC12 = 53,
        EM_MMA = 54,
        EM_PCP = 55,
        EM_NCPU = 56,
        EM_NDR1 = 57,
        EM_STARCORE = 58,
        EM_ME16 = 59,
        EM_ST100 = 60,
        EM_TINYJ = 61,
        EM_X86_64 = 62,
        EM_PDSP = 63,
        EM_PDP10 = 64,
        EM_PDP11 = 65,
        EM_FX66 = 66,
        EM_ST9PLUS = 67,
        EM_ST7 = 68,
        EM_68HC16 = 69,
        EM_68HC11 = 70,
        EM_68HC08 = 71,
        EM_68HC05 = 72,
        EM_SVX = 73,
        EM_ST19 = 74,
        EM_VAX = 75,
        EM_CRIS = 76,
        EM_JAVELIN = 77,
        EM_FIREPATH = 78,
        EM_ZSP = 79,
        EM_MMIX = 80,
        EM_HUANY = 81,
        EM_PRISM = 82,
        EM_AVR = 83,
        EM_FR30 = 84,
        EM_D10V = 85,
        EM_D30V = 86,
        EM_V850 = 87,
        EM_M32R = 88,
        EM_MN10300 = 89,
        EM_MN10200 = 90,
        EM_PJ = 91,
        EM_OPENRISC = 92,
        EM_ARC_COMPACT = 93,
        EM_XTENSA = 94,
        EM_VIDEOCORE = 95,
        EM_TMM_GPP = 96,
        EM_NS32K = 97,
        EM_TPC = 98,
        EM_SNP1K = 99,
        EM_ST200 = 100,
        EM_IP2K = 101,
        EM_MAX = 102,
        EM_CR = 103,
        EM_F2MC16 = 104,
        EM_MSP430 = 105,
        EM_BLACKFIN = 106,
        EM_SE_C33 = 107,
        EM_SEP = 108,
        EM_ARCA = 109,
        EM_UNICORE = 110,
        EM_EXCESS = 111,
        EM_DXP = 112,
        EM_ALTERA_NIOS2 = 113,
        EM_CRX = 114,
        EM_XGATE = 115,
        EM_C166 = 116,
        EM_M16C = 117,
        EM_DSPIC30F = 118,
        EM_CE = 119,
        EM_M32C = 120,
        EM_TSK3000 = 131,
        EM_RS08 = 132,
        EM_SHARC = 133,
        EM_ECOG2 = 134,
        EM_SCORE7 = 135,
        EM_DSP24 = 136,
        EM_VIDEOCORE3 = 137,
        EM_LATTICEMICO32 = 138,
        EM_SE_C17 = 139,
        EM_TI_C6000 = 140,
        EM_TI_C2000 = 141,
        EM_TI_C5500 = 142,
        EM_TI_ARP32 = 143,
        EM_TI_PRU = 144,
        EM_MMDSP_PLUS = 160,
        EM_CYPRESS_M8C = 161,
        EM_R32C = 162,
        EM_TRIMEDIA = 163,
        EM_QDSP6 = 164,
        EM_8051 = 165,
        EM_STXP7X = 166,
        EM_NDS32 = 167,
        EM_ECOG1X = 168,
        EM_MAXQ30 = 169,
        EM_XIMO16 = 170,
        EM_MANIK = 171,
        EM_CRAYNV2 = 172,
        EM_RX = 173,
        EM_METAG = 174,
        EM_MCST_ELBRUS = 175,
        EM_ECOG16 = 176,
        EM_CR16 = 177,
        EM_ETPU = 178,
        EM_SLE9X = 179,
        EM_L10M = 180,
        EM_K10M = 181,
        EM_AARCH64 = 183,
        EM_AVR32 = 185,
        EM_STM8 = 186,
        EM_TILE64 = 187,
        EM_TILEPRO = 188,
        EM_MICROBLAZE = 189,
        EM_CUDA = 190,
        EM_TILEGX = 191,
        EM_CLOUDSHIELD = 192,
        EM_COREA_1ST = 193,
        EM_COREA_2ND = 194,
        EM_ARC_COMPACT2 = 195,
        EM_OPEN8 = 196,
        EM_RL78 = 197,
        EM_VIDEOCORE5 = 198,
        EM_78KOR = 199,
        EM_56800EX = 200,
        EM_BA1 = 201,
        EM_BA2 = 202,
        EM_XCORE = 203,
        EM_MCHP_PIC = 204,
        EM_KM32 = 210,
        EM_KMX32 = 211,
        EM_EMX16 = 212,
        EM_EMX8 = 213,
        EM_KVARC = 214,
        EM_CDP = 215,
        EM_COGE = 216,
        EM_COOL = 217,
        EM_NORC = 218,
        EM_CSR_KALIMBA = 219,
        EM_Z80 = 220,
        EM_VISIUM = 221,
        EM_FT32 = 222,
        EM_MOXIE = 223,
        EM_AMDGPU = 224,
        EM_RISCV = 243,
        EM_BPF = 247,
        EM_CSKY = 252,
        EM_NUM = 253,
    };

    pub fn debug_print(self: @This()) void {
        print("magic: {x}\n", .{self.ident});
        print("type: {}\n", .{self.file_type});
        print("machine: {}\n", .{self.machine});
        print("phoff: {} bytes into file\n", .{self.phoff});
        print("shoff: {} bytes into file\n", .{self.shoff});
    }
};

pub const Elf64Phdr = packed struct {
    htype: SegmentType,
    flags: SegmentFlags,
    offset: u64,
    vaddr: u64,
    paddr: u64,
    filesz: u64,
    memsz: u64,
    aligned: u64,

    const SegmentFlags = packed struct {
        x: u1,
        w: u1,
        r: u1,
        _: u29,
    };

    const SegmentType = packed enum(u32) {
        PT_NULL = 0,
        PT_LOAD = 1,
        PT_DYNAMIC = 2,
        PT_INTERP = 3,
        PT_NOTE = 4,
        PT_SHLIB = 5,
        PT_PHDR = 6,
        PT_TLS = 7,
        PT_NUM = 8,
        PT_LOOS = 0x60000000,
        PT_GNU_EH_FRAME = 0x6474e550,
        PT_GNU_STACK = 0x6474e551,
        PT_GNU_RELRO = 0x6474e552,
        PT_GNU_PROPERTY = 0x6474e553,
        PT_PAX_FLAGS = 0x65041580,
        PT_LOSUNW = 0x6ffffffa,
        //       PT_SUNWBSS = 0x6ffffffa,
        PT_SUNWSTACK = 0x6ffffffb,
        PT_HISUNW = 0x6fffffff,
        //        PT_HIOS = 0x6fffffff,
        PT_LOPROC = 0x70000000,
        PT_HIPROC = 0x7fffffff,

        pub fn name(self: SegmentType) []const u8 {
            const result = switch (self) {
                .PT_NULL => "NULL",
                .PT_LOAD => "LOAD",
                .PT_DYNAMIC => "DYNAMIC",
                .PT_INTERP => "INTERP",
                .PT_NOTE => "NOTE",
                .PT_SHLIB => "SHLIB",
                .PT_PHDR => "PHDR",
                .PT_TLS => "TLS",
                .PT_NUM => "NUM",
                .PT_LOOS => "LOOS",
                .PT_GNU_EH_FRAME => "GNU_EH_FRAME",
                .PT_GNU_STACK => "GNU_STACK",
                .PT_GNU_RELRO => "GNU_RELRO",
                .PT_GNU_PROPERTY => "GNU_PROPERTY",
                .PT_PAX_FLAGS => "PAX_FLAGS",
                .PT_LOSUNW => "LOSUNW",
                .PT_SUNWSTACK => "SUNWSTACK",
                .PT_HISUNW => "HISUNW",
                .PT_LOPROC => "LOPROC",
                .PT_HIPROC => "HIPROC",
            };
            return result;
        }
    };

    pub fn debug_print(self: @This()) void {
        print("{:15}", .{self.htype.name()});

        var flagstring: [3]u8 = undefined;
        const disabled = '-';
        flagstring[0] = if (self.flags.r != 0) 'R' else disabled;
        flagstring[1] = if (self.flags.w != 0) 'W' else disabled;
        flagstring[2] = if (self.flags.x != 0) 'X' else disabled;

        print("{}", .{flagstring});
        print("{x:>10}", .{self.offset});
        print("{x:>10}", .{self.vaddr});
        print("{x:>10}", .{self.paddr});
        print("{x:>10}", .{self.memsz});
        print("{x:>10}\n", .{self.filesz});
    }
};

pub const Elf64Shdr = packed struct {
    name: u32,
    stype: SectionType,
    flags: u64,
    addr: u64,
    offset: u64,
    size: u64,
    link: u32,
    info: u32,
    addralign: u64,
    entsize: u64,

    const SectionType = packed enum(u32) {
        SHT_NULL = 0,
        SHT_PROGBITS = 1,
        SHT_SYMTAB = 2,
        SHT_STRTAB = 3,
        SHT_RELA = 4,
        SHT_HASH = 5,
        SHT_DYNAMIC = 6,
        SHT_NOTE = 7,
        SHT_NOBITS = 8,
        SHT_REL = 9,
        SHT_SHLIB = 10,
        SHT_DYNSYM = 11,
        SHT_INIT_ARRAY = 14,
        SHT_FINI_ARRAY = 15,
        SHT_PREINIT_ARRAY = 16,
        SHT_GROUP = 17,
        SHT_SYMTAB_SHNDX = 18,
        SHT_NUM = 19,
        SHT_LOOS = 0x60000000,
        SHT_GNU_ATTRIBUTES = 0x6ffffff5,
        SHT_GNU_HASH = 0x6ffffff6,
        SHT_GNU_LIBLIST = 0x6ffffff7,
        SHT_CHECKSUM = 0x6ffffff8,
        SHT_GNU_verdef = 0x6ffffffd,
        SHT_GNU_verneed = 0x6ffffffe,
        SHT_GNU_versym = 0x6fffffff,

        pub fn name(self: SectionType) []const u8 {
            return switch (self) {
                .SHT_NULL => "NULL",
                .SHT_PROGBITS => "PROGBITS",
                .SHT_SYMTAB => "SYMTAB",
                .SHT_STRTAB => "STRTAB",
                .SHT_RELA => "RELA",
                .SHT_HASH => "HASH",
                .SHT_DYNAMIC => "DYNAMIC",
                .SHT_NOTE => "NOTE",
                .SHT_NOBITS => "NOBITS",
                .SHT_REL => "REL",
                .SHT_SHLIB => "SHLIB",
                .SHT_DYNSYM => "DYNSYM",
                .SHT_INIT_ARRAY => "INIT_ARRAY",
                .SHT_FINI_ARRAY => "FINI_ARRAY",
                .SHT_PREINIT_ARRAY => "PREINIT_ARRAY",
                .SHT_GROUP => "GROUP",
                .SHT_SYMTAB_SHNDX => "SYMTAB_SHNDX",
                .SHT_NUM => "NUM",
                .SHT_LOOS => "LOOS",
                .SHT_GNU_ATTRIBUTES => "GNU_ATTRIBUTES",
                .SHT_GNU_HASH => "GNU_HASH",
                .SHT_GNU_LIBLIST => "GNU_LIBLIST",
                .SHT_CHECKSUM => "CHECKSUM",
                .SHT_GNU_verdef => "GNU_verdef",
                .SHT_GNU_verneed => "GNU_verneed",
                .SHT_GNU_versym => "GNU_versym",
            };
        }
    };

    pub fn debug_print(self: @This(), strings: []u8) void {
        const slice = strings[self.name..];
        const namelen = std.mem.indexOf(u8, slice, "\x00") orelse 0;
        print("{:12}", .{self.stype.name()});
        print("{:20}", .{strings[self.name .. self.name + namelen]});
        print("{x:0^8}\t", .{self.flags});
        print("0x{x}\t", .{self.addr});
        print("0x{x}\t", .{self.offset});
        print("0x{x}\n", .{self.size});
    }
};
