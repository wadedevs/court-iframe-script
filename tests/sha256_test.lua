-- Run with: lua5.4 tests/sha256_test.lua  (from the repo root)
local Sha256 = dofile("server/sha256.lua")

local function check(name, got, want)
    if got ~= want then
        error(string.format("%s\n  got:  %s\n  want: %s", name, got, want))
    end
    print("ok - " .. name)
end

check("sha256 empty", Sha256.hex(""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
check("sha256 abc", Sha256.hex("abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
check("sha256 two blocks", Sha256.hex("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")
check("sha256 55 bytes", Sha256.hex(string.rep("a", 55)), "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318")
check("sha256 64 bytes", Sha256.hex(string.rep("a", 64)), "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb")
-- RFC 4231 test case 2
check("hmac rfc4231 #2", Sha256.hmacHex("Jefe", "what do ya want for nothing?"),
    "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843")
-- RFC 4231 test case 6 (key longer than the block size)
check("hmac rfc4231 #6", Sha256.hmacHex(string.rep("\170", 131), "Test Using Larger Than Block-Size Key - Hash Key First"),
    "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54")
-- Same vector as court-connect test/embed.test.js ("fixed vector matches the Lua signer").
check("embed token vector", Sha256.hmacHex("test-embed-secret-0123456789", "embed-v1|https://cfx-nui-court_web|1792720600"),
    "d6ec7d0d1d2fb38689324c53f0a3931a4111867218d4ce9fa041638eaa954d39")
print("all sha256 tests passed")
