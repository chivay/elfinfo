//const print = @import("std").debug.print;
const std = @import("std");
const File = std.fs.File;
const os = std.os;
const process = std.process;
const cwd = std.fs.cwd;

const elf = @import("defs.zig");
const Elf64Header = elf.Elf64Header;
const Elf64Phdr = elf.Elf64Phdr;
const Elf64Shdr = elf.Elf64Shdr;
const io = std.io;

fn print(comptime fmt: []const u8, args: var) void {
    buffered_out.writer().print(fmt, args) catch return;
}

fn hex_print_chunks(buffer: []const u8, chunk_size: u32) void {
    var left = buffer;
    while (left.len > 0) {
        const len = if (left.len < chunk_size) left.len else chunk_size;
        print("{x}", .{left[0..len]});

        left = left[len..];

        if (left.len > 0) {
            print(" ", .{});
        }
    }
}

fn ascii_print(buffer: []const u8) void {
    for (buffer) |c| {
        if (c > 0x20 and c < 0x7f) {
            print("{c}", .{c});
        } else {
            print(".", .{});
        }
    }
}

fn hexdump(buffer: []const u8, base: usize) void {
    const WIDTH = 16;
    const GROUP = 2;

    var left = buffer;
    var total: usize = base;
    while (left.len > 0) {
        const len = if (left.len < WIDTH) left.len else WIDTH;
        const chunk = left[0..len];
        print("{x:0>8}: ", .{total});
        hex_print_chunks(chunk, GROUP);

        const should_be = WIDTH * 2 + ((WIDTH - 1) / GROUP);
        const actually = len * 2 + ((len - 1) / GROUP);
        var err = should_be - actually;
        while (err > 0) : (err -= 1) {
            print(" ", .{});
        }

        print(" ", .{});
        ascii_print(chunk);
        print("\n", .{});

        left = left[len..];
        total += len;
    }
}

pub fn ehdr_print(self: Elf64Header) void {
    print("========== ELF header\n", .{});
    print("  magic: {x}\n", .{self.ident});
    print("   type: {}\n", .{self.file_type});
    print("machine: {}\n", .{self.machine});
    print("  entry: {x}\n", .{self.entry});
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

pub fn shdr_print(self: Elf64Shdr, strings: ?[]const u8) void {
    var section_name: ?[]const u8 = null;
    if (strings != null) {
        const slice = strings.?[self.name..];
        const len = std.mem.indexOf(u8, slice, "\x00") orelse 0;
        section_name = slice[0..len];
    } else {
        section_name = "";
    }

    print("{:12}", .{self.stype.name()});
    print("{:20}", .{section_name});
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
    const strings = try build_str_table(file, &header);
    const section_headers = try parse_program_sections(file, &header);
    print("========== Section headers\n", .{});
    print("Type        Name                     Flags       Addr     Offset       Size\n", .{});
    for (section_headers) |shdr| {
        shdr_print(shdr, strings);
    }

    var i: u32 = 0;
    for (section_headers) |shdr| {
        shdr_print(shdr, strings);
        const data = try get_section(file, &header, i);
        print("Data in section: \n", .{});
        hexdump(data, shdr.addr);
        print("\n", .{});
        i += 1;
    }
}

pub fn parse_program_headers(file: File, header: *Elf64Header) !void {
    try file.seekTo(header.phoff);
    var i: u32 = 0;
    print("========== Program headers\n", .{});
    print("Type           Flags  Offset     Vaddr     Paddr  Mem size File size\n", .{});
    while (i < header.phnum) : (i += 1) {
        var phdr: Elf64Phdr = undefined;
        const rsize = try file.readAll(std.mem.asBytes(&phdr));
        phdr_print(phdr);
    }
}

/// Get contents of STRTAB array
pub fn build_str_table(file: File, header: *Elf64Header) ![]u8 {
    return get_section(file, header, header.shstrndx);
}

const ELFError = error{ShortRead};

pub fn get_section(file: File, header: *Elf64Header, idx: u32) ![]u8 {
    var shdr: Elf64Shdr = undefined;
    const buf = std.mem.asBytes(&shdr);

    const nread = try file.preadAll(buf, header.shoff + @sizeOf(Elf64Shdr) * idx);
    if (nread != @sizeOf(Elf64Shdr)) {
        return error.ShortRead;
    }

    const buffer = try alloc.alloc(u8, shdr.size);
    const bytes_read = try file.preadAll(buffer, shdr.offset);
    if (bytes_read != shdr.size) {
        return error.ShortRead;
    }

    return buffer;
}

pub fn parse_program_sections(file: File, header: *Elf64Header) ![]Elf64Shdr {
    var sections = try alloc.alloc(Elf64Shdr, header.shnum);
    try file.seekTo(header.shoff);
    var i: u32 = 0;
    while (i < header.shnum) : (i += 1) {
        var buf: []u8 = std.mem.asBytes(&sections[i]);
        var nread = try file.readAll(buf);
    }
    return sections;
}

var alloc: *std.mem.Allocator = undefined;
var buffered_out = std.io.bufferedWriter(std.io.getStdOut().writer());

pub fn main() !void {
    // Initialize allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    alloc = &arena.allocator;
    defer arena.deinit();

    defer buffered_out.flush() catch {};

    var argit = process.args();
    _ = argit.skip();
    const file_path: []u8 = try (argit.next(alloc) orelse {
        print("No file provided!\n", .{});
        return;
    });

    var file = try cwd().openFile(file_path, File.OpenFlags{ .read = true });
    try parse_elf(file);
}
