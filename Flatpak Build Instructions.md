## Flatpak Build Instructions from Source - A Walkthrough
This guide will be helpful if you are a Dev and wan't to contribute to the Nutty's Flatpak as the Dependencies and Runtimes get updated (or) if you are a linux power user who wants to build everything from source:)

First install `flatpak` and `flatpak-builder` in your system using your respective package manager.I am using `apt` here since I run linux distro which is based on debian family.
```bash
sudo apt install flatpak flatpak-builder
```

Enable Flathub repository in your system to download the gnome Runtime & Sdk which are required to run and build Nutty respectively.
```bash
flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Now Install the Gnome Runtime and Sdk from Flathub.Make sure you install the same version of gnome Runtime and Sdk that is specified in the flatpak manifest file(`.json` or `.yaml` file).For example to install version-46 of gnome Runtime and Sdk you can use:-
```bash
flatpak install flathub org.gnome.Platform/x86_64/46
flatpak install flathub org.gnome.Sdk/x86_64/46
```
Note that you have to always install the matching Sdk i.e if you have installed gnome Runtime version-46(as specified in manifest file),you must install the same version of gnome Sdk only.

Now clone this repo using `git` and then change-directory
```bash
git clone https://github.com/babluboy/nutty/
cd nutty
```

Now start building the flatpak of Nutty using the below command.
```bash
flatpak-builder build-dir com.github.babluboy.nutty.json --force-clean
```
This command will create a new directory named `build-dir` and installs all the flatpak build files inside it.It takes some time to build the flatpak as `flatpak-builder` needs to download and build lot of modules from source which are specified in the `com.github.babluboy.nutty.json` flatpak manifest file.It took me around 10min to complete the build process, so wait patiently or just grab some coffee meanwhile.

After you have built the flatpak for Nutty,you can run it using below command
```bash
flatpak-builder --run build-dir com.github.babluboy.nutty.json com.github.babluboy.nutty
```

If build is working prefectly fine,then you can install Nutty in your system using below command
```bash
flatpak-builder --user --install --force-clean build-dir com.github.babluboy.nutty.json
```
This will add the icon of Nutty to your desktop icon's tray (or) icon's menu.

You can also check if Nutty is properly installed or not in your system by using the below command.
```bash
flatpak list --app
```
Upon executing this command you should be able to see `Nutty` under the "Name"" sections and `com.github.babluboy.nutty` under "Application-ID" section.

To uninstall the app use
```bash
flatpak uninstall com.github.babluboy.nutty
```

To update the app from the updated source code, you first need to uninstall the app and repeat the entire build & installation process as specified in this guide.

Cheers👍

#### Author
*Kishor* [Github](https://github.com/root-reborn)










