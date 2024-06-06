Official CLI for the Refreshed framework.

```dart
// To install:
pub global activate refreshed_cli
// (to use this add the following to system PATH: [FlutterSDKInstallDir]\bin\cache\dart-sdk\bin

flutter pub global activate refreshed_cli

// To create a flutter project in the current directory:
get new project_name

// To generate the chosen structure on an existing project:
get init

// To create a page:
// (Pages have controller, view, and binding)
// Note: you can use any name, ex: `get create page:login`
// Nota: use this option if the chosen structure was GetX_pattern
get create page:home

// To create a screen
// (Screens have controller, view, and binding)
// Note: you can use any name, ex: `get screen page:login`
// Nota: use this option if the chosen structure was CLEAN (by Arktekko)
get create screen:home

// To create a new controller in a specific folder:
// Note: you don't need to reference the folder,
// Refreshed will search automatically for the home folder
// and add your controller there.
get create controller:dialogcontroller on home

// To create a new view in a specific folder:
// Note: you don't need to reference the folder,
// Refreshed will automatically search for the home folder
// and insert your view there.
get create view:dialogview on home

// To create a new provider in a specific folder:
get create provider:user on home

// To generate a localization file:
// Note: 'assets/locales' directory with your translation files in json format
get generate locales assets/locales

// To generate a class model:
// Note: 'assets/models/user.json' path of your template file in json format
// Note: on  == folder output file
// Refreshed will automatically search for the home folder
// and insert your class model there.
get generate model on home with assets/models/user.json

//to generate the model without the provider
get generate model on home with assets/models/user.json --skipProvider

//Note: the URL must return a json format
get generate model on home from "https://api.github.com/users/CpdnCristiano"

// To install a package in your project (dependencies):
get install quickly

// To install several packages from your project:
get install quickly path camera

// To install a package with specific version:
get install quickly:5.6.0

// You can also specify several packages with version numbers

// To install a dev package in your project (dependencies_dev):
get install flutter_launcher_icons --dev

// To remove a package from your project:
get remove http

// To remove several packages from your project:
get remove http path

// To update CLI:
get update
// or `get upgrade`

// Shows the current CLI version:
get -v
// or `get version`

// For help
get help
```
