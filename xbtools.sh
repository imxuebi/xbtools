#!/usr/bin/env bash
#####
Y="\e[33m"
G="\e[32m"
R="\e[31m"
E="\e[0m"
#####
if [ ! $(command -v apt) ] ;then
      sleep 0.1
	else mr_update="apt update"
	ainstall="apt install"
	yes=" -y"
fi
if [ ! $(command -v pacman) ];then
      sleep 0.1
      else mr_update="pacman -Syy"
      ainstall="pacman -Sy"
      yes=""
fi
#####
#系统源更新
date_t=`date +"%D"`
if ! grep -q $date_t ".date_tmp.log" 2>/dev/null; then
        echo -e "\n\e[33m系统源环境自检更新...\e[0m"
   $mr_update
        echo $date_t >>.date_tmp.log 2>&1
fi
######
VER="xbt_ver_0.3.0"
######
#软件安装
app_install(){
SA=$(uname -m)
SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
input=$(whiptail --title "App Install Menu" --menu "软件安装/管理(beta)，需要先安装图形界面" 20 50 9 \
	"1" "wine" \
	"2" "QQ" \
	"3" "图形界面" \
	"4" "vnc服务" \
	"0" "返回"  3>&1 1>&2 2>&3)
case $input in
   1)if [ $SYS_V = Arch ];then
	whiptail --title "Error " --msgbox "暂不支持Arch安装wine！\n请等待更新！ " 20 50
	app_install
	exit
   fi
   if [ ! $(command -v neofetch) ]; then
	   apt install neofetch -y;
   fi
   apt install wget
   case $SA in
	   x86_64)apt-get update
		apt-get install wineecho "安装完成，输入winecfg启动wine" 
		sleep 3
		app_install ;;
	aarch64)apt install neofetch -y
		if neofetch | grep -q proot ;then
		if [ ! $(command -v lsb_release) ]; then
			apt install lsb-release -y;
		fi
		case $(cat /etc/os-release | grep VERSION_CODENAME | gawk -F '=' '{print $2}') in
			bullseye)sleep 0.1 ;;
			impish)sleep 0.1 ;;
			*)echo "不支持您的系统版本，是否继续，可在termux环境使用本脚本，安装Ubuntu 21.10的proot容器"                     read -r -p "是否继续操作?
				1)继续
				2)停止
			        请选择：" input
				case $input in
					1)sleep0.1 ;;
					*)app_install ;;
				esac ;;
		esac
		echo "检测完成，继续安装"
		dpkg --add-architecture armhf
		apt update
		apt install zenity:armhf libasound*:armhf libstdc++6:armhf mesa*:armhf -y
		down_wine_deb(){
			wget https://shell.xb6868.com/wine/box86-and-box64-proot-wine3.0-arm64.deb
		if [ -f "box86-and-box64-proot-wine3.0-arm64.deb" ];then
		echo "下载完成"
		else echo "出错，尝试重新下载"
		down_wine_deb
		fi
		}
	        down_wine_deb
	        dpkg -i box86-and-box64-proot-wine3.0-arm64.deb
	        echo "完成"
	  else
		dpkg --add-architecture armhf
	        echo "即将开始安装，本脚本只支持debian-bullseye Ubuntu-impish"
		echo -e "按${G}回车键${E}继续"
		read enter
		apt update
		apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf -y
		if [ ! $(command -v zenity) ]; then
		apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf -y
		fi
		apt install cmake build-essential -y
		apt install git -y
		git_box86(){
		git clone https://github.com/ptitSeb/box86
		}
		git_box86
		if [ -d "box86/" ];then
			echo "下载完成"
		else git_box86
		fi
		cd box86
		mkdir build
		cd build
		cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
		make -j$(nproc); make install
		cd
		git_box64(){
		git clone https://github.com/ptitSeb/box64
		}
		git_box64
		if [ -d "box64/" ];then
			echo "下载完成"
		else git_box64
		fi
		cd box64
		mkdir build
		cd build
		cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
		make -j$(nproc); make install
		cd
		wget https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-amd64/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz
		tar zxvf PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz -C /usr
		echo -e "${G}安装完成，输入box64 wine64 task mgr启动wine${E}"
		echo -e "按${G}回车键${E}继续"
		read enter
		fi ;;
	esac ;;
       2)case $SYS_V in
	       Debian | Ubuntu)case $SA in
		     x86_64)apt install libgtk2.0-0 wget -y
             wget https://down.qq.com/qqweb/LinuxQQ/linuxqq_2.0.0-b2-1089_amd64.deb
             dpkg -i linuxqq_2.0.0-b2-1089_amd64.deb
             echo "安装完成"
             app_install ;;
           aarch64)apt install libgtk2.0-0 wget -y
             wget https://down.qq.com/qqweb/LinuxQQ/linuxqq_2.0.0-b2-1089_arm64.deb
             dpkg -i linuxqq_2.0.0-b2-1089_arm64.deb
             echo "安装完成"
             app_install ;;
			 esac ;;
		   Arch)case $SA in
		     x86_64)pacman -Sy wget
			 wget https://down.qq.com/qqweb/LinuxQQ/linuxqq_2.0.0-b2-1089_x86_64.pkg.tar.xz
			 pacman -U linuxqq_1.0.1-ci-94_x86_64.pkg.tar.xz
			 echo "安装完成"
			 sleep 1
			 app_install ;;
			 aarch64)pacman -Sy wget
			 if (whiptail --title "提示" --yesno "aarch64QQ仅支持第三方electron icalingua版本\n是否继续?" 10 60) then
		if [ ! $(command -v electron17) ]; then
			 wget https://shell.xb6868.com/electron/electron17-bin-17.4.1-1-aarch64.pkg.tar.xz
			 pacman -U electron17-bin-17.4.1-1-aarch64.pkg.tar.xz
		fi
			 wget https://shell.xb6868.com/electron/icalingua++-2.6.1-2-aarch64.pkg.tar.xz
			 pacman -U icalingua++-2.6.1-2-aarch64.pkg.tar.xz
			 sed -i 's/icalingua %u/icalingua --no-sandbox %u/g' /usr/share/applications/icalingua.desktop
		 else
			 app_install
			 fi ;;
			 esac;;
		esac;;
	3)case $SYS_V in
		Ubuntu | Debian)
		input=$(whiptail --title "Xbtool Menu" --menu "选择一个图形安装" 20 50 9 \
			"1" "xfce4" \
			"2" "lxde"  3>&1 1>&2 2>&3)
		case $input in
			1)apt install xfce4 xfce4-terminal ristretto dbus-x11 lxtask -y
			  sleep 3
			  echo "安装完成，如出错请重试" ;;
			2)apt install lxde-core lxterminal dbus-x11 -y
			 sleep 3
			 echo "安装完成，如出错请重试" ;;
	         esac ;;
	 Arch)if (whiptail --title "温馨提示" --yes-button "继续" --no-button "取消"  --yesno "arch桌面目前只支持xfce，是否继续？" 10 60) then
		 pacman -Syu xfce4 xfce4-goodies lxtask wqy-zenhei
	     else app_install
	       fi ;;
          esac ;;
        4)echo "本程序默认安装tigervnc"
	echo "正在检测您的系统..."
	sleep 5
	case $SYS_V in
		Ubuntu | Debian)apt install tigervnc-standalone-server tigervnc-viewer pulseaudio -y
			echo "export PULSE_SERVER=127.0.0.1
			pulseaudio --start
			tigervncserver :1" >>/usr/local/bin/start-vnc
			chmod 777 /usr/local/bin/start-vnc
			echo -e "${Y}配置完成，输入start-vnc启动vnc${E}"
			sleep 5 ;;
		Arch)pacman -Sy tigervnc pulseaudio
		     cat >/usr/local/bin/start-vnc <<-'eof'
		     echo -e "\e[33mvnc已启动，地址:127.0.0.1:1,输入ctrl+c关闭vnc\e[0m"
		     export PULSE_SERVER=127.0.0.1 >/dev/null 2>&1
		     pulseaudio --start >/dev/null 2>&1
		     vncserver :1 >/dev/null 2>&1

			eof
		     ;;
     esac ;;
esac
}
######
#脚本下载
down_sh(){
	if [ ! $(command -v wget) ]; then
	  $ainstall wget$yes;
	fi
	if [ -f "xbtools.sh" ];then
         ONLINE_VER=`curl https://shell.xb6868.com/ver/ | grep xbt | awk -F '"' '{print $2}'`
	if [ "${ONLINE_VER}" = "${VER}" ]; then
	   echo "无需更新"
	   else echo "脚本需要更新"
	if (whiptail --title "脚本需要更新" --yesno "是否更新脚本" 10 60) then
	rm -rf xbtools.sh
	wget https://shell.xb6868.com/xbtools.sh
	chmod 777 xbtools.sh
	  else
	exit
	fi
	fi
	else
	 wget https://shell.xb6868.com/xbtools.sh
	 chmod 777 xbtools.sh
	 echo "下载完成"
	fi
}
######
more_shell(){
	if [ ! $(command -v curl) ]; then
		$ainstall curl$yes;
	fi
	input=$(whiptail --title "更多脚本" --menu "" 15 60 4 \
		"1" "ytitool工具 finish" \
		"2" "utqemu 海叔" \
		"3" "termux-toolx 海叔" 3>&1 1>&2 2>&3)
   case $input in
     1)if [ ! $(command -v git) ]; then
       $ainstall git$yes;
       fi
       bash -c "$(curl https://gitee.com/yudezeng/yutools/raw/master/yti)"
       exit ;;
     2)bash -c "$(curl https://shell.xb6868.com/ut/utqemu.sh)"
       exit ;;
     3)bash -c "$(curl https://shell.xb6868.com/ut/termux-toolx.sh)"
       exit ;;
esac
}
######
#更新qemu
qbox_qemu_update(){
echo "您的QEMU版本为："
if [ $(command -v qemu-system-i386) ]; then
  qemu-system-i386 --version
  sleep 1.5
  echo "您的QEMU版本为："
  QEMU_V_C="5"
  QEMU_V_U=$(qemu-system-i386 --version | awk '/version/' | awk -F '.'  '{print $1}' | awk '{print $4}')
if [ $QEMU_V_U -gt $QEMU_V_C ]
  then echo "您已更新到6.0及以上版本，无需更新"
  qbox_begin
fi
if [ $(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}') = Arch ];then
  echo -e "${R}不支持的系统${E}"
  sleep 3
  qbox_begin
fi
if (whiptail --title "是否更新" --yesno "是否尝试更新qemu至qemu6.2" 10 60) then
  input="1"
else
  input="2"
fi
case $input in
  1)apt install lsb-release -y
	if lsb_release -a | grep -q bullseye;
	then echo "系统版本兼容检测已通过"
	else echo "暂不支持您的系统"
	exit
	fi
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free" >/etc/apt/sources.list
	apt update
	apt upgrade
	echo "更新完成，可能会出错哦" ;;
	2)echo "取消" ;;
esac
elif [ $(command -v qemu-system-i386-3.1) ]; then
	qemu-system-i386-3.1 --version
	echo "此版本不支持更新"
	sleep 1.5
else echo "未检测到qemu"
	exit
fi
}
######
#镜像工具
qbox_img_tool(){
zhuanhuan_img(){
echo "选择转换方式"
read -r -p "1)vmdk→qcow2 2)qcow2→raw 
请选择：" input
case $input in
 1)echo "输入原镜像路径"
   read ZHUANHUAN_OLD
   echo "输入转换后你想保存的路径(包含文件名)"
   read ZHUANHUAN_NEW
   qemu-img convert -f vmdk -O qcow2 ${ZHUANHUAN_OLD} ${ZHUANHUAN_NEW} ;;
 2)echo "输入原镜像路径"
   read ZHUANHUAN_OLD
   echo "输入转换后你想保存的路径(包含文件名)"
   read ZHUANHUAN_NEW
   qemu-img convert -f qcow2 -O raw ${ZHUANHUAN_OLD} ${ZHUANHUAN_NEW} ;;
esac
}
chuangjian_img(){
echo "请选择您要创建的格式"
read -r -p "1)raw 2)qcow2" input
case $input in
 1)echo "请输入你镜像要生成到的路径(要包含文件名！)"
   read PATH_IMG_A
   echo "生成大小？单位G，只输入数字"
   read IMG_SIZE
   qemu-img create -f raw ${PATH_IMG_A} ${IMG_SIZE}G
   qbox_img_tool ;;
 2)echo "请输入你镜像要生成到的路径(要包含文件名！)"
   read PATH_IMG_B
   echo "生成大小？单位G，只输入数字"
   read IMG_SIZE_B
   qemu-img create -f qcow2 ${PATH_IMG_B} ${IMG_SIZE_B}G
   qbox_img_tool ;;
esac
}
yasuo_img(){
   echo "仅支持qcow2的镜像"
   echo "请输入原镜像路径"
   read OLD_PATH
   echo "请输入压缩后文件路径(要包含文件名)"
   read NEW_PATH
   echo "压缩时间较长，请耐心等待"
   qemu-img convert -c -p -f qcow2 ${OLD_PATH} -O qcow2 ${NEW_PATH}
   qbox_img_tool
}
input=$(whiptail --title "Qbox Img Tool Menu" --menu "" 20 50 9 \
	"1" "创建空磁盘/镜像" \
	"2" "压缩镜像" \
	"3" "转换镜像格式" \
	"4" "返回"  3>&1 1>&2 2>&3)
case $input in
  1)chuangjian_img ;;
  2)yasuo_img ;;
  3)zhuanhuan_img ;;
esac
}
######
#proot安装 带qemu

termux_install_proot_qbox(){
if cat xbtool.config | grep -q qbox_model=easy; then
	wget --no-check-certificate https://down.xb6868.com/xuebi/%E9%95%9C%E5%83%8F/proot/bullseye-qbox.tar.gz -O bullseye-qbox.tar.gz
	tar -xvf bullseye-qbox.tar.gz
	touch bullseye-qbox/root/xbtool.config
	echo "qbox_model=easy
	start_system_qbox=true" >> bullseye-qbox/root/xbtool.config
	echo 'bash -c "$(curl https://shell.xb6868.com/xbtools.sh)"' >> bullseye-qbox/etc/profile
else
	apt install curl -y
	VERSION=`curl https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
	curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/debian/bullseye/arm64/default/${VERSION}rootfs.tar.xz
	mkdir bullseye-qbox
	tar xvf rootfs.tar.xz -C bullseye-qbox
	rm -rf rootfs.tar.xz
	echo $(uname -a) | sed 's/Android/GNU\/Linux/' >bullseye-qbox/proc/version
  	if ![ -f "bullseye/usr/bin/perl" ]; then
    	cp bullseye-qbox/usr/bin/perl* bullseye-qbox/usr/bin/perl
  	fi
	sed -i "1i\export TZ='Asia/Shanghai'" bullseye-qbox/etc/profile
	sed -i "3i\rm -rf \/tmp\/.X\*" bullseye-qbox/etc/profile
	sed -i "/zh_CN.UTF/s/#//" bullseye-qbox/etc/locale.gen
	rm bullseye-qbox/etc/resolv.conf 2>/dev/null
	echo "nameserver 223.5.5.5
	nameserver 223.6.6.6" >bullseye-qbox/etc/resolv.conf
	echo 'deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free
		deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free
		deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free
		#deb http://mirrors.ustc.edu.cn/debian-security/ bullseye/updates main contrib non-free
		deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib non-free' >bullseye-qbox/etc/apt/sources.list
	touch bullseye-qbox/root/run.sh
	touch bullseye-qbox/root/start.sh
	touch bullseye-qbox/root/xbtool.config
	cat > bullseye-qbox/root/start.sh <<-'eof'
	bash -c "$(curl https://shell.xb6868.com/xbtools.sh)"
	eof
	echo "qbox_model=common
	start_system_qbox=true" >> bullseye-qbox/root/xbtool.config
	cat > bullseye-qbox/root/run.sh <<-'eof'
		apt update
  		if ! grep -q https /etc/apt/sources.list; then
   			 apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update
  		fi
		apt install -y
		apt install pulseaudio -y
		apt install curl -y
		apt install wget -y
		if [ ! $(command -v wget) ]; then
			apt install wget -y
		fi
		if [ ! $(command -v curl) ]; then
			apt install curl -y
		fi
		if [ ! $(command -v pulseaudio) ]; then
			apt install pulseaudio -y
		fi
		sed -i 's/. run.sh/. start.sh/g' /etc/profile
		bash -c "$(curl https://shell.xb6868.com/xbtools.sh)"
	eof
	echo ". run.sh" >>bullseye-qbox/etc/profile
fi
}
######
#有tui启动qemu
qbox_start_qemu_tui(){
pulseaudio --start
export PULSE_SERVER=tcp:127.0.0.1
QEMU_SYSTEM=$(whiptail --title "Qemu启动" --menu "请选择您需要的架构" 15 60 4 \
"qemu-system-i386" " 适合32位系统" \
"qemu-system-x86_64" " 适合64位系统" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1 $input
else
    echo "You chose Cancel."
    exit
fi
input=$(whiptail --title "Qemu启动" --menu "请选择计算机类型" 15 60 4 \
"1" "pc" \
"2" "q35" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1 $input
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)MACHINE=" -machine pc" ;;
2)MACHINE=" -machine q35" ;;
esac

input=$(whiptail --title "Qemu启动" --menu "选择加速方式" 15 60 4 \
"1" "tcg加速" \
"2" "kvm加速"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1 $input
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)ACCEL=" --accel tcg,thread=multi" ;;
2)ACCEL=" --accel kvm" ;;
esac

FILE_IMG=$(whiptail --title "Qemu启动" --inputbox "请把镜像放在${PATH_IMGS}文件夹下
请输入imgs文件夹下系统镜像名字：
请输入：" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
    IMG=" -drive file="
else
    echo "You chose Cancel."
    exit
fi

CDROM_FILE=$(whiptail --title "Qemu启动" --inputbox "请把iso放在${PATH_IMGS}文件夹下
请输入imgs文件夹下系统iso名字：
如果不需要装iso，选择cancel即可
请输入：" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
    CDROM=" -cdrom"
    CDROM_FILE_B=" ${PATH_IMGS}"
else
    echo "You chose Cancel"
    CDROM=""
    CDROM_FILE_B=""
fi

input=$(whiptail --title "Qemu启动" --menu "选择磁盘类型" 15 60 4 \
"1" "ide(默认)" \
"2" "virtio" \
"3" "sata" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)IMG_LX=",if=ide,index=1,media=disk,aio=threads,cache=writeback" ;;
2)IMG_LX=",index=1,media=disk,if=virtio" ;;
3)IMG_LX=",if=none,id=disk1 -device ahci,id=SATA -device ide-hd,drive=disk1,bus=SATA.0" ;;
esac

input=$(whiptail --title "Qemu启动" --menu "请选择网卡" 15 60 4 \
"1" "rtl8139" \
"2" "e1000" \
"3" "virtio" \
"4" "不加载"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
else
    echo "You chose Cancel."
fi
case $input in
1)NETWORK_CARD=" -net user -net nic,model=rtl8139" ;;
2)NETWORK_CARD=" -net user -net nic,model=e1000" ;;
3)NETWORK_CARD=" -net user -net nic,model=virtio" ;;
4)NETWORK_CARD="" ;;
esac

input=$(whiptail --title "Qemu启动" --menu "请选择CPU" 15 60 4 \
"1" "core2duo" \
"2" "qemu32" \
"3" "qemu64" \
"4" "max 推荐"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1 $
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)CPU=" -cpu core2duo" ;;
2)CPU=" -cpu qemu32" ;;
3)CPU=" -cpu qemu64" ;;
4)CPU=" -cpu max,level=0xd,vendor=GenuineIntel" ;;
esac

CPUC=0
while [ $CPUC -eq 0 ]
do
input=$(whiptail --title "启动Qemu" --inputbox "请输入逻辑cpu参数，分别为核心、线程
、插槽个数，输入三位数字(例如2核1线2插槽,不能有0 则输212)" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo sleep 0.1
else
    echo "You chose Cancel."
    exit
fi
SMP="${input}"
        CORES=`echo $SMP | cut -b 1`
        THREADS=`echo $SMP | cut -b 2`
        SOCKETS=`echo $SMP | cut -b 3`
        let CPUC=$CORES*$THREADS*$SOCKETS 2>/dev/null
done

input=$(whiptail --title "Qemu启动" --menu "请选择显卡" 15 60 4 \
"1" "cirrus" \
"2" "vmware" \
"3" "vga" \
"4" "virtio"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)VGA=" -device cirrus-vga" ;;
2)VGA=" -device vmware-svga" ;;
3)VGA=" -device VGA" ;;
4)VGA=" -device virtio-vga" ;;
esac

input=$(whiptail --title "Qemu启动" --menu "请选择声卡" 15 60 4 \
"1" "sb16" \
"2" "hda" \
"3" "ac97" \
"4" "不加载"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1 $
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)SOUND_CARD=" -device sb16" ;;
2)SOUND_CARD=" -device hda" ;;
3)SOUND_CARD=" -device ac97" ;;
*)SOUND_CARD="" ;;
esac

input=$(whiptail --title "Qemu启动" --menu "请选择显示方式" 15 60 4 \
"1" "vnc显示" \
"2" "spice显示" \
"3" "图形界面显示"   3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    sleep 0.1
else
    echo "You chose Cancel."
    exit
fi
case $input in
1)echo "使用vnc软件链接127.0.0.1:0"
CONNECT=" -vnc :0  -machine usb=on -device usb-kbd -device usb-tablet" ;;
2)echo "使用spice软件链接127.0.0.1:5900"
CONNECT=" -spice port=5900,addr=127.0.0.1,disable-ticketing=on,seamless-migration=off" ;;
3)CONNECT="" ;;
esac

SHARE_FILE=$(whiptail --title "Qemu启动" --inputbox "输入您想要共享文件夹路径(不超过500m)\n如果不需要共享文件夹，请选择cancel" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    SHARE=" -hdd fat:rw:"
else
    echo "You chose Cancel."
    SHARE=""
    SHARE_FILE=""
fi

echo "${QEMU_SYSTEM}${MACHINE}${ACCEL}${IMG}${PATH_IMGS}${FILE_IMG}${IMG_LX}${CDROM}${CDROM_FILE_B}${CDROM_FILE}${NETWORK_CARD}${CPU} -smp ${CPUC}${VGA}${SOUND_CARD}${CONNECT}${SHARE}${SHARE_FILE}"
START="${QEMU_SYSTEM}${MACHINE}${ACCEL}${IMG}${PATH_IMGS}${FILE_IMG}${IMG_LX}${CDROM}${CDROM_FILE_B}${CDROM_FILE}${NETWORK_CARD}${CPU} -smp ${CPUC}${VGA}${SOUND_CARD}${CONNECT}${SHARE}${SHARE_FILE}"
#cat <<-EOF
$START
#EOF
exit
}
######
#简易QEMU
easy_qbox(){
input=$(whiptail --title "Easy Qbox Menu" --menu "     选择一项以启动win" 20 50 9 \
	"1" "启动windows xp" \
	"2" "切换普通模式"  3>&1 1>&2 2>&3)
case $input in
  1)if [ -f "xp.qcow2" ];then
    export PULSE_SERVER=tcp:127.0.0.1
    qemu-system-i386 -machine pc,vmport=off,dump-guest-core=off,mem-merge=off,kernel-irqchip=off,usb=on,hmat=off --accel tcg,thread=multi -device usb-tablet -nodefaults -no-user-config -no-hpet -no-fd-bootchk -msg timestamp=off -device VGA,vgamem_mb=256,global-vmstate=false,qemu-extended-regs=off,rombar=1 -device AC97 -rtc base=localtime -boot order=cd,menu=on,strict=off -cpu max,-hle,-rtm -smp 8,cores=8,threads=1,sockets=1 -m 1024 -mem-prealloc -device rtl8139,netdev=user0,mac=52:54:98:76:54:32 -netdev user,ipv6=off,id=user0 -drive file=xp.qcow2,if=ide,index=0,media=disk,aio=threads,cache=writeback -display vnc=127.0.0.1:0,lossy=on,non-adaptive=on
    echo -e"${Y}启动完成，打开vnc链接127.0.0.1:0${E}"
      else
    echo "文件不存在"
    wget --no-check-certificate https://down.xb6868.com/xuebi/%E9%95%9C%E5%83%8F/xp/xp.qcow2 -O xp.qcow2
    qemu-system-i386 -machine pc,vmport=off,dump-guest-core=off,mem-merge=off,kernel-irqchip=off,usb=on,hmat=off --accel tcg,thread=multi -device usb-tablet -nodefaults -no-user-config -no-hpet -no-fd-bootchk -msg timestamp=off -device VGA,vgamem_mb=256,global-vmstate=false,qemu-extended-regs=off,rombar=1 -device AC97 -rtc base=localtime -boot order=cd,menu=on,strict=off -cpu max,-hle,-rtm -smp 8,cores=8,threads=1,sockets=1 -m 1024 -mem-prealloc -device rtl8139,netdev=user0,mac=52:54:98:76:54:32 -netdev user,ipv6=off,id=user0 -drive file=xp.qcow2,if=ide,index=0,media=disk,aio=threads,cache=writeback -display vnc=127.0.0.1:0,lossy=on,non-adaptive=on
    echo -e"${Y}启动完成，打开vnc链接127.0.0.1:0${E}"
      fi
   easy_qbox ;;
  2)sed -i 's/qbox_model=easy/qbox_model=common/g' xbtool.config
    echo "设置完成"
    qbox_begin ;;
  *) exit ;;
esac
}
######
#没tui启动qemu
qbox_start_qemu(){
if [ -d "/data/data/com.termux" ];then
echo "您使用的是termux"
PATH_IMGS="/sdcard/imgs/"
else echo "您未使用termux，或系统检测错误"
read -r -p "请选择您使用的设备
1)电脑 2)安卓手机
请选择："
case $input in
1)PATH_IMGS="${HOME}/imgs/" ;;
2)PATH_IMGS="/sdcard/imgs/" ;;
esac
fi
if [ -d "${PATH_IMGS}" ];then
echo "检测文件夹是否存在"
else
echo "正在创建文件夹。。"
mkdir ${PATH_IMGS}
fi
if [ -d "${PATH_IMGS}" ];then
echo "done"
else "失败，请查看是否给予了存储权限"
exit
fi
QBOX_TUI_SUPPORT_VER="3"
QEMU_SUPPORT_VER=$(qemu-system-i386 --version | grep version | awk -F "." '{print $1}' | awk '{print $4}')
if [ $QEMU_SUPPORT_VER -gt $QBOX_TUI_SUPPORT_VER ]; then
if cat xbtool.config | grep -q xbtool_tui=true ;then
if (whiptail --title "温馨提示" --yes-button "使用有tui" --no-button "使用无tui"  --yesno "使用哪个版本？有tui还是无tui？\n区别：有tui操作更简便,但不支持qemu多版本 \n没tui操作较麻烦，但可自定义更多功能，且支持全版本，过老版本除外" 10 50) then
    qbox_start_qemu_tui
else
    sleep 0.1
fi
fi
fi
if [ $(command -v qemu-system-i386-3.1) ];
then 
echo "请选择您要使用的架构及qemu版本："
read -r -p "1) i386(qemu3.1版本)
2) x86_64(qemu3.1版本）
3) i386(qemu5.2版本)
4) x86_64(qemu5.2版本) 
请选择：" input
case $input in
1) QEMU_SYSTEM="/usr/bin/qemu-system-i386-3.1"
	SYS=OLD ;;
2) QEMU_SYSTEM="/usr/bin/qemu-system-x86_64-3.1"
	SYS=OLD ;;
3) QEMU_SYSTEM="/usr/local/bin/qemu-system-i386-5.2"
	SYS=NEW ;;
4) QEMU_SYSTEM="/usr/local/bin/qemu-system-x86_64-5.2"
	SYS=NEW ;;
esac
else
if qemu_ver=$(qemu-system-i386 --version)
	[[ $(echo $qemu_ver | grep version | awk -F "." '{print $1}' | awk '{print $4}') = [1-4] ]]; then
	SYS=OLD
else
	SYS=NEW
fi
echo "请选择您要使用的架构："
read -r -p "1) i386(适合32位架构 2) x86_64(适合64位架构）
请选择：" input
case $input in
1) QEMU_SYSTEM="/usr/bin/qemu-system-i386" ;;
*) QEMU_SYSTEM="/usr/bin/qemu-system-x86_64" ;;
esac
fi
echo "请选择计算机类型:"
read -r -p " 1)pc 2)q35
请选择：" input
case $input in
1) MACHINE="-machine pc" ;;
2) MACHINE="-machine q35" ;;
esac
echo "选择加速类型："
read -r -p "1)tcg 2)kvm
请选择：" input
case $input in
1) ACCEL="--accel tcg,thread=multi" ;;
2) ACCEL="--accel kvm" ;;
esac
echo "请把镜像放在${PATH_IMGS}文件夹下
请输入imgs文件夹下系统镜像名字：
请输入："
read PATH_1
echo "请选择您要的磁盘类型："
read -r -p "1)ide 2)virtio 3)sata 4)nvme
请选择：" input
case $input in
1)DISK_A="-drive file="
DISK_B=",if=ide,index=0,media=disk,aio=threads,cache=writeback" ;;
2)DISK_A="-drive file="
DISK_B=",index=0,media=disk,if=virtio" ;;
3)DISK_A="-drive file="
DISK_B=",if=none,id=disk0 -device ahci,id=SATA -device ide-hd,drive=disk0,bus=SATA.0" ;;
4)DISK_A="-drive file="
DISK_B=",if=none,id=disk0 -device nvme,serial=deadbeef,max_ioqpairs=64,msix_qsize=64,mdts=10,physical_block_size=2MB,drive=disk0" ;;
esac
moredisk_open(){
echo "已启用双硬盘"
echo "请把镜像放在${PATH_IMGS}文件夹下
输入您多磁盘的磁盘名字
请输入："
read PATH_2
PATH_A="${PATH_IMGS}"
echo "请选择您要的磁盘类型："
read -r -p "1)ide 2)virtio 3)sata 4)nvme
请选择：" input
case $input in
1)DISK_A_1=" -drive file="
DISK_B_1=",if=ide,index=1,media=disk,aio=threads,cache=writeback" ;;
2)DISK_A_1=" -drive file="
DISK_B_1=",index=1,media=disk,if=virtio" ;;
3)DISK_A_1=" -drive file="
DISK_B_1=",if=none,id=disk1 -device ahci,id=SATA -device ide-hd,drive=disk1,bus=SATA.0" ;;
4)DISK_A_1=" -drive file="
DISK_B_1=",if=none,id=disk1 -device nvme,serial=deadbeef,max_ioqpairs=64,msix_qsize=64,mdts=10,physical_block_size=2MB,drive=disk1" ;;
esac
}
moredisk_close(){
echo "双硬盘已禁用"
PATH_A=""
PATH_2=""
DISK_A_1=""
DISK_B_1=""
}
echo "启用双磁盘？"
read -r -p "1)开启 2)不开启
请选择：" input
case $input in
1)moredisk_open ;;
2)moredisk_close ;;
esac
morecdrom(){
echo "启用第二个cdrom？"
read -r -p "1)启用 2)不启用" input
case $input in
1)echo "请把iso放在${PATH_IMGS}文件夹下
请输入第二cdrom名字"
read MORECDROM_PATH_1
MORECDROM_PATH="${PATH_IMGS}"
MORECDROM_A=" -drive file="
MORECDROM_B=",index=3,media=cdrom" ;;
2)echo "已关闭多cdrom"
MORECDROM_PATH=""
MORECDROM_A=""
MORECDROM_B=""
MORECDROM_PATH_1="" ;;
esac
}
echo "启用cdrom？"
read -r -p "1)启用 2)不启用
请选择：" input
case $input in
1)DISK_CDROM=" -cdrom "
echo "请把iso放在${PATH_IMGS}文件夹下
请输入iso名："
read CDROM_PATH_1
CDROM_PATH="${PATH_IMGS}"
morecdrom ;;
2)DISK_CDROM=""
CDROM_PATH=""
CDRMO_PATH_1="" ;;
esac
echo "请选择您需要的网卡"
read -r -p "1)rtl8139 2)e1000 3)virtio 4)不加载
请选择： " input
case $input in
1)NETWORK_CARD=" -net user -net nic,model=rtl8139" ;;
2)NETWORK_CARD=" -net user -net nic,model=e1000" ;;
3)NETWORK_CARD=" -net user -net nic,model=virtio" ;;
4)NETWORK_CARD="" ;;
esac
echo "请选择您要的声卡"
read -r -p "1)sb16 2)hda 3)ac97 4)不加载
请选择：" input
case $SYS in
	OLD) 
case $input in
1)SOUND_CARD=" -soundhw sb16" ;;
2)SOUND_CARD=" -soundhw hda" ;;
3)SOUND_CARD=" -soundhw ac97" ;;
*)SOUND_CARD="" ;;
esac ;;
	NEW) 
case $input in
1)SOUND_CARD=" -device sb16" ;;
2)SOUND_CARD=" -device hda" ;;
3)SOUND_CARD=" -device ac97" ;;
*)SOUND_CARD="" ;;
esac ;;
esac
echo "输入需要的内存大小，仅输入数字即可，单位mb
请输入："
read ARM
echo "选择您需要的cpu"
read -r -p "1)core2duo 2)qemu32 3)qemu64 4)max(推荐)
请选择： " input
case $input in
1)CPU="-cpu core2duo" ;;
2)CPU="-cpu qemu32" ;;
3)CPU="-cpu qemu64" ;;
4)CPU="-cpu max,level=0xd,vendor=GenuineIntel" ;;
esac
echo "请选择显卡"
read -r -p "1)cirrus 2)vmware 3)vga 4)virtio
请选择："
case $input in
1)VGA="-device cirrus-vga" ;;
2)VGA="-device vmware-svga" ;;
3)VGA="-device VGA" ;;
4)VGA="-device virtio-vga" ;;
esac
cpuauto_open(){
HEXING="4"
XIANCHENG="2"
CACAO="1"
}
cpuauto_close(){
echo "请输入cpu核心数"
read HEXING
echo "请输入cpu线程数"
read XIANCHENG
echo "输入插槽数"
read CACAO
}
echo "自动配置还是手动配置cpu的，核心，线程，插槽？"
read -r -p "1)自动 2)手动
请选择：" input
case $input in
1)cpuauto_open ;;
2)cpuauto_close ;;
esac
echo "开启共享文件夹？"
read -r -p "1)开 2)不开
请选择：" input
case $input in
1)SHARE=" -hdd fat:rw:"
echo "输入共享文件夹路径，不能超过500mb"
read SHARE_PATH ;;
2)SHARE=""
SHARE_PATH="" ;;
esac
echo "连接方式？"
read -r -p "1)vnc 2)spice 3)图形界面下的qemu
请选择：" input
case $input in
1)echo "使用vnc软件链接127.0.0.1:0"
CONNECT=" -vnc :0" ;;
2)echo "使用spice软件链接127.0.0.1:5900"
CONNECT=" -spice port=5900,addr=127.0.0.1,disable-ticketing=on,seamless-migration=off" ;;
3)CONNECT="" ;;
esac
echo "鼠标跟随开启？"
read -r -p "1)开启 2)不开启
请选择：" input
case $input in
1)USB_MOUSE=" -machine usb=on -device usb-kbd -device usb-tablet" ;;
2)USB_MOUSE="" ;;
esac
echo "qemu即将启动"
echo "${QEMU_SYSTEM} ${MACHINE} ${ACCEL} ${DISK_A}${PATH_IMGS}${PATH_1}${DISK_B}${DISK_A_1}${PATH_A}${PATH_2}${DISK_B_1}${DISK_CDROM}${CDROM_PATH}${CDROM_PATH_1}${MORECDROM_A}${MORECDROM_PATH}${MORECDROM_PATH_1}${MORECDROM_B}${NETWORK_CARD}${SOUND_CARD} ${CPU} -smp $[$HEXING*$XIANCHENG*$CACAO],cores=${HEXING},threads=${XIANCHENG},sockets=${CACAO} ${VGA}${SHARE}${SHARE_PATH}${CONNECT}${USB_MOUSE}"
export PULSE_SERVER=tcp:127.0.0.1
START="${QEMU_SYSTEM} ${MACHINE} ${ACCEL} ${DISK_A}${PATH_IMGS}${PATH_1}${DISK_B}${DISK_A_1}${PATH_A}${PATH_2}${DISK_B_1}${DISK_CDROM}${CDROM_PATH}${CDROM_PATH_1}${MORECDROM_A}${MORECDROM_PATH}${MORECDROM_PATH_1}${MORECDROM_B}${NETWORK_CARD}${SOUND_CARD} ${CPU} -smp $[$HEXING*$XIANCHENG*$CACAO],cores=${HEXING},threads=${XIANCHENG},sockets=${CACAO} ${VGA}${SHARE}${SHARE_PATH}${CONNECT}${USB_MOUSE}"
#cat <<-EOF
$START
#EOF
exit
}
######
#Qbox启动界面
qbox_begin(){
if uname -a | grep -q Android; 
then echo "您处于termux环境，正在处理"
  if cat xbtool.config | grep -q first_use=true; 
  then
    input=$(whiptail --title "模式选择" --menu "     选择一项你需要的模式" 20 50 9 \
          "1" "普通模式" \
	  "2" "小白模式"  3>&1 1>&2 2>&3)
  case $input in
   1)echo "qbox_model=common" >> xbtool.config ;;
   2)echo "qbox_model=easy" >>xbtool.config ;;
   esac
apt install wget curl proot -y
sed -i 's/first_use=true/first_use=false/g' xbtool.config
 else
echo "正在处理"
sed -i 's/first_use=true/first_use=false/g' xbtool.config
fi
if [ -f "start-bullseye-qbox.sh" ];then
	echo "检测文件中"
else
	echo "创建文件"
	touch start-bullseye-qbox.sh
	chmod  +x start-bullseye-qbox.sh
	echo "sshd
	pkill -9 pulseaudio 2>/dev/null
	pulseaudio --start &
	unset LD_PRELOAD
	proot --kill-on-exit -S bullseye-qbox --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b bullseye-qbox/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >> start-bullseye-qbox.sh
	fi
	if [ -d "bullseye-qbox/" ];then
	 echo "容器存在"
        else
	 echo "容器检测失败，正在安装"
	termux_install_proot_qbox
	fi
	if [ ! $(command -v pulseaudio) ]; then
	apt install pulseaudio -y
	echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
	grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf
	sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
	echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf; 
        fi
        echo -e "${Y}正在启动${E}"
        ./start-bullseye-qbox.sh
        termux
         else echo "环境检测正常"
fi
if [ -f "xbtool.config" ];then
   echo -e "${Y}配置文件检测正常！${E}"
else
   echo -e "${Y}无配置文件，正在创建${E}"
   touch xbtool.config
   echo "qbox_model=common" >> xbtool.config
fi
if cat xbtool.config | grep -q qbox_model=easy; 
then easy_qbox
else echo "操作继续"
fi
echo "欢迎使用QBox for linux（qemu便捷启动脚本）"
if [ $(command -v qemu-system-i386) ]; then
  sleep 0.1
  QEMU_VERSION=$(qemu-system-i386 --version | grep version | awk '{print $4}')
elif [ $(command -v qemu-system-i386-3.1) ]; then
  echo -e "\e[33m您已安装双版本Qemu，操作继续\e[0m"
  QEMU_VERSION="3 and 5双版本"
else echo "你没有安装qemu，正在跳转安装qemu"
case $SYS_V in
	Arch)if [ $(uname -m) = aarch64 ];then
      if (whiptail --title "是否编译安装？" --yes-button "是" --no-button "否"  --yesno "仅支持编译安装，本脚本只编译x86_64和i386的qemu" 10 60) then
	echo "继续操作"
	pacman -Sy diffutils meson pkg-config gcc ninja make cmake wget
        wget https://download.qemu.org/qemu-6.2.0.tar.xz
        tar xvf qemu-6.2.0.tar.xz
        rm -rf qemu-6.2.0.tar.xz
        cd qemu-6.2.0
        ./configure --target-list=i386-softmmu,x86_64-softmmu
        make -j8
        make install
        echo "安装完成，如有出错请重试"
	qbox_begin
	 else
	exit
	fi
	fi
 if [ $(uname -m) = x86_64 ];then
   input=$(whiptail --title "Qemu Install Menu" --menu "选择qemu安装方式" 20 50 9 \
	   "1" "编译安装" \
	   "2" "pacman直接安装"  3>&1 1>&2 2>&3)
   case $input in
     1)echo "操作继续"
       pacman -Sy diffutils meson pkg-config gcc ninja make cmake wget
       wget https://download.qemu.org/qemu-6.2.0.tar.xz
       tar xvf qemu-6.2.0.tar.xz
       cd qemu-6.2.0
       ./configure --target-list=i386-softmmu,x86_64-softmmu
       make -j8
       make install
       echo "安装完成，如有出错请重试"
       qbox_begin ;;
     2)pacman -Syu qemu
       qbox_begin ;;
    esac
  fi ;;
        Ubuntu | Debian)input=$(whiptail --title "Qemu Install Menu" --menu "     选择一项以安装QEMU" 20 50 9 \
	"1" "常规apt install安装" \
	"2" "安装qemu 5.2和3.1版本(通过deb安装包安装，速度极快)" \
	"3" "通过apt install安装 qemu6.2版本(修改debian-sid源)" 3>&1 1>&2 2>&3)
case $input in
  1)apt update -y && apt --fix-broken install -y && apt install qemu-system-x86-64 qemu-system-i386 curl -y
    echo "操作结束，可能安装会有问题，重试即可" ;;
  2)wget --no-check-certificate https://down.xb6868.com/xuebi/Qemu/qemu3_5.deb -O qemu.deb
    dpkg -i qemu.deb
    rm -rf qemu.deb
    echo "安装完成" ;;
  3)apt install lsb-release
    if lsb_release -a | grep -q bullseye;
	then echo "系统版本兼容检测已通过"
	else echo "暂不支持您的系统"
	sleep 1.5
        qbox_install_qemu
    fi
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free" >/etc/apt/sources.list
    apt update
    apt update -y && apt --fix-broken install -y && apt install qemu-system-x86-64 qemu-system-i386 curl -y
    echo "安装完成，可能会出错，重试即可" ;;
  *)exit ;;
esac ;;
esac
qbox_begin
fi
input=$(whiptail --title "Qbox Menu" --menu "     选择一项以使用Qemu\n     您的Qemu版本为Qemu-system:${QEMU_VERSION}" 20 50 9 \
	"1" "启动qemu-system-x86_64模拟器" \
	"2" "镜像工具" \
	"3" "切换简易模式" \
	"4" "更新Qemu(支持部分系统)" \
	"5" "返回" \
	"0" "退出"  3>&1 1>&2 2>&3)
case $input in
  1)qbox_start_qemu ;;
  2)qbox_img_tool ;;
  3)sed -i 's/qbox_model=common/qbox_model=easy/g' xbtool.config
    echo "设置完成"
    easy_qbox ;;
  4)qbox_qemu_update
    qbox_begin ;;
  5)BACKPROOT="true"
    linux ;;
  *)exit ;;
esac

}
######
#termux环境proot安装
install_proot(){
input=$(whiptail --title "Proot Install Menu" --menu "      请选择您要安装的proot容器" 20 50 9 \
	"1" "debian-bullseye" \
	"2" "ubuntu-impish" \
	"3" "ubuntu-focal" \
	"4" "arch" \
	"0" "返回"  3>&1 1>&2 2>&3)
case $input in
	1)apt install pulseaudio -y
	bash -c "$(curl https://shell.xb6868.com/ut/bullseye.sh)" ;;
        2)cd
	apt install wget -y
	apt install proot -y
	VERSION=`curl https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/impish/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
	curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/impish/arm64/default/${VERSION}rootfs.tar.xz
	mkdir ubuntu-impish
	tar xvf rootfs.tar.xz -C ubuntu-impish
	echo $(uname -a) | sed 's/Android/GNU\/Linux/' >ubuntu-impish/proc/version
	if [ ! -f "ubuntu-impish/usr/bin/perl" ]; then
            cp ubuntu-impish/usr/bin/perl* ubuntu-focal/usr/bin/perl
	fi
	cat >ubuntu-impish/usr/bin/uptime<<-'eof'
	sed -n "/load average/s/#//;s@$(grep 'load average' /usr/bin/uptime | awk '{print $2}' | sed -n 1p)@$(date +%T)@"p /usr/bin/uptime
	eof
	wget https://down.xb6868.com/xuebi1/proot/proc_proot.tar.gz                          
	mkdir ubuntu-impish/etc/proc
	tar zxvf proc_proot.tar.gz -C ubuntu-impish/etc/proc
	rm -rf proc_proot.tar.gz
	touch start-uimpish.sh
	cat >start-uimpish.sh<<-'eof'
	pkill -9 pulseaudio 2>/dev/null
	pulseaudio --start &
	unset LD_PRELOAD
	proot --kill-on-exit -S ubuntu-impish --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b ubuntu-impish/root:/dev/shm --bind=ubuntu-impish/etc/proc/vmstat:/proc/vmstat --bind=ubuntu-impish/etc/proc/version:/proc/version --bind=ubuntu-impish/etc/proc/uptime:/proc/uptime --bind=ubuntu-impish/etc/proc/stat:/proc/stat --bind=ubuntu-impish/etc/proc/loadavg:/proc/loadavg  --bind=ubuntu-impish/etc/proc/bus/pci/00:/proc/bus/pci/00 --bind=ubuntu-impish/etc/proc/devices:/proc/bus/devices --bind=ubuntu-impish/etc/proc/bus/input/devices:/proc/bus/input/devices --bind=ubuntu-impish/etc/proc/modules:/proc/modules  --bind=/sys --bind=/proc/self/fd/2:/dev/stderr --bind=/proc/self/fd/1:/dev/stdout --bind=/proc/self/fd/0:/dev/stdin --bind=/proc/self/fd:/dev/fd --bind=/proc -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login
	eof
	cd
	rm -f rootfs.tar.xz
	if [ ! $(command -v pulseaudio) ]; then
	  apt install pulseaudio -y
	  echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
	  grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf
	  sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
	  echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf; 
	fi
	echo "安装完成！输入./start-uimpish.sh启动"
	chmod +x start-uimpish.sh
	echo ". run.sh" >>ubuntu-impish/etc/profile
	touch ubuntu-impish/root/run.sh
	cat >ubuntu-impish/root/run.sh<<-'eof'
	touch ${HOME}/.hushlogin
	mkdir -p /run/systemd/resolve 2>/dev/null && echo "nameserver 223.5.5.5
	nameserver 223.6.6.6" >/run/systemd/resolve/stub-resolv.conf
	sed -i "1i\export TZ='Asia/Shanghai'" /etc/profile
	echo "是否换源？
	1)是
	2)否"
	read -r -p "请选择：" input
	  case $input in
	  1)echo 'deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish main restricted universe multiverse
	    # deb-src https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish main restricted universe multiverse
	    deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-updates main restricted universe multiverse
	    # deb-src https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-updates main restricted universe multiverse
	    deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-backports main restricted universe multiverse
	    # deb-src https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-backports main restricted universe multiverse
	    deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-security main restricted universe multiverse
	    # deb-src https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-security main restricted universe multiverse
            # 预发布软件源，不建议启用
	    # deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-proposed main restricted universe multiverse
	    # deb-src https://mirrors.bfsu.edu.cn/ubuntu-ports/ impish-proposed main restricted universe multiverse' > /etc/apt/sources.list
	    apt update
	    echo "更换成功" ;;
	  *)echo "操作取消" ;;
	 esac
	echo "是否安装图形界面和常用软件？
	感谢海鲜对本功能的技术支持"
	read -r -p "1)是
	2)否
	请选择：" input
	case $input in
	  1)apt install -y && apt install curl wget vim fonts-wqy-zenhei tar xfce4 xfce4-terminal ristretto lxtask dbus-x11 python3 pulseaudio -y
	    apt install tigervnc* -y
	    echo "export PULSE_SERVER=127.0.0.1
	    pulseaudio --start
            tigervncserver :1" >>/usr/local/bin/start-vnc
	    chmod 777 /usr/local/bin/start-vnc
	    apt install firefox firefox-locale-zh-hans -y
	    if [ $(command -v firefox) ]; then
		if grep -q '^ex.*MOZ_FAKE_NO_SANDBOX=1' /etc/environment; then
		   printf "%s\n" "MOZ_FAKE_NO_SANDBOX=1" /etc/environment
		else
	    echo 'export MOZ_FAKE_NO_SANDBOX=1' >>/etc/environment
	    fi
	    if ! grep -q 'PATH' /etc/environment; then
	    sed -i '1i\PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' /etc/environment
	    fi
	    if ! grep -q 'environment' /etc/profile; then
	    echo 'source /etc/environment' >>/etc/profile
	    fi
	    fi
	    echo "即将开始设置密码，请输入第一次密码后出现 y/n 提示时，输y再设置一次密码"
	    tigervncserver :1
	    echo '#!/bin/sh
	    xrdb "$HOME/.Xresources"
	    xsetroot -solid grey
	    xfce4-session
	    #x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
	    #x-window-manager &
	    # Fix to make GNOME work
	    export XKL_XMODMAP_DISABLE=1
	    /etc/X11/Xsession' >/root/.vnc/xstartup
	    chmod 777 /root/.vnc/xstartup
	    echo "done 输入start-vnc 即可启动vnc" ;;
	  2)echo "操作取消" ;;
	esac
	echo "是否尝试更换语言为中文？
	1)是
	2)否"
	read -r -p "请选择：" input
	case $input in
	 1)apt install fonts-wqy-zenhei locales -y
	   sed -i '/zh_CN.UTF/s/#//' /etc/locale.gen
	   locale-gen || /usr/sbin/locale-gen
	   sed -i '/^export LANG/d' /etc/profile && sed -i '1i\export LANG=zh_CN.UTF-8' /etc/profile && source /etc/profile && export LANG=zh_CN.UTF-8 && echo '修改完毕,请重新登录' ;;
	 2)echo "取消" ;;
	esac
	sed -i 's/. run.sh//g' /etc/profile
	  eof
          ;;
	3)cd
	apt install wget -y
	apt install proot -y
	VERSION=`curl https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/focal/arm64/default/ | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
	curl -O https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/focal/arm64/default/${VERSION}rootfs.tar.xz
	mkdir ubuntu-focal
	tar xvf rootfs.tar.xz -C ubuntu-focal
        echo $(uname -a) | sed 's/Android/GNU\/Linux/' >ubuntu-focal/proc/version
	if [ ! -f "ubuntu-focal/usr/bin/perl" ]; then
          cp ubuntu-focal/usr/bin/perl* ubuntu-focal/usr/bin/perl
        fi
	cat >ubuntu-focal/usr/bin/uptime<<-'eof'
	sed -n "/load average/s/#//;s@$(grep 'load average' /usr/bin/uptime | awk '{print $2}' | sed -n 1p)@$(date +%T)@"p /usr/bin/uptime
	eof
	wget https://down.xb6868.com/xuebi1/proot/proc_proot.tar.gz
	mkdir ubuntu-focal/etc/proc
	tar zxvf proc_proot.tar.gz -C ubuntu-focal/etc/proc
	rm -rf proc_proot.tar.gz
	touch start-ubuntu.sh
	cat >start-ubuntu.sh<<-'eof'
	pkill -9 pulseaudio 2>/dev/null
	pulseaudio --start &
	unset LD_PRELOAD
	proot --kill-on-exit -S ubuntu-focal --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b ubuntu-focal/root:/dev/shm --bind=ubuntu-focal/etc/proc/vmstat:/proc/vmstat --bind=ubuntu-focal/etc/proc/version:/proc/version --bind=ubuntu-focal/etc/proc/uptime:/proc/uptime --bind=ubuntu-focal/etc/proc/stat:/proc/stat --bind=ubuntu-focal/etc/proc/loadavg:/proc/loadavg  --bind=ubuntu-focal/etc/proc/bus/pci/00:/proc/bus/pci/00 --bind=ubuntu-focal/etc/proc/devices:/proc/bus/devices --bind=ubuntu-focal/etc/proc/bus/input/devices:/proc/bus/input/devices --bind=ubuntu-focal/etc/proc/modules:/proc/modules  --bind=/sys --bind=/proc/self/fd/2:/dev/stderr --bind=/proc/self/fd/1:/dev/stdout --bind=/proc/self/fd/0:/dev/stdin --bind=/proc/self/fd:/dev/fd --bind=/proc -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login
	eof
	cd
	rm -f rootfs.tar.xz
	if [ ! $(command -v pulseaudio) ]; then
	  apt install pulseaudio -y
	  echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
	  grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf
	  sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
	  echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf; 
	fi
	echo "安装完成！输入./start-ubuntu.sh启动"
	chmod +x start-ubuntu.sh
	echo ". run.sh" >>ubuntu-focal/etc/profile
	cd ubuntu-focal/root/
	touch run.sh
	cat >run.sh<<-'eof'
	touch ${HOME}/.hushlogin
	mkdir -p /run/systemd/resolve 2>/dev/null && echo "nameserver 223.5.5.5
	nameserver 223.6.6.6" >/run/systemd/resolve/stub-resolv.conf
	sed -i "1i\export TZ='Asia/Shanghai'" /etc/profile
	echo "是否换源？
	1)是
	2)否"
	read -r -p "请选择：" input
	case $input in
	  1)cd /etc/apt/
	    cp sources.list sources.list.bf
	    echo "sources文件已备份，名叫sources.list.bf"
	    sleep 1
	    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal main restricted universe multiverse
	    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal main restricted universe multiverse
	    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-updates main restricted universe multiverse
	    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-updates main restricted universe multiverse
	    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-backports main restricted universe multiverse
	    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-backports main restricted universe multiverse
	    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-security main restricted universe multiverse
	    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ focal-security main restricted universe multiverse' > sources.list
	    apt update
	    echo "更换成功" ;;
	  *)echo "操作取消" ;;
	esac
	echo "是否安装图形界面和常用软件？
	感谢海鲜对本功能的技术支持"
	read -r -p "1)是
	2)否
	请选择：" input
	case $input in
	  1)apt install -y && apt install --no-install-recommends curl wget vim fonts-wqy-zenhei tar firefox firefox-locale-zh-hans ffmpeg mpv xfce4 xfce4-terminal ristretto dbus-x11 lxtask pavucontrol -y
	    if [ ! $(command -v dbus-launch) ] || [ ! $(command -v xfce4-session) ]; then
	    echo -e "\e[31m似乎安装出错,重新执行安装\e[0m"
	    sleep 2
	    apt --fix-broken install -y && apt install --no-install-recommends curl wget vim fonts-wqy-zenhei tar firefox firefox-locale-zh-hans ffmpeg mpv xfce4 xfce4-terminal ristretto dbus-x11 lxtask pavucontrol -y
	    fi
	    if grep -q '^ex.*MOZ_FAKE_NO_SANDBOX=1' /etc/environment; then
	       printf "%s\n" "MOZ_FAKE_NO_SANDBOX=1" /etc/environment
	    else
	       echo 'export MOZ_FAKE_NO_SANDBOX=1' >>/etc/environment
	    fi
	    if ! grep -q 'PATH' /etc/environment; then
	    sed -i '1i\PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' /etc/environment
	    fi
	    if ! grep -q 'environment' /etc/profile; then
	    echo 'source /etc/environment' >>/etc/profile
	    fi
	    apt install tightvncserver -y
	    touch /usr/local/bin/start-vnc
	    echo 'export PULSE_SERVER=127.0.0.1
	    pulseaudio --start
	    tightvncserver' >>/usr/local/bin/start-vnc
	    chmod +x /usr/local/bin/start-vnc
	    sed -i "3i\rm -rf \/tmp\/.X\*" /etc/profile
	    #apt install pavucontrol
	    apt install pulseaudio
	    #sed -i 's/exit 1/#exit1/g' /usr/bin/pulseaudio-equalizer
	    #echo 'load-module module-simple-protocol-tcp rate=44100 format=s16le channels=2 source=0 record=true port=12345' >>/etc/pulse/default.pa
	    echo "输入start-vnc启动vnc"
	    sleep 3 ;;
	   2)echo "操作取消" ;;
	esac
	echo "更换语言为中文？"
	read -r -p "1)是
	2)否
	请选择：" input
	case $inpit in
	  1)apt install fonts-wqy-zenhei locales -y
	    sed -i '/zh_CN.UTF/s/#//' /etc/locale.gen
	    locale-gen || /usr/sbin/locale-gen
	    sed -i '/^export LANG/d' /etc/profile
	    sed -i '1i\export LANG=zh_CN.UTF-8' /etc/profile
	    source /etc/profile
	    export LANG=zh_CN.UTF-8 ;;
	  2)echo "操作取消" ;;
	esac
	echo "请重启容器，以应用更改"
	sed -i 's/. run.sh//g' /etc/profile
	eof
        ;;
	4)cd
        apt install wget curl proot -y
	rm -rf rootfs.tar.xz
	DOWN_LINE=$(curl https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/archlinux/current/arm64/default/ | awk '{print $3}' | tail -n 3 | head -n 1 | awk -F '"' '{print $2}' | awk -F '/' '{print $1}')
	wget https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/archlinux/current/arm64/default/${DOWN_LINE}/rootfs.tar.xz
	mkdir arch
	tar xvf rootfs.tar.xz -C arch
	rm -rf rootfs.tar.xz
	wget https://down.xb6868.com/xuebi1/proot/proc_proot.tar.gz
	mkdir arch/etc/proc
	tar zxvf proc_proot.tar.gz -C arch/etc/proc
	rm -rf proc_proot.tar.gz
        echo 'killall -9 pulseaudio 2>/dev/null
	pulseaudio --start &
	unset LD_PRELOAD
	proot --kill-on-exit -S arch --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b arch/root:/dev/shm --bind=arch/etc/proc/vmstat:/proc/vmstat --bind=arch/etc/proc/version:/proc/version --bind=arch/etc/proc/uptime:/proc/uptime --bind=arch/etc/proc/stat:/proc/stat --bind=arch/etc/proc/loadavg:/proc/loadavg  --bind=arch/etc/proc/bus/pci/00:/proc/bus/pci/00 --bind=arch/etc/proc/devices:/proc/bus/devices --bind=arch/etc/proc/bus/input/devices:/proc/bus/input/devices --bind=arch/etc/proc/modules:/proc/modules   --bind=/sys --bind=/proc/self/fd/2:/dev/stderr --bind=/proc/self/fd/1:/dev/stdout --bind=/proc/self/fd/0:/dev/stdin --bind=/proc/self/fd:/dev/fd --bind=/proc -w /root /usr/bin/env -i --sysvipc HOME=/root TERM=xterm-256color USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 TZ=Asia/Shanghai /bin/bash --login' >>start-arch.sh
	chmod 777 start-arch.sh
	rm arch/etc/resolv.conf
	echo "nameserver 208.67.222.222
        nameserver 208.67.220.220" >arch/etc/resolv.conf
	echo 'Server = https://mirrors.bfsu.edu.cn/archlinuxarm/$arch/$repo' >arch/etc/pacman.d/mirrorlist
	echo '[archlinuxcn]
	Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >>arch/etc/pacman.conf
	if [ ! $(command -v pulseaudio) ]; then
	   apt install pulseaudio -y
	   echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ${PREFIX}/etc/pulse/default.pa
	   grep -q "exit-idle" ${PREFIX}/etc/pulse/daemon.conf
	   sed -i '/exit-idle/d' ${PREFIX}/etc/pulse/daemon.conf
	   echo "exit-idle-time = -1" >> ${PREFIX}/etc/pulse/daemon.conf; 
	fi
	echo 'export LC_ALL="zh_CN.UTF-8"
	. run.sh' >>arch/etc/profile
	cat >arch/usr/local/bin/start-vnc<<-'eof'
	echo -e "\e[33mvnc已启动，地址:127.0.0.1:1,输入ctrl+c关闭vnc\e[0m"
	export PULSE_SERVER=127.0.0.1 >/dev/null 2>&1
	pulseaudio --start >/dev/null 2>&1
	vncserver :1 >/dev/null 2>&1
	eof
	cat >arch/root/run.sh<<-'eof'
	echo -e "\e[33m正在配置系统...\e[0m"
	sleep 2
	pacman -Syy
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sed -i 's/#zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/g' /etc/locale.gen
	sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
	sed -i 's/#zh_CN GB2312/zh_CN GB2312/g' /etc/locale.gen
	locale-gen
	echo -e "\e[33m即将安装软件，中间出现提示请直接回车即可！\e[00m"
    chmod -R 755 /etc
    chmod 440 /etc/sudoers
    chmod -R 755 /usr
    chmod -R 755 /var 
	pacman -Syu tzdata aria2 xfce4 xfce4-goodies lxtask wqy-zenhei pulseaudio awk neofetch tigervnc chromium libnewt
	sed -i 's/\/usr\/bin\/chromium %U/\/usr/bin\/chromium --no-sandbox %U/g' /usr/share/applications/chromium.desktop
	sed -i 's/\/usr\/bin\/chromium/\/usr\/bin\/chromium --no-sandbox/g' /usr/share/applications/chromium.desktop
	sed -i 's/\/usr\/bin\/chromium --incognito/\/usr\/bin\/chromium --no-sandbox --incognito/g' /usr/share/applications/chromium.desktop
	chmod 777 /usr/local/bin/start-vnc
	echo -e "\e[33m设置vnc密码，输入后出现提示，请输入y回车再输一次\e[0m"
	vncpasswd
	echo "完成，出现问题请输入bash run.sh再次安装
	输入start-vnc启动vnc"
	sed -i 's/. run.sh//g' /etc/profile
	eof
	echo -e "${Y}输入./start-arch.sh启动arch${E}" ;;
	*)termux ;;
esac
}
######
#Linux界面
linux(){
if (( $(id -u) == 0 )); then
  sleep 0.1
else
  echo -e "\e[33m非root用户，为保障脚本完美运行，请使用root用户启动脚本\e[0m"
  read -r -p "1)继续运行脚本 2)停止运行脚本 3)尝试使用root用户启动脚本 请选择：" input
  case $input in
	  1)sleep 0.1 ;;
	  2)exit ;;
	  3)if [ -f "xbtools.sh" ];then
		  sudo bash xbtools.sh
	  else
		  bash -c "$(curl https://shell.xb6868.com/xbtools.sh)"
	  fi ;;
 esac
fi
if [ -f "xbtool.config" ];then
	sleep 0.1
	    else
	echo -e "${Y}无配置文件，正在创建${E}"
	touch xbtool.config
	echo "first_use=true" >> xbtool.config
fi
if [ $SYS_V = Arch ];then
	if [ ! $(command -v whiptail) ];then
		pacman -Sy libnewt
	fi
	if [ $(cat /etc/locale.gen | grep zh_CN | gawk '{print $1}' | gawk 'NR==4') = zh_CN ];then
		sleep 0.1
	else
		pacman -Sy wqy-zenhei
		sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
		sed -i 's/#zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/g' /etc/locale.gen
		sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
		sed -i 's/#zh_CN GB2312/zh_CN GB2312/g' /etc/locale.gen
		locale-gen
	fi
fi
if cat xbtool.config | grep -q start_system_qbox=true;
then if [ "${BACKPROOT}" = "true" ]; then
	 sleep 0.1
         else qbox_begin
     fi
else sleep 0.1
fi
input=$(whiptail --title "Xbtool Menu" --menu "      欢迎使用xbtool，选择一个选项以开始" 20 50 9 \
	"1" "更换国内源" \
	"2" "安装中文语言" \
	"3" "樱花内网穿透" \
	"4" "启动Qbox(qemu模拟器)" \
	"5" "启动dos系统(可玩dos游戏)" \
	"6" "软件安装/管理" \
	"7" "更多脚本" \
	"8" "下载&更新脚本"  3>&1 1>&2 2>&3)
case $input in
	1)SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
	if [ "${SYS_V}" = "Arch" ] ;then
	SA=$(uname -m)
	case $SA in
	aarch64)echo 'Server = https://mirrors.bfsu.edu.cn/archlinuxarm/$arch/$repo' >/etc/pacman.d/mirrorlist
	echo '[archlinuxcn]
	Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >>/etc/pacman.conf
	pacman -Syy
	linux ;;
x86_64)echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
echo '[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >>/etc/pacman.conf
pacman -Syy
linux ;;
*)echo "不支持您的架构"
linux ;;
esac
fi
echo "即将安装必要软件。。"
sleep 2
apt install wget -y
apt install lsb-release -y
apt install apt-transport-https ca-certificates -y
localectlset-locale LANG=zh_CN.UTF-8
echo "您的系统版本为："
lsb_release -a
echo "换源程序换源后为北外源"
MIRROR_URL="https://mirrors.bfsu.edu.cn"
sleep 3
if lsb_release -a | grep -q Debian ;then
if lsb_release -a | grep -q sid ;then
MIRROR_VER=""
MIRROR="deb ${MIRROR_URL}debian/ sid main contrib non-free"
fi
if lsb_release -a | grep -q testing ;then
MIRROR_VER="testing"
fi
if lsb_release -a | grep -q bullseye ;then
MIRROR_VER="bullseye"
fi
if lsb_release -a | grep -q buster ;then
MIRROR_VER="buster"
fi
if lsb_release -a | grep -q stretch ;then
MIRROR_VER="stretch"
fi
if lsb_release -a | grep -q jessie ;then
MIRROR_VER=""
MIRROR="deb ${MIRROR_URL}/debian/ jessie main contrib non-free
deb ${MIRROR_URL}/debian/ jessie-updates main contrib non-free
deb ${MIRROR_URL}/debian-security jessie/updates main contrib non-free"
fi
if [ ! $MIRROR_VER ]; then
  sleep 0.1
else
  echo "deb ${MIRROR_URL}/debian/ ${MIRROR_VER} main contrib non-free
deb ${MIRROR_URL}/debian/ ${MIRROR_VER}-updates main contrib non-free
deb ${MIRROR_URL}/debian/ ${MIRROR_VER}-backports main contrib non-free
deb ${MIRROR_URL}/debian-security ${MIRROR_VER}-security main contrib non-free" >/etc/apt/sources.list
apt update
echo "换源完成"
linux
fi
if [ ! $MIRROR ]; then
  sleep 0.1
else
  echo "${MIRROR}" >/etc/apt/sources.list
  apt update
  echo "换源完成"
  linux
fi
fi
if lsb_release -a | grep -q Ubuntu ;then
echo "您使用的是Ubuntu，暂不支持低于bionic的系统"
if uname -m | grep -q aarch64 ;then
mirror_path="ubuntu-ports"
fi
if uname -m | grep -q x86_64 ;then
mirror_path="ubuntu"
fi
if lsb_release -a | grep -q bionic ;then
MIRROR_VER="bionic"
fi
if lsb_release -a | grep -q focal ;then
MIRROR_VER="focal"
fi
if lsb_release -a | grep -q hirsute ;then
MIRROR_VER="hirsute"
fi
if lsb_release -a | grep -q impish ;then
MIRROR_VER="impish"
fi
if [ ! $MIRROR_VER ]; then
  sleep 0.1
else
  echo "deb ${MIRROR_URL}/${mirror_path}/ ${MIRROR_VER} main restricted universe multiverse
deb ${MIRROR_URL}/${mirror_path}/ ${MIRROR_VER}-updates main restricted universe multiverse
deb ${MIRROR_URL}/${mirror_path}/ ${MIRROR_VER}-backports main restricted universe multiverse
deb ${MIRROR_URL}/${mirror_path}/ ${MIRROR_VER}-security main restricted universe multiverse" >/etc/apt/sources.list
apt update
echo "更换完成"
linux
fi
fi
echo -e "${R}错误，暂不支持您的系统${E}"
linux ;;
    2)SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
    case $SYS_V in
      Debian | Ubuntu)apt install -y language-pack-zh-han* language-pack-gnome-zh-han* -y
       apt install fonts-wqy-zenhei locales -y
       sed -i '/zh_CN.UTF/s/#//' /etc/locale.gen
       locale-gen || /usr/sbin/locale-gen
       sed -i '/^export LANG/d' /etc/profile && sed -i '1i\export LANG=zh_CN.UTF-8' /etc/profile && source /etc/profile && export LANG=zh_CN.UTF-8 && echo '修改完毕,请重新登录' && sleep 2
       exit ;;
      Arch)pacman -Syy
      pacman -Syu wqy-zenhei
      sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
      sed -i 's/#zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/g' /etc/locale.gen
      sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
      sed -i 's/#zh_CN GB2312/zh_CN GB2312/g' /etc/locale.gen
      locale-gen
      echo "完成，请重新登录系统" ;;
      esac;;
   3)wget https://getfrp.sh/d/frpc_linux_arm64
	   chmod +x frpc_linux_arm64
	   ./frpc_linux_arm64 ;;
   4)qbox_begin ;;
   5)if [ $SYS_V = Arch ];then
	whiptail --title "错误！ " --msgbox "此功能暂不支持Arch " 20 50
	linux
   fi
   if [ ! $(command -v curl) ];then
	   $ainstall curl$yes
   fi
   bash -c "(curl https://shell.xb6868.com/ut/utdos.sh)"
   linux ;;
  6)app_install ;;
  7)more_shell ;;
  8)down_sh ;;
esac
}
######
#termux界面
termux(){
if [ -f "xbtool.config" ];then
	echo -e "${Y}配置文件检测正常！${E}"
else
	echo -e "${Y}无配置文件，正在创建${E}"
	touch xbtool.config
	echo "first_use=true" >> xbtool.config
fi
input=$(whiptail --title "Xbtool Menu" --menu "      欢迎使用xbtool，选择一个选项以开始" 20 50 9 \
	"1" "制作恢复包" \
	"2" "恢复恢复包" \
	"3" "安装Linux容器" \
	"4" "termux换源" \
	"5" "启动Qbox(qemu模拟器)" \
	"6" "二维码生成" \
	"7" "更多脚本" \
	"8" "下载&更新脚本"  3>&1 1>&2 2>&3)
case $input in
	1)cd /data/data/com.termux
		tar zcvf huifu.tar.gz files
		cp huifu.tar.gz /sdcard
		echo -e "操作已完成" 
	        whiptail --title "提示" --msgbox " 恢复包已保存至/sdcard" 10 60
		termux;;
	2)whiptail --title "提示" --msgbox " 请确认您已把恢复包放在/sdcard(手机目录下)" 10 60
	if [ -f /sdcard/huifu.tar.gz ]; then
	cd /data/data/com.termux/
	cp /sdcard/huifu.tar.gz .
	tar zxvf huifu.tar.gz
	echo -e "操作已完成"
	else echo "ERROR:未检测到恢复包"
	sleep 2
	fi
	termux ;;
	3)install_proot ;;
	4)echo -e "准备开始换源...."
	     sleep 1
	sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
	sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
	sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
	apt update && apt upgrade
	termux ;;
	5)qbox_begin ;;
	6)TEST=$(whiptail --title "二维码生成" --inputbox "请输入要生成的内容(如果是网址请带上http://)" 10 50 3>&1 1>&2 2>&3)
	echo "${TEST}" |curl -F-=\<- qrenco.de
	echo "done.."
	sleep 3
	termux ;;
	7)more_shell ;;
	8)down_sh ;;
	*)echo -e "已取消"
        exit ;;
esac
}
######
#更新日志
#echo "更新公告2021/9/5：
#本脚本已完全重写和更改，比原来好多了，不在是三个文件，脚本已经整合，因为我还是个小白，所以这个脚本写的不好，请多多见谅！"
#echo "2021/9/19:
#脚本暂时停更"
#echo "2021/9/21：脚本破例更新一次，下次更新估计是国庆节？"
#echo "最新公告2021/9/25:将于国庆节开始编写Qbox脚本(qemu便捷启动脚本)   敬请期待！"
#echo "脚本版本：0.0.3.3"
#echo "更新内容："
#2021/9/5：脚本重写 功能减少
#echo "2021/9/21:中秋节破例更新，更新了容器安装，可一键配置！"
#echo "2021/9/24：删除部分失效功能，优化换源方式！"
#echo "qbox编写完成，目前仅一个功能，其他功能请等待更新，欢迎反馈bug！"
#echo "2021/10/3 已修复无法自动运行qemu的bug，感谢群员提供的解决方式
#已更新多cdrom
#echo "2021/10/5 QBox工具已趋于完善"
clear
update_history(){
echo "更新日志：
2021/11/6

更新内容：qemu两个版本共存支持(已实现)
容器Ubuntu-focal支持pulseaudio放声(已修复)

修复已知bug

优化了一些功能

感谢海叔对本脚本的大力支持！

版本：0.0.6

2021/11/13

优化部分功能
修复已知bug

版本：0.0.7

2021/11/27

qemu脚本更新简易模式，可以一键运行(目前只支持一个系统)
优化了很多细节

版本：0.0.8
"

echo "更新内容:

2022/1/21

新增一个功能

版本：0.0.9"

echo "更新内容：

2022/1/30

优化体验
修复已知bug

版本：0.1.0"

echo "更新内容：

支持qemu运行时自动跳转vnc(只对部分设备有效)

版本：0.1.1

修复了亿些bug
增强了使用体验

版本：0.1.2"

echo "更新内容：

2022/2/4

新增debian-bullseye更新qemu6.2版本
新增xbtool控制面板
修复bug
优化体验
新增utdos，在容器运行dos功能

版本：0.1.4

2022/2/6

可将脚本下载到本地
可在线更新脚本

版本；0.1.5"

echo -e "${Y}热烈庆祝本脚本行数突破1000！${E}"


echo "2022/2/16

xbtools稳定版 0.1.6

包含功能：
termux环境：
termux数据备份与恢复
更换termux国内源
在termux里安装proot容器
安装qemu并启动（容器内）

容器环境：（只支持proot和chroot，debian和ubuntu系统）
（因没有root手机，chroot环境无法测试，在chroot环境内，可能会有bug）
给debian换源
安装中文
内网穿透
启动qemu 模拟Windows系统
启动dos系统

脚本已支持在线更新，和下载脚本到本地！"

echo "2022/2/19

支持Ubuntu-impish proot安装

版本：0.1.7"

echo "2022/2/20

在proot环境下，支持安装运行wine(建议先在termux环境安装Ubuntu-impish容器)

版本：0.1.8"

echo "2022/2/26

更新tui界面支持
qemu支持tui界面启动

版本：0.1.9 beta
0.2.0"

echo "2022/3/5

加快启动速度
增加更多脚本

版本：0.2.2(0.2.1 update)"

echo "2022/3/13

更换down链接
修复bug

版本：0.2.3"

echo "2022/3/20

更新软件安装
更新自动换源
优化兼容性检测
合并更新和下载脚本
已支持 proot chroot 实体机 (x86_64 & arm64 架构)
版本：0.2.4-beta
"

echo "2022/3/26

阉割xbtool控制面板
阉割vnc启动
软件安装/管理增加图形/vnc服务安装
优化qemu升级版本获取办法
qbox界面可以显示版本

版本: 0.2.5
"

echo "2022/4/3

proot容器安装已支持arch
更新启动脚本系统检测

arch系统功能努力编写中，敬请期待

版本：0.2.6 beta
"

echo "2022/4/10

修复已知bug
已支持arch

版本：0.2.7
0.2.8 beta
"
}
echo "2022/5/1

脚本已完全重构
菜单已合并
支持Ubuntu ，debian，arch，termux系统
目前只有tui(半图形)界面
重写可能有许多bug
脚本体积减小，代码优化
新增许多功能
proot支持更多软件

版本：0.3 developer
"

echo -e "按${G}回车键${E}继续"
read enter
######
#系统版本检测 
if [ $(uname -o) = Android ];then
	termux
	exit
fi
SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
case $SYS_V in
	Debian | Arch | Ubuntu)linux ;;
	*)if [ ! $(command -v gawk ) ]; then
	if [ ! $(command -v apt ) ] ;then
		sleep 0.1
	else apt install gawk
	        echo -e "${Y}尝试安装awk已完成，请重启脚本${E}"
		exit
	fi
	if [ ! $(command -v pacman) ];then
		sleep 0.1
	else pacman -Sy gawk
		echo -e "${Y}尝试安装awk已完成，请重启脚本${E}"
		exit
	fi
	fi
	echo "不受支持的系统"
	exit ;;
esac
