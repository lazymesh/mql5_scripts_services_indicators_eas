import ctypes

dll = ctypes.CDLL("C:\\Users\\rawnm\\source\\repos\\full_transaction\\x64\\Release\\full_transaction.dll")

# Declare function signatures
dll.GetStringData.restype = ctypes.c_bool
dll.get_item_dll.restype = ctypes.c_char_p
dll.create_item_dll.restype = ctypes.c_char_p

buffer_size = 4096
buffer = ctypes.create_string_buffer(buffer_size)

# Call the function
success = dll.GetStringData(buffer, buffer_size, 1)

if success:
    # Convert to Python string
    result = buffer.value.decode('utf-8')  # or 'latin-1' if ANSI
    print("getstringdata ", result)
else:
    print("failed to get result data")
print(dll.get_item_dll(1))
# print(dll.create_item_dll(b'{"Laptop": "lsjdlfj"}'))
