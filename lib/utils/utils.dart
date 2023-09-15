String buildIcon(String icon, bool isBigSize) {
  if (isBigSize) {
    return 'https://openweathermap.org/img/wn/$icon@4x.png';
  } else {
    return 'https://openweathermap.org/img/wn/$icon.png';
  }
}
