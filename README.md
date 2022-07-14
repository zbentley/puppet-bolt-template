# Puppet Bolt Workstation Skeleton

This repo represents a minimal [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html) project skeleton, which should allow Bolt to run Puppet code against selected workstations.

**This repo doesn't do much out of the box**.

# Assumptions

Unlike more opinionated "Puppetize your workstation" tools out there (e.g. the now retired [boxen]()), this module doesn't provide much in the way of a framework; it tries to be as classic/pure Puppet as possible, so that as many externally-provided Puppet snippets and modules as possible will work without modification.

Its only "opinions" are:
1. The Puppet code in `modules/globals` will run first on all targeted hosts. The `globals` module will never create any resources, but it will set global variables and change global resource defaults.
2. When the runner is invoked with a `--target` argument, the Puppet code in `modules/entry_points/manifests/$target` will be run.

You can totally opt out of either of those behaviors if you want; if you'd like to replace the entirety of `modules` with your own regular Puppet code, you may; just be sure to also update the "apply" block in `plans/init.pp` (which should not otherwise need modification).

# Included Capabilities

A skeleton provides:

- A basic Bolt inventory file containing tools for targeting `localhost` and a remote host via `ssh`.
- A basic Bolt plan which runs Puppet code contained in `modules/globals` (to provide some common global variables) and `modules/entry_points`, depending on arguments supplied.
- Packages for managing MacOS via Homebrew (this repo will work well against Linux as well).

# Example Functionality

In addition to the above opinions and capabilities, this module does do a few things (for example purposes) by default:
