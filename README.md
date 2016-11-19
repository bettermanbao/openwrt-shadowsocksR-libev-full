ShadowsocksR-libev-full for OpenWrt  
===

简介  
---

 本项目是 [ShadowsocksR-libev][1] 在 OpenWrt 上的完整移植，包括客户端和服务器端。   
 当前版本: 2.5.6-1  
 
 [预编译 OpenWrt Chaos Calmer ipk 下载][R]

 *** [详细介绍点这里][X] ***
 
特性  
---

可编译 两种客户端版本 和 一种服务器端版本。

 - shadowsocksR-libev

   > 官方原版客户端  
   
   > 可执行文件 `ssr-{local,redir,tunnel}`  
   > 默认启动:  
   > `ssr-local` 提供 SOCKS 代理  

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

 - shadowsocksR-libev-server

   > 官方原版服务器端  
   > 目前仅支持Shadowsocks原版协议
   
   > 可执行文件 `ssr-server`  
   > 默认启动:  
   > `ssr-server` 提供 shadowsocks 服务  

编译  
---

 - 从 OpenWrt 的 [SDK][S] 编译

   ```bash
   # 以 OpenWrt Chaos Calmer 15.05 ar71xx 平台为例
   wget https://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/generic/OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   tar xjf OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   cd OpenWrt-SDK-15.05-ar71xx-*
   # 获取 Makefile
   git clone https://github.com/chenhw2/openwrt-shadowsocksR-libev-full.git package/shadowsocksR-libev-full
   # 选择要编译的包 Network -> shadowsocksr-libev
   make menuconfig
   # 开始编译
   make package/shadowsocksR-libev-full/compile V=s
   ```

配置  
---

 - shadowsocks-libev 配置文件: `/etc/shadowsocksr.json`

 - shadowsocks-libev-gfwlist 配置文件: `/etc/shadowsocksr.json.main /etc/shadowsocksr.json.backup`

 - shadowsocks-libev-server 配置文件: `/etc/shadowsocksr-server.json`

截图  
---

![luci000](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci000.png)
![luci001](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci001.png)
![luci002](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci002.png)
![luci003](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci003.png)
![luci004](https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/blob/master/snapshot/luci004.png)

----------

  [O]: https://github.com/chenhw2/openwrt-shadowsocks-libev-full
  [1]: https://github.com/breakwa11/shadowsocks-libev
  [R]: https://github.com/chenhw2/openwrt-shadowsocksR-libev-full/releases
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
  [X]: http://www.right.com.cn/forum/thread-185635-1-1.html
