// rubik_cipher.dart

class RubikCipher {
  static const int cubeSize = 3; // 3x3x3 cube = 27 bytes per chunk

  // Encrypt video data using Rubik's Cube-like rotations
  static List<int> encrypt(List<int> data) {
    final paddedData = _padToCubeSize(data);
    final chunks = _chunkData(paddedData);
    final encryptedChunks = chunks.map(_rotateCube).toList();
    return encryptedChunks.expand((chunk) => chunk).toList();
  }

  // Decrypt video data using inverse Rubik's Cube rotations
  static List<int> decrypt(List<int> data) {
    final chunks = _chunkData(data);
    final decryptedChunks = chunks.map(_inverseRotateCube).toList();
    return _removePadding(decryptedChunks.expand((chunk) => chunk).toList());
  }

  // Pad data to nearest cube multiple
  static List<int> _padToCubeSize(List<int> data) {
    const chunkSize = cubeSize * cubeSize * cubeSize;
    final remainder = data.length % chunkSize;
    if (remainder == 0) return data;

    final padding = List<int>.filled(chunkSize - remainder, 0);
    return [...data, ...padding];
  }

  // Break data into 3x3x3 cube chunks
  static List<List<int>> _chunkData(List<int> data) {
    const chunkSize = cubeSize * cubeSize * cubeSize;
    final chunks = <List<int>>[];
    for (int i = 0; i < data.length; i += chunkSize) {
      chunks.add(data.sublist(i, i + chunkSize));
    }
    return chunks;
  }

  // Rotate the 3D cube (simulate a twist)
  static List<int> _rotateCube(List<int> chunk) {
    final cube = _to3DCube(chunk);
    final rotated = List.generate(cubeSize, (z) =>
      List.generate(cubeSize, (y) =>
        List.generate(cubeSize, (x) => cube[cubeSize - 1 - y][x][z])
      )
    );
    return _flatten3DCube(rotated);
  }

  // Reverse rotation
  static List<int> _inverseRotateCube(List<int> chunk) {
    final cube = _to3DCube(chunk);
    final inverseRotated = List.generate(cubeSize, (z) =>
      List.generate(cubeSize, (y) =>
        List.generate(cubeSize, (x) => cube[y][cubeSize - 1 - x][z])
      )
    );
    return _flatten3DCube(inverseRotated);
  }

  // Convert 1D chunk to 3D cube
  static List<List<List<int>>> _to3DCube(List<int> chunk) {
    final cube = List.generate(
      cubeSize,
      (z) => List.generate(cubeSize, (y) => List<int>.filled(cubeSize, 0)),
    );
    int index = 0;
    for (int z = 0; z < cubeSize; z++) {
      for (int y = 0; y < cubeSize; y++) {
        for (int x = 0; x < cubeSize; x++) {
          cube[z][y][x] = chunk[index++];
        }
      }
    }
    return cube;
  }

  // Flatten 3D cube back to 1D list
  static List<int> _flatten3DCube(List<List<List<int>>> cube) {
    final flat = <int>[];
    for (int z = 0; z < cubeSize; z++) {
      for (int y = 0; y < cubeSize; y++) {
        for (int x = 0; x < cubeSize; x++) {
          flat.add(cube[z][y][x]);
        }
      }
    }
    return flat;
  }

  // Remove padding zeros at the end
  static List<int> _removePadding(List<int> data) {
    int lastIndex = data.length;
    while (lastIndex > 0 && data[lastIndex - 1] == 0) {
      lastIndex--;
    }
    return data.sublist(0, lastIndex);
  }
}