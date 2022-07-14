# Puppet Bolt Workstation Skeleton

This repo represents a minimal [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) project skeleton, which should allow Bolt to run Puppet code against selected workstations.

## How to use

**This repo doesn't do much out of the box; it is intended for users to fork, customize, and edit for their personal use.

This is a project skeleton, like the (much better) ones on [cookiecutter](https://github.com/cookiecutter/cookiecutter). It does a little bit out of the box (i.e. it can make a few simple changes on MacOS `localhost` targets), that's purely for demonstration purposes.

Tl;dr:
1. Fork it (in GitHub or via `cp -r`; the former is slightly preferred since you can easily get changes to the base layer, but it's totally reasonable to want your workstation config to be in a private repo, in which case you can `cp -r` to perform the fork).
2. Test it out (see "usage" below).
3. Make changes to the Puppet code in the `modules/` directory to do whatever you desire. The world is your oyster. 

## Assumptions

Unlike more opinionated "Puppetize your workstation" tools out there (e.g. the now retired [boxen](https://github.com/boxen/puppet-boxen)), this module doesn't provide much in the way of a framework; it tries to be as classic/pure Puppet as possible, so that as many externally-provided Puppet snippets and modules as possible will work without modification.

Its only "opinions" are:
1. The Puppet code in `modules/globals` will run first on all targeted hosts. The `globals` module will never create any resources, but it will set global variables and change global resource defaults.
2. When the runner is invoked with a `--target` argument, the Puppet code in `modules/entry_points/manifests/$target` will be run.

You can totally opt out of either of those behaviors if you want; if you'd like to replace the entirety of `modules` with your own regular Puppet code, you may; just be sure to also update the "apply" block in `plans/init.pp` (which should not otherwise need modification).

## Included Capabilities

This skeleton provides:

- A basic Bolt inventory file containing tools for targeting `localhost` and a remote host via `ssh`.
- A basic Bolt plan which runs Puppet code contained in `modules/globals` (to provide some common global variables) which then invokes Puppet code corresponding to the `--target` argument in `modules/entry_points`.
- Packages for managing MacOS via Homebrew (this repo will work well against Linux as well).
- A basic static-file Hiera backend in `data/` that is usable from Pup[et code.]
- A Python runner script to invoke Bolt correctly.
- Custom [facts](https://puppet.com/docs/puppet/7/lang_facts_and_builtin_vars.html) containing the long-form Kernel version and (if MacOS and the XCode SDK is installed) the MacOS SDK root directory.

## Example Functionality

In addition to the above opinions and capabilities, this module does do a few things (for example purposes) by default:

- It ensures that the appropriate OpenSSL1.1 package is installed on target hosts.
- It installs the `htop` package on target hosts.
- It ensures that agent-managed Puppet is *disabled* on target hosts.
- It ensures that the SSH daemon is enabled on target hosts.
- On hosts using the `osx_base` module (intended for MacOS), it ensures that ZSH's shell directories are properly set up.
- On hosts using the `osx_base` module, 'ssh-agent' is configured to run in the background.
- On hosts using the `osx_base` module, a shortcut to the `Applications` directory is placed on the invoking user's desktop.
- On the (presumed MacOS) example localhost target `host1`, [Dropbox](dropbox.com) is installed, linked to the desktop, and configured to start at boot.

## Requirements

### For invocation

- Invocation must be performed on a MacOS host running MacOS 11 or better.
- The [Homebrew](https://brew.sh/) package manager must be installed and working on the host.
- Python 3.5 or better must be available on `PATH` with the command `python3`.

## Usage

### Running Bolt

Bolt should be used via the included `run.py` script. That script is preconfigured to allow Bolt to run against `localhost` via the `host1` target.

It can be invoked like this, to run in *dry-run only* mode:
```bash
sudo ./run.py --target host1
```

Bolt requires `sudo` invocation to run against `localhost` targets. It requires non-`sudo` invocation to run against remote targets (you'll get an informative error message if you try to use it wrong).

Dry-run/noop mode can be turned *off* by passing `--execute`.

### Inventory

Bolt requires targets to run. Targets are specified in `inventory.yaml`; two example targets are included: `host1`, which points to `localhost`/the current machine, and `host2` which can be configured (by editing `inventory.yaml`) to point at a network-accessible machine via SSH.

Bolt should be ready to use for `host1` out-of-the-box.

### Adding or Customizing Entry Points

Entry points must be named after `groups` that are specified in `inventory.yaml`. If you add a group with `name: foobar`, you must add a corresponding file `modules/entry_points/manifests/foobar.pp` containing a Puppet `class entry_points::foobar {` which contains your desired Puppet code.

The existing `host1` entry can (and probably should, since "host1" isn't a useful name) be renamed to refer to something more meaningful to you.

All Puppet code in this repo will have access to the global variables and resource defaults set in `globals/manifests/init.pp`, unless you decide to get rid of that convention and write pure, assumption-less Puppet code.

Hiera variables set in YAML files in `data` can be accessed in Puppet via the `lookup()` Puppet function.

The name of the project itself can be changed from `template` by updating `bolt-project.yaml`'s "name" field and the first line of `plans/init.pp` to a new name instead of "template".

## Contributing

Submit an issue or PR on GitHub! Use as much detail as you can!
