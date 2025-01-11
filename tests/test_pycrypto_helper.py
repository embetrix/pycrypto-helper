#
#  (C) Copyright 2025
#  Embetrix Embedded Systems Solutions, ayoub.zaki@embetrix.com
#

from pycrypto_helper import crypto_helper

def test_get_key_type():
    key_desc = "rsa_key.pem"
    key_type = crypto_helper.get_key_type(key_desc, "pa33w0rd")
    assert key_type == 'RSA', f"Expected 'RSA', got {key_type}"

    key_desc = "ecdsa_key.pem"
    key_type = crypto_helper.get_key_type(key_desc)
    assert key_type == 'EC', f"Expected 'EC', got {key_type}"

def test_load_pem_certificate():
    cert_path = "rsa_cert.pem"
    cert = crypto_helper.load_pem_certificate(cert_path)
    assert cert is not None, "Error loading PEM certificate:"

def test_parse_pkcs11_uri():
    uri = "pkcs11:token=token0;object=testkeyECp256"
    expected_result = {'token': 'token0', 'object': 'testkeyECp256'}
    result = crypto_helper.parse_pkcs11_uri(uri)
    assert result == expected_result, f"Expected {expected_result}, got {result}"

def test_sign_and_verify():
    key_desc = "rsa_key.pem"
    data = b"Hello, world!"
    signature = crypto_helper.sign(key_desc, data, "pa33w0rd")
    assert signature is not None, "Failed to sign data"
    crypto_helper.verify(key_desc, data, signature, "pa33w0rd")

def test_cms_sign_and_verify():
    key_desc = "rsa_key.pem"
    data = b"Hello, world!"
    signature = crypto_helper.cms_sign(key_desc, "rsa_cert.pem", data, "pa33w0rd")
    assert signature is not None, "Failed to sign data"
    crypto_helper.cms_verify("rsa_cert.pem",data, signature)

def test_encrypt_and_decrypt():
    key_desc = "aes.key"
    ivt = "000102030405060708090a0b0c0d0e0f"
    data = b"Hello, world!"
    encrypted_data = crypto_helper.encrypt(key_desc, ivt, data)
    assert encrypted_data is not None, "Failed to encrypt data"
    decrypted_data = crypto_helper.decrypt(key_desc, ivt, encrypted_data)
    assert decrypted_data == data, f"Expected {data}, got {decrypted_data}"

if __name__ == "__main__":
    try:
        test_get_key_type()
        test_load_pem_certificate()
        test_parse_pkcs11_uri()
        test_sign_and_verify()
        test_cms_sign_and_verify()
        test_encrypt_and_decrypt()
        print("All tests passed!")
    except Exception as e:
        print(f"An error occurred: {e}")