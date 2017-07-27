pkgname=postgresql
pkgver=10
pkgrel=0
pkgdesc="A sophisticated object-relational DBMS"
url="http://www.postgresql.org/"
arch="all"
license="BSD"
depends="postgresql-client"
install="$pkgname.pre-upgrade"
pkgusers="postgres"
pkggroups="postgres"
depends_dev="libressl-dev"
makedepends="$depends_dev libedit-dev zlib-dev libxml2-dev util-linux-dev"
subpackages="$pkgname-contrib $pkgname-dev $pkgname-doc libpq $pkgname-libs $pkgname-client"
source="ftp://ftp.$pkgname.org/pub/source/v${pkgver}beta2/$pkgname-${pkgver}beta2.tar.bz2"
builddir="$srcdir/$pkgname-${pkgver}beta2"

# secfixes:
#   9.6.3-r0:
#   - CVE-2017-7484
#   - CVE-2017-7485
#   - CVE-2017-7486

prepare() {
	default_prepare || return 1
	cd "$builddir"

	cp -al "$builddir" "$builddir"~py3
}

build() {
	cd "$builddir"
	_configure && make world || return 1
}

_configure() {
	./configure \
		--build=$CBUILD \
		--host=$CHOST \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--with-libedit-preferred \
		--with-libxml \
		--with-openssl \
		--with-uuid=e2fs \
		--disable-rpath
}

package() {
	cd "$builddir"

	make DESTDIR="$pkgdir" install install-docs || return 1

	install -d -m750 -o postgres -g postgres \
		"$pkgdir"/var/lib/postgresql \
		"$pkgdir"/var/log/$pkgname || return 1
}

dev() {
	default_dev || return 1

	mkdir -p "$subpkgdir"/usr/bin "$subpkgdir"/usr/lib/postgresql
	mv "$pkgdir"/usr/bin/pg_config \
		"$pkgdir"/usr/bin/ecpg \
		"$subpkgdir"/usr/bin/ || return 1
	mv "$pkgdir"/usr/lib/postgresql/pgxs \
		"$subpkgdir"/usr/lib/postgresql/ || return 1
}

libpq() {
	pkgdesc="PostgreSQL libraries"
	depends=""

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libpq.so.* "$subpkgdir"/usr/lib/
}

libs() {
	depends=""
	default_libs
}

client() {
	pkgdesc="PostgreSQL client"
	depends=""

	mkdir -p "$subpkgdir"/usr/bin
	mv "$pkgdir"/usr/bin/psql "$subpkgdir"/usr/bin/
}

contrib() {
	pkgdesc="Extension modules distributed with PostgreSQL"
	depends=""

	cd "$builddir"

	# Avoid installing plperl and plpython extensions, these will be
	# installed into separate subpackages.
	sed -Ei -e 's/(.*_plperl)/#\1/' \
		-e 's/(.*_plpython)/#\1/' \
		contrib/Makefile || return 1

	make -C contrib DESTDIR="$subpkgdir" install || return 1

	mv "$subpkgdir"/usr/share/doc/postgresql/extension \
		"$pkgdir"/usr/share/doc/postgresql/ || return 1
	rmdir -p "$subpkgdir"/usr/share/doc/postgresql || true
}

