![RCWorkspace](https://github.com/MalkarovPark/Robotic_Complex_Workspace/assets/62340924/0597a5a0-a6ae-40c5-9fcf-54a17d0dbb37)

# Industrial Builder

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Swift](https://img.shields.io/badge/swift-5.9-brightgreen.svg) ![Xcode 15.0+](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg) ![macOS 14.0+](https://img.shields.io/badge/macOS-14.0%2B-blue.svg) ![iOS 17.0+](https://img.shields.io/badge/iOS-17.0%2B-blue.svg) ![visionOS 1.0+](https://img.shields.io/badge/visionOS-1.0%2B-blue.svg)
<a href="https://github.com/MalkarovPark/IndustrialKit">
<img src="https://img.shields.io/badge/-IndustrialKit-05A89D"></a>

Industrial Builder is a multifunctional environment for production deployment. Everything necessary for production is collected in a special package – Standard Template Construct. Processing of such a package allows obtaining various data for designing and forming production depending on the customer's needs.

# Table of Contents
* [Requirements](#requirements)
* [Getting Started](#getting-started)
    * [Application Installation](#application-installation)
    * [Project Edititing](#project-editing)
* [Working With Document](#working-with-document)
    * [Info](#info)
    * [Components](#components)
* [STC Utilizing](#stc-utilizing)
   * [Building Modules](#building-modules)
* [Getting Help](#getting-help)
* [License](#license)

# Requirements <a name="requirements"></a>

The application codebase supports macOS, iOS, iPadOS, visionOS and requires Xcode 14.1 or newer. The Industrial Builder application has a Base SDK version of 13.0 and 16.1 respectively.

# Getting Started <a name="getting-started"></a>

* [Website](https://celadon-production-systems.carrd.co/)
* [Documentation](https://celadon-industrial.github.io/IndustrialKit/documentation/rcworkspace/)

### Application Installation <a name="application-installation"></a>

Download an image from the *releases* and use application package for the appropriate platform.

Connect the necessary property list files in the application settings for robots, tools and parts.

*macOS*

[Copy](https://support.apple.com/guide/mac-help/mh35835/mac) a package with the *app* extension to the Applications folder. [Confirm launch](https://support.apple.com/guide/mac-help/mh40616/mac).

*iOS & iPadOS*

Official free installation method coming after the world revolution. For now you can install application package by your own developer profile and special installers. Also possible to use the app in application playground format by the [Swift Playgrounds](https://apps.apple.com/us/app/swift-playgrounds/id908519492) (iPadOS only).

### Project Editing <a name="project-editing"></a>

You may view and edit this application project by two ways:
* Clone this repository;
* Download ZIP archive from this page.

Open downloaded project in the Xcode and confirm trust.

# Working With Document <a name="working-with-document"></a>

Industrial Builder is the document based app. Thus, each Standard Template Construct (STC) is a separate document. You can create a new or open an existing document that has a *stc* extension.

Production employing components are created in the relevant items available through the sidebar. All created objects can be placed and positioned in the workspace.

### Info <a name="info">

The description of the STC and its purposes is contained in the Info file, a special template file of the package. You can add an internal name for the STC, provide a more detailed description, and supplement all this with a gallery of related images.

### Components <a name="components">

The creation of production begins with the preparation of all the necessary information, presented in the form of components.

Resources can be added (Fig. #) by simply dragging them into the appropriate Resources sections or selected via the "↓" button on the toolbar. Empty listings can also be created using the "+" button and edited. Editing scenes and images, in turn, is not supported.

<p align="center">
  <img width="743" src="https://github.com/MalkarovPark/Robotic_Complex_Workspace/assets/62340924/7bb0bebc-15b7-40a9-8312-c9eeeac17522">
</p>

A separate, specific type of resource is a kinematic group. It is a named list of kinematic elements with a parameter indicating the kinematics type. The kinematic element itself is a named and identifiable Float value.

Unlike other resources, which are placed in one way or another in the model module package during layout, kinematics is used to synthesize resources. Kinematics processing is implemented using IndustrialBuilder, which currently supports the synthesis of robots with the 6DOF and Portal kinematics type.

When processing kinematics, based on the processing of its data, the code and scene of the manipulator are synthesized. <!-- The kinematic elements of the 6DOF robot define the lengths of the 6 links and the height of the base of the manipulator. In the Portal robot, the elements define, in addition to the lengths of the links, also the limitations on the displacements. -->

### Modules <a name="modules">

The digital essence of a production facility is implemented by the program code of its object and a virtual model reproducing the visual and physical properties of the associated production facility.

Thus, the module providing the program code of the digital and the components of the model must be assembled from the corresponding resources. The program code is described in text listing files, while the model is assembled from a set of scenes (SceneKit Scene file with the .scn extension) and textures (various raster graphics formats).

The current version of Industrial Builder allows you to create and edit modules of four types - for production facilities (Robot, Tool, Part) and Changer elements.

Editing of all module components is performed in Module Designer. The set of components available for editing varies depending on the module type. Model editing is available for robots, tools and parts.

<!--
Table # – Editable module components
Robot Tool Part Changer module
Description + + + +
Operations - + - -
Code Controller, Connector Controller, Connector - Change
Resources + + + -
Connection Parameters + + - -
Linked Internal Components + + - -
-->

All used listings can be generated and supplemented by the developer. Please note that depending on how the module will be connected (external or internal), generate for the corresponding type.

For tools, a list of available values ​​of operational codes is additionally specified.

For controlled devices – robots and tools – editing of the list of names of connected model nodes and parameters of connection to real equipment is available.

<!-- This data is stored in arrays of the header file. When assembling internal modules, data is injected into the connector/controller listings, as a result of which the module already has an initialized set of parameters. For external modules, the parameter list is extracted from the module package header file. -->

For objects whose digital entities involve visual modeling (robots, tools, parts), scenes and textures with the models used are specified among those available in the STC package.

One of the selected scenes is specified as the main one. This approach allows the module to have several scenes and textures - one scene can refer to other resources of the module package.

For controlled devices and those with a model controller (robots, tools), a list of names of connected scene nodes is additionally specified via the Connected Nodes menu.

# STC Utilizing <a name="stc-utilizing">

The STC package enables production deployments and can be used in a variety of ways for different purposes. Currently, it supports compilation of plug-ins for IndustrialKit-based applications.

### Building Modules <a name="building-modules">

The set of modules to be composed is specified in the assembly sheet implemented by the BuildModulesList class and consists of four lists corresponding to four types of modules – Robot, Tool, Part, Changer. STC can contain many such sheets.

In Industrial Builder, editing assembly sheets and assembling modules is performed using the Build assembly tool, accessible via the "" button in the Package section.

<p align="center">
  <img width="743" src="https://github.com/MalkarovPark/Robotic_Complex_Workspace/assets/62340924/7bb0bebc-15b7-40a9-8312-c9eeeac17522">
</p>

There are two types of assembly available – Files for exporting modules as a set of external plug-in packages and App for exporting as packages embedded in the application project and compiled together with it.

When assembling internal modules, a Modules folder is created with a set of module packages and a List listing file initiating a tuple of arrays of internal modules – internal_modules.

<!-- When creating a module package file, the build_module_file function creates a listing with the _Info postfix, containing the initialization code for the corresponding digitalia - an instance of a module class of a certain type.

Then a function is executed that creates a set of listings in accordance with the name and content of each element in the code_items of the module being processed. For robots and tools, a list of scene nodes is also injected into the ModelController code and connection parameters for WorkspaceObjectConnector. All listing files of one module are placed in the Code folder and receive a prefix of the form <module name>_, which is necessary to ensure correct compilation during further assembly as part of the application project. Then the updated code files are saved using the code_files_store function.

Then the resources are saved to the Resources.scnassets folder, similar to when creating an external module package.

The finished Modules folder can be simply placed in the RCWorkspace application project and compiled. -->

Assembling external modules involves saving module data in the Info header file.

Next, as with internal modules, code elements are saved in the corresponding Code folders of the module package file. However, no parameters are injected into the listing code, since the corresponding data (the previously mentioned list of model nodes, connection parameters) are saved in the header file.

The final stage of exporting a module is saving its resources in the Resources.scnassets folder of its package <!-- using the make_resources_folder function -->.

After all external modules have been compiled and placed in the export folder, Industrial Builder additionally places a set of scripts in the folder for compiling listings of software components of module components into Unix executable files. In the iOS, iPadOS and visionOS versions, the export of external modules is completed at this stage, since they do not have a terminal. In turn, on macOS, it is possible to launch the compilation directly from Industrial Builder.

<!-- The compilation kit includes the following scripts:
LtPConvert – converts the specified Swift listing file into a terminal application project package. The Unix executable file compiled by such a project gets the same name as the original listing. The package name consists of the listing name and the _Project postfix. The latest version of the IndustrialKit library is also connected to the project.
PBuild – compiles the project package into an executable file, which is located in the same directory as the project.
LCompile – Converts the listing into an executable Unix file. In fact, this script sequentially executes the LtPConvert and PBuild scripts. When called with the -c parameter, after execution it also deletes the original listing and the project package file of the executable file based on it.
MPCompile – compiles software components of all modules (have extensions .robot, .tool, .part, .changer), located in the same folder as the running script itself. To do this, it finds all swift files and executes the LCompile script for them with the -c parameter.

The compilation kit allows you to develop program files of external modules and compile them independently of IndustrialBuilder. For example, a developer can modify the executable file project by adding separate listing files and connecting additional libraries. Also, deferred compilation is necessary when exporting external modules on platforms that do not support the terminal. -->

# Getting Help <a name="getting-help"></a>
GitHub is our primary forum for RCWorkspace. Feel free to open up issues about questions, problems, or ideas.

# License <a name="license"></a>
This project is made available under the terms of a Apache 2.0 license. See the [LICENSE](LICENSE) file.
