---
title: "华硕天选5Pro折腾Arch+Win11双系统"
categories:
    - Blog
tags:
    - auth
    - .net
img_path: "/assets/posts/2023-12-14-identity-server-sample"
---

本文会持续更新，供有和我一样情况的朋友参考。很多地方一笔带过，如果有需要请反馈，我会补充细节

给了一万预算买笔记本，选华硕最重要的原因大概是看见官方有个单独的Linux页面，显得很重视的样子，而Archwiki的Laptop Category下ASUS也有最长的篇幅介绍

买的是13代i9+4060的版本（最理想的是A卡+4070但买的时候没货）

## 目前状态

**概述**： 集显模式正常工作

第一次用这种带独显的笔记本，之前在一个只有集显的荣耀Magicbook上面用了几年的Arch没出过问题。当前目标是能用，先保证集成显卡模式正常，屏蔽独显，后续再研究混合输出模式

| 部位       | 状态      | 配置                                       | 其他                                             |
|:-----------|:----------|:-------------------------------------------|:-------------------------------------------------|
| 集显       | 正常      |                                            |                                                  |
| 独显/混合  | -         | 待后续研究                                 |                                                  |
| 声音       | 正常      | 装好ALSA后未进行任何配置                   | ASUS好评！之前用的荣耀笔记本折腾了很久的声卡配置 |
| 触摸板     | 正常      | 默认是按下单击，轻敲点按需要改libinput配置 |                                                  |
| 键盘灯/LED | 正常      | 通过asusctl控制                            |                                                  |
| 话筒       | -         | 待测试                                     |                                                  |
| 关闭盖子   | x  起不来 |                                            |                                                  |
| 电源休眠   | -         |                                            |                                                  |


按坊间惯例先screenfetch：

```
                   -`                    qk@ringo
                  .o+`                   --------
                 `ooo/                   OS: Arch Linux x86_64
                `+oooo:                  Host: ASUS TUF Gaming F16 FX607JV_FX607JV
               `+oooooo:                 Kernel: 6.7.6-arch1-1
               -+oooooo+:                Uptime: 13 mins
             `/:-:++oooo+:               Packages: 776 (pacman)
            `/++++/+++++++:              Shell: zsh 5.9
           `/++++++++++++++:             Resolution: 2560x1600
          `/+++ooooooooooooo/`           WM: i3
         ./ooosssso++osssssso+`          Theme: Adwaita [GTK3]
        .oossssso-````/ossssss+`         Icons: Adwaita [GTK3]
       -osssssso.      :ssssssso.        Terminal: tmux
      :osssssss/        osssso+++.       CPU: 13th Gen Intel i9-13980HX (32) @ 5.40
     /ossssssss/        +ssssooo/-       GPU: Intel Raptor Lake-S UHD Graphics
   `/ossssso+/:-        -:/+osssso+-     Memory: 1218MiB / 15609MiB
  `+sso+:-`                 `.-/+oso:
 `++:.                           `-/+/
 .`                                 `/
```

## 待解决问题

- 合上盖子后无法恢复，键盘闪烁绿光，任何按键无反应，只能按电源关闭
- 给asusctl搞个配置
- 开机提示Warning root未以RO模式挂载，但实际使用未发现影响
- 因为EFI分区过小，intel ucode装不上
    - XXX：是否可以把vmlinuz-fallback文件删掉给ucode腾位置？
- 息屏 / 休眠


## 安装过程

大体直接按照官方文档，以下是需要特别注意的

### EFI分区

这里犯了个错误是提前把Win11折腾好（比如多个软件的配置、几百个G的Steam库），不想再重装

Archwiki中提到，两个盘上都存在EFI分区会影响Win工作，我几年前在台式机上这么做过好像并未出过问题，但笔记本要工作用，保险起见就只保留一个EFI分区

但TUF原装的Win11系统的efi分区只有260M这么大，不想重装Win的话，系统引导就只有两种方案可选：

1. 用refind等比较精简的bootloader，因为grub装不下，后续也不考虑在boot分区进行其他动作
2. 废弃盘A的EFI分区，在盘B重建EFI分区，重建Win11引导，再安装多系统引导

当然选1

如果你不介意重装Win，那么建议直接把盘A的EFI分区大一点（Archwiki建议1G），这样后续搞各种扩展都方便

XXX: 盘符变动

### 桌面环境

我这次没什么耐心，装的很快，甚至没有打开维基百科找一下显卡对应的编码，就直接装了最新的官方驱动


## supergfxctl

supergfxctl是asusctl推荐的方式，因此不再考虑optimus manager

屏蔽独显配置为：

```json
{
  "mode": "Integrated",
  "vfio_enable": false,
  "vfio_save": false,
  "always_reboot": false,
  "no_logind": false,
  "logout_timeout_s": 180,
  "hotplug_type": "None"
}
```

> 待研究： Use super gfxctl for GPU passthrough

## 已解决问题

supergfxctl配置模式为Integrated后修复：
- GPU渲染不正常，以下应用卡死：alacritty / chrome / rog center

