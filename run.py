#!/usr/bin/env python3
from contextlib import contextmanager
import fcntl
import argparse
import os
import tempfile
import subprocess
import shutil
import sys
from functools import lru_cache


SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))


def run(cmd):
    if isinstance(cmd, str):
        cmd = cmd.split()
    print("run.py running:: ", " ".join(cmd))
    subprocess.run(cmd, check=True)


try:
    import yaml
except ImportError:
    try:
        import pip_installed.yaml as yaml
    except ImportError:
        print("Attempting to install pyyaml; ignore pip warnings (but not errors) below")
        os.makedirs(os.path.join(SCRIPT_DIR, 'pip_installed'), exist_ok=True)
        run([sys.executable, '-mpip', 'install', 'pyyaml', '-t', os.path.join(SCRIPT_DIR, 'pip_installed')])
        import pip_installed.yaml as yaml


@lru_cache()
def inventory_data():
    with open(os.path.join(SCRIPT_DIR, 'inventory.yaml'), 'r') as fh:
        return yaml.safe_load(fh)


@lru_cache()
def project_name():
    with open(os.path.join(SCRIPT_DIR, 'bolt-project.yaml'), 'r') as fh:
        return yaml.safe_load(fh)['name']


def validate_user(target):
    data = inventory_data()
    for group in data['groups']:
        if target == group['name']:
            if 'user' in target:
                return target['user']
            elif 'config' in group:
                for k, v in group['config'].items():
                    if k == 'user':
                        return v
                    elif isinstance(v, dict) and 'user' in v:
                        return v['user']
            elif len(group['targets']) == 1 and 'user' in group['targets'][0]:
                return group['targets'][0]['user']
            else:
                assert os.geteuid() == 0, "command must be run with sudo for target {}".format(target)
                return os.environ["SUDO_USER"]
    raise ValueError('No configured group in inventory.yaml matched target {}'.format(target))


@contextmanager
def locked():
    lock_path = os.path.join(tempfile.gettempdir(), '.{}.lock'.format(project_name()))
    with open(lock_path, 'w') as lockfh:
        fcntl.flock(lockfh, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield


def main(args):
    assert args.target, "--target is required"
    user = validate_user(args.target)
    with locked():
        os.chdir(os.path.dirname(__file__))
        bolt = shutil.which('bolt') or '/opt/puppetlabs/bin/bolt'
        brew = shutil.which('brew') or '/opt/homebrew/bin/brew'
        if not os.path.exists(bolt):
            run(f'{brew} tap puppetlabs/puppet')
            run(f'{brew} install --cask puppet-bolt')
            bolt = shutil.which('bolt') or '/opt/puppetlabs/bin/bolt'
            assert os.path.exists(bolt), "bolt not found"
        if not shutil.which('wget'):
            run(f'{brew} install wget')
        if not args.fast:
            run(f'{bolt} --clear-cache module install --force')
        run((
            bolt,
            '--stream',
            'plan',
            'run',
            project_name(),
            f'user={user}',
            f'noop={str(not args.execute).lower()}',
            f'target={args.target}',
        ))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--execute', action='store_true')
    parser.add_argument('--fast', action='store_true')
    parser.add_argument('--target', action='store', choices=tuple(g['name'] for g in inventory_data()['groups']))
    main(parser.parse_args())
