const std = @import("std");

pub fn main() !void {
    readLinePerLineNoAlloc();
}

pub fn readLinePerLineNoAlloc() !void {
    const stdout = std.io.getStdOut().writer();

    // Abre el archivo
    const file = try std.fs.cwd().openFile("day2.txt", .{});
    defer file.close();

    // Preparar el lector bufferizado
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    while (true) {
        var line: [64]u8 = undefined;
        const line_slice_opt = try reader.readUntilDelimiterOrEof(&line, '\n');
        const line_slice = line_slice_opt orelse break;

        // Separa la línea usando 'x' como delimitador
        var tokenizer = std.mem.tokenizeAny(u8, line_slice, &[_]u8{'x'});
        var nums: [3]i32 = undefined;

        // Asigna los números a las variables
        var i: usize = 0;
        while (tokenizer.next()) |token| {
            nums[i] = std.fmt.parseInt(i32, token, 10) catch |err| {
                stdout.print("Error en la conversión: {}\n", .{err}) catch unreachable;
                return;
            };
            i += 1;
        }

        // Utiliza las variables aquí
        stdout.print("Valores: {}, {}, {}\n", .{ nums[0], nums[1], nums[2] }) catch unreachable;
    }
}

pub fn startServer() !void {
    const server_addr = "127.0.0.1";
    const server_port = 8000;
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    const server = std.http.Server.init(allocator, .{ .reuse_addres = true });
    defer server.deinit();

    const address = std.net.Address.parseIp(server_addr, server_port) catch unreachable;
    try server.listen(address);
}
