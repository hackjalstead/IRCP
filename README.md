# Incident Response Collection Protocol (IRCP)

A series of PowerShell scripts to automate artefact collection & assist Responders triaging endpoints in lab-based & onsite environments.

## IRCP Features

IRCP supports E01, VMDK, VHD, VHDX images & Live hosts.

IRCP includes lab single image, lab multi-image, Live host & Bootable versions.

Each script contains built-in automation to mount/dismount of images, detect OS partition, detect OS type, create Evidence folders & execute KAPE with parsers id'd by OS detection. A full breakdown of each scripts features can be found below.

IRCP has customizable KAPE parser variables which Responders can change to suit varied investigative needs.  

All logging is copied to the root of each hosts evidence folder. The logs include IRCP console log, KAPE Modules/Targets log & Target System Information containing IP, domain, OS, users, timezone etc. taken with RECmd.

## IRCP Interface 

![ircp](https://user-images.githubusercontent.com/77779774/150213330-c068ce63-2d1b-4522-8c64-8e493bba66ec.gif)

## How to Use
Place IRCP scripts in the root of a directory containing KAPE & Arsenal and name the folders like the screenshots below. 

Arsenal DL Link - https://arsenalrecon.com/downloads/

Ensure there is enough storage in the location you are running it from as all artefacts will be placed in `.\Evidence` for the Single, Multi & Live versions.

The Bootable version will prompt user for destination harvest drive.

![image](https://user-images.githubusercontent.com/77779774/150188642-36a8e4b3-87ac-49b2-b45d-de3dd5a07e23.png)

## KAPE Parser Variables

Change the KAPE parser variables at the top of each script to what you require to be collected.

![image](https://user-images.githubusercontent.com/77779774/150187617-97a5ff9e-75fe-402c-a471-50d50bfaf330.png)

## IRCP-Lab-Multi

For artefact collection of multiple images across a network share or onsite harvest drive. This will locate, mount, detect OS partition, collect & dismount each image one-by-one. With minimal user interaction it is intended to 'Fire & Forget' while acquisition takes place. The cycle below will run until all images have been processed -

- Select drive containing images
- Script detects location of all images & image pointers if VMDK
- Creates Evidence folders with each image filename
- Mounts each image with Arsenal
- Locates OS partition
- KAPE executes with preset parsers
- Image dismounts when complete
- All logging copied to host folder root

## IRCP-Lab-Single

For artefact collection of single image. 

 -  Select image location
 -  Image mounts with Arsenal
 -  Locates OS partition
 -  Select type of endpoint (Workstation/Server)
 -  Creates Evidence folders with image filename
 -  KAPE executes with preset parsers
 -  Image dismounts when complete
 -  All logging copied to host folder root

## IRCP-Live

For artefact collection of a Live host. 

-  Select image location
-  Image mounts with Arsenal
-  Creates Evidence folders from hostname
-  Detects OS type - Workstation or Server
-  KAPE executes with endpoint id'd specific parsers
-  All logging copied to host folder root

## IRCP-Bootable

For artefact collection of hosts booted into WinPE/WinFE. 

- Select OS drive
- Select harvest drive
- Collects hostname from registry
- Creates Evidence folders from hostname
- Detects OS type - Workstation or Server
- KAPE executes with endpoint id'd specific parsers
- All logging copied to host folder root
