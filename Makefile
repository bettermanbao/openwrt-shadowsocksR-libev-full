include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksR-libev
PKG_VERSION:=2.6.0-1
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_SOURCE_URL:=https://github.com/breakwa11/shadowsocks-libev.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=cd646ce98f0c21d54011d636dabba1fc053fbc0d
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=breakwa11

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocksr-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy
	URL:=https://github.com/breakwa11/shadowsocks-libev
endef

define Package/shadowsocksr-libev
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (OpenSSL)
	VARIANT:=openssl
	DEPENDS:=+libopenssl +libpcre +libpthread
endef

define Package/shadowsocksr-libev-polarssl
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (PolarSSL)
	VARIANT:=polarssl
	DEPENDS:=+libpolarssl +libpcre +libpthread
endef

define Package/shadowsocksr-libev-gfwlist
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (OpenSSL)
	VARIANT:=openssl
	DEPENDS:=+libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget
endef

define Package/shadowsocksr-libev-gfwlist-polarssl
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (PolarSSL)
	VARIANT:=polarssl
	DEPENDS:=+libpolarssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget-nossl
endef

define Package/shadowsocksr-libev-gfwlist-4M
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (PolarSSL)
	VARIANT:=polarssl
	DEPENDS:=+libpolarssl +libpcre +libpthread +dnsmasq-full +ipset +iptables
endef

define Package/shadowsocksr-libev-server
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (OpenSSL)
	VARIANT:=openssl
	DEPENDS:=+libopenssl +libpcre +libpthread
endef

define Package/shadowsocksr-libev-server-polarssl
	$(call Package/shadowsocksr-libev/Default)
	TITLE+= (PolarSSL)
	VARIANT:=polarssl
	DEPENDS:=+libpolarssl +libpcre +libpthread
endef

define Package/shadowsocksr-libev/description
ShadowsocksR-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocksr-libev-polarssl/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-gfwlist/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-gfwlist-polarssl/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-gfwlist-4M/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-server/description=$(Package/shadowsocksr-libev/description)
Package/shadowsocksr-libev-server-polarssl/description=$(Package/shadowsocksr-libev/description)

define Package/shadowsocksr-libev/conffiles
/etc/shadowsocksr.json
endef

Package/shadowsocksr-libev-polarssl/conffiles = $(Package/shadowsocksr-libev/conffiles)

define Package/shadowsocksr-libev-gfwlist/conffiles
/etc/shadowsocksr.json
/etc/dnsmasq.d/custom_list.conf
endef

Package/shadowsocksr-libev-gfwlist-polarssl/conffiles = $(Package/shadowsocksr-libev-gfwlist/conffiles)
Package/shadowsocksr-libev-gfwlist-4M/conffiles = $(Package/shadowsocksr-libev-gfwlist/conffiles)

define Package/shadowsocksr-libev-server/conffiles
/etc/shadowsocksr-server.json
endef

Package/shadowsocksr-libev-server-polarssl/conffiles = $(Package/shadowsocksr-libev-server/conffiles)

define Package/shadowsocksr-libev-gfwlist/postinst
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

define Package/shadowsocks-libev-gfwlist/postrm
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

Package/shadowsocksr-libev-gfwlist-polarssl/postinst = $(Package/shadowsocksr-libev-gfwlist/postinst)
Package/shadowsocksr-libev-gfwlist-polarssl/postrm = $(Package/shadowsocksr-libev-gfwlist/postrm)
Package/shadowsocksr-libev-gfwlist-4M/postinst = $(Package/shadowsocksr-libev-gfwlist/postinst)
Package/shadowsocksr-libev-gfwlist-4M/postrm = $(Package/shadowsocksr-libev-gfwlist/postrm)

CONFIGURE_ARGS += --disable-ssp

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocksr-libev/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocksr.init $(1)/etc/init.d/shadowsocksr
	$(INSTALL_CONF) ./files/shadowsocksr.json $(1)/etc/shadowsocksr.json
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel
endef

Package/shadowsocksr-libev-polarssl/install=$(Package/shadowsocksr-libev/install)

define Package/shadowsocksr-libev-gfwlist/install
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

Package/shadowsocksr-libev-gfwlist-polarssl/install = $(Package/shadowsocksr-libev-gfwlist/install)
Package/shadowsocksr-libev-gfwlist-4M/install = $(Package/shadowsocksr-libev-gfwlist/install)

define Package/shadowsocksr-libev-server/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/shadowsocksr-server.json $(1)/etc/shadowsocksr-server.json
	$(INSTALL_BIN) ./files/shadowsocksr-server.init $(1)/etc/init.d/shadowsocksr-server
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-server $(1)/usr/bin/ssr-server
endef

Package/shadowsocksr-libev-server-polarssl/install=$(Package/shadowsocksr-libev-server/install)

$(eval $(call BuildPackage,shadowsocksr-libev))
$(eval $(call BuildPackage,shadowsocksr-libev-polarssl))
$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist))
$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist-polarssl))
$(eval $(call BuildPackage,shadowsocksr-libev-gfwlist-4M))
$(eval $(call BuildPackage,shadowsocksr-libev-server))
$(eval $(call BuildPackage,shadowsocksr-libev-server-polarssl))
