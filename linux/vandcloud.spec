Name: vandcloud
Version: 1.0.1
Release: 1
Summary: VandCloud

License: MIT
URL: https://github.com/code3-dev/VandCloud
Source0: %{name}-%{version}.tar.gz

Requires: gtk3, xz-libs

%description
Cross-Platform Host Checking Application.

%prep
%setup -q

%build
# Nothing to build, this is a pre-built application

%install
mkdir -p %{buildroot}/%{_bindir}
mkdir -p %{buildroot}/%{_datadir}/applications
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/16x16/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/22x22/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/24x24/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/32x32/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/48x48/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/64x64/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/128x128/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/256x256/apps
mkdir -p %{buildroot}/%{_datadir}/icons/hicolor/512x512/apps

# Install application files
cp -r bundle/* %{buildroot}/%{_bindir}/

# Install desktop file
cp vandcloud.desktop %{buildroot}/%{_datadir}/applications/

# Install icons
cp icons/icon_16.png %{buildroot}/%{_datadir}/icons/hicolor/16x16/apps/vandcloud.png
cp icons/icon_22.png %{buildroot}/%{_datadir}/icons/hicolor/22x22/apps/vandcloud.png
cp icons/icon_24.png %{buildroot}/%{_datadir}/icons/hicolor/24x24/apps/vandcloud.png
cp icons/icon_32.png %{buildroot}/%{_datadir}/icons/hicolor/32x32/apps/vandcloud.png
cp icons/icon_48.png %{buildroot}/%{_datadir}/icons/hicolor/48x48/apps/vandcloud.png
cp icons/icon_64.png %{buildroot}/%{_datadir}/icons/hicolor/64x64/apps/vandcloud.png
cp icons/icon_128.png %{buildroot}/%{_datadir}/icons/hicolor/128x128/apps/vandcloud.png
cp icons/icon_256.png %{buildroot}/%{_datadir}/icons/hicolor/256x256/apps/vandcloud.png
cp icons/icon_512.png %{buildroot}/%{_datadir}/icons/hicolor/512x512/apps/vandcloud.png
cp icons/vandcloud.png %{buildroot}/%{_datadir}/icons/hicolor/256x256/apps/vandcloud.png

%files
%{_bindir}/vandcloud
%{_datadir}/applications/vandcloud.desktop
%{_datadir}/icons/hicolor/16x16/apps/vandcloud.png
%{_datadir}/icons/hicolor/22x22/apps/vandcloud.png
%{_datadir}/icons/hicolor/24x24/apps/vandcloud.png
%{_datadir}/icons/hicolor/32x32/apps/vandcloud.png
%{_datadir}/icons/hicolor/48x48/apps/vandcloud.png
%{_datadir}/icons/hicolor/64x64/apps/vandcloud.png
%{_datadir}/icons/hicolor/128x128/apps/vandcloud.png
%{_datadir}/icons/hicolor/256x256/apps/vandcloud.png
%{_datadir}/icons/hicolor/512x512/apps/vandcloud.png

%changelog
* Thu Oct 16 2025 Hossein Pira <h3dev.pira@gmail.com> - 1.0.1-2
- Initial release