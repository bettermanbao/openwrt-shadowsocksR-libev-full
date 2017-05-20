include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksr-gfwlist
PKG_VERSION:=2.5.6
PKG_RELEASE:=2670ab26ddd63dd790ba6c35f57d4dd040dec194

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocksr/shadowsocksr-libev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_RELEASE)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocksr-gfwlist/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy $(2)
	URL:=https://github.com/shadowsocksr/shadowsocksr-libev.git
	VARIANT:=$(1)
	DEPENDS:=$(3) +libpcre +libpthread +dnsmasq-full +ipset +iptables
endef

Package/shadowsocksr-gfwlist =          $(call Package/shadowsocksr-gfwlist/Default,openssl,(OpenSSL),+libopenssl +zlib)
Package/shadowsocksr-gfwlist-mbedtls =  $(call Package/shadowsocksr-gfwlist/Default,mbedtls,(mbedTLS),+libmbedtls)
Package/shadowsocksr-gfwlist-polarssl = $(call Package/shadowsocksr-gfwlist/Default,polarssl,(PolarSSL),+libpolarssl)

define Package/shadowsocksr-gfwlist/description
ShadowsocksR-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

define Package/shadowsocksr-gfwlist/conffiles
/etc/shadowsocksr.json
/etc/dnsmasq.d/custom_list.conf
endef

define Package/shadowsocksr-gfwlist/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/shadowsocksr-postinst ]; then
		( . /etc/uci-defaults/shadowsocksr-postinst ) && \
		rm -f /etc/uci-defaults/shadowsocksr-postinst
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

	/etc/init.d/cron restart
	/etc/init.d/dnsmasq restart
	/etc/init.d/shadowsocksr restart
fi
exit 0
endef

define Package/shadowsocks-gfwlist/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	mv -f /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
	rm -f /etc/dnsmasq.conf.ssr
	rm -f /etc/dnsmasq.d/gfw_list.conf
	rm -f /etc/dnsmasq.d/custom_list.conf
	/etc/init.d/dnsmasq restart

	mv -f /etc/firewall.user.bak /etc/firewall.user
	rm -f /etc/firewall.user.ssr
	/etc/init.d/firewall restart

	sed -i '/shadowsocksr_watchdog/d' /etc/crontabs/root
	/etc/init.d/cron restart
	/etc/init.d/shadowsocksr stop
fi
exit 0
endef


Package/shadowsocksr-gfwlist-mbedtls/description=$(Package/shadowsocksr-gfwlist/description)
Package/shadowsocksr-gfwlist-mbedtls/conffiles = $(Package/shadowsocksr-gfwlist/conffiles)
Package/shadowsocksr-gfwlist-mbedtls/postinst = $(Package/shadowsocksr-gfwlist/postinst)
Package/shadowsocksr-gfwlist-mbedtls/postrm = $(Package/shadowsocksr-gfwlist/postrm)

Package/shadowsocksr-gfwlist-polarssl/description=$(Package/shadowsocksr-gfwlist/description)
Package/shadowsocksr-gfwlist-polarssl/conffiles = $(Package/shadowsocksr-gfwlist/conffiles)
Package/shadowsocksr-gfwlist-polarssl/postinst = $(Package/shadowsocksr-gfwlist/postinst)
Package/shadowsocksr-gfwlist-polarssl/postrm = $(Package/shadowsocksr-gfwlist/postrm)

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert

ifeq ($(BUILD_VARIANT),mbedtls)
	CONFIGURE_ARGS += --with-crypto-library=mbedtls
endif

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocksr-gfwlist/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/shadowsocksr-gfwlist.postinst $(1)/etc/uci-defaults/shadowsocksr-postinst
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocksr-gfwlist.init $(1)/etc/init.d/shadowsocksr
	$(INSTALL_CONF) ./files/shadowsocksr-gfwlist.json $(1)/etc/shadowsocksr.json.main
	$(INSTALL_CONF) ./files/shadowsocksr-gfwlist.json $(1)/etc/shadowsocksr.json.backup
	$(INSTALL_CONF) ./files/firewall.user $(1)/etc/firewall.user.ssr
	$(INSTALL_CONF) ./files/dnsmasq.conf $(1)/etc/dnsmasq.conf.ssr
	$(INSTALL_DIR) $(1)/etc/dnsmasq.d
	$(INSTALL_CONF) ./files/gfw_list.conf $(1)/etc/dnsmasq.d/gfw_list.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/dnsmasq.d/custom_list.conf
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_BIN) ./files/ssr-watchdog.sh $(1)/root/ssr-watchdog
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocksr-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocksr-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev
	$(INSTALL_CONF) ./files/shadowsocksr-libev-general.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev/shadowsocksr-libev-general.lua
	$(INSTALL_CONF) ./files/shadowsocksr-libev-backup.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev/shadowsocksr-libev-backup.lua
	$(INSTALL_CONF) ./files/shadowsocksr-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocksr-libev/shadowsocksr-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocksr-libev
	$(INSTALL_CONF) ./files/gfwlistr.htm $(1)/usr/lib/lua/luci/view/shadowsocksr-libev/gfwlistr.htm
	$(INSTALL_CONF) ./files/watchdogr.htm $(1)/usr/lib/lua/luci/view/shadowsocksr-libev/watchdogr.htm
endef

Package/shadowsocksr-gfwlist-polarssl/install = $(Package/shadowsocksr-gfwlist/install)

$(eval $(call BuildPackage,shadowsocksr-gfwlist))
$(eval $(call BuildPackage,shadowsocksr-gfwlist-mbedtls))
$(eval $(call BuildPackage,shadowsocksr-gfwlist-polarssl))
