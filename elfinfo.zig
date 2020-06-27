const print = @import("std").debug.print;
const std = @import("std");
const File = std.fs.File;
const os = std.os;
const process = std.process;
const cwd = std.fs.cwd;

const elf = @import("defs.zig");
const Elf64Header = elf.Elf64Header;
const Elf64Phdr = elf.Elf64Phdr;
const Elf64Shdr = elf.Elf64Shdr;


pub fn ehdr_print(self: Elf64Header) void {
    print("========== ELF header\n", .{});
    print("  magic: {x}\n", .{self.ident});
    print("   type: {}\n", .{self.file_type});
    print("machine: {}\n", .{self.machine});
    print("  phoff: {} bytes into file\n", .{self.phoff});
    print("  shoff: {} bytes into file\n", .{self.shoff});
}


pub fn phdr_print(self: Elf64Phdr) void {
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

pub fn shdr_print(self: Elf64Shdr, strings: []u8) void {
    const slice = strings[self.name..];
    const namelen = std.mem.indexOf(u8, slice, "\x00") orelse 0;
    print("{:12}", .{self.stype.name()});
    print("{:20}", .{strings[self.name .. self.name + namelen]});
    print("{x:>10} ", .{self.flags});
    print("{x:>10} ", .{self.addr});
    print("{x:>10} ", .{self.offset});
    print("{x:>10}\n", .{self.size});
}

pub fn parse_elf(file: File) !void {
    var header: Elf64Header = undefined;
    var nread = try file.pread(std.mem.asBytes(&header), 0);
    ehdr_print(header);

    try parse_program_headers(file, &header);
    try parse_program_sections(file, &header);
}

pub fn parse_program_headers(file: File, header: *Elf64Header) !void {
    try file.seekTo(header.phoff);
    var i: u32 = 0;
    print("========== PHDRs\n", .{});
    print("Type           Flags  Offset     Vaddr     Paddr  Mem size File size\n", .{});
    while (i < header.phnum) : (i += 1) {
        var phdr: Elf64Phdr = undefined;
        const rsize = try file.readAll(std.mem.asBytes(&phdr));
        phdr_print(phdr);
    }
}

pub fn build_str_table(file: File, header: *Elf64Header) ![]u8 {
    var section_idx = header.shstrndx;
    try file.seekTo(header.shoff + @sizeOf(Elf64Shdr) * section_idx);
    var shdr: Elf64Shdr = undefined;
    var buf: []u8 = std.mem.asBytes(&shdr);
    var nread = try file.read(buf);

    const offset = shdr.offset;
    const size = shdr.size;
    try file.seekTo(shdr.offset);
    const buffer = try alloc.alloc(u8, size);
    nread = try file.read(buffer);
    return buffer;
}

pub fn parse_program_sections(file: File, header: *Elf64Header) !void {
    var strings = try build_str_table(file, header);
    try file.seekTo(header.shoff);
    var i: u32 = 0;
    print("========== SHDRs\n", .{});
    print("Type        Name                     Flags       Addr     Offset       Size\n", .{});
    while (i < header.shnum) : (i += 1) {
        var shdr: Elf64Shdr = undefined;
        var buf: []u8 = std.mem.asBytes(&shdr);
        var nread = try file.readAll(buf);
        shdr_print(shdr, strings);
    }
}

var alloc: *std.mem.Allocator = undefined;

pub fn main() !void {
    // Initialize allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    alloc = &arena.allocator;
    defer arena.deinit();

    var argit = process.args();
    _ = argit.skip();
    const file_path: []u8 = try (argit.next(alloc) orelse {
        print("No file provided!\n", .{});
        return;
    });

    var file = try cwd().openFile(file_path, File.OpenFlags{ .read = true });
    try parse_elf(file);
}
