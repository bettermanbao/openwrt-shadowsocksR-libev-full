ShadowsocksR-libev-full for OpenWrt  
===

简介  
---

 本项目是 [ShadowsocksR-libev][1] 在 OpenWrt 上的移植。   
 当前版本: v20170907  
 
 v20170907 更新:  
 > 修正 shadowsocksr-libev 源地址  
 > 支持加密协议 "none"  
 > 支持混淆协议(Protocol) "auth_chain_a"  
 > 支持混淆方式(Obfs) "tls1.2_ticket_auth"  
 
 [预编译 LEDE ipk 下载][R]


特性  
---

 - shadowsocksR-libev

   > 官方原版客户端  
   
   > 可执行文件 `ssr-{local,redir}`  
   > 默认启动:  
   > `ssr-local` 提供 SOCKS 代理  
   
 - shadowsocksR-libev-gfwlist

   > 集成GFWList的一键安装包，含Luci界面。  
   
   > 可执行文件 `ssr-redir`  
   > 默认启动:  
   > `ssr-redir` 提供透明代理  
   > 依赖[DNS-Forwarder][D]进行DNS-TCP转发。  
   
   > 使用opkg安装ipk包时，必须带上--force-overwrite参数！  
   

编译  
---

 - 从 lede 的 [SDK][S] 编译
 
```bash
   
   # 以 ubuntu 14.04 x86_64 为例
   apt-get update
   apt-get install software-properties-common xz-utils build-essential ccache git libncurses5-dev libncursesw5-dev gawk
   
   # ubuntu 14.04 以后的版本不需要这一步
   add-apt-repository ppa:ubuntu-toolchain-r/test
   apt-get update
   apt-get install libstdc++6-4.7-dev libstdc++6
   
   # 下载lede-SDK，以ramips为例
   wget https://downloads.lede-project.org/releases/17.01.2/targets/ramips/mt7620/lede-sdk-17.01.2-ramips-mt7620_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz
   tar xf lede-sdk-17.01.2-ramips-mt7620_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz
   cd lede-sdk-*
   
   # 一些杂七杂八的坑
   ./scripts/feeds update base
   ./scripts/feeds update packages
   ./scripts/feeds install libpcre libopenssl libopenssl libmbedtls
   wget -P package/feeds/base/mbedtls/patches https://github.com/bettermanbao/lede/raw/lede-17.01.2/package/libs/mbedtls/patches/999-tweak-config-for-shadowsocks.patch
   
   # git clone openwrt-shadowsocksR-libev-full
   git clone -b master https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full.git package/shadowsocksR-libev-full
   
   # 选择要编译的包 Network -> shadowsocksr-libev
   make menuconfig
   
   # 开始编译
   make package/shadowsocksR-libev-full/compile V=s
   
   ```

配置  
---

 - shadowsocks-libev 配置文件: `/etc/shadowsocksr.json`

截图  
---

![luci000](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci%20000.png)
![luci001](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci%20001.png)
![luci002](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci%20002.png)
![luci003](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci%20003.png)

感谢  
---

Makefile参考  [openwrt-shadowsocks][E]

----------

  [O]: https://github.com/bettermanbao/openwrt-shadowsocks-libev-full
  [1]: https://github.com/breakwa11/shadowsocks-libev
  [R]: https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/releases
  [S]: https://lede-project.org/docs/guide-developer/compile_packages_for_lede_with_the_sdk
  [E]: https://github.com/shadowsocks/openwrt-shadowsocks
  [D]: https://github.com/aa65535/openwrt-dns-forwarder
  
