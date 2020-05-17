extern "C" void kmain(void) {

  char *vidbuff = (char *)0xb8000; 
  unsigned int j = 0;
  j = 0;
  unsigned int i = 0;
  char *str = "Hello from kernel !";
  while (str[j] != '\0') {
    vidbuff[i] = str[j];
    vidbuff[i + 1] = 0x0E;
    j++;
    i += 2;
  }
  return;
}
