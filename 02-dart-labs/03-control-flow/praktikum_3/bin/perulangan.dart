void main(List<String> arguments) {
  int i = 0;

  while (i < 5) {
    print('While ke-${i + 1}');
    i++;
  }

  i = 0;
  do {
    print('Do-while ke-${i + 1}');
    i++;
  } while (i < 5);

  for (i = 10; i >= 1; i--) {
    print('For ke-$i');
  }

  i = 0;
  for (;;) {
    if (i == 5) {
      break;
    }
    print('Perulangan');
    i++;
  }

  for (int j = 1; j < 10; j++) {
    if (j % 2 == 0) {
      continue;
    }
    print(j);
  }
}
