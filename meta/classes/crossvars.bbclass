# This software is a part of ISAR.
# Copyright (C) 2022 ilbers GmbH

ISAR_CROSS_COMPILE ??= "0"

inherit compat

python __anonymous() {
    import pwd
    d.setVar('SCHROOT_USER', pwd.getpwuid(os.geteuid()).pw_name)

    mode = d.getVar('ISAR_CROSS_COMPILE')

    # support derived schroots
    flavor = d.getVar('SBUILD_FLAVOR')
    flavor_suffix = ('-' + flavor) if flavor else ''

    distro_arch = d.getVar('DISTRO_ARCH')
    if mode == "0" or d.getVar('HOST_ARCH') == distro_arch or distro_arch == None:
        d.setVar('BUILD_HOST_ARCH', distro_arch)
        schroot_dir = d.getVar('SCHROOT_TARGET_DIR', False)
        sbuild_dep = "sbuild-chroot-target" + flavor_suffix + ":do_build"
        sdk_toolchain = "build-essential"
    else:
        d.setVar('BUILD_HOST_ARCH', d.getVar('HOST_ARCH'))
        schroot_dir = d.getVar('SCHROOT_HOST_DIR', False)
        sbuild_dep = "sbuild-chroot-host" + flavor_suffix + ":do_build"
        sdk_toolchain = "crossbuild-essential-" + distro_arch
    d.setVar('SCHROOT_DIR', schroot_dir + flavor_suffix)
    d.setVar('SCHROOT_DEP', sbuild_dep)
    if isar_can_build_compat(d):
        sdk_toolchain += " crossbuild-essential-" + d.getVar('COMPAT_DISTRO_ARCH')
    d.setVar('SDK_TOOLCHAIN', sdk_toolchain)
}
