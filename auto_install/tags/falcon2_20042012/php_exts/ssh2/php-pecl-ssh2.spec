%{!?__pecl: %{expand: %%global __pecl %{_bindir}/pecl}}
%global php_extdir %(%{_bindir}/php-config --extension-dir 2>/dev/null || echo %{_libdir}/php4)
%global php_zendabiver %((echo 0; php -i 2>/dev/null | sed -n 's/^PHP Extension => //p') | tail -1)
%global php_version %((echo 0; php-config --version 2>/dev/null) | tail -1)
%global pecl_name ssh2

Summary:       SSH2 PHP extension - Bindings for the libssh2 library
Name:          php-pecl-ssh2
Version:       0.12
Release:       1%{?dist}
License:       PHP
Group:         Development/Languages
URL:           http://pecl.php.net/package/ssh2
Source:        http://pecl.php.net/get/ssh2-%{version}.tgz

BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: php-devel >= 5.3.0, httpd-devel, php-pear, pcre-devel
Requires(post): %{__pecl}
Requires(postun): %{__pecl}
%if 0%{?php_zend_api:1}
# Require clean ABI/API versions if available (Fedora)
Requires:      php(zend-abi) = %{php_zend_api}
Requires:      php(api) = %{php_core_api}
%else
%if "%{rhel}" == "5"
# RHEL5 where we have php-common providing the Zend ABI the "old way"
Requires:      php-zend-abi = %{php_zendabiver}
%else
# RHEL4 where we have no php-common and nothing providing the Zend ABI...
Requires:      php = %{php_version}
%endif
%endif
Provides:      php-pecl(%{pecl_name}) = %{version}

Requires(post): %{__pecl}
Requires(postun): %{__pecl}

%description
PHP bindings for the libssh2 library



%prep
%setup -q -c 


%build
cd ssh2-%{version}
%{_bindir}/phpize
%configure --enable-apc-mmap --with-php-config=%{_bindir}/php-config
%{__make} %{?_smp_mflags}


%install
pushd ssh2-%{version}
%{__rm} -rf %{buildroot}
%{__make} install INSTALL_ROOT=%{buildroot}

mkdir -p %{buildroot}/%{_datadir}/%{name}


popd
# Install the package XML file
%{__mkdir_p} %{buildroot}%{pecl_xmldir}
%{__install} -m 644 package.xml %{buildroot}%{pecl_xmldir}/%{name}.xml

# Drop in the bit of configuration
%{__mkdir_p} %{buildroot}%{_sysconfdir}/php.d
%{__cat} > %{buildroot}%{_sysconfdir}/php.d/ssh2.ini << 'EOF'
; Enable ssh2 extension module
extension = ssh2.so
EOF


%check
cd %{pecl_name}-%{version}
TEST_PHP_EXECUTABLE=%{_bindir}/php %{_bindir}/php run-tests.php \
    -n -q -d extension_dir=modules \
    -d extension=ssh2.so


%if 0%{?pecl_install:1}
%post
%{pecl_install} %{pecl_xmldir}/%{name}.xml >/dev/null || :
%endif


%if 0%{?pecl_uninstall:1}
%postun
if [ $1 -eq 0 ] ; then
    %{pecl_uninstall} %{pecl_name} >/dev/null || :
fi
%endif


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-, root, root, 0755)
%doc ssh2-%{version}/LICENSE
%config(noreplace) %{_sysconfdir}/php.d/ssh2.ini
%config(noreplace) %{_sysconfdir}/php.d/ssh2.ini
%dir %{_datadir}/%{name}

%{php_extdir}/ssh2.so
%{pecl_xmldir}/%{name}.xml



%changelog
* Fri Jan 25 2013 Jess Portnoy <jess.portnoy@kaltura.com> - 0.12-1
- Initial build to be used for Kaltura OnPrem Falcon.
