import ctypes

dll = ctypes.CDLL("C:\\path\\to\\api_client.dll")

# Declare function signatures
dll.get_item_dll.restype = ctypes.c_char_p
dll.create_item_dll.restype = ctypes.c_char_p

print(dll.get_item_dll(1).decode())
print(dll.create_item_dll(b"Laptop", 1200.5, True).decode())
