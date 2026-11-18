%global cookbook_path /var/chef/cookbooks/rb-sflow2kafka

Name: cookbook-rb-sflow2kafka
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: redborder-sflow2kafka cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-rb-sflow2kafka
Source0: %{name}-%{version}.tar.gz

Obsoletes: cookbook-sflow2kafka

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}%{cookbook_path}
cp -f -r  resources/* %{buildroot}%{cookbook_path}
chmod -R 0755 %{buildroot}%{cookbook_path}
install -D -m 0644 README.md %{buildroot}%{cookbook_path}/README.md

%pre
if [ -d /var/chef/cookbooks/rb-sflow2kafka ]; then
    rm -rf /var/chef/cookbooks/rb-sflow2kafka
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    if systemctl is-active --quiet opscode-erchef; then
      su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-sflow2kafka'
    fi
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-sflow2kafka ]; then
  rm -rf /var/chef/cookbooks/rb-sflow2kafka
fi

%files
%defattr(0644,root,root)
%attr(0755,root,root)
%{cookbook_path}
%defattr(0644,root,root)
%{cookbook_path}/README.md

%doc

%changelog
* Wed Nov 18 2026 manegron <manegron@redborder.com>
- Rename cookbook from sflow2kafka to rb-sflow2kafka

* Tue Nov 17 2026 Miguel Negrón <manegron@redborder.com>
- first spec version
