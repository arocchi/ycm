# Copyright (C) 2013  iCub Facility, Istituto Italiano di Tecnologia
# Authors: Daniele E. Domenichelli <daniele.domenichelli@iit.it>
# CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT

set(YCM_MODULES AddUninstallTarget.cmake
                ExtractVersion.cmake
                FindOrBuildPackage.cmake
                IncludeUrl.cmake
                InstallBasicPackageFiles.cmake
                StandardFindModule.cmake
                YCMDefaultDirs.cmake
                YCMEPHelper.cmake)

install(FILES ${YCM_MODULES}
        DESTINATION share/YCM/modules)
