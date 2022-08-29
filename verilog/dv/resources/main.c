// Program to convert a string to ASCII in hex for input to the HW SHA modules
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define USE_INPUT 0
#define INPUT_LIMIT 100

// Link for hashing digests: https://www.fileformat.info/tool/hash.htm?hex=68656c6c6f20776f726c64

int main() {
  char* str_to_convert;

  if (USE_INPUT) {
    char str[INPUT_LIMIT];
    printf("Enter string to convert:\n");
    fgets(str, INPUT_LIMIT, stdin);
  } else {
    // str_to_convert = "abc";
    // str_to_convert = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
    str_to_convert = "hello world";
  }

  int i;
  printf("Hex value of '%s' is:\n", str_to_convert);

  for (i = 0; i < strlen(str_to_convert) + 1; i++) {
    printf("%02x", str_to_convert[i] & 0xFF);
  }
  printf("\nNum chars = %d", i);

  return 0;
}
