ShadowsocksR-libev-full for OpenWrt  
===

简介  
---

 本项目是 [ShadowsocksR-libev][1] 在 OpenWrt 上的完整移植，包括客户端和服务器端。   
 当前版本: 2.5.6 (SSR:2670ab2)
 
 [预编译 OpenWrt Chaos Calmer ipk 下载][R]

 *** [详细介绍点这里][X] ***
 
特性  
---

 - shadowsocksR-libev-gfwlist

   > 集成 GFW List 的一键安装版客户端，安装后只要在luci界面填入服务器信息就能直接使用。  
   > 此版本已预置测试用的shadowsocks服务器，建议安装后直接访问 www.google.com.hk 检测配置是否成功。  
   
   > 可执行文件 `ssr-{redir,tunnel,watchdog}`  
   > 默认启动:  
   > `ssr-redir` 提供透明代理  
   > `ssr-tunnel` 提供 UDP 转发, 用于 DNS 查询。  
   > `ssr-watchdog` 守护进程，在主服务器不可用时自动切换到备用服务器。
   
   > 安装方法：  
     >> shadowsocksr-libev-gfwlist 使用openssl加密库 完整安装需要约 5.0M 空间  
     >> shadowsocksr-libev-gfwlist-polarssl 使用polarssl加密库 完整安装需要约 3.5M 空间  
     >> 以上两个包只要选一个安装，强烈建议在原版openwrt固件上安装。  
     >> 用 winscp 把对应平台的 shadowsocksr-libev-gfwlist 的ipk文件上传到路由器 /tmp 目录  
     >> 带上--force-overwrite 选项运行 opkg install  
     >> ```bash  
     >> opkg update
     >> opkg --force-overwrite install /tmp/shadowsocksr-libev-gfwlist*.ipk  
     >> ```  
     >> 安装结束时会提示一条错误信息，这是升级dnsmasq-full时的配置文件残留造成的，可以忽略。  

编译  
---

 - 从 OpenWrt 的 [SDK][S] 编译

   ```bash
   # 以 ar71xx 平台为例
   tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
   cd OpenWrt-SDK-ar71xx-*
   # 安装 feeds
   # 如果是 uClibc SDK (15.05.1 及以下)
    git clone https://github.com/aa65535/openwrt-feeds.git package/feeds
   # 如果是 musl SDK (trunk 或 LEDE)
    ./scripts/feeds update base packages
    ./scripts/feeds install zlib libopenssl libpolarssl libmbedtls libpcre
    rm -rf package/feeds/base/mbedtls/patches
   # 获取 shadowsocks-libev Makefile
   git clone https://github.com/chenhw2/openwrt-shadowsocksR-libev-full.git package/feeds/shadowsocksr-gfwlist
   # 选择要编译的包 Network -> shadowsocksr-gfwlist*
   make menuconfig
   # 开始编译
   make package/feeds/shadowsocksr-gfwlist/compile V=s
   ```

配置  
---

 - shadowsocks-libev-gfwlist 配置文件: `/etc/shadowsocksr.json.main /etc/shadowsocksr.json.backup`

 - 软件包本身并不包含配置文件, 配置文件内容为 JSON 格式, 支持的键:  

   键名           | 数据类型   | 说明
   ---------------|------------|-----------------------------------------------
   server         | 字符串     | 服务器地址, 可以是 IP 或者域名
   server_port    | 数值       | 服务器端口号, 小于 65535
   local_address  | 字符串     | 本地绑定的 IP 地址, 默认 127.0.0.1
   local_port     | 数值       | 本地绑定的端口号, 小于 65535
   password       | 字符串     | 服务端设置的密码
   method         | 字符串     | 加密方式, [详情参考][E]
   timeout        | 数值       | 超时时间（秒）, 默认 60
   fast_open      | 布尔值     | 是否启用 [TCP-Fast-Open][F], 只适用于 ss-local
   nofile         | 数值       | 设置 Linux ulimit
   protocol       | 协议插件   | 客户端的协议插件，推荐使用[auth_sha1_v4, auth_aes128_md5, auth_aes128_sha1][P]
   obfs           | 混淆插件   | 客户端的混淆插件，推荐使用[plain, http_simple, http_post, tls1.2_ticket_auth][P]


截图  
---
![make](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/make.png)
![luci000](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci000.png)
![luci001](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci001.png)
![luci002](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci002.png)
![luci003](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci003.png)
![luci004](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci004.png)

----------

  [O]: https://github.com/chenhw2/openwrt-shadowsocks-libev-full
  [1]: https://github.com/shadowsocksr/shadowsocksr-libev
  [R]: https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/releases
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
  [X]: http://www.right.com.cn/forum/thread-185635-1-1.html
  [P]: https://github.com/breakwa11/shadowsocks-rss/wiki/obfs
