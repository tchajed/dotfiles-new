# Alfred

Alfred preferences migrated from Dropbox. The install script points Alfred at this repo's `alfred/Alfred.alfredpreferences` via `com.runningwithcrayons.Alfred-Preferences syncfolder`.

## Workflow notes

- Bear: if macOS blocks the workflow scripts, open the Bear workflow directory and remove quarantine from the executables:

  ```sh
  xattr -rd com.apple.quarantine cmd
  ```
