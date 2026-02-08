int gcd(int a, int b) {
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

int lcm(int a, int b) => (a * b) ~/ gcd(a, b);

List<double> beatPositions(int n) {
  return List.generate(n, (i) => i / n);
}
