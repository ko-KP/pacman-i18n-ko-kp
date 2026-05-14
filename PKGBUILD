# Maintainer: ko-KP Project <https://github.com/ko-KP>

pkgname=pacman-i18n-ko-kp
pkgver=0.1.0
pkgrel=1
pkgdesc='Korean (ko_KP) translations for pacman'
arch=('any')
url='https://github.com/ko-KP/pacman-i18n-ko-kp'
depends=('pacman')
makedepends=('gettext' 'meson')
source=("${pkgname}-${pkgver}.tar.gz::${url}/archive/v${pkgver}.tar.gz")
b2sums=('SKIP')

build() {
  arch-meson "${pkgname}-${pkgver}" build
}

package() {
  DESTDIR="${pkgdir}" meson install -C build
}
