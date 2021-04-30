Here's the changelog of my (Banshee) changes:


12/06/2020: 0.584
- Supports Loading and Saving .PGM files used in 8-Bit Armies/Hordes/Invaders and also pack custom maps from CnC Remastered Collection. It's basically the .MEG files with another extension.
- Fixes an offset bug when saving .MEG files.

06/06/2020: 0.583
-> Update with the following features/bug fixes:

- Extract All window's size has been corrected.
- Creating a new directory when extracting files now updates the directory listing component at Extract All window.
- TGA reader from OS BIG Editor can now read 32 bits TGA files from C&C: Remastered Collection and other games properly. 

24/05/2020: 0.582
-> Updated some code that would be incompatible with 64 bits (because there is a functional 64 bits version of the program elsewhere)

23/12/2016: 0.581
-> Loads encrypted Config.MEG from 8-Bit Armies/Hordes/Invaders and Grey Goo, thanks to Mike.NL's documentation at: http://modtools.petrolution.net/docs/MegFileFormat. It is important to mention that the user must select the correct game to allow it to work correctly.

29/12/2008: 0.58
-> Added Save and moved the old 'Save' to 'Save As'. The image of the save as button is temporary.
-> Save As is now smarter and detects the file type of the current file or set BIGF for the new ones.

Here's the list of remaining things:
-> Fix .MEG file saving.
-> TSHyper graphics still need to be added.
-> About Box must credit the original author and patch author on future versions.
-> Options need to be expanded.
-> Finish the Language file
-> Compile SVN directories? Maybe it will be a 0.6 future or it will go into future versions...

26/12/2008: 0.58
-> CRCs from MEG files are now ordered correctly.

25/12/2008: 0.58
-> Heavy speed optimization for file saving. Real Time Edition should be fully functional now.
-> Some fixes to save .MEG files that still need to be tested.
-> Fix on reloading the treefiles.
-> Brazilian and french languages added. I've made the brazilian and the french was made by warofgenerals.com webmaster.

21/12/2008: 0.58
-> Removed lag when clicking the already opened file.
-> Preview binary no longer wrap lines and it shows the horizontal lines.
-> Added protection against lack of memory when vieweing huge files.

16/02/2008: 0.58
-> View Binary Files As Text.

15/02/2008: 0.58
-> Users may copy files internally.
-> You may now Open files.
-> You may open files with wordpad (or another program set at options.ini). If nothing is set there, you won't see this feature.

08/02/2008: 0.58:
-> Users may move files internally.

25/01/2008: 0.58:
-> Binary files are now dumped. Note that files bigger than 5mb are on the lag limit and the user will be asked if they really want to load it.
-> User can preview bitmaps, PNGs and JPGs.
-> You can now drag and drop files from windows explorer to your selected directory.

20/01/2008: 0.58:
-> Expanded popup menu.
-> Rename options at both popup menu and Edit menu.
-> Add New Directory.

19/01/2008: 0.58:
-> Bug Fix: removed a major memory leak when saving with refpack.
-> Files are now edited properly.
-> Delete now works again to delete files.

18/01/2008: 0.58:
-> Load and save .meg files from Petroglyph games.
-> Bug fix from 0.56, preventing files from being deleted when being renamed.

08/09/2007: 0.58:
-> You may now rename files and directories.
-> Big fix from speed up file loading from 0.57, where the first letters of root files didnt't show up.

08/09/2007: 0.57:
-> Files load faster.

17/08/2007: 0.57:
-> Real Time Edition
-> Errors when saving will no longer lock the program.
-> Directories are added correctly and files load faster because of that.

12/08/2007: 0.56:
-> Delete Selected Files (and Directories).

11/08/2007: 0.56:
-> Drag and drop files from windows explorer
-> If the program doesn't load any .BIG files during the load, it starts with a new file.
-> Prevents program from saving null .BIG files.
-> Add Directory option in the Edit menu.

10/08/2007: 0.55:
-> Extract directories is working.
-> New File

08/08/2007: 0.55:
-> Saving code and refpack were totally fixed.

06/08/2007: 0.55 changelog
-> The saving code was done and I'm now testing it and fixing bugs.

29/07/2007: 0.5.5 progress.
-> I'm editing the refpack file with KUDr's code (http://mazanec1.netbox.cz/svn/big/releases/0.21/include/refpack/refpack_compress.h). It's almost done at this moment.


25/07/2007: 0.5.5 WIP version changes compared to 0.5.4 (March 2007)
-> Fixed problems with mouse cursor that were lagging the program and even preventing it from displaying files.
-> Refpack compression is still being coded.
-> Save file system is still being coded.
-> TSHyper graphics still need to be added.
-> About Box must credit the original author and patch author on future versions.


0.5.4 version changes compared to 0.5.3
-> This version has absorbed Danny van Loon's tree view support.
-> BIG_File.pas has received inumerous functions to support: File Binary Search by name, addition of files from .big files or hard disk, support for detection of repetitive files (good for .BIG files generated by FinalBIG), fake deletion and clearing of 'useless' files marked as repetitive or deleted by the program.
-> Increased language support.
-> Compared to Danny's source: Treeview loads much, much faster! Drag and Drop extraction support fixed. The BIG_File.Pas changes mentioned above also applies to Danny's versions.
-> Minor changes on certain forms that I can't remember. Mainly language support.


Made from 0.5.1 version from Igi
-> Identation is 3 spaces. This is sacred!
-> Most of 0.5.2 changes were absorbed by this version, except the ones on FrmBIGMain related to treeview. Sorry, but I'm not using it yet.
-> New multi-language support, except that you can't select a new language inside the program yet.
-> All languages will be on /languages/
-> A big fix from Prabab's bug fix.
-> Contributor and MajorContributor constants are obsolette. It's all set in the about now.
-> The polish support forum link from Prabab was kept and is supported by the new language.
-> Igi and Prabab contributed to the program, but this doesn't make them author. Danny Van Loon and Igi contributed a lot and are considered major contributors...
-> TreeView support should be added on next version, once I get the new FrmBIGMain from Danny.


If there was more, I don't remember.