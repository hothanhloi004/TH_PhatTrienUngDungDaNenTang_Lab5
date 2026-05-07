class Config {
  // Change this to your machine's IP when running on a physical device
  // For Android emulator use: http://10.0.2.2:3000
  // For physical device use: http://<YOUR_LOCAL_IP>:3000
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const String registerUrl = '$baseUrl/users/register';
  static const String loginUrl = '$baseUrl/users/login';
  static const String todoUrl = '$baseUrl/todos';
}
