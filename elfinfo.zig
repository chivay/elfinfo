const print = @import("std").debug.print;
const std = @import("std");
const File = std.fs.File;
const os = std.os;
const process = std.process;

const elf = @import("defs.zig");
const Elf64Header = elf.Elf64Header;
const Elf64Phdr = elf.Elf64Phdr;
const Elf64Shdr = elf.Elf64Shdr;

var alloc: *std.mem.Allocator = undefined;

pub fn parse_elf(path: []const u8) !void {
    var file = try std.fs.openFileAbsolute(path, File.OpenFlags{ .read = true });
    var header: Elf64Header = undefined;
    var buf: []u8 = std.mem.asBytes(&header);
    var nread = try file.read(buf);
    header.debug_print();

    try parse_program_headers(file, &header);
    try parse_program_sections(file, &header);
}

pub fn parse_program_headers(file: File, header: *Elf64Header) !void {
    print("seeking to {}\n", .{header.phoff});
    try file.seekTo(header.phoff);

    var i: u32 = 0;
    print("==========PHDRs\n", .{});
    while (i < header.phnum) : (i += 1) {
        try parse_phdr(file, header);
    }
}

pub fn parse_phdr(file: File, header: *Elf64Header) !void {
    var phdr: Elf64Phdr = undefined;
    const rsize = try file.read(std.mem.asBytes(&phdr));
    phdr.debug_print();
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
    print("==========SHDRs\n", .{});
    while (i < header.shnum) : (i += 1) {
        var shdr: Elf64Shdr = undefined;
        var buf: []u8 = std.mem.asBytes(&shdr);
        var nread = try file.read(buf);
        shdr.debug_print(strings);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    alloc = &arena.allocator;

    defer arena.deinit();

    var argit = process.args();
    _ = argit.skip();
    var file = try argit.next(alloc).?;
    try parse_elf(file);
}
