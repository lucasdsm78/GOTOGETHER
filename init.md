#doc flutter
https://docs.flutter.dev/get-started/install/macos#update-your-path



#github / jira aka les elements scrums
https://lucas59988.atlassian.net/jira/software/projects/GT/boards/2/roadmap
https://github.com/lucasdsm78/GOTOGETHER


#initialisation

on met le PATH de flutter en var d'environnement, ce qui se fait dans le fichier `~/.zshrc`.
la ligne a ajouter est `export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/bin"`, entre crochet mettre le path de la lib flutter dézippé.
Une fois fait, on fait `source ~/.zshrc`
 
A l'emplacement du projet,  
si la commande `which flutter` renvoie le path correctement, c'est good.



##installation xcode
###utilisé xcode
```
sudo xcode-select --switch /Desktop/Xcode-beta.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license 
```
You can view the license agreements in Xcode's About Box, or at /Volumes/neo/Desktop/Xcode-beta.app/Contents/Resources/English.lproj/License.rtf

--------

###lancer le simulateur
`open -a Simulator`

-------

### créer le projet flutter
`flutter create go_together`
(a eu un soucis avec les autorisations du terminal, 
a du aller dans preference systeme , et dans confidentialité/accés complet au disque, et mettre les droits au terminal
)

(fin d'installation : 
```
In order to run your application, type:

  $ cd go_together
  $ flutter run

Your application code is in go_together/lib/main.dart.
```
)

---------

###deploy on iOS device
-1 `sudo gem install cocoapods`

(
pb pour installé cocoapod

{
"pkg-config --exists libffi"
| pkg-config --libs libffi
=> "-lffi\n"
"xcrun clang -o conftest -I/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0/universal-darwin20 -I/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0/ruby/backward -I/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0 -I. -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE -D_DARWIN_UNLIMITED_SELECT -D_REENTRANT    -g -Os -pipe -DHAVE_GCC_ATOMIC_BUILTINS -DUSE_FFI_CLOSURE_ALLOC conftest.c  -L. -L/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib -L. -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.5.Internal.sdk/usr/local/lib     -lruby.2.6   "
In file included from conftest.c:1:
In file included from /Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0/ruby.h:33:
/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0/ruby/ruby.h:24:10: fatal error: 'ruby/config.h' file not found
#include "ruby/config.h"

/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.0.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/include/ruby-2.6.0/ruby/ruby.h:24:10: note: did not find header 'config.h' in framework 'ruby' (loaded from '/Volumes/neo/Desktop/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks')
1 error generated.
checked program was:
begin
1: #include "ruby.h"
2:
3: int main(int argc, char argv)
4: {
5:   return 0;
6: }
 end

}

Solution 1? :
curl -L https://get.rvm.io | bash -s stable
{
        Adding rvm PATH line to /Volumes/neo/.profile /Volumes/neo/.mkshrc /Volumes/neo/.bashrc /Volumes/neo/.zshrc.
    Adding rvm loading line to /Volumes/neo/.profile /Volumes/neo/.bash_profile /Volumes/neo/.zlogin.
Installation of RVM in /Volumes/neo/.rvm/ is almost complete:

  * To start using RVM you need to run `source /Volumes/neo/.rvm/scripts/rvm`
    in all your open shell windows, in rare cases you need to reopen all shell windows.
}

```
source /Volumes/neo/.rvm/scripts/rvm
rvm install ruby-3.0.3
rvm --default use 3.0.3
```

error homebrew : fix homebrew permission
{
```
sudo chown -R $(whoami) /usr/local/var/homebrew  
ou
sudo chown -R "$USER":admin /usr/local
sudo chown -R "$USER":admin /Library/Caches/Homebrew
```
1er semble avoir fonctionné
}


)

-2 aller dans le projet crée , faire la commande `open ios/Runner.xcworkspace`
toutes la section concerne la torture des certificats
on va l'ignorer pour le moment, parce que c'est là dessus que je bloque a chaque fois, tellement compliqué avec mac



## setup android
###Install Android Studio

`flutter config --android-studio-dir <directory>`
au final : `flutter config --android-studio-dir=/Volumes/neo/Downloads/"Android Studio.app"/Contents`

reponse :
Setting "android-studio-dir" value to "/Volumes/neo/Downloads/AndroidStudio".
You may need to restart any open editors for them to read new settings.
on a raffraichi le cache , en ouvrant le projet android studio, puis file/invalidate.

###Set up your Android device
crée son AVD (plutot la derniere version en image x86)
pour l'emulated performance, prendre `Hardware - GLES 2.0`, qui devrait rendre l'emulateur plus performant


###Agree to Android Licenses
`flutter doctor --android-licenses`

nécessite d'avoir le `Android SDK Command-line Tools` activé pour android studio
pour l'activer : 
Open Android Studio
Tools Menu, SDK Manager
In the window that comes up there are inner panels, choose SDK Tools panel
Tick Android SDK Command-line Tools
Choose Apply button near the bottom of the window


aprés cela, on aura surement un message du genre `6 of 7 SDK package licenses not accepted.`
dans ce cas faire `y`, et on valide `y` jusqu'a accepté toutes les conditions d'utilisations.


`~/.zshrc` doit contenir
```
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:/Volumes/neo/Documents/cours/L3/flutter/bin"
```


en faisant `flutter doctor`, on ne devrait avoir aucune issue detected.


##macOS setup
###Enable desktop support
`flutter config --enable-macos-desktop`



