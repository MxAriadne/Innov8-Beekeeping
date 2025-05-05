
1. Zip the directory containing the files. Make sure *main.lua* is in the **root directory** of the zip, and not contained within a folder in the zip, which is the default with many archive programs like WinRAR.
2. Rename the file extension from *.zip* to *.love*
3. In terminal, run the following commands in the same directory as the .love file:

**Note:** *This command just downloads the current love executable. In the future, you may need to get the latest release from the official Love2D GitHub. Though, updates to the main executable are few and far between, so just copy pasting this should be fine for a while.*

```
wget https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage

chmod +x love-11.5-x86_64.AppImage

./love-11.5-x86_64.AppImage --appimage-extract
```

4. This will create a folder called squashfs-root in that same directory. This contains the Love2D Linux binaries. Run the following command in terminal:

```
cat squashfs-root/bin/love <game file name>.love > squashfs-root/bin/<game file name>
```

5. This will merge the binaries into one executable; however, this alone won't make the game launchable. Love2D still needs some supporting files to run, so you'll need to modify the execution of the AppImage and repackage it. Open the following file in a text editor:

```
/squashfs-root/love.desktop
```

It will look something like this:

```
[Desktop Entry]
Name=LÖVE
Comment=The unquestionably awesome 2D game engine
MimeType=application/x-love-game;
Exec=love %f
Type=Application
Categories=Development;Game;
Terminal=false
Icon=love
NoDisplay=true
```

Modify the comment and name however you like, and change the line:

```
Exec=love %f
```

To:

```
Exec=<name of your game> %f
```

The command we ran earlier will have generated a file of the same name as the .love file within the directory /squashfs-root/bin/ the love.desktop file simply looks in that directory for the executable of the same name, so no more modification is needed. 

6. Additionally, you can change the icon of the AppImage by changing the line:

```
Icon=love
```

To the title of any PNG or SVG file in the same directory as love.desktop. Do not include the file extension in the name.

7. Finally, to generate the final AppImage, download [AppImageTool at this link](https://github.com/AppImage/appimagetool/releases/tag/continuous), place the  *appimagetool-x86_64.AppImage* file in the same directory as the */squashfs-root/* folder and run the following command in terminal:

```
appimagetool squashfs-root <name of game>.AppImage
```

It will generate the final AppImage in the current working directory. 
You can now distribute that file!